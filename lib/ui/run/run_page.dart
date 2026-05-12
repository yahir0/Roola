import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:claude_skills_launcher/data/skill_runner/skill_run_state.dart';
import 'package:claude_skills_launcher/data/skill_runner/skill_runner.dart';
import 'package:claude_skills_launcher/ui/run/run_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xterm/xterm.dart';

/// 実行画面。PTY 上で起動した `claude` の出力を xterm に描画し、
/// キー入力を PTY に書き戻すフルターミナル UI。
class RunPage extends HookConsumerWidget {
  const RunPage({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(runViewModelProvider(entryId));
    final viewModel = ref.read(runViewModelProvider(entryId).notifier);
    final terminal = _useWiredTerminal(pageState.runner);

    return Scaffold(
      appBar: AppBar(
        title: Text(pageState.entry.displayName),
        actions: [
          _StateBadge(state: pageState.runState),
          _ActionButtons(
            state: pageState.runState,
            onCancel: viewModel.cancelRun,
            onRestart: viewModel.restart,
            onBackHome: () async {
              await viewModel.cancelRun();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: TerminalView(terminal, padding: const EdgeInsets.all(8)),
      ),
    );
  }

  /// `Terminal` を 1 つ生成し、`SkillRunner` と双方向に配線する Hook。
  ///
  /// - PTY 出力 → terminal.write
  /// - terminal.onOutput → PTY.write
  /// - terminal.onResize → PTY.resize
  Terminal _useWiredTerminal(SkillRunner runner) {
    final terminal = useMemoized(Terminal.new, [runner]);

    useEffect(() {
      final outputSub = runner.output.listen((bytes) {
        terminal.write(utf8.decode(bytes, allowMalformed: true));
      });
      terminal.onOutput = (data) {
        runner.write(Uint8List.fromList(utf8.encode(data)));
      };
      terminal.onResize = (cols, rows, _, _) {
        runner.resize(cols: cols, rows: rows);
      };
      return () {
        outputSub.cancel();
        terminal.onOutput = null;
        terminal.onResize = null;
      };
    }, [runner, terminal]);

    return terminal;
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({required this.state});

  final SkillRunState state;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (state) {
      SkillRunIdle() => ('待機中', Colors.grey, Icons.hourglass_empty),
      SkillRunStarting() => ('起動中…', Colors.blue, Icons.play_circle_outline),
      SkillRunRunning() => ('実行中', Colors.green, Icons.circle),
      SkillRunCompleted(:final exitCode) =>
        exitCode == 0
            ? ('完了 (0)', Colors.green, Icons.check_circle)
            : ('終了 ($exitCode)', Colors.orange, Icons.warning),
      SkillRunFailed() => ('失敗', Colors.red, Icons.error),
      SkillRunCancelled() => ('キャンセル', Colors.grey, Icons.stop_circle),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Chip(
        avatar: Icon(icon, size: 16, color: color),
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
  });

  final SkillRunState state;
  final Future<void> Function() onCancel;
  final VoidCallback onRestart;
  final Future<void> Function() onBackHome;

  @override
  Widget build(BuildContext context) {
    final isRunning = state is SkillRunStarting || state is SkillRunRunning;
    return Row(
      children: [
        if (isRunning)
          IconButton(
            icon: const Icon(Icons.stop),
            tooltip: 'キャンセル',
            onPressed: onCancel,
          ),
        if (!isRunning)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '再実行',
            onPressed: onRestart,
          ),
        IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'ホームへ戻る',
          onPressed: onBackHome,
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
