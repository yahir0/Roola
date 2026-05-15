import 'package:roola/data/workspace/workspace_layout.dart';

/// 崩し再フロー後の描画モード（ADR-0026）。
///
/// - [single]: コンテンツを持つスロットが 1 つ。単一ペイン全画面。
/// - [twoHorizontal]: 上段の左右 2 スロット。`bottom` が空のとき。
/// - [twoVertical]: 上段の片方 + `bottom`。上下 2 分割。
/// - [three]: 3 スロットすべてにコンテンツ。上 2 + 下 1。
enum WorkspaceLayoutMode { single, twoHorizontal, twoVertical, three }

/// 崩し再フローの結果。描画モードと、描画対象スロットの並び順を持つ。
class ResolvedWorkspaceLayout {
  const ResolvedWorkspaceLayout({
    required this.mode,
    required this.visibleSlots,
  });

  final WorkspaceLayoutMode mode;

  /// 描画対象スロット。`twoHorizontal` は左→右、`twoVertical` は上→下の順。
  final List<PaneSlotId> visibleSlots;
}

/// レイアウトの非空スロット数から描画モードを決める純粋関数（ADR-0026）。
///
/// - 0 / 1 スロット → [WorkspaceLayoutMode.single]（0 個は理論上発生しない
///   が、フォールバックで `topLeft` を返す）
/// - 2 スロット → 上段 2 つなら [WorkspaceLayoutMode.twoHorizontal]、
///   そうでなければ（上段片方 + `bottom`）[WorkspaceLayoutMode.twoVertical]
/// - 3 スロット → [WorkspaceLayoutMode.three]
ResolvedWorkspaceLayout resolveWorkspaceLayout(WorkspaceLayout layout) {
  final slots = layout.nonEmptySlots;
  switch (slots.length) {
    case 0:
      return const ResolvedWorkspaceLayout(
        mode: WorkspaceLayoutMode.single,
        visibleSlots: [PaneSlotId.topLeft],
      );
    case 1:
      return ResolvedWorkspaceLayout(
        mode: WorkspaceLayoutMode.single,
        visibleSlots: slots,
      );
    case 2:
      final hasTopLeft = slots.contains(PaneSlotId.topLeft);
      final hasTopRight = slots.contains(PaneSlotId.topRight);
      if (hasTopLeft && hasTopRight) {
        return const ResolvedWorkspaceLayout(
          mode: WorkspaceLayoutMode.twoHorizontal,
          visibleSlots: [PaneSlotId.topLeft, PaneSlotId.topRight],
        );
      }
      // 上段の片方 + bottom。`slots` は PaneSlotId.values 順なので
      // 既に [上段スロット, bottom] に並んでいる。
      return ResolvedWorkspaceLayout(
        mode: WorkspaceLayoutMode.twoVertical,
        visibleSlots: slots,
      );
    default:
      return const ResolvedWorkspaceLayout(
        mode: WorkspaceLayoutMode.three,
        visibleSlots: [
          PaneSlotId.topLeft,
          PaneSlotId.topRight,
          PaneSlotId.bottom,
        ],
      );
  }
}
