import Cocoa
import Darwin
import FlutterMacOS
import UserNotifications

/// Claude Code タスク完了通知（ADR-0057）の macOS ローカル通知を扱う。
///
/// `roola/notification` の `MethodChannel` から呼ばれ、`UNUserNotificationCenter`
/// 経由で通知を発射する。`flutter_local_notifications` は使わず、既存の
/// `roola/trash` 等と同じネイティブ連携パターンに揃える（ADR-0005 / ADR-0057）。
/// フォアグラウンドでもバナーを表示するため delegate を自身に設定する。
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
  override init() {
    super.init()
    UNUserNotificationCenter.current().delegate = self
  }

  /// 初回の通知許可を要求する。結果（許可されたか）を completion で返す。
  func requestAuthorization(completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .sound]
    ) { granted, _ in
      DispatchQueue.main.async { completion(granted) }
    }
  }

  /// 現在の許可状態を Dart の `NotificationAuthorizationStatus` 名で返す。
  func authorizationStatus(completion: @escaping (String) -> Void) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      let name: String
      switch settings.authorizationStatus {
      case .authorized, .provisional, .ephemeral:
        name = "authorized"
      case .denied:
        name = "denied"
      case .notDetermined:
        name = "notDetermined"
      @unknown default:
        name = "notDetermined"
      }
      DispatchQueue.main.async { completion(name) }
    }
  }

  /// 通知クリック時に呼ばれるコールバック（ADR-0066）。`sessionId` 付き
  /// 通知（`notify(title:body:sessionId:)`）のみ対象。`MainFlutterWindow` が
  /// `roola/notification` チャネルの `notificationClicked` へ橋渡しする。
  var onNotificationClick: ((String) -> Void)?

  /// ローカル通知を 1 件発射する。`trigger: nil` で即時配信。
  /// `sessionId` は通知元ペインの識別子。クリック時のフォーカス復帰
  /// （ADR-0066）のため `userInfo` に載せる。
  func notify(title: String, body: String, sessionId: String?) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    if let sessionId = sessionId {
      content.userInfo = ["sessionId": sessionId]
    }
    let request = UNNotificationRequest(
      identifier: UUID().uuidString,
      content: content,
      trigger: nil
    )
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
  }

  /// macOS のシステム通知設定を開く（拒否後の再許可導線）。
  func openSystemSettings() {
    if let url = URL(
      string: "x-apple.systempreferences:com.apple.preference.notifications"
    ) {
      NSWorkspace.shared.open(url)
    }
  }

  /// アプリがフォアグラウンドのときもバナー / サウンドで通知を出す。
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
      @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .sound, .list])
  }

  /// 通知クリック（ADR-0066）。`userInfo` の `sessionId` を Dart へ橋渡しし、
  /// 該当ペインへのフォーカス復帰につなげる。クリックでアプリ自体は macOS が
  /// 前面化（activate）させるため、ここでは識別子の転送のみ行う。
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    defer { completionHandler() }
    guard
      let sessionId =
        response.notification.request.content.userInfo["sessionId"] as? String
    else { return }
    onNotificationClick?(sessionId)
  }
}

class MainFlutterWindow: NSWindow {
  /// ウィンドウ再アクティブ化（key 化）を Dart へ通知するチャネル（ADR-0055）。
  /// `awakeFromNib` でエンジンの binaryMessenger に紐付けて生成する。
  private var windowChannel: FlutterMethodChannel?

  /// タスク完了通知のマネージャ（ADR-0057）。`UNUserNotificationCenter` の
  /// delegate を保持し続ける必要があるため、ウィンドウに強参照で常駐させる。
  private var notificationManager: NotificationManager?

  /// ウィンドウが key ウィンドウになったとき（別ウィンドウ / 別アプリから
  /// 戻ってきたとき）に Dart へ通知する（ADR-0055）。Dart 側は直前に
  /// フォーカスしていたペインへフォーカスを戻す。`becomeKey` は初回表示でも
  /// 発火するが、その時点では復帰対象（focusedTabId）が未設定のため no-op。
  override func becomeKey() {
    super.becomeKey()
    windowChannel?.invokeMethod("didBecomeKey", arguments: nil)
  }

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

    // システムメトリクス（`roola/system/metrics`）は packages/roola_activity の
    // macOS プラグインが登録する（ADR-0069）。

    // ウィンドウ再アクティブ化通知（ADR-0055）。native→Dart の一方向通知のみ
    // 行うため、ハンドラは設定しない（Dart 側が setMethodCallHandler する）。
    windowChannel = FlutterMethodChannel(
      name: "roola/window",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    // Claude Code タスク完了通知（ADR-0057）。Dart 側からは
    // `roola/notification` の `notify` / `requestAuthorization` /
    // `authorizationStatus` / `openSystemSettings` を呼ぶ。delegate を持つ
    // マネージャを常駐させるため、ハンドラに捕捉させる。
    let notificationManager = NotificationManager()
    self.notificationManager = notificationManager
    let notificationChannel = FlutterMethodChannel(
      name: "roola/notification",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    // 通知クリック → Dart へ橋渡し（ADR-0066）。Dart 側は該当ペインへ
    // フォーカスを戻す。
    notificationManager.onNotificationClick = { sessionId in
      notificationChannel.invokeMethod(
        "notificationClicked",
        arguments: ["sessionId": sessionId]
      )
    }
    notificationChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "notify":
        guard let args = call.arguments as? [String: Any],
          let title = args["title"] as? String,
          let body = args["body"] as? String
        else {
          result(
            FlutterError(
              code: "INVALID_ARGS",
              message: "title and body are required",
              details: nil
            )
          )
          return
        }
        notificationManager.notify(
          title: title,
          body: body,
          sessionId: args["sessionId"] as? String
        )
        result(nil)
      case "requestAuthorization":
        notificationManager.requestAuthorization { granted in
          result(granted)
        }
      case "authorizationStatus":
        notificationManager.authorizationStatus { status in
          result(status)
        }
      case "openSystemSettings":
        notificationManager.openSystemSettings()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()

    // 信号灯（close / minimize / zoom）を Flutter 側トップバーの中で上下中央へ
    // 寄せる（ADR-0064）。`titleBarStyle: hidden` + `titlebarAppearsTransparent`
    // では信号灯が macOS 標準タイトルバー（約 28px）基準で上端寄りに置かれ、
    // Roola の 40px トップバー（`MacosWindowAppBar._toolbarHeight`）の中では
    // 上に詰まって見える。レイアウトのたびに各ボタンの y を再計算して中央へ
    // 落とす。リサイズで AppKit が既定位置へ戻すため、リサイズ / フルスクリーン
    // 復帰の通知でも再適用する。
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(centerWindowButtons),
      name: NSWindow.didResizeNotification,
      object: self
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(centerWindowButtons),
      name: NSWindow.didExitFullScreenNotification,
      object: self
    )
    // 初回表示時はビュー階層が組み上がった次の run loop で適用する。
    DispatchQueue.main.async { [weak self] in self?.centerWindowButtons() }
  }

  /// 信号灯ボタンの中心を、トップバー上端から `topBarHeight / 2` の位置へ
  /// 揃える。フルスクリーン中は OS がボタンを管理するため何もしない。
  @objc private func centerWindowButtons() {
    guard !styleMask.contains(.fullScreen) else { return }

    // Flutter 側 `MacosWindowAppBar._toolbarHeight` と一致させる。
    let topBarHeight: CGFloat = 40
    let buttons = [
      standardWindowButton(.closeButton),
      standardWindowButton(.miniaturizeButton),
      standardWindowButton(.zoomButton),
    ].compactMap { $0 }
    // ボタンの親（タイトルバービュー）はウィンドウ上端に固定されるので、その
    // 上端からの距離でボタン中心を決める。非 flipped 座標なので上端は
    // bounds.height、そこから topBarHeight/2 下げた位置が目標の中心。
    guard let titlebar = buttons.first?.superview else { return }
    let centerY = titlebar.bounds.height - topBarHeight / 2
    for button in buttons {
      var frame = button.frame
      frame.origin.y = centerY - button.bounds.height / 2
      button.frame = frame
    }
  }
}
