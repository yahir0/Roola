import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  /// ウィンドウは 1 枚だけなので、閉じたらアプリも終了する（spec: ウィンドウ）。
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
