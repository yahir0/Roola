import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

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

    super.awakeFromNib()
  }
}
