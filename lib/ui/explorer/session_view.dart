import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/terminal_runner/terminal_run_state.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/session_state_icon.dart';
import 'package:roola/ui/explorer/terminal_surface.dart';
import 'package:roola/ui/run/adhoc_run_view_model.dart';

/// ターミナルセッション 1 件分のビュー（ターミナルタブの body）。
///
/// ヘッダ行（状態 chip + 再実行）と、その下の SwiftTerm ネイティブビュー
/// （[TerminalSurface]）の縦並び。ターミナルの終了はタブストリップの × に
/// 一本化しているため、ここには閉じる / 停止ボタンを置かない（ADR-0026）。
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
    required this.onRestart,
  });

  final String title;
  final SkillRunState state;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final isTerminated =
        state is SkillRunCompleted ||
        state is SkillRunFailed ||
        state is SkillRunCancelled;
    final l10n = AppLocalizations.of(context);
    final label = switch (state) {
      SkillRunIdle() => l10n.sessionStateIdle,
      SkillRunStarting() => l10n.sessionStateStarting,
      SkillRunRunning() => l10n.sessionStateRunning,
      SkillRunWaitingInput() => l10n.sessionStateWaitingInput,
      SkillRunCompleted(:final exitCode) =>
        exitCode == 0
            ? l10n.sessionStateCompleted(0)
            : l10n.sessionStateExited(exitCode),
      SkillRunFailed() => l10n.sessionStateFailed,
      SkillRunCancelled() => l10n.sessionStateCancelled,
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
            avatar: sessionStateAvatar(PolarisTokens.of(context), state),
            label: Text(label),
            visualDensity: VisualDensity.compact,
          ),
          if (isTerminated)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: AppLocalizations.of(context).sessionRerunTooltip,
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
