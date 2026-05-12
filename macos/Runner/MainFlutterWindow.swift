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

    super.awakeFromNib()
  }
}
