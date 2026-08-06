import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_tab.dart';

part 'workspace_layout.freezed.dart';

/// 4 つのペインスロットの識別子（ADR-0026 / ADR-0068）。
///
/// 上段が `topLeft` / `topRight`、下段が `bottomLeft` / `bottomRight`。
/// 列挙順は「上段左 → 上段右 → 下段左 → 下段右」で、`nonEmptySlots` など
/// 順序に依存する処理はこの順を前提にする。
enum PaneSlotId {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight;

  /// 上段のスロットか。
  bool get isTopRow => this == topLeft || this == topRight;

  /// 下段のスロットか。
  bool get isBottomRow => !isTopRow;
}

/// ワークスペース全体のレイアウト状態。
///
/// 4 つのペインスロット（`topLeft` / `topRight` / `bottomLeft` /
/// `bottomRight`）と、3 本のスプリッタ比率を持つ。空スロット（タブ 0 個）の
/// 扱いと描画構成の決定は `resolveWorkspaceLayout`
/// （`workspace_layout_mode.dart`）が担う。
@freezed
abstract class WorkspaceLayout with _$WorkspaceLayout {
  const factory WorkspaceLayout({
    required PaneSlot topLeft,
    required PaneSlot topRight,
    required PaneSlot bottomLeft,

    /// 右下スロット。既定 seed では空で、ユーザーがタブを移動して初めて
    /// 4 分割になる（ADR-0068）。
    @Default(PaneSlot.empty) PaneSlot bottomRight,

    /// 上段の高さ比率（0..1）。上下スプリッタで変化する。
    @Default(0.62) double topRatio,

    /// **上段**における `topLeft` の幅比率（0..1）。上段の左右スプリッタで
    /// 変化する。下段の分割位置とは独立（ADR-0068）。
    @Default(0.5) double leftRatio,

    /// **下段**における `bottomLeft` の幅比率（0..1）。下段の左右スプリッタで
    /// 変化する。上段の分割位置とは独立（ADR-0068）。
    @Default(0.5) double bottomLeftRatio,
  }) = _WorkspaceLayout;

  const WorkspaceLayout._();

  /// スロット id から対応する [PaneSlot] を取り出す。
  PaneSlot slot(PaneSlotId id) => switch (id) {
    PaneSlotId.topLeft => topLeft,
    PaneSlotId.topRight => topRight,
    PaneSlotId.bottomLeft => bottomLeft,
    PaneSlotId.bottomRight => bottomRight,
  };

  /// 指定スロットを差し替えた新しいレイアウトを返す。
  WorkspaceLayout withSlot(PaneSlotId id, PaneSlot value) => switch (id) {
    PaneSlotId.topLeft => copyWith(topLeft: value),
    PaneSlotId.topRight => copyWith(topRight: value),
    PaneSlotId.bottomLeft => copyWith(bottomLeft: value),
    PaneSlotId.bottomRight => copyWith(bottomRight: value),
  };

  /// コンテンツ（タブ 1 つ以上）を持つスロットの id を `PaneSlotId.values`
  /// の順で返す。
  List<PaneSlotId> get nonEmptySlots => [
    for (final id in PaneSlotId.values)
      if (slot(id).isNotEmpty) id,
  ];

  /// id 一致のタブを返す。見つからなければ `null`。
  WorkspaceTab? tabById(String? tabId) {
    if (tabId == null) {
      return null;
    }
    for (final id in PaneSlotId.values) {
      for (final tab in slot(id).tabs) {
        if (tab.id == tabId) {
          return tab;
        }
      }
    }
    return null;
  }
}
