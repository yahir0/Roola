import Cocoa
import Darwin
import FlutterMacOS
import IOKit
import IOKit.storage

/// システムメトリクス（CPU / メモリ / ディスク I/O / ネットワーク I/O /
/// プロセス一覧）を macOS の標準 API から取得する（ADR-0039 / ADR-0048）。
///
/// - CPU: `host_statistics`(HOST_CPU_LOAD_INFO) の累積 tick 差分から使用率を
///   算出する。差分方式のため前回 tick を保持する。初回呼び出しは前回値が
///   無く 0% を返し、2 回目以降が「前回呼び出しからの使用率」になる。
/// - メモリ: `host_statistics64`(HOST_VM_INFO64) と `sysctl hw.memsize` から
///   使用量 / 総容量を算出する。
/// - ディスク I/O: IOKit の `IOBlockStorageDriver` 統計から累積バイトを合計
///   する（read / write 別）。レート計算は Dart 側 ViewModel が前回値との
///   差分から行う（ADR-0048 D4）。
/// - ネットワーク I/O: `getifaddrs` の `if_data` から累積バイトを合計する
///   （loopback 除外）。レート計算は Dart 側で行う。
/// - 上位プロセス: CPU / メモリは `ps` を 1 回実行して標準出力をパース、
///   ディスクは `proc_pid_rusage` を 1 秒間隔で 2 サンプリング、ネットワークは
///   `nettop -P -L 2 -s 1 -x` を 1 回実行して 2 サンプルの差分から取得する
///   （ADR-0048 D2 / D3）。クリック時のみ呼ばれるためコストは許容範囲。
final class SystemMetricsProvider {
  private var previousCPUTicks: host_cpu_load_info?

  /// システム全体の CPU 使用率（0–100）。
  func cpuUsage() -> Double {
    var count = mach_msg_type_number_t(
      MemoryLayout<host_cpu_load_info_data_t>.size
        / MemoryLayout<integer_t>.size
    )
    var load = host_cpu_load_info()
    let status = withUnsafeMutablePointer(to: &load) { pointer -> kern_return_t in
      pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
        host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
      }
    }
    guard status == KERN_SUCCESS else { return 0 }

    defer { previousCPUTicks = load }
    guard let previous = previousCPUTicks else { return 0 }

    let user = Double(load.cpu_ticks.0 &- previous.cpu_ticks.0)
    let system = Double(load.cpu_ticks.1 &- previous.cpu_ticks.1)
    let idle = Double(load.cpu_ticks.2 &- previous.cpu_ticks.2)
    let nice = Double(load.cpu_ticks.3 &- previous.cpu_ticks.3)
    let used = user + system + nice
    let total = used + idle
    guard total > 0 else { return 0 }
    return min(100, max(0, used / total * 100))
  }

  /// メモリ使用量と総容量（bytes）。使用量は active + wired + compressed。
  func memoryInfo() -> (used: UInt64, total: UInt64) {
    var total: UInt64 = 0
    var totalSize = MemoryLayout<UInt64>.size
    sysctlbyname("hw.memsize", &total, &totalSize, nil, 0)

    var count = mach_msg_type_number_t(
      MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size
    )
    var stats = vm_statistics64()
    let status = withUnsafeMutablePointer(to: &stats) { pointer -> kern_return_t in
      pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
        host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
      }
    }
    guard status == KERN_SUCCESS else { return (0, total) }

    let pageSize = UInt64(vm_kernel_page_size)
    let used =
      (UInt64(stats.active_count)
        + UInt64(stats.wire_count)
        + UInt64(stats.compressor_page_count)) * pageSize
    return (used, total)
  }

  /// ディスク I/O の累積バイト数（read / write）。物理ディスクごとに
  /// `IOBlockStorageDriver` を辿って `Statistics` 辞書の Bytes 列を合計する。
  /// 累積値なのでレート計算は呼び出し側（Dart の ViewModel）が前回値との
  /// 差分から行う（ADR-0048 D1 / D4）。
  func diskIOCounters() -> (bytesRead: UInt64, bytesWritten: UInt64) {
    var totalRead: UInt64 = 0
    var totalWritten: UInt64 = 0

    let matchingDict = IOServiceMatching("IOBlockStorageDriver")
    var iterator: io_iterator_t = 0
    let port: mach_port_t
    if #available(macOS 12.0, *) {
      port = kIOMainPortDefault
    } else {
      port = kIOMasterPortDefault
    }
    guard
      IOServiceGetMatchingServices(port, matchingDict, &iterator)
        == KERN_SUCCESS
    else {
      return (0, 0)
    }
    defer { IOObjectRelease(iterator) }

    while case let drive = IOIteratorNext(iterator), drive != 0 {
      defer { IOObjectRelease(drive) }
      var props: Unmanaged<CFMutableDictionary>?
      guard
        IORegistryEntryCreateCFProperties(
          drive, &props, kCFAllocatorDefault, 0
        ) == KERN_SUCCESS,
        let dict = props?.takeRetainedValue() as? [String: Any],
        let stats = dict[kIOBlockStorageDriverStatisticsKey] as? [String: Any]
      else {
        continue
      }
      if let r = stats[kIOBlockStorageDriverStatisticsBytesReadKey] as? NSNumber
      {
        totalRead &+= r.uint64Value
      }
      if let w = stats[kIOBlockStorageDriverStatisticsBytesWrittenKey]
        as? NSNumber
      {
        totalWritten &+= w.uint64Value
      }
    }
    return (totalRead, totalWritten)
  }

  /// ネットワーク I/O の累積バイト数（in / out）。`getifaddrs` で全
  /// インターフェイスを列挙し、`AF_LINK` の `if_data` から `ifi_ibytes` /
  /// `ifi_obytes` を合計する。`lo` 始まりのループバックは除外する（自分宛て
  /// 通信を二重計上しないため。ADR-0048 D1）。
  func networkIOCounters() -> (bytesIn: UInt64, bytesOut: UInt64) {
    var totalIn: UInt64 = 0
    var totalOut: UInt64 = 0
    var ifaddrPtr: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddrPtr) == 0 else { return (0, 0) }
    defer { freeifaddrs(ifaddrPtr) }
    var current = ifaddrPtr
    while let ptr = current {
      defer { current = ptr.pointee.ifa_next }
      let name = String(cString: ptr.pointee.ifa_name)
      if name.hasPrefix("lo") { continue }
      guard let addr = ptr.pointee.ifa_addr,
        addr.pointee.sa_family == UInt8(AF_LINK),
        let data = ptr.pointee.ifa_data
      else { continue }
      let netData = data.assumingMemoryBound(to: if_data.self).pointee
      totalIn &+= UInt64(netData.ifi_ibytes)
      totalOut &+= UInt64(netData.ifi_obytes)
    }
    return (totalIn, totalOut)
  }

  /// 上位プロセスの生リスト（並び替え前）。`ps` を 1 回実行して取得する。
  func processes() -> [[String: Any]] {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/bin/ps")
    task.arguments = ["-Ao", "pid=,pcpu=,rss=,comm="]
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = Pipe()
    do {
      try task.run()
    } catch {
      return []
    }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    task.waitUntilExit()
    guard let output = String(data: data, encoding: .utf8) else { return [] }

    var result: [[String: Any]] = []
    for rawLine in output.split(separator: "\n") {
      let line = rawLine.trimmingCharacters(in: .whitespaces)
      // 先頭 3 列は pid / %cpu / rss(KB)、4 列目以降は実行ファイルパス
      // （空白を含みうるため joined で復元し basename を採る）。
      let parts = line.split(separator: " ", omittingEmptySubsequences: true)
      guard parts.count >= 4,
        let pid = Int(parts[0]),
        let cpu = Double(parts[1]),
        let rssKB = Int(parts[2])
      else { continue }
      let path = parts[3...].joined(separator: " ")
      let name = path.split(separator: "/").last.map(String.init) ?? path
      result.append([
        "pid": pid,
        "name": name,
        "cpu": cpu,
        "memoryBytes": rssKB * 1024,
      ])
    }
    return result
  }

  /// ディスク I/O 上位プロセス（並び替え前）。`proc_listallpids` で全 PID を
  /// 列挙し、各 PID に `proc_pid_rusage(RUSAGE_INFO_V2)` を呼んで
  /// `ri_diskio_bytesread + ri_diskio_byteswritten` を取得、1 秒スリープして
  /// 再取得し、差分から per-second rate を算出する（ADR-0048 D2）。
  /// I/O が 0 のプロセスは含めない（呼び出し側で並び替え・件数制限する前提）。
  func diskTopProcesses() -> [[String: Any]] {
    let pids = listAllPids()
    var first: [Int32: UInt64] = [:]
    first.reserveCapacity(pids.count)
    for pid in pids {
      if let total = pidDiskIOTotal(pid: pid) {
        first[pid] = total
      }
    }
    Thread.sleep(forTimeInterval: 1.0)
    var result: [[String: Any]] = []
    for pid in pids {
      guard let prev = first[pid], let cur = pidDiskIOTotal(pid: pid) else {
        continue
      }
      // OS の wrap-around / プロセス再起動で減ったときは 0 として扱う。
      let delta = cur >= prev ? cur - prev : 0
      if delta == 0 { continue }
      result.append([
        "pid": Int(pid),
        "name": pidProcessName(pid: pid),
        // サンプリング間隔は 1.0 秒なので delta = per-second rate。
        "ioBytesPerSec": Int(delta),
      ])
    }
    return result
  }

  /// ネットワーク I/O 上位プロセス（並び替え前）。`nettop -P -L 2 -s 1 -x -J`
  /// を 1 回サブプロセス実行し、2 サンプル目と 1 サンプル目の差分から
  /// per-second rate を算出する（ADR-0048 D3）。
  /// I/O が 0 のプロセスは含めない。
  func networkTopProcesses() -> [[String: Any]] {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/nettop")
    // -P: per-process 集計 / -L 2 -s 1: 1 秒間隔 2 サンプル / -x: 生バイト /
    // -J: 列を限定して出力パースを安定化させる。
    task.arguments = [
      "-P", "-L", "2", "-s", "1", "-x", "-J", "bytes_in,bytes_out",
    ]
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = Pipe()
    do {
      try task.run()
    } catch {
      return []
    }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    task.waitUntilExit()
    guard let output = String(data: data, encoding: .utf8) else { return [] }

    // nettop 出力は CSV 風で、各サンプルが `,bytes_in,bytes_out,` の列ヘッダ
    // 行から始まり、後続行がプロセス行（"<name>.<pid>,<bytes_in>,<bytes_out>,"）。
    // ヘッダ行を見つけたら現在の sample を閉じて次の sample に切り替える。
    var samples: [[String: (UInt64, UInt64, String)]] = []
    var current: [String: (UInt64, UInt64, String)] = [:]
    for rawLine in output.split(separator: "\n", omittingEmptySubsequences: false) {
      let line = String(rawLine)
      // 先頭が空フィールド（"," 始まり）の行は列ヘッダ。サンプル境界として
      // 使い、現在の sample を閉じる。
      if line.hasPrefix(",") {
        if !current.isEmpty {
          samples.append(current)
          current = [:]
        }
        continue
      }
      let parts = line.split(separator: ",", omittingEmptySubsequences: false)
      guard parts.count >= 3 else { continue }
      let nameAndPid = String(parts[0])
      // "<name>.<pid>" を後ろから分解する。<name> 自体に "." を含みうるので
      // 最後の "." 以降を pid と解釈する。
      guard let dotIndex = nameAndPid.lastIndex(of: "."),
        Int(nameAndPid[nameAndPid.index(after: dotIndex)...]) != nil,
        let bytesIn = UInt64(parts[1].trimmingCharacters(in: .whitespaces)),
        let bytesOut = UInt64(parts[2].trimmingCharacters(in: .whitespaces))
      else { continue }
      let name = String(nameAndPid[..<dotIndex])
      // key は "<name>.<pid>" のままにして、同一 (name, pid) ペアで突合する。
      current[nameAndPid] = (bytesIn, bytesOut, name)
    }
    if !current.isEmpty {
      samples.append(current)
    }
    guard samples.count >= 2 else { return [] }
    let prevSample = samples[samples.count - 2]
    let curSample = samples[samples.count - 1]

    var result: [[String: Any]] = []
    for (key, cur) in curSample {
      let prev = prevSample[key] ?? (cur.0, cur.1, cur.2)
      let inDelta = cur.0 >= prev.0 ? cur.0 - prev.0 : 0
      let outDelta = cur.1 >= prev.1 ? cur.1 - prev.1 : 0
      let total = inDelta + outDelta
      if total == 0 { continue }
      // "<name>.<pid>" を再分解して pid を抜く。
      guard let dotIndex = key.lastIndex(of: "."),
        let pid = Int(key[key.index(after: dotIndex)...])
      else { continue }
      result.append([
        "pid": pid,
        "name": cur.2,
        "ioBytesPerSec": Int(total),
      ])
    }
    return result
  }

  /// 現在の全 PID を列挙する。`proc_listallpids` をバッファ確保付きで叩く。
  private func listAllPids() -> [Int32] {
    let neededBytes = proc_listallpids(nil, 0)
    guard neededBytes > 0 else { return [] }
    let count = Int(neededBytes) / MemoryLayout<pid_t>.size
    var pids = [pid_t](repeating: 0, count: count)
    let returnedBytes = pids.withUnsafeMutableBufferPointer { buffer in
      proc_listallpids(buffer.baseAddress, Int32(neededBytes))
    }
    guard returnedBytes > 0 else { return [] }
    let returnedCount = Int(returnedBytes) / MemoryLayout<pid_t>.size
    return pids.prefix(returnedCount).filter { $0 > 0 }
  }

  /// 指定 PID のディスク I/O 累積バイト（read + write の合計）。
  /// `proc_pid_rusage(RUSAGE_INFO_V2)` を呼ぶ。プロセスが既に居ない / 権限が
  /// 無い等の理由で失敗したら nil を返す。
  private func pidDiskIOTotal(pid: Int32) -> UInt64? {
    var info = rusage_info_v2()
    let status: Int32 = withUnsafeMutablePointer(to: &info) { rusagePtr in
      var bufPtr: rusage_info_t? = UnsafeMutableRawPointer(rusagePtr)
      return proc_pid_rusage(pid, RUSAGE_INFO_V2, &bufPtr)
    }
    guard status == 0 else { return nil }
    return info.ri_diskio_bytesread &+ info.ri_diskio_byteswritten
  }

  /// 指定 PID の実行ファイル basename。取得できなければ "(pid N)" を返す。
  ///
  /// `PROC_PIDPATHINFO_MAXSIZE`（4 * MAXPATHLEN = 4096）は C マクロのため
  /// Swift から名前で参照できない。値そのまま定数化する。
  private func pidProcessName(pid: Int32) -> String {
    let maxLen = 4 * 1024
    var buf = [CChar](repeating: 0, count: maxLen)
    let n = buf.withUnsafeMutableBufferPointer { pointer -> Int32 in
      proc_pidpath(pid, pointer.baseAddress, UInt32(maxLen))
    }
    guard n > 0 else { return "(pid \(pid))" }
    let path = String(cString: buf)
    return (path as NSString).lastPathComponent
  }
}

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // ウィンドウの最小サイズ。3 ペインのワークスペース（ADR-0026）が
    // 破綻なく収まる下限。これ以下に縮めるとレイアウトが溢れるため固定する。
    self.minSize = NSSize(width: 800, height: 600)

    // 透過ウィンドウ設定（Flutter 側で背景を制御する）
    self.isOpaque = false
    self.backgroundColor = .clear
    self.titlebarAppearsTransparent = true

    // FlutterView 自体も透過させないと、ウィンドウは透過していても
    // Flutter の描画レイヤーがウィンドウ全体を opaque で塗ってしまい
    // 結果として透過モードでも背景が見えなくなる。
    flutterViewController.backgroundColor = .clear

    RegisterGeneratedPlugins(registry: flutterViewController)

    // ターミナル描画用の SwiftTerm ネイティブビュー（ADR-0031）。
    // Dart 側 `TerminalSurface` の `AppKitView`（viewType `roola/terminal-view`）
    // から生成される。
    let terminalRegistrar = flutterViewController.registrar(
      forPlugin: "RoolaTerminalView"
    )
    terminalRegistrar.register(
      TerminalViewFactory(registrar: terminalRegistrar),
      withId: "roola/terminal-view"
    )

    // ゴミ箱への移動。Dart 側からは `roola/trash` の
    // `moveToTrash` を呼ぶ。NSWorkspace 経由ではなく FileManager
    // .trashItem を使うことで、Finder の Cmd+Delete と同じ挙動になる。
    let trashChannel = FlutterMethodChannel(
      name: "roola/trash",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    trashChannel.setMethodCallHandler { call, result in
      guard call.method == "moveToTrash" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let args = call.arguments as? [String: Any],
            let path = args["path"] as? String
      else {
        result(
          FlutterError(
            code: "INVALID_ARGS",
            message: "path is required",
            details: nil
          )
        )
        return
      }
      let url = URL(fileURLWithPath: path)
      do {
        try FileManager.default.trashItem(at: url, resultingItemURL: nil)
        result(nil)
      } catch {
        result(
          FlutterError(
            code: "TRASH_FAILED",
            message: error.localizedDescription,
            details: nil
          )
        )
      }
    }

    // 手動アップデート確認（ADR-0043）。Dart 側からは `roola/updater` の
    // `checkForUpdates` を呼ぶ。Sparkle のチェック実行は AppDelegate が持つ
    // `SPUStandardUpdaterController` の責務なので、ここから直接実行せず
    // AppDelegate.checkForUpdates(_:) に転送する。
    let updaterChannel = FlutterMethodChannel(
      name: "roola/updater",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    updaterChannel.setMethodCallHandler { call, result in
      guard call.method == "checkForUpdates" else {
        result(FlutterMethodNotImplemented)
        return
      }
      if let delegate = NSApp.delegate as? AppDelegate {
        delegate.checkForUpdates(nil)
        result(nil)
      } else {
        result(
          FlutterError(
            code: "DELEGATE_MISSING",
            message: "AppDelegate is unavailable",
            details: nil
          )
        )
      }
    }

    // システムメトリクス（ADR-0039 / ADR-0048）。Dart 側からは
    // `roola/system/metrics` の `getSystemMetrics`（1 秒ポーリング）/
    // `getTopProcesses`（ポップオーバーを開いたとき、引数 `sortKey`）を呼ぶ。
    // `metricsProvider` は CPU の tick 差分のため状態を持つので、ハンドラに
    // captures させて常駐させる。ディスク / ネットワークの累積カウンタも
    // `getSystemMetrics` に同梱し、レート計算は Dart 側 ViewModel が担う
    // （ADR-0048 D4）。
    let metricsProvider = SystemMetricsProvider()
    let metricsChannel = FlutterMethodChannel(
      name: "roola/system/metrics",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    metricsChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "getSystemMetrics":
        let memory = metricsProvider.memoryInfo()
        let disk = metricsProvider.diskIOCounters()
        let network = metricsProvider.networkIOCounters()
        result([
          "cpu": metricsProvider.cpuUsage(),
          "memoryUsed": Int(memory.used),
          "memoryTotal": Int(memory.total),
          "diskReadBytes": Int(disk.bytesRead),
          "diskWrittenBytes": Int(disk.bytesWritten),
          "networkInBytes": Int(network.bytesIn),
          "networkOutBytes": Int(network.bytesOut),
        ])
      case "getTopProcesses":
        // sortKey は "cpu" / "memory" / "disk" / "network"。
        // cpu / memory は既存 `ps` 経路で同じレスポンスを返し、Dart 側で
        // 並び替えを行う（ADR-0039）。disk / network は I/O 専用経路で
        // ioBytesPerSec を含むレスポンスを返す（ADR-0048 D6）。
        let sortKey =
          (call.arguments as? [String: Any])?["sortKey"] as? String ?? "cpu"
        switch sortKey {
        case "disk":
          result(metricsProvider.diskTopProcesses())
        case "network":
          result(metricsProvider.networkTopProcesses())
        default:
          result(metricsProvider.processes())
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }
}
