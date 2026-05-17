import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roola/data/git/git_repository.dart';
import 'package:roola/data/git/git_status.dart';
import 'package:roola/data/git/process_git_repository.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/git/git_tab.dart';
import 'package:roola/ui/workspace/current_tab_id_provider.dart';
import 'package:roola/ui/workspace/workspace_seed.dart';

class _MockGitRepository extends Mock implements GitRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  void stubLoad(_MockGitRepository mock, {required GitStatus status}) {
    when(() => mock.status(any())).thenAnswer((_) async => status);
    when(() => mock.branches(any())).thenAnswer((_) async => const []);
    when(
      () => mock.log(
        any(),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const []);
    when(() => mock.stashes(any())).thenAnswer((_) async => const []);
  }

  Widget harness(_MockGitRepository mock) {
    const layout = WorkspaceLayout(
      topLeft: PaneSlot(
        tabs: [WorkspaceTab.git(id: 'g1', repoRoot: '/repo')],
      ),
      topRight: PaneSlot.empty,
      bottom: PaneSlot.empty,
    );
    return ProviderScope(
      overrides: [
        workspaceInitialLayoutProvider.overrideWithValue(layout),
        gitRepositoryProvider.overrideWithValue(mock),
        currentTabIdProvider.overrideWithValue('g1'),
      ],
      child: const MaterialApp(home: Scaffold(body: GitTabBody())),
    );
  }

  testWidgets('クリーンなリポジトリでツールバーと空状態を表示する', (tester) async {
    final mock = _MockGitRepository();
    when(mock.isGitAvailable).thenAnswer((_) async => true);
    stubLoad(mock, status: const GitStatus(branch: 'main'));

    await tester.pumpWidget(harness(mock));
    await tester.pumpAndSettle();

    expect(find.text('main'), findsOneWidget);
    expect(find.text('作業ツリーはクリーンです'), findsOneWidget);
  });

  testWidgets('git が無いときは案内を表示する', (tester) async {
    final mock = _MockGitRepository();
    when(mock.isGitAvailable).thenAnswer((_) async => false);

    await tester.pumpWidget(harness(mock));
    await tester.pumpAndSettle();

    expect(find.text('git コマンドが見つかりません'), findsOneWidget);
  });

  testWidgets('変更があるとファイル行が表示される', (tester) async {
    final mock = _MockGitRepository();
    when(mock.isGitAvailable).thenAnswer((_) async => true);
    stubLoad(
      mock,
      status: const GitStatus(
        branch: 'main',
        unstaged: [
          GitFileChange(
            path: 'lib/main.dart',
            type: GitChangeType.modified,
            staged: false,
          ),
        ],
      ),
    );

    await tester.pumpWidget(harness(mock));
    await tester.pumpAndSettle();

    expect(find.text('lib/main.dart'), findsOneWidget);
    expect(find.text('作業ツリーはクリーンです'), findsNothing);
  });
}
