import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/task_notification/osc_notification_controller.dart';
import 'package:roola/data/terminal_runner/terminal_runner.dart';
import 'package:roola/ui/workspace/current_tab_id_provider.dart';
import 'package:roola/ui/workspace/focused_tab_provider.dart';
import 'package:webview_windows/webview_windows.dart';

/// Windows 専用: xterm.js を WebView2 に埋め込んだターミナル面（ADR-0058 D1）。
///
/// PTY 出力（[TerminalRunner.output]）を base64 エンコードして
/// JS の `term_write(data)` に渡し xterm.js に描画させる。
/// ユーザー入力は xterm.js の `onData` → WebView message → [TerminalRunner.write]。
/// リサイズは ResizeObserver 経由で xterm.js → WebView message → [TerminalRunner.resize]。
class TerminalSurfaceWindows extends ConsumerStatefulWidget {
  const TerminalSurfaceWindows({
    required this.channelId,
    required this.runner,
    super.key,
  });

  /// ad-hoc セッション id。OSC 通知要求のセッション識別に使う（ADR-0066）。
  final String channelId;

  final TerminalRunner runner;

  @override
  ConsumerState<TerminalSurfaceWindows> createState() =>
      _TerminalSurfaceWindowsState();
}

class _TerminalSurfaceWindowsState
    extends ConsumerState<TerminalSurfaceWindows> {
  final _controller = WebviewController();
  StreamSubscription<Uint8List>? _outputSub;
  StreamSubscription<dynamic>? _messageSub;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _controller.initialize();

    // WebView → Dart メッセージ購読（input / resize）。
    _messageSub = _controller.webMessage.listen(_handleWebMessage);

    // xterm.js と CSS を Flutter assets から読み込んで HTML に inline embed する。
    final xtermJs = await rootBundle.loadString('assets/js/xterm/xterm.js');
    final xtermCss = await rootBundle.loadString('assets/js/xterm/xterm.css');
    final fitJs = await rootBundle.loadString(
      'assets/js/xterm/xterm-addon-fit.js',
    );

    await _controller.loadStringContent(_buildHtml(xtermJs, xtermCss, fitJs));

    // PTY 出力を購読してターミナルへ流す。
    _outputSub = widget.runner.output.listen(_onPtyOutput);

    if (mounted) setState(() => _initialized = true);
  }

  void _handleWebMessage(dynamic message) {
    if (message is! String) return;
    try {
      final map = jsonDecode(message) as Map<String, dynamic>;
      final type = map['type'] as String?;
      if (type == 'input') {
        final data = map['data'] as String?;
        if (data != null) {
          widget.runner.write(Uint8List.fromList(utf8.encode(data)));
        }
      } else if (type == 'resize') {
        final cols = (map['cols'] as num?)?.toInt() ?? 80;
        final rows = (map['rows'] as num?)?.toInt() ?? 24;
        widget.runner.resize(cols: cols, rows: rows);
      } else if (type == 'copy') {
        // 右クリック選択テキストをクリップボードにコピー。
        final text = map['text'] as String?;
        if (text != null && text.isNotEmpty) {
          unawaited(Clipboard.setData(ClipboardData(text: text)));
        }
      } else if (type == 'paste') {
        // 右クリックでクリップボードの内容を PTY へ送る。
        unawaited(_pasteFromClipboard());
      } else if (type == 'notify') {
        // xterm.js が解釈した OSC 9/777 通知要求（ADR-0066）。
        _handleNotify(
          title: map['title'] as String?,
          body: map['body'] as String? ?? '',
        );
      }
    } catch (_) {
      // JSON パース失敗は無視する。
    }
  }

  /// OSC 通知要求のフォーカス判定（macOS 側 `TerminalSurface` と同じ規則:
  /// 自タブが focusedTab かつアプリ前面なら「見ている」ので発射しない）。
  /// 発射判断の本体はコントローラに委譲する。
  void _handleNotify({String? title, required String body}) {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    final isFocused =
        ref.read(focusedTabProvider).focusedTabId ==
            ref.read(currentTabIdProvider) &&
        (lifecycle == null || lifecycle == AppLifecycleState.resumed);
    unawaited(
      ref
          .read(oscNotificationControllerProvider)
          .handleNotify(
            sessionId: widget.channelId,
            isFocused: isFocused,
            title: title,
            body: body,
          ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text != null && text.isNotEmpty) {
      widget.runner.write(Uint8List.fromList(utf8.encode(text)));
    }
  }

  void _onPtyOutput(Uint8List bytes) {
    if (!_controller.value.isInitialized) return;
    // base64 エンコードしてから JS に渡す。バックスラッシュや引用符の
    // エスケープが不要になるため、base64 経由が安全。
    final b64 = base64.encode(bytes);
    _controller.executeScript("term_write('$b64');").ignore();
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _outputSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const ColoredBox(color: Color(0xFF1A1A1A));
    }
    return Webview(_controller);
  }

  static String _buildHtml(String xtermJs, String xtermCss, String fitJs) {
    return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
$xtermCss
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body { width: 100%; height: 100%; background: #1a1a1a; overflow: hidden; }
#terminal { width: 100%; height: 100%; }
.xterm { height: 100%; }
</style>
</head>
<body>
<div id="terminal"></div>
<script>$xtermJs</script>
<script>$fitJs</script>
<script>
var term = new Terminal({
  fontFamily: "monospace",
  fontSize: 13,
  theme: {
    background: '#1a1a1a', foreground: '#d4d4d4', cursor: '#d4a017',
    black: '#1a1a1a', red: '#e06c75', green: '#98c379', yellow: '#e5c07b',
    blue: '#61afef', magenta: '#c678dd', cyan: '#56b6c2', white: '#abb2bf',
    brightBlack: '#5c6370', brightRed: '#e06c75', brightGreen: '#98c379',
    brightYellow: '#e5c07b', brightBlue: '#61afef', brightMagenta: '#c678dd',
    brightCyan: '#56b6c2', brightWhite: '#ffffff',
  },
  cursorBlink: true,
  scrollback: 5000,
  allowTransparency: false,
});
var fitAddon = new FitAddon.FitAddon();
term.loadAddon(fitAddon);
term.open(document.getElementById('terminal'));
fitAddon.fit();

window.term_write = function(b64) {
  var bytes = Uint8Array.from(atob(b64), function(c) { return c.charCodeAt(0); });
  term.write(bytes);
};

term.onData(function(data) {
  window.chrome.webview.postMessage(JSON.stringify({ type: 'input', data: data }));
});

var ro = new ResizeObserver(function() {
  fitAddon.fit();
  window.chrome.webview.postMessage(
    JSON.stringify({ type: 'resize', cols: term.cols, rows: term.rows })
  );
});
ro.observe(document.getElementById('terminal'));

// OSC 9 / OSC 777 通知シーケンス → Dart（ADR-0066）。発射判断（フォーカス・
// レート制限）は Dart 側に集約する。
// フォーカスレポーティング（mode 1004 の CSI I/O）は xterm.js が組み込みで
// 送出するため、ここでの実装は不要。
function postNotify(title, body) {
  window.chrome.webview.postMessage(
    JSON.stringify({ type: 'notify', title: title, body: body })
  );
}
term.parser.registerOscHandler(9, function(data) {
  // "9;4;..." は ConEmu 進捗レポートであり通知ではない。
  if (!data || data === '4' || data.indexOf('4;') === 0) return true;
  postNotify(null, data);
  return true;
});
term.parser.registerOscHandler(777, function(data) {
  var parts = data.split(';');
  if (parts.length < 3 || parts[0] !== 'notify') return true;
  postNotify(parts[1], parts.slice(2).join(';'));
  return true;
});

// キーボードコピペ
// Ctrl+Shift+C / Ctrl+Alt+C: 選択テキストをコピー
// Ctrl+Shift+V / Ctrl+Alt+V: クリップボードからペースト
// e.preventDefault() でブラウザデフォルト（DevTools 等）を抑止する
term.attachCustomKeyEventHandler(function(e) {
  if (e.type !== 'keydown') return true;
  var key = e.code || '';
  var isC = key === 'KeyC';
  var isV = key === 'KeyV';
  if (!isC && !isV) return true;
  var isCopy    = e.ctrlKey && e.shiftKey && !e.altKey && isC;
  var isCopyAlt = e.ctrlKey && e.altKey && !e.shiftKey && isC;
  var isPaste    = e.ctrlKey && e.shiftKey && !e.altKey && isV;
  var isPasteAlt = e.ctrlKey && e.altKey && !e.shiftKey && isV;
  if (isCopy || isCopyAlt) {
    e.preventDefault();
    if (term.hasSelection()) {
      var text = term.getSelection();
      term.clearSelection();
      window.chrome.webview.postMessage(JSON.stringify({ type: 'copy', text: text }));
    }
    return false;
  }
  if (isPaste || isPasteAlt) {
    e.preventDefault();
    window.chrome.webview.postMessage(JSON.stringify({ type: 'paste' }));
    return false;
  }
  return true;
});

// 右クリック: 選択あり→コピー、選択なし→ペースト（Windows Terminal 慣習）
document.addEventListener('contextmenu', function(e) {
  e.preventDefault();
  if (term.hasSelection()) {
    var text = term.getSelection();
    term.clearSelection();
    window.chrome.webview.postMessage(JSON.stringify({ type: 'copy', text: text }));
  } else {
    window.chrome.webview.postMessage(JSON.stringify({ type: 'paste' }));
  }
});
</script>
</body>
</html>
''';
  }
}
