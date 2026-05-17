import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/terminal_runner/terminal_run_state.dart';
import 'package:roola/ui/common/session_state_icon.dart';
import 'package:roola/ui/explorer/terminal_surface.dart';
import 'package:roola/ui/run/adhoc_run_view_model.dart';

/// ターミナルセッション 1 件分のビュー（ターミナルタブの body）。
///
/// ヘッダ行（状態 chip + キャンセル / 再実行）と、その下の SwiftTerm
/// ネイティブビュー（[TerminalSurface]）の縦並び。タブを閉じる操作はタブ
/// ストリップの × が担うため、ここには閉じるボタンを置かない（ADR-0026）。
///
/// 描画・入力は SwiftTerm（ネイティブ NSView）が担う（ADR-0031）。配色・
/// フォントは native 側（`TerminalView` ファクトリ）に定義する。
///
/// PTY は `adhocRunViewModelProvider` 側で keep-alive 保持されるので、この
/// widget が dispose されても出力は失われない。
class SessionView extends ConsumerWidget {
  const SessionView(this.args, {super.key});

  final AdhocRunArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(adhocRunViewModelProvider(args));
    final notifier = ref.read(adhocRunViewModelProvider(args).notifier);

    return Column(
      children: [
        _SessionHeader(
          title: pageState.entry.displayName,
          state: pageState.runState,
          onCancel: notifier.cancelRun,
          onRestart: notifier.restart,
        ),
        const Divider(height: 1),
        Expanded(
          child: TerminalSurface(
            // ad-hoc セッション id をタブ固有のチャネル id として使う。
            channelId: args.adhocId,
            runner: pageState.runner,
          ),
        ),
      ],
    );
  }
}

/// セッションビューの上端に置くヘッダ。表示名・状態 chip・操作ボタンを
/// 横一列に並べる。
class _SessionHeader extends StatelessWidget {
  const _SessionHeader({
    required this.title,
    required this.state,
    required this.onCancel,
    required this.onRestart,
  });

  final String title;
  final SkillRunState state;
  final Future<void> Function() onCancel;
  final VoidCallback onRestart;

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
