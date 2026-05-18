import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/launchers/entry_edit_page.dart';
import 'package:roola/ui/launchers/entry_edit_view_model.dart';

class _MockLauncherEntryRepository extends Mock
    implements LauncherEntryRepository {}

class _FakeLauncherEntry extends Fake implements LauncherEntry {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeLauncherEntry());
  });

  late Directory tempDir;
  late Directory repoA;
  late Directory repoB;
  late _MockLauncherEntryRepository repo;

  Future<void> seedSkill(Directory repo, String skillName) async {
    final dir = Directory('${repo.path}/.claude/skills/$skillName');
    await dir.create(recursive: true);
    await File('${dir.path}/SKILL.md').writeAsString('# $skillName');
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_eep_');
    repoA = await Directory.systemTemp.createTemp('roola_eep_a_');
    repoB = await Directory.systemTemp.createTemp('roola_eep_b_');
    await seedSkill(repoA, 'alpha');
    await seedSkill(repoB, 'bravo');

    repo = _MockLauncherEntryRepository();
    when(() => repo.loadAll()).thenAnswer((_) async => const []);
    when(() => repo.add(any())).thenAnswer((_) async {});
    when(() => repo.update(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    for (final d in [tempDir, repoA, repoB]) {
      if (d.existsSync()) {
        await d.delete(recursive: true);
      }
    }
  });

  testWidgets(
    'PopupMenuButton items reflect availableSkills when path changes twice',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appPathsProvider.overrideWithValue(AppPaths(root: tempDir)),
            launcherEntryRepositoryProvider.overrideWith((ref) => repo),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('ja'),
            home: EntryEditPage(entryId: null),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 直接 ViewModel を介して 1 回目のパスを設定
      final container = ProviderScope.containerOf(
        tester.element(find.byType(EntryEditPage)),
      );
      final notifier = container.read(
        entryEditViewModelProvider(null).notifier,
      );

      // Skill 候補プルダウンは ClaudeSkill セグメント配下にしか出ない
      // ので、まずアクションタイプを切り替える。
      notifier.setActionType(LauncherActionType.claudeSkill);
      notifier.setWorkingDirectory(repoA.path);
      await tester.pumpAndSettle();

      // suffix の dropdown を開いて中身を確認
      // フォルダドロップダウンと同じ arrow_drop_down を持つので、
      // tooltip で Skill 候補ボタンに限定して tap する。
      await tester.tap(find.byTooltip('候補から選択'));
      await tester.pumpAndSettle();
      expect(find.text('alpha'), findsOneWidget);
      expect(find.text('bravo'), findsNothing);

      // 一度メニューを閉じる
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // 2 回目のパスを設定（連続して別ディレクトリへ）
      notifier.setWorkingDirectory(repoB.path);
      await tester.pumpAndSettle();

      // フォルダドロップダウンと同じ arrow_drop_down を持つので、
      // tooltip で Skill 候補ボタンに限定して tap する。
      await tester.tap(find.byTooltip('候補から選択'));
      await tester.pumpAndSettle();
      expect(find.text('bravo'), findsOneWidget);
      expect(find.text('alpha'), findsNothing);
    },
  );
}
