import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/launcher_entry/launcher_entries_provider.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:roola/data/skill_runner/skill_run_state.dart';
import 'package:roola/data/skill_session/active_sessions.dart';
import 'package:roola/ui/home/active_sessions_strip.dart';

class _MockRepo extends Mock implements LauncherEntryRepository {}

void main() {
  late Directory tempDir;
  late _MockRepo repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_strip_');
    repo = _MockRepo();
    when(() => repo.loadAll()).thenAnswer(
      (_) async => [
        LauncherEntry(
          id: 'a',
          displayName: 'Alpha',
          repositoryPath: '/x',
          skillName: 'skill-a',
          createdAt: DateTime(2026),
        ),
        LauncherEntry(
          id: 'b',
          displayName: 'Bravo',
          repositoryPath: '/y',
          skillName: 'skill-b',
          createdAt: DateTime(2026),
        ),
      ],
    );
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget buildHarness({required ProviderContainer container}) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Scaffold(body: ActiveSessionsStrip()),
            ),
            GoRoute(
              path: '/run/:entryId',
              builder: (_, state) => Scaffold(
                body: Text('run:${state.pathParameters['entryId']}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('renders nothing when no active sessions', (tester) async {
    final container = ProviderContainer(
      overrides: [
        appPathsProvider.overrideWithValue(AppPaths(root: tempDir)),
        launcherEntryRepositoryProvider.overrideWith((ref) => repo),
      ],
    );
    addTearDown(container.dispose);
    await container.read(launcherEntriesProvider.future);

    await tester.pumpWidget(buildHarness(container: container));
    await tester.pump();

    expect(find.byType(InputChip), findsNothing);
  });

  testWidgets('renders chip for each active session', (tester) async {
    final container = ProviderContainer(
      overrides: [
        appPathsProvider.overrideWithValue(AppPaths(root: tempDir)),
        launcherEntryRepositoryProvider.overrideWith((ref) => repo),
      ],
    );
    addTearDown(container.dispose);
    await container.read(launcherEntriesProvider.future);

    container
        .read(activeSessionsProvider.notifier)
        .register(
          entryId: 'a',
          initialState: const SkillRunState.running(),
          cancel: () async {},
        );
    container
        .read(activeSessionsProvider.notifier)
        .register(
          entryId: 'b',
          initialState: const SkillRunState.completed(0),
          cancel: () async {},
        );

    await tester.pumpWidget(buildHarness(container: container));
    await tester.pump();

    expect(find.byType(InputChip), findsNWidgets(2));
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Bravo'), findsOneWidget);
  });

  testWidgets('tapping a chip navigates to /run/:entryId', (tester) async {
    final container = ProviderContainer(
      overrides: [
        appPathsProvider.overrideWithValue(AppPaths(root: tempDir)),
        launcherEntryRepositoryProvider.overrideWith((ref) => repo),
      ],
    );
    addTearDown(container.dispose);
    await container.read(launcherEntriesProvider.future);

    container
        .read(activeSessionsProvider.notifier)
        .register(
          entryId: 'a',
          initialState: const SkillRunState.running(),
          cancel: () async {},
        );

    await tester.pumpWidget(buildHarness(container: container));
    await tester.pump();

    await tester.tap(find.byType(InputChip));
    // PulsingIcon が永久アニメーションするため pumpAndSettle が使えない。
    // GoRouter 遷移は数フレームで完了するため pump を有限回繰り返す。
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('run:a'), findsOneWidget);
  });

  testWidgets('delete icon removes the session from the registry', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        appPathsProvider.overrideWithValue(AppPaths(root: tempDir)),
        launcherEntryRepositoryProvider.overrideWith((ref) => repo),
      ],
    );
    addTearDown(container.dispose);
    await container.read(launcherEntriesProvider.future);

    var cancelCalled = false;
    container
        .read(activeSessionsProvider.notifier)
        .register(
          entryId: 'a',
          initialState: const SkillRunState.cancelled(),
          cancel: () async => cancelCalled = true,
        );

    await tester.pumpWidget(buildHarness(container: container));
    await tester.pump();

    expect(container.read(activeSessionsProvider).containsKey('a'), isTrue);

    // InputChip の deleteIcon (✕) をタップ
    final deleteIcon = find.descendant(
      of: find.byType(InputChip),
      matching: find.byIcon(Icons.close),
    );
    expect(deleteIcon, findsOneWidget);
    await tester.tap(deleteIcon);
    await tester.pump();

    expect(container.read(activeSessionsProvider).containsKey('a'), isFalse);
    // terminate は cancel ハンドルも内部で発火しないシンプル設計なので
    // cancel は呼ばれない（破棄の責務は invalidate 経由の runner.dispose）。
    expect(cancelCalled, isFalse);
  });
}
