import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_layout_mode.dart';
import 'package:roola/data/workspace/workspace_tab.dart';

/// 1 タブを持つエクスプローラスロット。
PaneSlot _slot() => PaneSlot(
  tabs: [
    WorkspaceTab.explorer(
      id: 'e-${DateTime.now().microsecond}',
      currentPath: '/',
    ),
  ],
);

WorkspaceLayout _layout({
  PaneSlot? topLeft,
  PaneSlot? topRight,
  PaneSlot? bottomLeft,
  PaneSlot? bottomRight,
}) => WorkspaceLayout(
  topLeft: topLeft ?? PaneSlot.empty,
  topRight: topRight ?? PaneSlot.empty,
  bottomLeft: bottomLeft ?? PaneSlot.empty,
  bottomRight: bottomRight ?? PaneSlot.empty,
);

void main() {
  group('resolveWorkspaceLayout', () {
    test('4 スロットすべてにコンテンツ → 上下とも 2 スロット（4 分割）', () {
      final resolved = resolveWorkspaceLayout(
        _layout(
          topLeft: _slot(),
          topRight: _slot(),
          bottomLeft: _slot(),
          bottomRight: _slot(),
        ),
      );
      expect(resolved.topSlots, [PaneSlotId.topLeft, PaneSlotId.topRight]);
      expect(resolved.bottomSlots, [
        PaneSlotId.bottomLeft,
        PaneSlotId.bottomRight,
      ]);
      expect(resolved.visibleCount, 4);
      expect(resolved.hasRowSplit, isTrue);
    });

    test('bottomRight が空 → 既定の 3 分割（上 2 + 下 1・下段は全幅）', () {
      final resolved = resolveWorkspaceLayout(
        _layout(topLeft: _slot(), topRight: _slot(), bottomLeft: _slot()),
      );
      expect(resolved.topSlots, [PaneSlotId.topLeft, PaneSlotId.topRight]);
      expect(resolved.bottomSlots, [PaneSlotId.bottomLeft]);
      expect(resolved.visibleCount, 3);
      expect(resolved.hasRowSplit, isTrue);
    });

    test('bottomLeft が空 → 3 分割（下段は bottomRight が全幅）', () {
      final resolved = resolveWorkspaceLayout(
        _layout(topLeft: _slot(), topRight: _slot(), bottomRight: _slot()),
      );
      expect(resolved.topSlots, [PaneSlotId.topLeft, PaneSlotId.topRight]);
      expect(resolved.bottomSlots, [PaneSlotId.bottomRight]);
    });

    test('上段の片方が空 → 上 1 + 下 2（上段は全幅）', () {
      final resolved = resolveWorkspaceLayout(
        _layout(topRight: _slot(), bottomLeft: _slot(), bottomRight: _slot()),
      );
      expect(resolved.topSlots, [PaneSlotId.topRight]);
      expect(resolved.bottomSlots, [
        PaneSlotId.bottomLeft,
        PaneSlotId.bottomRight,
      ]);
      expect(resolved.visibleCount, 3);
    });

    test('下段が両方空 → 上段のみ 2 分割（全高）', () {
      final resolved = resolveWorkspaceLayout(
        _layout(topLeft: _slot(), topRight: _slot()),
      );
      expect(resolved.topSlots, [PaneSlotId.topLeft, PaneSlotId.topRight]);
      expect(resolved.bottomSlots, isEmpty);
      expect(resolved.hasRowSplit, isFalse);
    });

    test('上段が両方空 → 下段のみ 2 分割（全高）', () {
      final resolved = resolveWorkspaceLayout(
        _layout(bottomLeft: _slot(), bottomRight: _slot()),
      );
      expect(resolved.topSlots, isEmpty);
      expect(resolved.bottomSlots, [
        PaneSlotId.bottomLeft,
        PaneSlotId.bottomRight,
      ]);
      expect(resolved.hasRowSplit, isFalse);
    });

    test('各段に 1 つずつ → 上下 2 分割（それぞれ全幅）', () {
      final resolved = resolveWorkspaceLayout(
        _layout(topLeft: _slot(), bottomRight: _slot()),
      );
      expect(resolved.topSlots, [PaneSlotId.topLeft]);
      expect(resolved.bottomSlots, [PaneSlotId.bottomRight]);
      expect(resolved.visibleCount, 2);
      expect(resolved.hasRowSplit, isTrue);
    });

    test('コンテンツが 1 スロットだけ → 単一ペイン（スプリッタ無し）', () {
      final resolved = resolveWorkspaceLayout(_layout(topRight: _slot()));
      expect(resolved.topSlots, [PaneSlotId.topRight]);
      expect(resolved.bottomSlots, isEmpty);
      expect(resolved.visibleCount, 1);
      expect(resolved.hasRowSplit, isFalse);
    });

    test('下段 1 スロットだけでも単一ペイン', () {
      final resolved = resolveWorkspaceLayout(_layout(bottomRight: _slot()));
      expect(resolved.topSlots, isEmpty);
      expect(resolved.bottomSlots, [PaneSlotId.bottomRight]);
      expect(resolved.visibleCount, 1);
    });

    test('全スロット空 → single（topLeft フォールバック）', () {
      final resolved = resolveWorkspaceLayout(_layout());
      expect(resolved.topSlots, [PaneSlotId.topLeft]);
      expect(resolved.bottomSlots, isEmpty);
      expect(resolved.visibleCount, 1);
    });
  });
}
