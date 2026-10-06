import Cocoa
import Darwin
import IOKit

/// システムメトリクス（CPU / メモリ / プロセス一覧）を macOS の標準 API から
/// 取得する（ADR-0039）。
///
/// - CPU: `host_statistics`(HOST_CPU_LOAD_INFO) の累積 tick 差分から使用率を
///   算出する。差分方式のため前回 tick を保持する。初回呼び出しは前回値が
///   無く 0% を返し、2 回目以降が「前回呼び出しからの使用率」になる。
/// - メモリ: `host_statistics64`(HOST_VM_INFO64) と `sysctl hw.memsize` から
///   使用量 / 総容量を算出する。
/// - プロセス一覧: `ps` を 1 回実行して標準出力をパースする（クリック時のみ
///   呼ばれるため、サブプロセス起動のコストは許容範囲）。
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
}

/// アクティビティタブ（ADR-0067）向けの累積値スナップショット。
///
/// トップバー用の `cpuUsage()` と違い **状態を持たない**。累積カウンタを
/// そのまま返し、差分・レート計算は Dart 側の ViewModel が呼び出し元ごとに
/// 行う（250ms のタブと 1 秒のトップバーが差分区間を奪い合わないため）。
/// 取得できない項目はキーを含めない。
extension SystemMetricsProvider {
  func snapshot() -> [String: Any] {
    var result: [String: Any] = [:]
    if let ticks = perCoreTicks() {
      result["cpuTicks"] = ticks
    }
    let memory = memoryInfo()
    result["memoryUsed"] = Int(memory.used)
    result["memoryTotal"] = Int(memory.total)
    if let swap = swapUsage() {
      result["swapUsed"] = Int(swap.used)
      result["swapTotal"] = Int(swap.total)
    }
    if let disk = diskTotals() {
      result["diskReadBytes"] = Int(truncatingIfNeeded: disk.read)
      result["diskWriteBytes"] = Int(truncatingIfNeeded: disk.write)
    }
    result["netInterfaces"] = networkInterfaces()
    var loads = [Double](repeating: 0, count: 3)
    if getloadavg(&loads, 3) == 3 {
      result["loadAverage"] = loads
    }
    if let uptime = uptimeSeconds() {
      result["uptimeSeconds"] = uptime
    }
    return result
  }

  /// コアごとの累積 tick `[user, system, idle, nice]`（`host_processor_info`）。
  /// 各値は 32bit で一周しうるため、Dart 側は 2^32 剰余で差分を取る。
  private func perCoreTicks() -> [[Int]]? {
    var cpuCount: natural_t = 0
    var info: processor_info_array_t?
    var infoCount: mach_msg_type_number_t = 0
    guard
      host_processor_info(
        mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &cpuCount, &info, &infoCount
      ) == KERN_SUCCESS,
      let info
    else { return nil }
    defer {
      vm_deallocate(
        mach_task_self_,
        vm_address_t(bitPattern: info),
        vm_size_t(Int(infoCount) * MemoryLayout<integer_t>.stride)
      )
    }
    var cores: [[Int]] = []
    for core in 0..<Int(cpuCount) {
      let base = Int(CPU_STATE_MAX) * core
      let tick = { (state: Int32) in Int(UInt32(bitPattern: info[base + Int(state)])) }
      cores.append([
        tick(CPU_STATE_USER), tick(CPU_STATE_SYSTEM), tick(CPU_STATE_IDLE),
        tick(CPU_STATE_NICE),
      ])
    }
    return cores
  }

  private func swapUsage() -> (used: UInt64, total: UInt64)? {
    var usage = xsw_usage()
    var size = MemoryLayout<xsw_usage>.size
    guard sysctlbyname("vm.swapusage", &usage, &size, nil, 0) == 0 else { return nil }
    return (usage.xsu_used, usage.xsu_total)
  }

  /// 全ブロックストレージの読み書き累積バイト（IOKit `IOBlockStorageDriver`）。
  private func diskTotals() -> (read: UInt64, write: UInt64)? {
    var iterator: io_iterator_t = 0
    guard
      IOServiceGetMatchingServices(
        kIOMainPortDefault, IOServiceMatching("IOBlockStorageDriver"), &iterator
      ) == KERN_SUCCESS
    else { return nil }
    defer { IOObjectRelease(iterator) }
    var read: UInt64 = 0
    var write: UInt64 = 0
    while case let service = IOIteratorNext(iterator), service != 0 {
      defer { IOObjectRelease(service) }
      var properties: Unmanaged<CFMutableDictionary>?
      guard
        IORegistryEntryCreateCFProperties(service, &properties, kCFAllocatorDefault, 0)
          == KERN_SUCCESS,
        let dict = properties?.takeRetainedValue() as? [String: Any],
        let stats = dict["Statistics"] as? [String: Any]
      else { continue }
      read &+= (stats["Bytes (Read)"] as? NSNumber)?.uint64Value ?? 0
      write &+= (stats["Bytes (Write)"] as? NSNumber)?.uint64Value ?? 0
    }
    return (read, write)
  }

  /// 物理ネットワーク IF（`en*`）ごとの受信 / 送信累積バイト。
  ///
  /// macOS は一般プロセスにこのカウンタを 32bit で一周させ、1 KiB 単位に
  /// 丸めて渡す（`NET_RT_IFLIST2` の 64bit 版でも同じ）。合計してから差分を
  /// 取ると一周で壊れるため IF ごとに返し、Dart 側が IF ごとに 2^32 剰余の
  /// 差分を取る。VPN のトンネル（`utun*`）は `en*` と二重計上になるので除外する
  /// （design D8 の検証結果）。
  private func networkInterfaces() -> [[String: Any]] {
    var head: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&head) == 0 else { return [] }
    defer { freeifaddrs(head) }
    var result: [[String: Any]] = []
    var cursor = head
    while let entry = cursor {
      cursor = entry.pointee.ifa_next
      guard entry.pointee.ifa_addr?.pointee.sa_family == UInt8(AF_LINK),
        let data = entry.pointee.ifa_data
      else { continue }
      let name = String(cString: entry.pointee.ifa_name)
      guard name.hasPrefix("en") else { continue }
      let stats = data.assumingMemoryBound(to: if_data.self).pointee
      result.append([
        "name": name,
        "rx": Int(stats.ifi_ibytes),
        "tx": Int(stats.ifi_obytes),
      ])
    }
    return result
  }

  private func uptimeSeconds() -> Int? {
    var bootTime = timeval()
    var size = MemoryLayout<timeval>.size
    guard sysctlbyname("kern.boottime", &bootTime, &size, nil, 0) == 0 else { return nil }
    return max(0, Int(Date().timeIntervalSince1970) - bootTime.tv_sec)
  }
}
