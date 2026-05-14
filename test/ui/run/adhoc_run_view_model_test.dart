import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/skill_session/active_sessions.dart';
import 'package:roola/data/terminal_runner/terminal_run_state.dart';
import 'package:roola/ui/run/adhoc_run_view_model.dart';

void main() {
  late Directory tempDir;
  late ProviderContainer container;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_adhoc_');
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'build registers ad-hoc session with displayName label (after microtask)',
    () async {
      final args = AdhocRunArgs(
        adhocId: 'adhoc-1',
        workingDirectory: tempDir.path,
        displayName: '${tempDir.path.split('/').last} (Claude)',
        action: const LauncherAction.runCommand(
          command: 'claude',
          keepShellAfterExit: false,
        ),
      );
      container.read(adhocRunViewModelProvider(args));
      await Future<void>.delayed(Duration.zero);

      final sessions = container.read(activeSessionsProvider);
      expect(sessions.containsKey('adhoc-1'), isTrue);

      final notifier = container.read(activeSessionsProvider.notifier);
      expect(notifier.labelFor('adhoc-1'), args.displayName);
    },
  );

  test('terminateAdhocSession unregisters and invalidates', () async {
    final args = AdhocRunArgs(
      adhocId: 'adhoc-2',
      workingDirectory: tempDir.path,
      displayName: 'foo (Terminal)',
      action: const LauncherAction.openHere(),
    );
    container.read(adhocRunViewModelProvider(args));
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(activeSessionsProvider).containsKey('adhoc-2'),
      isTrue,
    );

    // View 側の terminate に相当する 2 行
    container.read(activeSessionsProvider.notifier).unregister(args.adhocId);
    container.invalidate(adhocRunViewModelProvider(args));

    expect(
      container.read(activeSessionsProvider).containsKey('adhoc-2'),
      isFalse,
    );
  });

  test('build runs failed state when working directory is invalid', () async {
    const args = AdhocRunArgs(
      adhocId: 'adhoc-3',
      workingDirectory: '/path/does/not/exist',
      displayName: 'invalid',
      action: LauncherAction.openHere(),
    );
    container.read(adhocRunViewModelProvider(args));
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final pageState = container.read(adhocRunViewModelProvider(args));
    expect(pageState.runState, isA<SkillRunFailed>());
  });
}
