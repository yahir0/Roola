import 'dart:async';

import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry.dart';
import 'package:claude_skills_launcher/data/skill_runner/pty_skill_runner.dart';
import 'package:claude_skills_launcher/data/skill_runner/skill_run_state.dart';
import 'package:claude_skills_launcher/data/skill_session/active_sessions.dart';
import 'package:claude_skills_launcher/data/skill_session/adhoc_run_args.dart';
import 'package:claude_skills_launcher/ui/run/run_view_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:claude_skills_launcher/data/skill_session/adhoc_run_args.dart';

part 'adhoc_run_view_model.g.dart';

/// エクスプローラ右クリックから起動する一時セッションの ViewModel。
///
/// 永続エントリを持たない（`launcherEntriesProvider` に乗らない）点が
/// `RunViewModel` との違い。`ActiveSessions` には `adhocLabel` 付きで
/// 登録され、chip 列での表示名はそこから fallback で取得される。
/// 設計の背景は ADR-0009 を参照。
@Riverpod(keepAlive: true)
class AdhocRunViewModel extends _$AdhocRunViewModel {
  @override
  RunPageState build(AdhocRunArgs args) {
    final runner = PtySkillRunner(
      repositoryPath: args.repositoryPath,
      skillName: args.skillName,
    );
    final entry = LauncherEntry(
      id: args.adhocId,
      displayName: args.displayName,
      repositoryPath: args.repositoryPath,
      skillName: args.skillName,
      createdAt: DateTime.now(),
    );

    final registry = ref.read(activeSessionsProvider.notifier);

    late final StreamSubscription<SkillRunState> sub;
    sub = runner.state.listen((next) {
      state = RunPageState(entry: entry, runState: next, runner: runner);
      registry.updateState(args.adhocId, next);
    });

    ref.onDispose(() async {
      await sub.cancel();
      await runner.dispose();
    });

    // build 中に他 provider を modify することは Riverpod 3.x の規約違反
    // （`_debugCurrentlyBuildingElement` assert）になるため、register と
    // start は build 完了後の microtask で実行する。
    Future.microtask(() {
      registry.register(
        entryId: args.adhocId,
        initialState: runner.currentState,
        cancel: runner.cancel,
        adhocArgs: args,
      );
      runner.start();
    });

    return RunPageState(
      entry: entry,
      runState: runner.currentState,
      runner: runner,
    );
  }

  /// PTY を SIGTERM で終了する。chip と出力履歴は保持される。
  Future<void> cancelRun() => state.runner.cancel();

  /// 再実行。同じ args で provider を作り直す。
  void restart() => ref.invalidateSelf();
}

/// ad-hoc セッションの明示破棄。`launcherEntriesProvider` を触らない以外は
/// 永続版 `terminateSkillSession` と同じ責務。
void terminateAdhocSession(WidgetRef ref, AdhocRunArgs args) {
  ref.read(activeSessionsProvider.notifier).unregister(args.adhocId);
  ref.invalidate(adhocRunViewModelProvider(args));
}
