import Cocoa
import FlutterMacOS

/// Roola Monitor のメインウィンドウ（ADR-0069 D7 / design D5）。
///
/// タイトルバーは残したまま透明にし、地の色（Polaris の `bg`）と一体に見せる。
/// Polaris はダーク専用なので外観もダークに固定する。大きさと位置は
/// `setFrameAutosaveName` で macOS に記憶させ、次回起動時に復元する。
class MainFlutterWindow: NSWindow {
  /// Polaris の `bg`（筐体の枠・`packages/polaris` の `AppTheme.tokens.bg`）。
  /// Flutter の描画が始まる前の一瞬とタイトルバーの地に使う。
  private static let polarisBg = NSColor(
    srgbRed: 0x12 / 255.0, green: 0x13 / 255.0, blue: 0x17 / 255.0, alpha: 1
  )

  /// 計器盤（ツールバー＋メーター）が崩れない最小サイズ。
  private static let minimumContentSize = NSSize(width: 480, height: 320)

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    flutterViewController.backgroundColor = Self.polarisBg
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    appearance = NSAppearance(named: .darkAqua)
    titlebarAppearsTransparent = true
    backgroundColor = Self.polarisBg
    contentMinSize = Self.minimumContentSize
    // 保存済みの位置・大きさがあれば復元する（無ければ xib の既定のまま）。
    setFrameAutosaveName("RoolaMonitorMainWindow")

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
