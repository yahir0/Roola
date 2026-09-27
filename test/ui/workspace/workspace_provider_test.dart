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
          bottomLeft: PaneSlot.empty,
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
          bottomLeft: PaneSlot.empty,
        ),
      );
      final workspace = container.read(workspaceProvider.notifier);
      workspace.addTerminalTab(PaneSlotId.bottomLeft);

      final tab = container.read(workspaceProvider).bottomLeft.tabs.single;
      expect(tab, isA<TerminalTab>());
    });

    test('activateTab は対象タブをアクティブにする', () {
      final container = _container(
        WorkspaceLayout(
          topLeft: _explorerSlot(['a', 'b', 'c']),
          topRight: PaneSlot.empty,
          bottomLeft: PaneSlot.empty,
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
          bottomLeft: PaneSlot.empty,
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
          bottomLeft: PaneSlot.empty,
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
          bottomLeft: PaneSlot.empty,
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
          bottomLeft: PaneSlot.empty,
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
          bottomLeft: PaneSlot.empty,
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
          bottomLeft: PaneSlot.empty,
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
          bottomLeft: PaneSlot.empty,
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
          bottomLeft: PaneSlot.empty,
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
          bottomLeft: PaneSlot.empty,
        ),
      );
      final workspace = container.read(workspaceProvider.notifier);
      // まずエクスプローラ a を遷移先にしておく。
      workspace.activateTab('a');
      workspace.addTerminalTab(PaneSlotId.bottomLeft);

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
      workspace.setBottomLeftRatio(0.99);
      expect(container.read(workspaceProvider).bottomLeftRatio, 0.85);
    });

    test('上段と下段の左右比率は独立して動く', () {
      final container = _container(seedDefaultWorkspace());
      final workspace = container.read(workspaceProvider.notifier);
      workspace.setLeftRatio(0.3);
      expect(container.read(workspaceProvider).leftRatio, 0.3);
      // 下段を動かしても上段は据え置き。
      expect(container.read(workspaceProvider).bottomLeftRatio, 0.5);
      workspace.setBottomLeftRatio(0.7);
      expect(container.read(workspaceProvider).leftRatio, 0.3);
      expect(container.read(workspaceProvider).bottomLeftRatio, 0.7);
    });
  });

  group('Workspace 4 分割（ADR-0068）', () {
    test('既定 seed は bottomRight が空（起動直後は 3 分割）', () {
      final layout = seedDefaultWorkspace();
      expect(layout.bottomRight.isEmpty, isTrue);
      expect(layout.nonEmptySlots, [
        PaneSlotId.topLeft,
        PaneSlotId.topRight,
        PaneSlotId.bottomLeft,
      ]);
    });

    test('bottomRight へタブを移動すると 4 スロットすべてが埋まる', () {
      final container = _container(
        WorkspaceLayout(
          topLeft: _explorerSlot(['a', 'b']),
          topRight: _explorerSlot(['c']),
          bottomLeft: _explorerSlot(['d']),
        ),
      );
      final workspace = container.read(workspaceProvider.notifier);
      workspace.moveTab('b', PaneSlotId.bottomRight, 0);

      final layout = container.read(workspaceProvider);
      expect(layout.topLeft.tabs.map((t) => t.id), ['a']);
      expect(layout.bottomRight.tabs.map((t) => t.id), ['b']);
      expect(layout.bottomRight.activeIndex, 0);
      expect(layout.nonEmptySlots.length, 4);
    });

    test('bottomRight の最後のタブを閉じると 3 分割へ戻る', () {
      final container = _container(
        WorkspaceLayout(
          topLeft: _explorerSlot(['a']),
          topRight: _explorerSlot(['b']),
          bottomLeft: _explorerSlot(['c']),
          bottomRight: _explorerSlot(['d']),
        ),
      );
      container.read(workspaceProvider.notifier).closeTab('d');

      final layout = container.read(workspaceProvider);
      expect(layout.bottomRight.isEmpty, isTrue);
      expect(layout.nonEmptySlots, [
        PaneSlotId.topLeft,
        PaneSlotId.topRight,
        PaneSlotId.bottomLeft,
      ]);
    });

    test('bottomRight のタブも tabById / _locate で見つかる', () {
      final container = _container(
        WorkspaceLayout(
          topLeft: _explorerSlot(['a']),
          topRight: PaneSlot.empty,
          bottomLeft: PaneSlot.empty,
          bottomRight: _explorerSlot(['z']),
        ),
      );
      final workspace = container.read(workspaceProvider.notifier);
      expect(workspace.tabById('z'), isA<ExplorerTab>());
      // activateTab は _locate 経由。見つからなければ no-op になる。
      workspace.activateTab('z');
      expect(container.read(focusedTabProvider).focusedTabId, 'z');
    });
  });
}
