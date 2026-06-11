import Cocoa
import FlutterMacOS
import SwiftTerm

/// SwiftTerm の `TerminalView` を Flutter の `AppKitView` プラットフォーム
/// ビューとしてホストする（ADR-0031）。
///
/// PTY は Dart 側（`flutter_pty` / `PtyTerminalRunner`）が所有し、本ファイルは
/// レンダラ＋入力に徹する。Dart ⇄ native のバイト列は per-tab のチャネルで
/// 直送する（base64 等のエンコード不要）:
///
/// - `roola/terminal/<channelId>`（`FlutterBasicMessageChannel` +
///   `FlutterBinaryCodec`）— Dart→native = PTY 出力 / native→Dart = ユーザー入力
/// - `roola/terminal/<channelId>/ctrl`（`FlutterMethodChannel`）—
///   native→Dart = `resize`
///
/// 対応する Dart 側は `TerminalChannel` / `TerminalSurface`。

// MARK: - Factory

/// `roola/terminal-view` viewType の `AppKitView` を生成するファクトリ。
/// `MainFlutterWindow` で registrar に登録する。
class TerminalViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger
  private let registrar: FlutterPluginRegistrar

  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
    self.messenger = registrar.messenger
    super.init()
  }

  /// creationParams は Dart 側で `StandardMessageCodec` エンコードされる。
  func createArgsCodec() -> (FlutterMessageCodec & NSObjectProtocol)? {
    return FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withViewIdentifier viewId: Int64, arguments args: Any?) -> NSView {
    let params = args as? [String: Any]
    let channelId = (params?["channelId"] as? String) ?? "\(viewId)"
    return RoolaTerminalView(
      channelId: channelId,
      messenger: messenger,
      registrar: registrar
    )
  }
}

// MARK: - Platform view

/// SwiftTerm `TerminalView` を 1 枚ホストする `NSView`。チャネル配線と
/// `TerminalViewDelegate` を兼ねる。
class RoolaTerminalView: NSView, TerminalViewDelegate {
  /// Return キー（36）/ テンキー Enter（76）の keyCode。
  private static let returnKeyCodes: Set<UInt16> = [36, 76]
  /// Shift+Enter で送る LF（`\n`）。
  private static let lineFeed = Data([0x0a])

  private let terminal: RoolaTerminalRenderingView
  private let dataChannel: FlutterBasicMessageChannel
  private let ctrlChannel: FlutterMethodChannel
  /// Shift+Enter を横取りするためのローカル keyDown モニタ。
  private var keyMonitor: Any?

  init(
    channelId: String,
    messenger: FlutterBinaryMessenger,
    registrar: FlutterPluginRegistrar
  ) {
    terminal = RoolaTerminalRenderingView(frame: .zero)
    dataChannel = FlutterBasicMessageChannel(
      name: "roola/terminal/\(channelId)",
      binaryMessenger: messenger,
      codec: FlutterBinaryCodec.sharedInstance()
    )
    ctrlChannel = FlutterMethodChannel(
      name: "roola/terminal/\(channelId)/ctrl",
      binaryMessenger: messenger
    )
    super.init(frame: .zero)

    terminal.translatesAutoresizingMaskIntoConstraints = false
    addSubview(terminal)
    NSLayoutConstraint.activate([
      terminal.leadingAnchor.constraint(equalTo: leadingAnchor),
      terminal.trailingAnchor.constraint(equalTo: trailingAnchor),
      terminal.topAnchor.constraint(equalTo: topAnchor),
      terminal.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

    // 透過: ラッパと SwiftTerm ビューの layer を透明にし、Flutter 側の
    // 暗幕（ADR-0020）を背後に透かす（ADR-0031 スパイク (c)）。
    // SwiftTerm のセル背景色は TerminalTheme で .clear に設定済み。
    wantsLayer = true
    layer?.isOpaque = false
    layer?.backgroundColor = NSColor.clear.cgColor
    terminal.wantsLayer = true
    terminal.layer?.isOpaque = false
    terminal.layer?.backgroundColor = NSColor.clear.cgColor

    terminal.terminalDelegate = self
    TerminalTheme.apply(to: terminal, registrar: registrar)

    // native→Dart: SwiftTerm がクリックでフォーカスされたとき、Flutter 側へ
    // 通知してフォーカス追跡（focusedTabProvider）を更新させる（ADR-0055）。
    // ターミナルへのクリックは AppKitView の外（ネイティブ NSView）で処理され
    // Flutter のポインタ系を通らないため、Flutter 側の Listener / FocusNode
    // だけでは「ターミナルがフォーカスされた」を検知できない。クリックを
    // この通知で橋渡しする。
    terminal.onMouseDown = { [weak self] in
      self?.ctrlChannel.invokeMethod("terminalDidFocus", arguments: nil)
    }

    // Dart→native: PTY 出力バイト列を SwiftTerm に feed する。
    dataChannel.setMessageHandler { [weak self] message, reply in
      if let data = message as? Data {
        self?.terminal.feed(byteArray: [UInt8](data)[...])
      }
      reply(nil)
    }

    // Dart→native: Flutter 側でターミナル面がフォーカスを得たとき、SwiftTerm を
    // ウインドウの first responder にしてキー入力先を Flutter のフォーカスと
    // 一致させる（ADR-0037）。
    ctrlChannel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(nil)
        return
      }
      switch call.method {
      case "focusTerminal":
        if self.window?.firstResponder !== self.terminal {
          _ = self.window?.makeFirstResponder(self.terminal)
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    installKeyMonitor()
    installOscNotificationHandlers()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    dataChannel.setMessageHandler(nil)
    ctrlChannel.setMethodCallHandler(nil)
    if let keyMonitor = keyMonitor {
      NSEvent.removeMonitor(keyMonitor)
    }
  }

  // MARK: キーボード横取り（Shift+Enter / コピー & ペースト）

  /// ローカル keyDown モニタを張り、SwiftTerm 既定処理より前にキーを
  /// 横取りする（ADR-0032 / ADR-0035）。
  ///
  /// - Shift+Enter → LF(`\n`)。通常 Enter は SwiftTerm 既定の CR(`\r`)＝行
  ///   確定のまま。Shift+Enter は LF を送り、Claude Code 等の TUI に
  ///   「改行の挿入」として解釈させる（iTerm2 の Claude 用キーマップと同じ）。
  /// - ⌘C / ⌘V → ターミナルのコピー / ペースト（ADR-0035）。
  ///
  /// SwiftTerm の `keyDown` は `public` 止まりでモジュール外から override
  /// できないため、サブクラス化ではなくローカルイベントモニタで横取りする。
  private func installKeyMonitor() {
    keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
      [weak self] event in
      guard let self = self else { return event }
      if self.shouldSendLineFeed(for: event) {
        self.dataChannel.sendMessage(RoolaTerminalView.lineFeed)
        return nil  // keyDown へ伝播させない（CR を送らせない）。
      }
      if self.handleClipboardShortcut(event) {
        return nil  // SwiftTerm 既定処理へ伝播させない。
      }
      return event
    }
  }

  /// 素の ⌘C / ⌘V をターミナルのコピー / ペーストとして処理する（ADR-0035）。
  ///
  /// このターミナルにフォーカスがあるときだけ反応する（タブ複数対応）。
  /// ⇧/⌃/⌥ が混じるコンビ（⌘⇧C 等のアプリコマンド）はメニューバー側に
  /// 委ねるため対象外。処理したら true を返す。
  private func handleClipboardShortcut(_ event: NSEvent) -> Bool {
    guard window?.firstResponder === terminal else { return false }
    let flags = event.modifierFlags
    guard flags.contains(.command),
      flags.isDisjoint(with: [.shift, .control, .option])
    else { return false }
    switch event.charactersIgnoringModifiers {
    case "c":
      NSApp.sendAction(#selector(NSText.copy(_:)), to: terminal, from: self)
      return true
    case "v":
      NSApp.sendAction(#selector(NSText.paste(_:)), to: terminal, from: self)
      return true
    default:
      return false
    }
  }

  /// `event` が「このターミナル宛ての素の Shift+Enter」かを判定する。
  private func shouldSendLineFeed(for event: NSEvent) -> Bool {
    // フォーカスが自分のターミナルにあるときだけ反応する（タブ複数対応）。
    guard window?.firstResponder === terminal else { return false }
    // Kitty keyboard protocol 有効時は SwiftTerm が修飾キー込みで Enter を
    // 報告できるため横取りしない。
    guard terminal.getTerminal().keyboardEnhancementFlags.isEmpty else {
      return false
    }
    let flags = event.modifierFlags
    return RoolaTerminalView.returnKeyCodes.contains(event.keyCode)
      && flags.contains(.shift)
      // Ctrl / Cmd / Option との同時押しは SwiftTerm 既定処理に委ねる。
      && flags.isDisjoint(with: [.control, .command, .option])
  }

  // MARK: OSC 通知（ADR-0066）

  /// OSC 9（iTerm2 系: `ESC ] 9 ; body BEL`）と OSC 777
  /// （`ESC ] 777 ; notify ; title ; body BEL`）を通知要求として Dart へ
  /// 転送する。OS 通知を出すか否か（フォーカス・レート制限・ADR-0057 との
  /// 重複抑止）の判断は Dart 側の通知ポリシー層に集約する。
  ///
  /// `registerOscHandler` で登録したハンドラは SwiftTerm 組み込みの解釈より
  /// 優先される。OSC 777 は組み込みでも解釈されるが、その通知は
  /// `TerminalDelegate.notify`（Terminal レベル）止まりで
  /// `TerminalViewDelegate` まで転送されないため、9 / 777 とも明示登録で受ける。
  private func installOscNotificationHandlers() {
    let term = terminal.getTerminal()
    term.registerOscHandler(code: 9) { [weak self] data in
      guard let body = String(bytes: data, encoding: .utf8), !body.isEmpty
      else { return }
      // `9;4;...` は ConEmu 進捗レポートであり通知ではないため無視する
      // （明示登録は SwiftTerm 組み込みの progress 解釈を上書きするため、
      // ここで弾かないと進捗更新のたびに偽通知になる）。
      if body == "4" || body.hasPrefix("4;") { return }
      self?.sendNotifyToDart(title: nil, body: body)
    }
    term.registerOscHandler(code: 777) { [weak self] data in
      guard let text = String(bytes: data, encoding: .utf8) else { return }
      let parts = text.components(separatedBy: ";")
      guard parts.count >= 3, parts[0] == "notify" else { return }
      self?.sendNotifyToDart(
        title: parts[1],
        body: parts[2...].joined(separator: ";")
      )
    }
  }

  /// native→Dart: 通知要求イベント。title は OSC 9 のとき nil（Dart 側が
  /// タブ名で補完する）。
  private func sendNotifyToDart(title: String?, body: String) {
    var arguments: [String: Any] = ["body": body]
    if let title = title { arguments["title"] = title }
    ctrlChannel.invokeMethod("notify", arguments: arguments)
  }

  // MARK: TerminalViewDelegate

  /// native→Dart: ユーザー入力バイト列を PTY へ送るため Dart へ転送する。
  func send(source: TerminalView, data: ArraySlice<UInt8>) {
    dataChannel.sendMessage(Data(data))
  }

  /// native→Dart: 端末サイズ変更を PTY へ伝えるため Dart へ転送する。
  func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {
    ctrlChannel.invokeMethod(
      "resize",
      arguments: ["cols": newCols, "rows": newRows]
    )
  }

  /// SwiftTerm が選択テキストのクリップボード書き出しを要求したときの実装
  /// （ADR-0035）。⌘C → `copy:` アクション経由で呼ばれる。
  func clipboardCopy(source: TerminalView, content: Data) {
    guard let text = String(data: content, encoding: .utf8), !text.isEmpty
    else { return }
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(text, forType: .string)
  }

  // 以降は本アプリでは使わない `TerminalViewDelegate` 要件（空実装）。
  func scrolled(source: TerminalView, position: Double) {}
  func setTerminalTitle(source: TerminalView, title: String) {}
  func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}
  func bell(source: TerminalView) {}
  func requestOpenLink(
    source: TerminalView, link: String, params: [String: String]
  ) {}
  func rangeChanged(source: TerminalView, startY: Int, endY: Int) {}
  func iTermContent(source: TerminalView, content: ArraySlice<UInt8>) {}
}

// MARK: - Terminal subclass (autoscroll on drag)

/// 選択ドラッグ中、カーソルがビュー外に出たときバッファを自動スクロール
/// する `TerminalView` サブクラス（ADR-0047）。
///
/// SwiftTerm の `MacTerminalView` には `autoScrollDelta` フィールドと
/// `scrollingTimerElapsed` コールバックが存在するが、それを駆動する
/// `Timer.scheduledTimer(...)` がどこにも書かれておらず autoscroll が
/// 機能しない（Issue #56）。Roola 側で薄く Timer を持ち、ドラッグ中だけ
/// `tickAutoScroll` を回して `scrollUp` / `scrollDown` を呼ぶ。
///
/// 選択範囲の伸張は SwiftTerm 内部の `selection` を直接触らず、同じ
/// `NSEvent` を `super.mouseDragged(with:)` に再投入することで間接的に
/// `selection.dragExtend(bufferPosition:)` を発火させる
/// （`calculateMouseHit` が「同じウィンドウ座標 × 新しい yDisp = 新しい
/// buffer 行」を返す性質を利用）。
final class RoolaTerminalRenderingView: TerminalView {
  /// autoscroll タイマー周期。25fps 相当。
  private static let tickInterval: TimeInterval = 0.04

  /// 1 tick あたりの最大スクロール行数。
  private static let maxLinesPerTick = 5

  /// ビュー外距離 → スクロール行数の単位（20px ごとに +1 行）。
  private static let pixelsPerLine: CGFloat = 20

  private var autoScrollTimer: Timer?
  private var lastDragEvent: NSEvent?

  /// クリックでフォーカス（first responder）を獲得したときに呼ぶコールバック。
  /// Flutter 側のフォーカス追跡更新に使う（ADR-0055）。
  ///
  /// SwiftTerm が `becomeFirstResponder()` を `public`（非 `open`）で
  /// オーバーライドしているためモジュール外から再オーバーライドできず
  /// （`keyDown` と同じ制約。ADR-0032）、`open` のままの `mouseDown` で
  /// クリックを捕まえる。キーボードのみでのフォーカス移動は Dart 側が
  /// 駆動する（`requestNativeFocus`）ため、クリック検知で十分。
  var onMouseDown: (() -> Void)?

  override func mouseDown(with event: NSEvent) {
    super.mouseDown(with: event)
    onMouseDown?()
    startAutoScrollTimerIfNeeded()
  }

  override func mouseDragged(with event: NSEvent) {
    super.mouseDragged(with: event)
    lastDragEvent = event
  }

  override func mouseUp(with event: NSEvent) {
    stopAutoScrollTimer()
    super.mouseUp(with: event)
  }

  private func startAutoScrollTimerIfNeeded() {
    guard autoScrollTimer == nil else { return }
    autoScrollTimer = Timer.scheduledTimer(
      withTimeInterval: RoolaTerminalRenderingView.tickInterval,
      repeats: true
    ) { [weak self] _ in
      self?.tickAutoScroll()
    }
  }

  private func stopAutoScrollTimer() {
    autoScrollTimer?.invalidate()
    autoScrollTimer = nil
    lastDragEvent = nil
  }

  /// タイマー駆動の autoscroll 判定本体。ドラッグイベントが無い・カーソルが
  /// ビュー内 / マウスレポーティング有効 のときは何もしない。
  private func tickAutoScroll() {
    guard let event = lastDragEvent else { return }

    // TUI（vim 等）がマウスを内部用途で握っているときは SwiftTerm 既定の
    // 挙動に任せて autoscroll を発動しない（ADR-0047 Decision 6）。
    // SwiftTerm の `MouseMode.sendButtonTracking()` は internal で呼べない
    // が、`mouseMode != .off` の全モードで SwiftTerm 側 mouseDragged が
    // 早期 return している（あるいは button tracking 用イベントだけ送る）
    // ため、ここでも `.off` 以外は autoscroll を諦める方が安全。
    if getTerminal().mouseMode != .off { return }

    // ウィンドウ座標 → view-local 座標。macOS のビュー座標系は y 上向き、
    // 原点は左下なので、 y > bounds.height がビュー上端より「上」。
    let point = convert(event.locationInWindow, from: nil)
    let direction: ScrollDirection
    let distance: CGFloat
    if point.y > bounds.height {
      direction = .up
      distance = point.y - bounds.height
    } else if point.y < 0 {
      direction = .down
      distance = -point.y
    } else {
      return
    }

    let lines = min(
      max(1, Int(distance / RoolaTerminalRenderingView.pixelsPerLine)),
      RoolaTerminalRenderingView.maxLinesPerTick
    )
    switch direction {
    case .up:
      scrollUp(lines: lines)
    case .down:
      scrollDown(lines: lines)
    }

    // スクロール後に同じイベントを super.mouseDragged に再投入する。
    // SwiftTerm 側で calculateMouseHit が「同じウィンドウ座標 × 更新済み
    // yDisp = 新しい buffer 行」を返すので、selection.dragExtend が新しく
    // 表示された行まで選択を伸ばす（ADR-0047 Decision 4）。
    super.mouseDragged(with: event)
  }

  /// autoscroll の方向。
  private enum ScrollDirection {
    case up
    case down
  }
}

// MARK: - Theme

/// 旧 `session_view.dart` の `_terminalTheme` / `_terminalStyle` を native へ
/// 移設した配色・フォント定義（ADR-0031 / ADR-0017 / ADR-0020）。
enum TerminalTheme {
  static func apply(
    to terminal: TerminalView, registrar: FlutterPluginRegistrar
  ) {
    // 16 ANSI パレット。値は旧 `_terminalTheme` と同一。
    let palette: [SwiftTerm.Color] = [
      rgb(0x00, 0x00, 0x00),  // black
      rgb(0xCD, 0x31, 0x31),  // red
      rgb(0x0D, 0xBC, 0x79),  // green
      rgb(0xE5, 0xE5, 0x10),  // yellow
      rgb(0x24, 0x72, 0xC8),  // blue
      rgb(0xBC, 0x3F, 0xBC),  // magenta
      rgb(0x11, 0xA8, 0xCD),  // cyan
      rgb(0xE5, 0xE5, 0xE5),  // white
      rgb(0x66, 0x66, 0x66),  // brightBlack
      rgb(0xF1, 0x4C, 0x4C),  // brightRed
      rgb(0x23, 0xD1, 0x8B),  // brightGreen
      rgb(0xF5, 0xF5, 0x43),  // brightYellow
      rgb(0x3B, 0x8E, 0xEA),  // brightBlue
      rgb(0xD6, 0x70, 0xD6),  // brightMagenta
      rgb(0x29, 0xB8, 0xDB),  // brightCyan
      rgb(0xFF, 0xFF, 0xFF),  // brightWhite
    ]
    terminal.installColors(palette)

    terminal.nativeForegroundColor = nsColor(0xE0, 0xE0, 0xE0)
    // 背景は透過。Flutter 側の暗幕（_AppearanceLayer）を透かす（ADR-0020）。
    terminal.nativeBackgroundColor = .clear
    terminal.caretColor = nsColor(0x90, 0xC0, 0xF0)
    terminal.selectedTextBackgroundColor = nsColor(0x50, 0x80, 0xC0)

    // フォント: バンドル済み Sarasa Term J（ADR-0017）。登録失敗時は
    // SwiftTerm 既定の等幅フォントにフォールバックする。
    if let font = loadBundledFont(registrar: registrar, size: 13) {
      terminal.font = font
    }
  }

  /// SwiftTerm の `Color` は 16bit コンポーネント（0-65535）。8bit 値を
  /// `* 257` で 16bit に引き伸ばす（0xFF*257 = 0xFFFF）。
  private static func rgb(_ r: Int, _ g: Int, _ b: Int) -> SwiftTerm.Color {
    return SwiftTerm.Color(
      red: UInt16(r * 257), green: UInt16(g * 257), blue: UInt16(b * 257)
    )
  }

  private static func nsColor(_ r: Int, _ g: Int, _ b: Int) -> NSColor {
    return NSColor(
      red: CGFloat(r) / 255, green: CGFloat(g) / 255,
      blue: CGFloat(b) / 255, alpha: 1
    )
  }

  /// pubspec.yaml の Flutter assets に登録された `SarasaTermJ-Regular.ttf` を
  /// `registrar.lookupKey(forAsset:)` で解決し、プロセスにフォント登録して
  /// `NSFont` を返す。解決・登録に失敗したら nil。
  private static func loadBundledFont(
    registrar: FlutterPluginRegistrar, size: CGFloat
  ) -> NSFont? {
    let key = registrar.lookupKey(
      forAsset: "assets/fonts/SarasaTermJ-Regular.ttf"
    )
    guard let path = Bundle.main.path(forResource: key, ofType: nil) else {
      return nil
    }
    let url = URL(fileURLWithPath: path)
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    return NSFont(name: "Sarasa Term J", size: size)
  }
}
