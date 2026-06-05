import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/explorer/launcher_actions.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:roola/ui/workspace/workspace_seed.dart';

final _entry = LauncherEntry(
  id: 'entry-1',
  displayName: 'dev サーバ',
  workingDirectory: '/tmp',
  action: const LauncherAction.openHere(),
  createdAt: DateTime(2026),
);

/// 起動ボタン 1 個のハーネス。タップで [entry] を起動する。
class _Harness extends ConsumerWidget {
  const _Harness({required this.entry});

  final LauncherEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => launchLauncherEntry(context, ref, entry),
      child: const Text('launch'),
    );
  }
}

ProviderContainer _emptyBottomContainer() {
  final container = ProviderContainer(
    overrides: [
      // bottom が空の状態から始める。
      workspaceInitialLayoutProvider.overrideWithValue(
        const WorkspaceLayout(
          topLeft: PaneSlot(
            tabs: [WorkspaceTab.explorer(id: 'e', currentPath: '/')],
          ),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      ),
    ],
  );
  return container;
}

Future<void> _pump(
  WidgetTester tester,
  ProviderContainer container,
  LauncherEntry entry,
) {
  return tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ja'),
        home: Scaffold(body: _Harness(entry: entry)),
      ),
    ),
  );
}

void main() {
  testWidgets('launchLauncherEntry は bottom ペインにターミナルタブを追加する', (tester) async {
    final container = _emptyBottomContainer();
    addTearDown(container.dispose);

    await _pump(tester, container, _entry);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    final bottom = container.read(workspaceProvider).bottom;
    expect(bottom.tabs.length, 1);
    final tab = bottom.tabs.single;
    expect(tab, isA<TerminalTab>());
    expect((tab as TerminalTab).args.displayName, 'dev サーバ');
    expect(tab.args.workingDirectory, '/tmp');
  });

  group('Claude Skill 引数あり（ADR-0062）', () {
    final skillEntry = LauncherEntry(
      id: 'entry-skill',
      displayName: 'Transcribe',
      workingDirectory: '/tmp',
      action: const LauncherAction.claudeSkill(
        skillName: 'transcribe',
        requiresArgument: true,
      ),
      createdAt: DateTime(2026),
    );

    testWidgets('requiresArgument のとき入力ダイアログを出し、入力値を skillArgument に渡す', (
      tester,
    ) async {
      final container = _emptyBottomContainer();
      addTearDown(container.dispose);

      await _pump(tester, container, skillEntry);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // 複数行入力ダイアログが出る（TextField が現れる）。
      final field = find.byType(TextField);
      expect(field, findsOneWidget);

      // 改行を含む長文を入力（trim されずそのまま渡る）。
      const input = 'log line 1\nlog line 2';
      await tester.enterText(field, input);
      // 確定ボタン（"実行"）を押す。
      await tester.tap(find.widgetWithText(FilledButton, '実行'));
      await tester.pumpAndSettle();

      final bottom = container.read(workspaceProvider).bottom;
      expect(bottom.tabs.length, 1);
      final tab = bottom.tabs.single as TerminalTab;
      expect(tab.args.skillArgument, input);
      expect(tab.args.action, isA<ClaudeSkillAction>());
    });

    testWidgets('ダイアログを取消したら起動しない', (tester) async {
      final container = _emptyBottomContainer();
      addTearDown(container.dispose);

      await _pump(tester, container, skillEntry);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // キャンセル（OutlinedButton / "キャンセル"）。
      await tester.tap(find.widgetWithText(OutlinedButton, 'キャンセル'));
      await tester.pumpAndSettle();

      expect(container.read(workspaceProvider).bottom.tabs, isEmpty);
    });
  });
}
