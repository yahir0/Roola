import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:roola/data/terminal_runner/terminal_channel.dart';
import 'package:roola/data/terminal_runner/terminal_runner.dart';

/// SwiftTerm（ネイティブ macOS NSView）を `AppKitView` プラットフォームビュー
/// としてホストするターミナル面（ADR-0031）。
///
/// 描画・入力は SwiftTerm が担い、本 widget は PTY（[TerminalRunner]）と
/// ネイティブビューを [TerminalChannel] で配線するだけ:
///
/// - PTY 出力（[TerminalRunner.output]）を購読し、`channel.feed` で native へ
/// - native からのユーザー入力を `runner.write` へ
/// - native からのサイズ変更を `runner.resize` へ
///
/// [runner] は `adhocRunViewModelProvider` 側で keep-alive 保持されるため、
/// 本 widget の dispose では runner は破棄せず、チャネル配線のみ解放する。
class TerminalSurface extends StatefulWidget {
  const TerminalSurface({
    required this.channelId,
    required this.runner,
    super.key,
  });

  /// チャネル名のベース（ad-hoc セッション id）。実際のチャネル名は
  /// マウントごとに一意化される（[_TerminalSurfaceState] 参照）。
  final String channelId;

  /// 描画対象の PTY セッション。
  final TerminalRunner runner;

  @override
  State<TerminalSurface> createState() => _TerminalSurfaceState();
}

class _TerminalSurfaceState extends State<TerminalSurface> {
  /// SwiftTerm ホスト NSView の `AppKitView` viewType（native 側の
  /// `NSViewFactory` 登録 id と一致させる）。
  static const _viewType = 'roola/terminal-view';

  /// プロセス内で TerminalSurface のマウントごとに一意な連番。
  ///
  /// タブをペイン間 DnD 移動すると本 widget は remount され、移動の瞬間に
  /// 新旧 2 つの `TerminalSurface` が一瞬共存する。チャネル名を
  /// [TerminalSurface.channelId] 固定にすると新旧が同名チャネルを奪い合い、
  /// 古い側の `dispose`（`setMessageHandler(null)`）が新しい側のハンドラを
  /// 解除してしまう（移動先のターミナルが描画も入力も受け付けなくなる）。
  /// マウントごとに一意な id を使ってこの衝突を防ぐ。
  static int _mountSeq = 0;

  /// 本マウント固有のチャネル名（`<channelId>#<連番>`）。
  late final String _channelName;
  late final TerminalChannel _channel;
  StreamSubscription<Uint8List>? _outputSub;

  @override
  void initState() {
    super.initState();
    _channelName = '${widget.channelId}#${_mountSeq++}';
    _channel = TerminalChannel(_channelName)
      ..onInput = widget.runner.write
      ..onResize = (cols, rows) => widget.runner.resize(cols: cols, rows: rows);
    // プラットフォームビュー生成前の出力は TerminalChannel がバッファする
    // ため、購読は initState の時点で開始してよい。
    _outputSub = widget.runner.output.listen(_channel.feed);
  }

  void _onPlatformViewCreated(int id) {
    // native の NSViewFactory がチャネルハンドラを登録し終えた後。
    // バッファ済みの PTY 出力をここで flush する。
    _channel.markReady();
  }

  @override
  void dispose() {
    _outputSub?.cancel();
    _channel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppKitView(
      viewType: _viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: <String, String>{'channelId': _channelName},
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onPlatformViewCreated,
    );
  }
}
