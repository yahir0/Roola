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

  private let terminal: TerminalView
  private let dataChannel: FlutterBasicMessageChannel
  private let ctrlChannel: FlutterMethodChannel
  /// Shift+Enter を横取りするためのローカル keyDown モニタ。
  private var keyMonitor: Any?

  init(
    channelId: String,
    messenger: FlutterBinaryMessenger,
    registrar: FlutterPluginRegistrar
  ) {
    terminal = TerminalView(frame: .zero)
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

    // Dart→native: PTY 出力バイト列を SwiftTerm に feed する。
    dataChannel.setMessageHandler { [weak self] message, reply in
      if let data = message as? Data {
        self?.terminal.feed(byteArray: [UInt8](data)[...])
      }
      reply(nil)
    }

    installShiftEnterMonitor()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    dataChannel.setMessageHandler(nil)
    if let keyMonitor = keyMonitor {
      NSEvent.removeMonitor(keyMonitor)
    }
  }

  // MARK: Shift+Enter による改行入力

  /// Shift+Enter を LF(`\n`) として送るローカル keyDown モニタを張る。
  ///
  /// 通常の Enter は SwiftTerm 既定の CR(`\r`)＝行確定のまま。Shift+Enter は
  /// LF を送り、Claude Code 等の TUI に「改行の挿入」として解釈させる
  /// （iTerm2 の Claude 用キーマップと同じ挙動）。
  ///
  /// SwiftTerm の `keyDown` は `public` 止まりでモジュール外から override
  /// できないため、サブクラス化ではなくローカルイベントモニタで横取りする。
  private func installShiftEnterMonitor() {
    keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
      [weak self] event in
      guard let self = self, self.shouldSendLineFeed(for: event) else {
        return event
      }
      self.dataChannel.sendMessage(RoolaTerminalView.lineFeed)
      return nil  // keyDown へ伝播させない（CR を送らせない）。
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

  // 以降は本アプリでは使わない `TerminalViewDelegate` 要件（空実装）。
  func scrolled(source: TerminalView, position: Double) {}
  func setTerminalTitle(source: TerminalView, title: String) {}
  func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}
  func clipboardCopy(source: TerminalView, content: Data) {}
  func bell(source: TerminalView) {}
  func requestOpenLink(
    source: TerminalView, link: String, params: [String: String]
  ) {}
  func rangeChanged(source: TerminalView, startY: Int, endY: Int) {}
  func iTermContent(source: TerminalView, content: ArraySlice<UInt8>) {}
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
