import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/terminal_runner/terminal_runner.dart';
import 'package:webview_windows/webview_windows.dart';

/// Windows 専用: xterm.js を WebView2 に埋め込んだターミナル面（ADR-0058 D1）。
///
/// PTY 出力（[TerminalRunner.output]）を base64 エンコードして
/// JS の `term_write(data)` に渡し xterm.js に描画させる。
/// ユーザー入力は xterm.js の `onData` → WebView message → [TerminalRunner.write]。
/// リサイズは ResizeObserver 経由で xterm.js → WebView message → [TerminalRunner.resize]。
class TerminalSurfaceWindows extends ConsumerStatefulWidget {
  const TerminalSurfaceWindows({
    required this.runner,
    super.key,
  });

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
    final fitJs = await rootBundle.loadString('assets/js/xterm/xterm-addon-fit.js');

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
      }
    } catch (_) {
      // JSON パース失敗は無視する。
    }
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

  static String _buildHtml(
    String xtermJs,
    String xtermCss,
    String fitJs,
  ) {
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

// キーボードショートカット（Windows Terminal 慣習）
// Ctrl+Shift+C: 選択テキストをコピー
// Ctrl+Shift+V: クリップボードからペースト
term.attachCustomKeyEventHandler(function(e) {
  if (e.type !== 'keydown') return true;
  if (e.ctrlKey && e.shiftKey && !e.altKey) {
    if (e.code === 'KeyC') {
      if (term.hasSelection()) {
        var text = term.getSelection();
        term.clearSelection();
        window.chrome.webview.postMessage(JSON.stringify({ type: 'copy', text: text }));
      }
      return false;
    }
    if (e.code === 'KeyV') {
      window.chrome.webview.postMessage(JSON.stringify({ type: 'paste' }));
      return false;
    }
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
