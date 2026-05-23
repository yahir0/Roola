import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/workspace/focused_tab_provider.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:roola/ui/workspace/workspace_seed.dart';

PaneSlot _explorerSlot(List<String> ids) => PaneSlot(
  tabs: [for (final id in ids) WorkspaceTab.explorer(id: id, currentPath: '/')],
);

ProviderContainer _container(WorkspaceLayout initial) {
  final container = ProviderContainer(
    overrides: [workspaceInitialLayoutProvider.overrideWithValue(initial)],
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

  group('Workspace フォーカス追跡（サイドバーの遷移先）', () {
    test('新規エクスプローラタブを開くと lastExplorerTabId が新タブを指す', () {
      final container = _container(
        WorkspaceLayout(
          topLeft: _explorerSlot(['a']),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      );
      final workspace = container.read(workspaceProvider.notifier);
      final newId = workspace.addExplorerTab(PaneSlotId.topLeft);

      // body をクリックしていなくても、新規タブがサイドバーの遷移先になる。
      expect(container.read(focusedTabProvider).lastExplorerTabId, newId);
    });

    test('エクスプローラタブを activateTab すると lastExplorerTabId が追従する', () {
      final container = _container(
        WorkspaceLayout(
          topLeft: _explorerSlot(['a', 'b']),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      );
      container.read(workspaceProvider.notifier).activateTab('b');
      expect(container.read(focusedTabProvider).lastExplorerTabId, 'b');
    });

    test('ターミナルタブを追加しても lastExplorerTabId は据え置かれる', () {
      final container = _container(
        WorkspaceLayout(
          topLeft: _explorerSlot(['a']),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      );
      final workspace = container.read(workspaceProvider.notifier);
      // まずエクスプローラ a を遷移先にしておく。
      workspace.activateTab('a');
      workspace.addTerminalTab(PaneSlotId.bottom);

      expect(container.read(focusedTabProvider).lastExplorerTabId, 'a');
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
