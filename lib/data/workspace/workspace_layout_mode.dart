import 'package:roola/data/workspace/workspace_layout.dart';

/// 崩し再フローの結果（ADR-0026 / ADR-0068）。
///
/// 上段・下段それぞれの描画対象スロットを、左→右の順で持つ。描画側は
/// この 2 つのリストから直接レイアウトを組み立てられる。
///
/// - 両 row が非空 → 上下 2 分割（`topRatio`）
/// - 片方の row だけ非空 → その row を画面全高に広げる
/// - row 内が 2 つ → 左右 2 分割（上段は `leftRatio` / 下段は `bottomLeftRatio`）
/// - row 内が 1 つ → そのまま全幅
class ResolvedWorkspaceLayout {
  const ResolvedWorkspaceLayout({
    required this.topSlots,
    required this.bottomSlots,
  });

  /// 上段の描画対象スロット（左→右）。0〜2 個。
  final List<PaneSlotId> topSlots;

  /// 下段の描画対象スロット（左→右）。0〜2 個。
  final List<PaneSlotId> bottomSlots;

  /// 描画対象スロットの総数。1 なら単一ペイン全画面。
  int get visibleCount => topSlots.length + bottomSlots.length;

  /// 上下スプリッタが要るか（両 row にコンテンツがある）。
  bool get hasRowSplit => topSlots.isNotEmpty && bottomSlots.isNotEmpty;
}

/// レイアウトの非空スロットから描画構成を決める純粋関数（ADR-0068）。
///
/// 上段・下段を独立に解決するため、単一ペインから 4 分割までが 1 つの規則で
/// 表現できる。空スロットは描画対象から外れる（崩し再フロー）。
///
/// 全スロットが空のときは `topLeft` 単体にフォールバックする（`_ensureNotEmpty`
/// が先に seed するため、実際には理論上のみ）。
ResolvedWorkspaceLayout resolveWorkspaceLayout(WorkspaceLayout layout) {
  final slots = layout.nonEmptySlots;
  if (slots.isEmpty) {
    return const ResolvedWorkspaceLayout(
      topSlots: [PaneSlotId.topLeft],
      bottomSlots: [],
    );
  }
  return ResolvedWorkspaceLayout(
    topSlots: [
      for (final id in slots)
        if (id.isTopRow) id,
    ],
    bottomSlots: [
      for (final id in slots)
        if (id.isBottomRow) id,
    ],
  );
}
