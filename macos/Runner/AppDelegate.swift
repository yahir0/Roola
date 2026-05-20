import Cocoa
import FlutterMacOS
import Sparkle

@main
class AppDelegate: FlutterAppDelegate {
  /// Sparkle の自動更新コントローラ（Phase A）。
  ///
  /// `SUFeedURL` と `SUPublicEDKey` が Info.plist に設定されている場合のみ
  /// バックグラウンドの自動チェックを開始する。未設定（公開後の Phase B で
  /// 埋める前の状態）では nil のままで Sparkle 関連 API は no-op。
  /// セットアップ手順は docs/release.md の Sparkle セクション参照。
  private lazy var updaterController: SPUStandardUpdaterController? = {
    NSLog("Roola/Sparkle: lazy updaterController initializer entered")
    let bundleId = Bundle.main.bundleIdentifier ?? "<nil>"
    NSLog("Roola/Sparkle: Bundle.main.bundleIdentifier = %@", bundleId)
    let feedURL =
      (Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") as? String) ?? ""
    let publicKey =
      (Bundle.main.object(forInfoDictionaryKey: "SUPublicEDKey") as? String) ?? ""
    NSLog("Roola/Sparkle: SUFeedURL length=%d, SUPublicEDKey length=%d", feedURL.count, publicKey.count)
    guard !feedURL.isEmpty, !publicKey.isEmpty else {
      NSLog(
        "Roola/Sparkle: SUFeedURL or SUPublicEDKey is not configured; auto-updates disabled."
      )
      return nil
    }
    NSLog("Roola/Sparkle: Initializing SPUStandardUpdaterController...")
    let controller = SPUStandardUpdaterController(
      startingUpdater: true,
      updaterDelegate: nil,
      userDriverDelegate: nil
    )
    NSLog("Roola/Sparkle: SPUStandardUpdaterController initialized successfully")
    return controller
  }()

  override init() {
    // GUI 起動経路 (Dock / Finder / open) では stdout/stderr の宛先が早期に
    // クローズされる場合があり、Dart / Flutter Engine が write した瞬間に
    // SIGPIPE で即死する。ターミナル直起動だと TTY に繋がるため再現しない。
    // 詳細・代替案は ADR-0025 を参照。
    signal(SIGPIPE, SIG_IGN)
    super.init()
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    NSLog("Roola/Sparkle: applicationDidFinishLaunching - entering")
    super.applicationDidFinishLaunching(notification)
    NSLog("Roola/Sparkle: applicationDidFinishLaunching - super returned, triggering updaterController")
    // 起動直後に lazy 初期化を発火させ、Info.plist 設定済みなら自動チェックを
    // スタートさせる（未設定なら no-op で何も起きない）。
    let controller = updaterController
    NSLog("Roola/Sparkle: applicationDidFinishLaunching - updaterController = %@", controller != nil ? "non-nil" : "nil")
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  /// メニューバーの「ファイル > 新規ウィンドウ」（⌘N）と、Dock 右クリックの
  /// 「新規ウィンドウ」から呼ばれる。
  ///
  /// Roola.app の新しいインスタンスを別プロセスとして起動する。プロセスは
  /// 完全に独立しており、設定（launcher entries 等）は永続化ファイル経由で
  /// しか共有されない。設計判断の背景は ADR-0012 を参照。
  @IBAction func newWindow(_ sender: Any?) {
    let url = Bundle.main.bundleURL
    let config = NSWorkspace.OpenConfiguration()
    config.createsNewApplicationInstance = true
    NSWorkspace.shared.openApplication(at: url, configuration: config) { _, error in
      if let error = error {
        NSLog("Failed to open new Roola instance: \(error.localizedDescription)")
      }
    }
  }

  /// Dock アイコンを右クリック（または長押し）したときに表示されるメニュー。
  /// 「新規ウィンドウ」を 1 項目だけ追加する（メニューバーの「ファイル >
  /// 新規ウィンドウ」と同じアクションに routing）。
  override func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
    let menu = NSMenu()
    let item = NSMenuItem(
      title: "新規ウィンドウ",
      action: #selector(newWindow(_:)),
      keyEquivalent: ""
    )
    item.target = self
    menu.addItem(item)
    return menu
  }
}
