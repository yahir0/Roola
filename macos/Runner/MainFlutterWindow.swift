import Cocoa
import Darwin
import FlutterMacOS

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

class MainFlutterWindow: NSWindow {
  /// メニューバーのショートカット（key equivalent）を、フォーカス中のビュー
  /// より先に評価する（ADR-0033 / ADR-0052）。
  ///
  /// macOS の既定の処理順では、command / control を含むキーは
  /// 「キーウィンドウの `performKeyEquivalent:`（＝ビュー階層）」が先に処理し、
  /// ここで消費されるとメインメニューの key equivalent は発火しない
  /// （Apple「Handling Key Events」/ WWDC 2010-145）。Roola では Flutter
  /// ビューや SwiftTerm のターミナルビューが command 系キーを
  /// `performKeyEquivalent:` で横取りするため、ADR-0033 が前提とした
  /// 「メニューの key equivalent がファーストレスポンダに関係なく発火する」が
  /// 成立せず、全ショートカットがキー操作では効かなかった（メニュー項目の
  /// クリックでは発火）。
  ///
  /// ここでウィンドウの `performKeyEquivalent` をオーバーライドし、まず
  /// メインメニューに評価させる。メニューが処理すれば `true` を返してビューへ
  /// 渡さない。処理しなければ `super` に委ね、従来どおりビュー（ターミナルの
  /// ⌘C / ⌘V 等）が処理する。メニューに載るのは ⌘⇧C のような修飾付き
  /// コマンドだけで、テキスト編集用に予約した ⌘C / ⌘V / ⌘X / ⌘A / ⌘Z
  /// （ADR-0035）はメニュー項目を持たないため、テキスト入力やターミナルの
  /// コピー＆ペーストを奪うことはない。レコーダ表示中はメニュー側の key
  /// equivalent が外れる（`AppMenuBar`）ので、ここでも素通りしてレコーダが
  /// キーを受け取れる。
  override func performKeyEquivalent(with event: NSEvent) -> Bool {
    if NSApp.mainMenu?.performKeyEquivalent(with: event) == true {
      return true
    }
    return super.performKeyEquivalent(with: event)
  }

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

    // システムメトリクス（ADR-0039）。Dart 側からは `roola/system/metrics`
    // の `getSystemMetrics`（1 秒ポーリング）/ `getTopProcesses`
    // （ポップオーバーを開いたとき）を呼ぶ。`metricsProvider` は CPU の
    // tick 差分のため状態を持つので、ハンドラに captures させて常駐させる。
    let metricsProvider = SystemMetricsProvider()
    let metricsChannel = FlutterMethodChannel(
      name: "roola/system/metrics",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    metricsChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "getSystemMetrics":
        let memory = metricsProvider.memoryInfo()
        result([
          "cpu": metricsProvider.cpuUsage(),
          "memoryUsed": Int(memory.used),
          "memoryTotal": Int(memory.total),
        ])
      case "getTopProcesses":
        result(metricsProvider.processes())
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }
}
