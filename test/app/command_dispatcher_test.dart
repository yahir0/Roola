import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/command_dispatcher.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/workspace/focused_tab_provider.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:roola/ui/workspace/workspace_seed.dart';

PaneSlot _explorerSlot(List<String> ids) => PaneSlot(
  tabs: [for (final id in ids) WorkspaceTab.explorer(id: id, currentPath: '/')],
);

/// `dispatchCommand` に渡す `WidgetRef` を捕まえつつ、ワークスペースを
/// 指定レイアウトで初期化したテストツリーを pump する。
Future<WidgetRef> _pump(WidgetTester tester, WorkspaceLayout layout) async {
  late WidgetRef captured;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [workspaceInitialLayoutProvider.overrideWithValue(layout)],
      child: Consumer(
        builder: (context, ref, _) {
          captured = ref;
          return const SizedBox();
        },
      ),
    ),
  );
  return captured;
}

void main() {
  group('dispatchCommand: タブ操作', () {
    testWidgets('nextTab は同一ペイン内でアクティブタブを次へ送る', (tester) async {
      final ref = await _pump(
        tester,
        WorkspaceLayout(
          topLeft: _explorerSlot(['a', 'b', 'c']),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      );
      ref.read(focusedTabProvider.notifier).focusExplorer('a');

      dispatchCommand(CommandId.nextTab, ref);
      expect(ref.read(workspaceProvider).topLeft.activeIndex, 1);
    });

    testWidgets('nextTab は末尾で先頭に巻き戻る', (tester) async {
      final ref = await _pump(
        tester,
        WorkspaceLayout(
          topLeft: _explorerSlot(['a', 'b']),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      );
      ref.read(focusedTabProvider.notifier).focusExplorer('b');

      dispatchCommand(CommandId.nextTab, ref);
      expect(ref.read(workspaceProvider).topLeft.activeIndex, 0);
    });

    testWidgets('previousTab はアクティブタブを前へ送る', (tester) async {
      final ref = await _pump(
        tester,
        WorkspaceLayout(
          topLeft: _explorerSlot(['a', 'b', 'c']),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      );
      ref.read(focusedTabProvider.notifier).focusExplorer('c');

      dispatchCommand(CommandId.previousTab, ref);
      expect(ref.read(workspaceProvider).topLeft.activeIndex, 1);
    });

    testWidgets('closeTab はフォーカス中タブを閉じる', (tester) async {
      final ref = await _pump(
        tester,
        WorkspaceLayout(
          topLeft: _explorerSlot(['a', 'b']),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      );
      ref.read(focusedTabProvider.notifier).focusExplorer('a');

      dispatchCommand(CommandId.closeTab, ref);
      final tabs = ref.read(workspaceProvider).topLeft.tabs;
      expect(tabs.map((t) => t.id), ['b']);
    });

    testWidgets('moveTabBottom はフォーカス中タブを下ペインへ移す', (tester) async {
      final ref = await _pump(
        tester,
        WorkspaceLayout(
          topLeft: _explorerSlot(['a', 'b']),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      );
      ref.read(focusedTabProvider.notifier).focusExplorer('a');

      dispatchCommand(CommandId.moveTabBottom, ref);
      final layout = ref.read(workspaceProvider);
      expect(layout.topLeft.tabs.map((t) => t.id), ['b']);
      expect(layout.bottom.tabs.map((t) => t.id), ['a']);
    });

    testWidgets('newTerminalTab はフォーカス中ペインにタブを足す', (tester) async {
      final ref = await _pump(
        tester,
        WorkspaceLayout(
          topLeft: _explorerSlot(['a']),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      );
      ref.read(focusedTabProvider.notifier).focusExplorer('a');

      dispatchCommand(CommandId.newTerminalTab, ref);
      expect(ref.read(workspaceProvider).topLeft.tabs.length, 2);
    });
  });
}
