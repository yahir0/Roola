import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roola/core/exceptions/app_exception.dart';
import 'package:roola/data/git/git_repository.dart';
import 'package:roola/data/git/git_status.dart';
import 'package:roola/data/git/process_git_repository.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/git/git_view_model.dart';
import 'package:roola/ui/workspace/workspace_seed.dart';

class _MockGitRepository extends Mock implements GitRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String>[]);
    registerFallbackValue(<GitFileChange>[]);
  });

  /// `_load` で呼ばれる読み取り系メソッドを既定スタブする。
  void stubLoad(_MockGitRepository mock, {GitStatus? status}) {
    when(mock.isGitAvailable).thenAnswer((_) async => true);
    when(
      () => mock.status(any()),
    ).thenAnswer((_) async => status ?? const GitStatus(branch: 'main'));
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

  ProviderContainer makeContainer(_MockGitRepository mock) {
    const layout = WorkspaceLayout(
      topLeft: PaneSlot(
        tabs: [WorkspaceTab.git(id: 'g1', repoRoot: '/repo')],
      ),
      topRight: PaneSlot.empty,
      bottom: PaneSlot.empty,
    );
    final container = ProviderContainer(
      overrides: [
        workspaceInitialLayoutProvider.overrideWithValue(layout),
        gitRepositoryProvider.overrideWithValue(mock),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('build はリポジトリ状態を読み込む', () async {
    final mock = _MockGitRepository();
    stubLoad(mock);
    final container = makeContainer(mock);

    final state = await container.read(gitViewModelProvider('g1').future);
    expect(state.gitMissing, isFalse);
    expect(state.branch, 'main');
  });

  test('git が利用できないとき gitMissing になる', () async {
    final mock = _MockGitRepository();
    when(mock.isGitAvailable).thenAnswer((_) async => false);
    final container = makeContainer(mock);

    final state = await container.read(gitViewModelProvider('g1').future);
    expect(state.gitMissing, isTrue);
  });

  test('stage はリポジトリの stage を呼び再読込する', () async {
    final mock = _MockGitRepository();
    stubLoad(mock);
    when(() => mock.stage(any(), any())).thenAnswer((_) async {});
    final container = makeContainer(mock);
    await container.read(gitViewModelProvider('g1').future);

    await container.read(gitViewModelProvider('g1').notifier).stage(const [
      GitFileChange(path: 'x.txt', type: GitChangeType.modified, staged: false),
    ]);

    verify(() => mock.stage('/repo', ['x.txt'])).called(1);
  });

  test('操作失敗時は通知を立てる', () async {
    final mock = _MockGitRepository();
    stubLoad(mock);
    when(
      () => mock.commit(any(), any(), amend: any(named: 'amend')),
    ).thenThrow(const AppException.gitCommandFailure('boom'));
    final container = makeContainer(mock);
    await container.read(gitViewModelProvider('g1').future);

    await container.read(gitViewModelProvider('g1').notifier).commit('メッセージ');

    final state = container.read(gitViewModelProvider('g1')).value;
    expect(state?.notice, isNotNull);
    expect(state?.notice?.message, 'boom');
    expect(state?.runningOperation, isNull);
  });
}
