import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_dashboard_settings.freezed.dart';

/// アクティビティタブの表示モード（ADR-0067 D2）。
///
/// - `level`: 放送用レベルゲージ風の縦 LED バー
/// - `tacho`: タコメータ（スタイルは [TachoStyle]）
enum ActivityDisplayMode { level, tacho }

/// TACHO モードのスタイル。
///
/// - `classic`: 針のタコメータ
/// - `digital`: オレンジ蛍光表示管（VFD）風のセグメント円弧
/// - `race`: Track Mode 風クラスタ（右肩上がり CPU バーグラフ＋シフトライト）
enum TachoStyle { classic, digital, race }

/// アクティビティタブの表示設定。次回以降も同じ表示で開くため永続化する。
@freezed
abstract class ActivityDashboardSettings with _$ActivityDashboardSettings {
  const factory ActivityDashboardSettings({
    @Default(ActivityDisplayMode.level) ActivityDisplayMode mode,
    @Default(TachoStyle.classic) TachoStyle tachoStyle,

    /// CPU をコア別にも表示するか。既定は全体 1 本のみ。
    @Default(false) bool showAllCores,
  }) = _ActivityDashboardSettings;

  /// 既定値（LEVEL・CLASSIC・全コア表示オフ）。
  factory ActivityDashboardSettings.defaults() =>
      const ActivityDashboardSettings();
}
