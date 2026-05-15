import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_repository.dart';
import 'package:roola/data/workspace/workspace_repository_impl.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/explorer/explorer_view_model.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:roola/ui/workspace/workspace_seed.dart';

class _FakeWorkspaceRepository implements WorkspaceRepository {
  @override
  Future<WorkspaceLayout?> load() async => null;

  @override
  Future<void> save(WorkspaceLayout layout) async {}
}

void main() {
  late Directory tempDir;
  late Directory dirA;
  late Directory subA;
  late Directory dirB;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_evm_');
    dirA = await Directory('${tempDir.path}/a').create();
    subA = await Directory('${dirA.path}/sub').create();
    dirB = await Directory('${tempDir.path}/b').create();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  ProviderContainer containerWith2Tabs() {
    final container = ProviderContainer(
      overrides: [
        workspaceInitialLayoutProvider.overrideWithValue(
          WorkspaceLayout(
            topLeft: PaneSlot(
              tabs: [
                WorkspaceTab.explorer(id: 'tab-a', currentPath: dirA.path),
              ],
            ),
            topRight: PaneSlot(
              tabs: [
                WorkspaceTab.explorer(id: 'tab-b', currentPath: dirB.path),
              ],
            ),
            bottom: PaneSlot.empty,
          ),
        ),
        workspaceRepositoryProvider.overrideWithValue(
          _FakeWorkspaceRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('各タブはタブ生成時のパスで初期化される', () {
    final container = containerWith2Tabs();
    expect(
      container.read(explorerViewModelProvider('tab-a')).currentPath,
      dirA.path,
    );
    expect(
      container.read(explorerViewModelProvider('tab-b')).currentPath,
      dirB.path,
    );
  });

  test('1 タブの navigateTo は他タブのカレントパスに影響しない', () {
    final container = containerWith2Tabs();
    // 先に両方を build しておく。
    container.read(explorerViewModelProvider('tab-a'));
    container.read(explorerViewModelProvider('tab-b'));

    container
        .read(explorerViewModelProvider('tab-a').notifier)
        .navigateTo(subA.path);

    expect(
      container.read(explorerViewModelProvider('tab-a')).currentPath,
      subA.path,
    );
    // tab-b は変化しない。
    expect(
      container.read(explorerViewModelProvider('tab-b')).currentPath,
      dirB.path,
    );
  });

  test('履歴はタブごとに独立して戻る / 進むできる', () {
    final container = containerWith2Tabs();
    final notifierA = container.read(
      explorerViewModelProvider('tab-a').notifier,
    );
    notifierA.navigateTo(subA.path);
    expect(notifierA.canGoBack, isTrue);

    notifierA.goBack();
    expect(
      container.read(explorerViewModelProvider('tab-a')).currentPath,
      dirA.path,
    );
    expect(notifierA.canGoForward, isTrue);

    notifierA.goForward();
    expect(
      container.read(explorerViewModelProvider('tab-a')).currentPath,
      subA.path,
    );

    // tab-b の履歴は手つかず。
    final notifierB = container.read(
      explorerViewModelProvider('tab-b').notifier,
    );
    expect(notifierB.canGoBack, isFalse);
  });

  test('navigateTo はワークスペースのタブパスへ反映される', () {
    final container = containerWith2Tabs();
    container.read(explorerViewModelProvider('tab-a'));
    container
        .read(explorerViewModelProvider('tab-a').notifier)
        .navigateTo(subA.path);

    final tab = container.read(workspaceProvider).tabById('tab-a');
    expect((tab! as ExplorerTab).currentPath, subA.path);
  });
}
