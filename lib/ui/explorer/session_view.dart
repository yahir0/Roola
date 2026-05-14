import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/skill_runner/skill_run_state.dart';
import 'package:roola/ui/common/session_state_icon.dart';
import 'package:roola/ui/run/adhoc_run_view_model.dart';
import 'package:roola/ui/run/run_view_model.dart';
import 'package:xterm/xterm.dart';

/// xterm 用のロゴ準拠テーマ。`TerminalView` 側で `backgroundOpacity: 0`
/// を指定して描画レイヤーの Container を透過させるため、ここでの
/// `background` は cell 単位の塗りや IME composing 等のフォールバック
/// 用途でのみ使われる。`Color(0x00000000)` を渡すと内部の
/// `withOpacity(1.0)` で alpha が 255 に再付与され opaque black に
/// なってしまうため、必ず非ゼロ alpha の色（ここでは LogoTheme の
/// deep background）を渡すこと。cursor / selection はロゴアクセント
/// ブルー。ANSI 16 色は xterm defaultTheme を継承（VS Code 系配色で
/// Claude Code の出力が崩れない）。
const TerminalTheme _terminalTheme = TerminalTheme(
  cursor: Color(0xFF90C0F0),
  selection: Color(0x665080C0),
  foreground: Color(0xFFE0E0E0),
  background: Color(0xFF1E232A),
  black: Color(0xFF000000),
  red: Color(0xFFCD3131),
  green: Color(0xFF0DBC79),
  yellow: Color(0xFFE5E510),
  blue: Color(0xFF2472C8),
  magenta: Color(0xFFBC3FBC),
  cyan: Color(0xFF11A8CD),
  white: Color(0xFFE5E5E5),
  brightBlack: Color(0xFF666666),
  brightRed: Color(0xFFF14C4C),
  brightGreen: Color(0xFF23D18B),
  brightYellow: Color(0xFFF5F543),
  brightBlue: Color(0xFF3B8EEA),
  brightMagenta: Color(0xFFD670D6),
  brightCyan: Color(0xFF29B8DB),
  brightWhite: Color(0xFFFFFFFF),
  searchHitBackground: Color(0xFFFFFF2B),
  searchHitBackgroundCurrent: Color(0xFF31FF26),
  searchHitForeground: Color(0xFF000000),
);

/// セッション 1 件分のビュー（Scaffold を含まない埋め込み形 widget）。
///
/// ヘッダ行（状態 chip + キャンセル / 再実行 / 閉じる）と、その下の
/// `TerminalView` の縦並び。エクスプローラの body に直接埋め込んで使う。
///
/// 永続エントリと ad-hoc セッションの両方を扱えるよう、`fromEntry` /
/// `fromAdhoc` の 2 つの名前付きコンストラクタを持つ。watch する Provider と
/// 破棄ヘルパーだけ切り替わる。
///
/// PTY 自体は keep-alive provider 側に保持されているので、この widget が
/// dispose されても出力は失われない（再度表示すると復元される）。
class SessionView extends ConsumerWidget {
  const SessionView.fromEntry(String entryId, {this.onClosed, super.key})
    : _entryId = entryId,
      _adhocArgs = null;

  const SessionView.fromAdhoc(AdhocRunArgs args, {this.onClosed, super.key})
    : _entryId = null,
      _adhocArgs = args;

  final String? _entryId;
  final AdhocRunArgs? _adhocArgs;

  /// 閉じるボタン押下時に呼ばれるコールバック。selection をディレクトリ
  /// ビューに戻すなど、呼び出し側の都合に応じて処理する。
  final VoidCallback? onClosed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdhoc = _entryId == null;
    final pageState = isAdhoc
        ? ref.watch(adhocRunViewModelProvider(_adhocArgs!))
        : ref.watch(runViewModelProvider(_entryId));

    final cancelRun = isAdhoc
        ? ref.read(adhocRunViewModelProvider(_adhocArgs!).notifier).cancelRun
        : ref.read(runViewModelProvider(_entryId).notifier).cancelRun;
    final restart = isAdhoc
        ? ref.read(adhocRunViewModelProvider(_adhocArgs!).notifier).restart
        : ref.read(runViewModelProvider(_entryId).notifier).restart;

    return Column(
      children: [
        _SessionHeader(
          title: pageState.entry.displayName,
          state: pageState.runState,
          onCancel: cancelRun,
          onRestart: restart,
          onClose: () {
            final adhocArgs = _adhocArgs;
            final entryId = _entryId;
            if (adhocArgs != null) {
              terminateAdhocSession(ref, adhocArgs);
            } else if (entryId != null) {
              terminateSkillSession(ref, entryId);
            }
            onClosed?.call();
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: TerminalView(
            pageState.runner.terminal,
            theme: _terminalTheme,
            // 内部 Container を完全透過にし、`_AppearanceLayer` の暗幕を
            // そのまま見せる。デフォルトの 1.0 のままだと theme.background
            // の色が opaque で塗られてターミナル領域だけ不透明になる。
            backgroundOpacity: 0,
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }
}

/// セッションビューの上端に置くヘッダ。表示名・状態 chip・操作ボタンを
/// 横一列に並べる。AppBar とは独立して body 内に置くので、AppBar の actions
/// と被らないように軽めの装飾にする。
class _SessionHeader extends StatelessWidget {
  const _SessionHeader({
    required this.title,
    required this.state,
    required this.onCancel,
    required this.onRestart,
    required this.onClose,
  });

  final String title;
  final SkillRunState state;
  final Future<void> Function() onCancel;
  final VoidCallback onRestart;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final isRunning =
        state is SkillRunStarting ||
        state is SkillRunRunning ||
        state is SkillRunWaitingInput;
    final isTerminated =
        state is SkillRunCompleted ||
        state is SkillRunFailed ||
        state is SkillRunCancelled;
    final label = switch (state) {
      SkillRunIdle() => '待機中',
      SkillRunStarting() => '起動中…',
      SkillRunRunning() => '実行中',
      SkillRunWaitingInput() => '入力待ち',
      SkillRunCompleted(:final exitCode) =>
        exitCode == 0 ? '完了 (0)' : '終了 ($exitCode)',
      SkillRunFailed() => '失敗',
      SkillRunCancelled() => 'キャンセル',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Chip(
            avatar: sessionStateAvatar(state),
            label: Text(label),
            visualDensity: VisualDensity.compact,
          ),
          if (isRunning)
            IconButton(
              icon: const Icon(Icons.stop),
              tooltip: 'キャンセル (PTY を終了。出力履歴は残る)',
              onPressed: onCancel,
            ),
          if (isTerminated)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '再実行',
              onPressed: onRestart,
            ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'セッションを閉じる',
            onPressed: onClose,
          ),
          if (state is SkillRunFailed) ...[
            const SizedBox(width: 4),
            Tooltip(
              message: (state as SkillRunFailed).message,
              child: const Icon(Icons.info_outline),
            ),
          ],
        ],
      ),
    );
  }
}
