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
  required PaneSlot topLeft,
  required PaneSlot topRight,
  required PaneSlot bottom,
}) => WorkspaceLayout(topLeft: topLeft, topRight: topRight, bottom: bottom);

void main() {
  group('resolveWorkspaceLayout', () {
    test('3 スロットすべてにコンテンツ → three', () {
      final resolved = resolveWorkspaceLayout(
        _layout(topLeft: _slot(), topRight: _slot(), bottom: _slot()),
      );
      expect(resolved.mode, WorkspaceLayoutMode.three);
      expect(resolved.visibleSlots, [
        PaneSlotId.topLeft,
        PaneSlotId.topRight,
        PaneSlotId.bottom,
      ]);
    });

    test('bottom が空 → twoHorizontal（上段左右）', () {
      final resolved = resolveWorkspaceLayout(
        _layout(topLeft: _slot(), topRight: _slot(), bottom: PaneSlot.empty),
      );
      expect(resolved.mode, WorkspaceLayoutMode.twoHorizontal);
      expect(resolved.visibleSlots, [PaneSlotId.topLeft, PaneSlotId.topRight]);
    });

    test('topRight が空 → twoVertical（topLeft + bottom）', () {
      final resolved = resolveWorkspaceLayout(
        _layout(topLeft: _slot(), topRight: PaneSlot.empty, bottom: _slot()),
      );
      expect(resolved.mode, WorkspaceLayoutMode.twoVertical);
      expect(resolved.visibleSlots, [PaneSlotId.topLeft, PaneSlotId.bottom]);
    });

    test('topLeft が空 → twoVertical（topRight + bottom）', () {
      final resolved = resolveWorkspaceLayout(
        _layout(topLeft: PaneSlot.empty, topRight: _slot(), bottom: _slot()),
      );
      expect(resolved.mode, WorkspaceLayoutMode.twoVertical);
      expect(resolved.visibleSlots, [PaneSlotId.topRight, PaneSlotId.bottom]);
    });

    test('コンテンツが 1 スロットだけ → single', () {
      final resolved = resolveWorkspaceLayout(
        _layout(
          topLeft: PaneSlot.empty,
          topRight: _slot(),
          bottom: PaneSlot.empty,
        ),
      );
      expect(resolved.mode, WorkspaceLayoutMode.single);
      expect(resolved.visibleSlots, [PaneSlotId.topRight]);
    });

    test('全スロット空 → single（topLeft フォールバック）', () {
      final resolved = resolveWorkspaceLayout(
        _layout(
          topLeft: PaneSlot.empty,
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      );
      expect(resolved.mode, WorkspaceLayoutMode.single);
      expect(resolved.visibleSlots, [PaneSlotId.topLeft]);
    });
  });
}
