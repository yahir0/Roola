import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/launcher_entry/launcher_entries_provider.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:roola/ui/launchers/entry_edit_view_model.dart';

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
    tempDir = await Directory.systemTemp.createTemp('roola_evm_');
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

  test('初期 state は OpenHereAction（新規エントリ）', () {
    final state = container.read(entryEditViewModelProvider(null));
    expect(state.action, const LauncherAction.openHere());
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

  test('submit fails validation when working directory does not exist', () async {
    final notifier = container.read(entryEditViewModelProvider(null).notifier);
    notifier
      ..setDisplayName('My App')
      ..setWorkingDirectory('/path/does/not/exist')
      ..setActionType(LauncherActionType.claudeSkill)
      ..setSkillName('demo');
    final ok = await notifier.submit();
    expect(ok, isFalse);
    final state = container.read(entryEditViewModelProvider(null));
    expect(state.errors['workingDirectory'], contains('見つかりません'));
  });

  test('submit succeeds and calls repository.add for new entry (Claude Skill)', () async {
    await container.read(launcherEntriesProvider.future);

    final notifier = container.read(entryEditViewModelProvider(null).notifier);
    notifier
      ..setDisplayName('My App')
      ..setWorkingDirectory(tempDir.path)
      ..setActionType(LauncherActionType.claudeSkill)
      ..setSkillName('demo');
    final ok = await notifier.submit();
    expect(ok, isTrue);
    verify(
      () => repo.add(
        any(
          that: isA<LauncherEntry>().having(
            (e) => e.action,
            'action',
            const LauncherAction.claudeSkill(skillName: 'demo'),
          ),
        ),
      ),
    ).called(1);
  });

  test('submit succeeds for OpenHere action (no command/skillName needed)', () async {
    await container.read(launcherEntriesProvider.future);
    final notifier = container.read(entryEditViewModelProvider(null).notifier);
    notifier
      ..setDisplayName('Just open')
      ..setWorkingDirectory(tempDir.path);
    // setActionType は呼ばない（初期値が OpenHereAction）
    final ok = await notifier.submit();
    expect(ok, isTrue);
    verify(
      () => repo.add(
        any(
          that: isA<LauncherEntry>().having(
            (e) => e.action,
            'action',
            const LauncherAction.openHere(),
          ),
        ),
      ),
    ).called(1);
  });

  test('submit succeeds for RunCommand action', () async {
    await container.read(launcherEntriesProvider.future);
    final notifier = container.read(entryEditViewModelProvider(null).notifier);
    notifier
      ..setDisplayName('Dev Server')
      ..setWorkingDirectory(tempDir.path)
      ..setActionType(LauncherActionType.runCommand)
      ..setCommand('npm run dev');
    final ok = await notifier.submit();
    expect(ok, isTrue);
    verify(
      () => repo.add(
        any(
          that: isA<LauncherEntry>().having(
            (e) => e.action,
            'action',
            const LauncherAction.runCommand(command: 'npm run dev'),
          ),
        ),
      ),
    ).called(1);
  });

  test('RunCommand のコマンドが空ならバリデーションエラーになる', () async {
    final notifier = container.read(entryEditViewModelProvider(null).notifier);
    notifier
      ..setDisplayName('Dev Server')
      ..setWorkingDirectory(tempDir.path)
      ..setActionType(LauncherActionType.runCommand);
    final ok = await notifier.submit();
    expect(ok, isFalse);
    final state = container.read(entryEditViewModelProvider(null));
    expect(state.errors['command'], isNotNull);
  });

  test('ClaudeSkill の Skill 名が空ならバリデーションエラーになる', () async {
    final notifier = container.read(entryEditViewModelProvider(null).notifier);
    notifier
      ..setDisplayName('Skill')
      ..setWorkingDirectory(tempDir.path)
      ..setActionType(LauncherActionType.claudeSkill);
    final ok = await notifier.submit();
    expect(ok, isFalse);
    final state = container.read(entryEditViewModelProvider(null));
    expect(state.errors['skillName'], isNotNull);
  });

  test('動作タイプを切り替えても editedXxx は保持される（戻したら値が復活）', () async {
    final notifier = container.read(entryEditViewModelProvider(null).notifier);
    // RunCommand に値を入れる
    notifier
      ..setActionType(LauncherActionType.runCommand)
      ..setCommand('echo hi')
      ..setKeepShellAfterExit(false);
    // ClaudeSkill に切替えて Skill 名を入れる
    notifier
      ..setActionType(LauncherActionType.claudeSkill)
      ..setSkillName('foo');
    // RunCommand に戻る
    notifier.setActionType(LauncherActionType.runCommand);
    final state = container.read(entryEditViewModelProvider(null));
    final action = state.action;
    expect(action, isA<RunCommandAction>());
    final cmd = action as RunCommandAction;
    expect(cmd.command, 'echo hi');
    expect(cmd.keepShellAfterExit, isFalse);
    // editedSkillName も保持されている
    expect(state.editedSkillName, 'foo');
  });

  test(
    'setWorkingDirectory refreshes availableSkills when path changes',
    () async {
      final repoA = await Directory.systemTemp.createTemp('roola_repo_a_');
      final repoB = await Directory.systemTemp.createTemp('roola_repo_b_');
      addTearDown(() async {
        if (repoA.existsSync()) await repoA.delete(recursive: true);
        if (repoB.existsSync()) await repoB.delete(recursive: true);
      });

      Future<void> seedSkill(Directory dir, String skillName) async {
        final skillDir = Directory('${dir.path}/.claude/skills/$skillName');
        await skillDir.create(recursive: true);
        await File('${skillDir.path}/SKILL.md').writeAsString('# $skillName');
      }

      await seedSkill(repoA, 'alpha');
      await seedSkill(repoB, 'bravo');

      final notifier = container.read(
        entryEditViewModelProvider(null).notifier,
      );

      notifier.setWorkingDirectory(repoA.path);
      expect(container.read(entryEditViewModelProvider(null)).availableSkills, [
        'alpha',
      ]);

      notifier.setWorkingDirectory(repoB.path);
      expect(container.read(entryEditViewModelProvider(null)).availableSkills, [
        'bravo',
      ]);

      notifier.setWorkingDirectory('/path/does/not/exist');
      expect(
        container.read(entryEditViewModelProvider(null)).availableSkills,
        isEmpty,
      );
    },
  );
}
