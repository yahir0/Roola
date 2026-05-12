import 'dart:io';

import 'package:claude_skills_launcher/core/storage/app_paths.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entries_provider.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry_repository.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:claude_skills_launcher/ui/settings/entry_edit_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class _MockLauncherEntryRepository extends Mock
    implements LauncherEntryRepository {}

class _FakeLauncherEntry extends Fake implements LauncherEntry {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeLauncherEntry());
  });

  late Directory tempDir;
  late _MockLauncherEntryRepository repo;
  late ProviderContainer container;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cskl_evm_');
    repo = _MockLauncherEntryRepository();
    when(() => repo.loadAll()).thenAnswer((_) async => const []);
    when(() => repo.add(any())).thenAnswer((_) async {});
    when(() => repo.update(any())).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        appPathsProvider.overrideWithValue(AppPaths(root: tempDir)),
        launcherEntryRepositoryProvider.overrideWith((ref) => repo),
      ],
    );
    addTearDown(container.dispose);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'submit returns false when required fields are empty (new entry)',
    () async {
      final notifier = container.read(
        entryEditViewModelProvider(null).notifier,
      );
      final ok = await notifier.submit();
      expect(ok, isFalse);
      final state = container.read(entryEditViewModelProvider(null));
      expect(state.errors, isNotEmpty);
      expect(state.errors.containsKey('displayName'), isTrue);
    },
  );

  test('submit fails validation when repository path does not exist', () async {
    final notifier = container.read(entryEditViewModelProvider(null).notifier);
    notifier
      ..setDisplayName('My App')
      ..setRepositoryPath('/path/does/not/exist')
      ..setSkillName('demo');
    final ok = await notifier.submit();
    expect(ok, isFalse);
    final state = container.read(entryEditViewModelProvider(null));
    expect(state.errors['repositoryPath'], contains('見つかりません'));
  });

  test('submit succeeds and calls repository.add for new entry', () async {
    // ロード完了を待ってから notifier を取得する。
    await container.read(launcherEntriesProvider.future);

    final notifier = container.read(entryEditViewModelProvider(null).notifier);
    notifier
      ..setDisplayName('My App')
      ..setRepositoryPath(tempDir.path)
      ..setSkillName('demo');
    final ok = await notifier.submit();
    expect(ok, isTrue);
    verify(() => repo.add(any())).called(1);
  });

  test(
    'setRepositoryPath refreshes availableSkills when path changes',
    () async {
      final repoA = await Directory.systemTemp.createTemp('cskl_repo_a_');
      final repoB = await Directory.systemTemp.createTemp('cskl_repo_b_');
      addTearDown(() async {
        if (repoA.existsSync()) await repoA.delete(recursive: true);
        if (repoB.existsSync()) await repoB.delete(recursive: true);
      });

      Future<void> seedSkill(Directory repo, String skillName) async {
        final dir = Directory('${repo.path}/.claude/skills/$skillName');
        await dir.create(recursive: true);
        await File('${dir.path}/SKILL.md').writeAsString('# $skillName');
      }

      await seedSkill(repoA, 'alpha');
      await seedSkill(repoB, 'bravo');

      final notifier = container.read(
        entryEditViewModelProvider(null).notifier,
      );

      notifier.setRepositoryPath(repoA.path);
      expect(container.read(entryEditViewModelProvider(null)).availableSkills, [
        'alpha',
      ]);

      notifier.setRepositoryPath(repoB.path);
      expect(container.read(entryEditViewModelProvider(null)).availableSkills, [
        'bravo',
      ]);

      notifier.setRepositoryPath('/path/does/not/exist');
      expect(
        container.read(entryEditViewModelProvider(null)).availableSkills,
        isEmpty,
      );
    },
  );
}
