import Cocoa
import FlutterMacOS

/// `roola/system/metrics` チャネルを登録するプラグイン（ADR-0039 / ADR-0067 / ADR-0069）。
///
/// Dart 側からは `getSystemMetrics`（トップバーの 1 秒ポーリング）、
/// `getTopProcesses`（ポップオーバーを開いたとき）、`getSystemSnapshot`
/// （計器盤の 250ms ポーリング）を呼ぶ。`SystemMetricsProvider` は CPU の tick 差分の
/// ため状態を持つので、プラグインのインスタンスに持たせてエンジンの寿命だけ常駐させる。
public class RoolaActivityPlugin: NSObject, FlutterPlugin {
  private let metricsProvider = SystemMetricsProvider()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "roola/system/metrics",
      binaryMessenger: registrar.messenger
    )
    registrar.addMethodCallDelegate(RoolaActivityPlugin(), channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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
    case "getSystemSnapshot":
      result(metricsProvider.snapshot())
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
