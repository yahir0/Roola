import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:roola/data/launcher_entry/launcher_entries_provider.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/skill_runner/pty_skill_runner.dart';
import 'package:roola/data/skill_runner/skill_run_state.dart';
import 'package:roola/data/skill_runner/skill_runner.dart';
import 'package:roola/data/skill_session/active_sessions.dart';

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
/// build() で PtySkillRunner を 1 つ生成し、`session-registry` に登録した
/// うえで状態 Stream を購読しながらプロセスを start する。
/// keepAlive のため、実行画面ウィジェットの離脱後もインスタンスは維持され、
/// 明示的な `close()` か `restart()` まで生存する。
@Riverpod(keepAlive: true)
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

    final registry = ref.read(activeSessionsProvider.notifier);

    late final StreamSubscription<SkillRunState> sub;
    sub = runner.state.listen((next) {
      state = RunPageState(entry: entry, runState: next, runner: runner);
      registry.updateState(entryId, next);
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
        entryId: entryId,
        initialState: runner.currentState,
        cancel: runner.cancel,
      );
      runner.start();
    });

    return RunPageState(
      entry: entry,
      runState: runner.currentState,
      runner: runner,
    );
  }

  /// 実行中の PTY を SIGTERM で終了する。Terminal とセッションは保持される。
  Future<void> cancelRun() => state.runner.cancel();

  /// 再実行（既存 runner を dispose して新しい runner を生成）。
  void restart() => ref.invalidateSelf();

  // セッションの明示破棄（「閉じる」操作）は keepAlive provider を自身から
  // invalidate できない Riverpod 3.x の制約のため、View 側で
  // `terminateSkillSession` ヘルパー（unregister + invalidate）を呼ぶ。
  // `runner.dispose()` は invalidate 経由で `ref.onDispose` から発火する。
}

/// セッションを完全破棄するための View 用ヘルパー。
///
/// `RunPage` の「閉じる」ボタンと、ホームの session chip の ✕ ボタンの
/// 双方から呼ばれる。`ActiveSessions` から除去 → `runViewModelProvider`
/// invalidate の 2 段で、PTY 終了と Terminal 解放を含めて完了する。
void terminateSkillSession(WidgetRef ref, String entryId) {
  ref.read(activeSessionsProvider.notifier).unregister(entryId);
  ref.invalidate(runViewModelProvider(entryId));
}
