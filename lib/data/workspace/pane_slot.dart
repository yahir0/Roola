import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:roola/data/workspace/workspace_tab.dart';

part 'pane_slot.freezed.dart';

/// ペインスロット 1 つ分の状態。タブ群と、その中のアクティブタブ位置を持つ。
///
/// タブ 0 個のスロットは「空」とみなされ、`workspace-layout` の崩し再フロー
/// で描画対象から外れる（ADR-0026）。
@freezed
abstract class PaneSlot with _$PaneSlot {
  const factory PaneSlot({
    @Default(<WorkspaceTab>[]) List<WorkspaceTab> tabs,
    @Default(0) int activeIndex,
  }) = _PaneSlot;

  const PaneSlot._();

  /// タブを持たない空スロット。
  static const PaneSlot empty = PaneSlot();

  bool get isEmpty => tabs.isEmpty;

  bool get isNotEmpty => tabs.isNotEmpty;

  /// `tabs` の範囲内にクランプしたアクティブ位置。`tabs` が空なら 0。
  int get safeActiveIndex =>
      tabs.isEmpty ? 0 : activeIndex.clamp(0, tabs.length - 1);

  /// アクティブタブ。空スロットなら `null`。
  WorkspaceTab? get activeTab => tabs.isEmpty ? null : tabs[safeActiveIndex];
}
