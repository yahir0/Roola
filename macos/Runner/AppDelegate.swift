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
    let feedURL =
      (Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") as? String) ?? ""
    let publicKey =
      (Bundle.main.object(forInfoDictionaryKey: "SUPublicEDKey") as? String) ?? ""
    guard !feedURL.isEmpty, !publicKey.isEmpty else {
      NSLog(
        "Sparkle: SUFeedURL or SUPublicEDKey is not configured; auto-updates disabled."
      )
      return nil
    }
    return SPUStandardUpdaterController(
      startingUpdater: true,
      updaterDelegate: nil,
      userDriverDelegate: nil
    )
  }()

  override init() {
    // GUI 起動経路 (Dock / Finder / open) では stdout/stderr の宛先が早期に
    // クローズされる場合があり、Dart / Flutter Engine が write した瞬間に
    // SIGPIPE で即死する。ターミナル直起動だと TTY に繋がるため再現しない。
    // 詳細・代替案は ADR-0025 を参照。
    signal(SIGPIPE, SIG_IGN)
    super.init()
    // Sparkle 自動更新を init 時点で発火させる。
    //
    // 当初は applicationDidFinishLaunching(_:) を override してそこで触る
    // 設計にしていたが、macOS 26 系で Swift 側の `Notification` を引数に取る
    // override が Obj-C 側からのディスパッチで unrecognized selector になり
    // AppKit が落ちる現象を確認した（具体的には NSApplication が
    // applicationDidFinishLaunching: を送った瞬間に NSNotification→Notification
    // ブリッジの thunk 内で例外）。FlutterAppDelegate 側の同メソッドは Obj-C
    // 実装で正常に呼ばれるので、override を消して親に任せ、Sparkle init は
    // init() の中で済ませる。SPUStandardUpdaterController(startingUpdater:
    // true, ...) は app launch の前後どちらでも安全に呼べる設計（内部で適切に
    // バックグラウンドスケジュールする）。
    _ = updaterController
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
