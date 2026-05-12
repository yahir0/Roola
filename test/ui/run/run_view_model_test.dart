import 'dart:io';

import 'package:claude_skills_launcher/core/storage/app_paths.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entries_provider.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry_repository.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:claude_skills_launcher/data/skill_runner/skill_run_state.dart';
import 'package:claude_skills_launcher/data/skill_session/active_sessions.dart';
import 'package:claude_skills_launcher/ui/run/run_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class _MockLauncherEntryRepository extends Mock
    implements LauncherEntryRepository {}

void main() {
  late Directory tempDir;
  late _MockLauncherEntryRepository repo;
  late LauncherEntry sampleEntry;
  late ProviderContainer container;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cskl_rvm_');
    sampleEntry = LauncherEntry(
      id: 'a',
      displayName: 'Sample',
      repositoryPath: '/path/does/not/exist',
      skillName: 'demo',
      createdAt: DateTime(2026),
    );

    repo = _MockLauncherEntryRepository();
    when(() => repo.loadAll()).thenAnswer((_) async => [sampleEntry]);

    container = ProviderContainer(
      overrides: [
        appPathsProvider.overrideWithValue(AppPaths(root: tempDir)),
        launcherEntryRepositoryProvider.overrideWith((ref) => repo),
      ],
    );
    addTearDown(container.dispose);

    // 永続化からの初期ロード完了まで待つ
    await container.read(launcherEntriesProvider.future);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'build registers session into ActiveSessions (after microtask)',
    () async {
      container.read(runViewModelProvider('a'));
      // register は build 後の microtask で走る
      await Future<void>.delayed(Duration.zero);
      final sessions = container.read(activeSessionsProvider);
      expect(sessions.containsKey('a'), isTrue);
    },
  );

  test(
    'runner reflects failed state when repository path is invalid',
    () async {
      container.read(runViewModelProvider('a'));
      // microtask の register + start を進める
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      final state = container.read(runViewModelProvider('a'));
      expect(state.runState, isA<SkillRunFailed>());
      final sessions = container.read(activeSessionsProvider);
      expect(sessions['a'], isA<SkillRunFailed>());
    },
  );

  test('close flow (unregister + invalidate) drops session', () async {
    container.read(runViewModelProvider('a').notifier);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(activeSessionsProvider).containsKey('a'), isTrue);

    // View 側「閉じる」ボタン相当の 2 行
    container.read(activeSessionsProvider.notifier).unregister('a');
    container.invalidate(runViewModelProvider('a'));

    expect(container.read(activeSessionsProvider).containsKey('a'), isFalse);
  });

  test('cancelRun does not unregister (session remains)', () async {
    final notifier = container.read(runViewModelProvider('a').notifier);
    // 存在しないディレクトリなので start は failed に至る
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    await notifier.cancelRun();
    // cancel は終了済み状態では no-op だが、いずれにせよ unregister は呼ばれない
    expect(container.read(activeSessionsProvider).containsKey('a'), isTrue);
  });
}
