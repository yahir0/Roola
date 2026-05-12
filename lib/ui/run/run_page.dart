import 'package:claude_skills_launcher/data/skill_runner/skill_run_state.dart';
import 'package:claude_skills_launcher/ui/common/session_state_icon.dart';
import 'package:claude_skills_launcher/ui/run/run_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xterm/xterm.dart';

/// 実行画面。PTY 上で起動した `claude` の出力を xterm に描画し、
/// キー入力を PTY に書き戻すフルターミナル UI。Terminal インスタンスは
/// `SkillRunner` 側で保有しているため、ホーム遷移などで widget が破棄
/// されてもスクロールバックは保持される。
class RunPage extends HookConsumerWidget {
  const RunPage({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(runViewModelProvider(entryId));
    final viewModel = ref.read(runViewModelProvider(entryId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(pageState.entry.displayName),
        actions: [
          _StateBadge(state: pageState.runState),
          _ActionButtons(
            state: pageState.runState,
            onCancel: viewModel.cancelRun,
            onRestart: viewModel.restart,
            onBackHome: () {
              // セッションは保持したまま、ホームへ戻るだけ
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            onClose: () {
              terminateSkillSession(ref, entryId);
              context.go('/');
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: TerminalView(
          pageState.runner.terminal,
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({required this.state});

  final SkillRunState state;

  @override
  Widget build(BuildContext context) {
    final label = switch (state) {
      SkillRunIdle() => '待機中',
      SkillRunStarting() => '起動中…',
      SkillRunRunning() => '実行中',
      SkillRunCompleted(:final exitCode) =>
        exitCode == 0 ? '完了 (0)' : '終了 ($exitCode)',
      SkillRunFailed() => '失敗',
      SkillRunCancelled() => 'キャンセル',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Chip(
        avatar: sessionStateAvatar(state),
        label: Text(label),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.state,
    required this.onCancel,
    required this.onRestart,
    required this.onBackHome,
    required this.onClose,
  });

  final SkillRunState state;
  final Future<void> Function() onCancel;
  final VoidCallback onRestart;
  final VoidCallback onBackHome;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final isRunning = state is SkillRunStarting || state is SkillRunRunning;
    final isTerminated =
        state is SkillRunCompleted ||
        state is SkillRunFailed ||
        state is SkillRunCancelled;

    return Row(
      children: [
        if (isRunning)
          IconButton(
            icon: const Icon(Icons.stop),
            tooltip: 'キャンセル (PTY を終了。出力履歴は残ります)',
            onPressed: onCancel,
          ),
        if (isTerminated)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '再実行',
            onPressed: onRestart,
          ),
        IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'ホームへ戻る (セッションは保持されます)',
          onPressed: onBackHome,
        ),
        if (isTerminated)
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'セッションを閉じる',
            onPressed: onClose,
          ),
        if (state is SkillRunFailed) ...[
          const SizedBox(width: 8),
          Tooltip(
            message: (state as SkillRunFailed).message,
            child: const Icon(Icons.info_outline),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }
}
