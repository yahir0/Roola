import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/skill_session/active_sessions.dart';
import 'package:roola/data/skill_session/adhoc_run_args.dart';
import 'package:roola/data/task_notification/notification_environment.dart';
import 'package:roola/data/task_notification/notify_token.dart';
import 'package:roola/data/terminal_runner/pty_terminal_runner.dart';
import 'package:roola/data/terminal_runner/terminal_run_state.dart';
import 'package:roola/data/terminal_runner/terminal_runner.dart';
import 'package:roola/data/terminal_runner/windows_shell.dart';
import 'package:roola/data/terminal_settings/terminal_settings_repository_impl.dart';

export 'package:roola/data/skill_session/adhoc_run_args.dart';

part 'adhoc_run_view_model.g.dart';

/// ターミナルセッションの表示用 State（表示名・実行状態・runner 参照）。
///
/// ワークスペースのターミナルタブはすべて ad-hoc セッションに正規化されて
/// いる（ADR-0026 design Decision 5）。`entry` は表示名取得のための
/// 軽量ラッパで、永続化された `LauncherEntry` とは限らない。
class RunPageState {
  RunPageState({
    required this.entry,
    required this.runState,
    required this.runner,
  });

  final LauncherEntry entry;
  final SkillRunState runState;
  final TerminalRunner runner;
}

/// ターミナルタブ 1 つ分の ViewModel（`family(AdhocRunArgs)` / keepAlive）。
///
/// build() で `PtyTerminalRunner` を 1 つ生成し、`ActiveSessions` に登録した
/// うえで状態 Stream を購読しながらプロセスを start する。keepAlive のため、
/// タブを別ペインへ DnD 移動して widget が remount されても PTY と出力履歴
/// は保持される。破棄はタブを閉じたときに `Workspace.closeTab` から明示
/// invalidate される。
///
/// 動作タイプの分岐は `args.action`（`LauncherAction`）に統合されており、
/// runner 構築は `PtyTerminalRunner.fromAction` が一括で処理する（ADR-0016）。
@Riverpod(keepAlive: true)
class AdhocRunViewModel extends _$AdhocRunViewModel {
  @override
  RunPageState build(AdhocRunArgs args) {
    final windowsShell = args.windowsShell
        ?? ref.read(terminalSettingsProvider).value?.windowsShell
        ?? WindowsShell.powershell;
    final runner = PtyTerminalRunner.fromAction(
      workingDirectory: args.workingDirectory,
      action: args.action,
      environment: notificationEnvironment(
        action: args.action,
        tabId: args.adhocId,
        token: ref.read(notifyTokenProvider),
      ),
      windowsShell: windowsShell,
    );
    final entry = LauncherEntry(
      id: args.adhocId,
      displayName: args.displayName,
      workingDirectory: args.workingDirectory,
      action: args.action,
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

  /// 再実行。同じ args で provider を作り直す。
  void restart() => ref.invalidateSelf();
}
