import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_tab.dart';

part 'workspace_layout.freezed.dart';

/// 3 つのペインスロットの識別子（ADR-0026）。
enum PaneSlotId { topLeft, topRight, bottom }

/// ワークスペース全体のレイアウト状態。
///
/// 3 つのペインスロット（`topLeft` / `topRight` / `bottom`）と、2 本の
/// スプリッタ比率を持つ。空スロット（タブ 0 個）の扱いと描画モードの決定は
/// `resolveWorkspaceLayout`（`workspace_layout_mode.dart`）が担う。
@freezed
abstract class WorkspaceLayout with _$WorkspaceLayout {
  const factory WorkspaceLayout({
    required PaneSlot topLeft,
    required PaneSlot topRight,
    required PaneSlot bottom,

    /// 上段の高さ比率（0..1）。上下スプリッタで変化する。
    @Default(0.62) double topRatio,

    /// 上段における `topLeft` の幅比率（0..1）。左右スプリッタで変化する。
    @Default(0.5) double leftRatio,
  }) = _WorkspaceLayout;

  const WorkspaceLayout._();

  /// スロット id から対応する [PaneSlot] を取り出す。
  PaneSlot slot(PaneSlotId id) => switch (id) {
    PaneSlotId.topLeft => topLeft,
    PaneSlotId.topRight => topRight,
    PaneSlotId.bottom => bottom,
  };

  /// 指定スロットを差し替えた新しいレイアウトを返す。
  WorkspaceLayout withSlot(PaneSlotId id, PaneSlot value) => switch (id) {
    PaneSlotId.topLeft => copyWith(topLeft: value),
    PaneSlotId.topRight => copyWith(topRight: value),
    PaneSlotId.bottom => copyWith(bottom: value),
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
