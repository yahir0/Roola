import 'dart:async';

import 'package:claude_skills_launcher/data/launcher_entry/launcher_entries_provider.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry.dart';
import 'package:claude_skills_launcher/data/skill_runner/pty_skill_runner.dart';
import 'package:claude_skills_launcher/data/skill_runner/skill_run_state.dart';
import 'package:claude_skills_launcher/data/skill_runner/skill_runner.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_view_model.g.dart';

/// 実行画面の表示用 State（表示名・実行状態・SkillRunner 参照）。
class RunPageState {
  RunPageState({
    required this.entry,
    required this.runState,
    required this.runner,
  });

  final LauncherEntry entry;
  final SkillRunState runState;
  final SkillRunner runner;
}

/// `RunPage` 用 ViewModel。
///
/// build() で PtySkillRunner を 1 つ生成し、状態 Stream を購読しながら
/// プロセスを start する。再実行は `ref.invalidateSelf` 経由で全体を作り直す。
@riverpod
class RunViewModel extends _$RunViewModel {
  @override
  RunPageState build(String entryId) {
    final entries = ref.read(launcherEntriesProvider).value ?? const [];
    final entry = entries.firstWhere(
      (e) => e.id == entryId,
      orElse: () => throw StateError('Entry not found: $entryId'),
    );
    final runner = PtySkillRunner(
      repositoryPath: entry.repositoryPath,
      skillName: entry.skillName,
    );

    late final StreamSubscription<SkillRunState> sub;
    sub = runner.state.listen((next) {
      state = RunPageState(entry: entry, runState: next, runner: runner);
    });

    ref.onDispose(() async {
      await sub.cancel();
      await runner.cancel();
    });

    // 起動を 1 度だけトリガする（start は idempotent）。
    Future.microtask(runner.start);

    return RunPageState(
      entry: entry,
      runState: runner.currentState,
      runner: runner,
    );
  }

  /// 再実行（Provider を invalidate して新しい runner を生成）。
  void restart() => ref.invalidateSelf();

  /// プロセスをキャンセルする（離脱時に呼ぶ）。
  Future<void> cancelRun() => state.runner.cancel();
}
