import 'package:claude_skills_launcher/app/router.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entries_provider.dart';
import 'package:claude_skills_launcher/data/skill_runner/skill_run_state.dart';
import 'package:claude_skills_launcher/data/skill_session/active_sessions.dart';
import 'package:claude_skills_launcher/ui/common/session_state_icon.dart';
import 'package:claude_skills_launcher/ui/run/adhoc_run_view_model.dart';
import 'package:claude_skills_launcher/ui/run/run_view_model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// ホーム画面上部に実行中・終了済みセッションを横並びで表示するストリップ。
///
/// セッションが 0 件のときは縦方向のスペースを占有しない。
class ActiveSessionsStrip extends ConsumerWidget {
  const ActiveSessionsStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(activeSessionsProvider);
    if (sessions.isEmpty) {
      return const SizedBox.shrink();
    }
    final entries = ref.watch(launcherEntriesProvider).value ?? const [];

    final registry = ref.read(activeSessionsProvider.notifier);
    final chips = <Widget>[];
    for (final session in sessions.entries) {
      final entry = entries.where((e) => e.id == session.key).firstOrNull;
      if (entry != null) {
        chips.add(
          _SessionChip(
            entryId: session.key,
            label: entry.displayName,
            state: session.value,
          ),
        );
        continue;
      }
      // 永続エントリに無ければ ad-hoc セッションの可能性。
      final adhocArgs = registry.adhocArgsFor(session.key);
      if (adhocArgs != null) {
        chips.add(_AdhocSessionChip(args: adhocArgs, state: session.value));
      }
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: chips.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) => chips[i],
        ),
      ),
    );
  }
}

class _SessionChip extends ConsumerWidget {
  const _SessionChip({
    required this.entryId,
    required this.label,
    required this.state,
  });

  final String entryId;
  final String label;
  final SkillRunState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // InputChip は onPressed (タップで遷移) と onDeleted (✕ で破棄) を
    // 同時に持てる Chip 派生。chip 自体のタップで RunRoute へ go し、
    // ✕ で `terminateSkillSession` を呼ぶ。
    return InputChip(
      avatar: sessionStateAvatar(state),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      onPressed: () => RunRoute(entryId: entryId).push<void>(context),
      deleteIcon: const Icon(Icons.close, size: 16),
      deleteButtonTooltipMessage: 'セッションを完全に破棄',
      onDeleted: () => terminateSkillSession(ref, entryId),
    );
  }
}

class _AdhocSessionChip extends ConsumerWidget {
  const _AdhocSessionChip({required this.args, required this.state});

  final AdhocRunArgs args;
  final SkillRunState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InputChip(
      avatar: sessionStateAvatar(state),
      label: Text(args.displayName),
      visualDensity: VisualDensity.compact,
      onPressed: () => RunAdhocRoute(
        adhocId: args.adhocId,
        $extra: args,
      ).push<void>(context),
      deleteIcon: const Icon(Icons.close, size: 16),
      deleteButtonTooltipMessage: 'セッションを完全に破棄',
      onDeleted: () => terminateAdhocSession(ref, args),
    );
  }
}
