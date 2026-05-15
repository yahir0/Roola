import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_repository.dart';
import 'package:roola/data/workspace/workspace_repository_impl.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:roola/ui/workspace/workspace_seed.dart';

/// 保存をしない fake リポジトリ（テストで実ファイル I/O を避ける）。
class _FakeWorkspaceRepository implements WorkspaceRepository {
  @override
  Future<WorkspaceLayout?> load() async => null;

  @override
  Future<void> save(WorkspaceLayout layout) async {}
}

PaneSlot _explorerSlot(List<String> ids) => PaneSlot(
  tabs: [for (final id in ids) WorkspaceTab.explorer(id: id, currentPath: '/')],
);

ProviderContainer _container(WorkspaceLayout initial) {
  final container = ProviderContainer(
    overrides: [
      workspaceInitialLayoutProvider.overrideWithValue(initial),
      workspaceRepositoryProvider.overrideWithValue(_FakeWorkspaceRepository()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('Workspace addTab / activateTab', () {
    test('addExplorerTab は空スロットにタブを足してアクティブにする', () {
      final container = _container(
        WorkspaceLayout(
          topLeft: _explorerSlot(['a']),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      );
      final workspace = container.read(workspaceProvider.notifier);
      final id = workspace.addExplorerTab(PaneSlotId.topRight);

      final layout = container.read(workspaceProvider);
      expect(layout.topRight.tabs.single.id, id);
      expect(layout.topRight.activeIndex, 0);
    });

    test('addTerminalTab はターミナルタブを追加する', () {
      final container = _container(
        WorkspaceLayout(
          topLeft: _explorerSlot(['a']),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      );
      final workspace = container.read(workspaceProvider.notifier);
      workspace.addTerminalTab(PaneSlotId.bottom);

      final tab = container.read(workspaceProvider).bottom.tabs.single;
      expect(tab, isA<TerminalTab>());
    });

    test('activateTab は対象タブをアクティブにする', () {
      final container = _container(
        WorkspaceLayout(
          topLeft: _explorerSlot(['a', 'b', 'c']),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      );
      container.read(workspaceProvider.notifier).activateTab('c');
      expect(container.read(workspaceProvider).topLeft.activeIndex, 2);
    });
  });

  group('Workspace closeTab', () {
    test('タブを閉じると activeIndex が範囲内にクランプされる', () {
      final container = _container(
        const WorkspaceLayout(
          topLeft: PaneSlot(
            tabs: [
              WorkspaceTab.explorer(id: 'a', currentPath: '/'),
              WorkspaceTab.explorer(id: 'b', currentPath: '/'),
            ],
            activeIndex: 1,
          ),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      );
      container.read(workspaceProvider.notifier).closeTab('b');

      final layout = container.read(workspaceProvider);
      expect(layout.topLeft.tabs.map((t) => t.id), ['a']);
      expect(layout.topLeft.activeIndex, 0);
    });

    test('スロット最後のタブを閉じるとスロットが空になる', () {
      final container = _container(
        WorkspaceLayout(
          topLeft: _explorerSlot(['a']),
          topRight: _explorerSlot(['b']),
          bottom: PaneSlot.empty,
        ),
      );
      container.read(workspaceProvider.notifier).closeTab('b');
      expect(container.read(workspaceProvider).topRight.isEmpty, isTrue);
    });

    test('全タブを閉じるとエクスプローラタブが自動 seed される', () {
      final container = _container(
        WorkspaceLayout(
          topLeft: _explorerSlot(['a']),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      );
      container.read(workspaceProvider.notifier).closeTab('a');

      final layout = container.read(workspaceProvider);
      expect(layout.nonEmptySlots, isNotEmpty);
      expect(layout.topLeft.tabs.single, isA<ExplorerTab>());
    });
  });

  group('Workspace moveTab', () {
    test('同一スロット内でタブを末尾へ並べ替える', () {
      final container = _container(
        WorkspaceLayout(
          topLeft: _explorerSlot(['a', 'b', 'c']),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      );
      // a を末尾ギャップ（index 3）へ。
      container
          .read(workspaceProvider.notifier)
          .moveTab('a', PaneSlotId.topLeft, 3);
      expect(container.read(workspaceProvider).topLeft.tabs.map((t) => t.id), [
        'b',
        'c',
        'a',
      ]);
    });

    test('ペイン間移動でタブが移り、移動先でアクティブになる', () {
      final container = _container(
        WorkspaceLayout(
          topLeft: _explorerSlot(['a', 'b']),
          topRight: _explorerSlot(['x']),
          bottom: PaneSlot.empty,
        ),
      );
      container
          .read(workspaceProvider.notifier)
          .moveTab('a', PaneSlotId.topRight, 1);
      final layout = container.read(workspaceProvider);
      expect(layout.topLeft.tabs.map((t) => t.id), ['b']);
      expect(layout.topRight.tabs.map((t) => t.id), ['x', 'a']);
      expect(layout.topRight.activeIndex, 1);
    });

    test('唯一のタブを別ペインへ移動すると元スロットが空になる', () {
      final container = _container(
        WorkspaceLayout(
          topLeft: _explorerSlot(['a']),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      );
      container
          .read(workspaceProvider.notifier)
          .moveTab('a', PaneSlotId.topRight, 0);
      final layout = container.read(workspaceProvider);
      expect(layout.topLeft.isEmpty, isTrue);
      expect(layout.topRight.tabs.single.id, 'a');
    });
  });

  group('Workspace setSplitRatio', () {
    test('比率は 0.15〜0.85 にクランプされる', () {
      final container = _container(seedDefaultWorkspace());
      final workspace = container.read(workspaceProvider.notifier);
      workspace.setTopRatio(0.99);
      expect(container.read(workspaceProvider).topRatio, 0.85);
      workspace.setLeftRatio(0.01);
      expect(container.read(workspaceProvider).leftRatio, 0.15);
    });
  });
}
