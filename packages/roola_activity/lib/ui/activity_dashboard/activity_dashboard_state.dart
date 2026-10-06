import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_dashboard_state.freezed.dart';

/// アクティビティタブが描画する最新サンプル（ADR-0067）。
///
/// 値は 250ms ごとのスナップショット差分から算出した「目標値」で、メーターの
/// なめらかな動きは描画側が補間して作る（design D5）。取得できない項目は null
/// で、その項目のメーターは表示しない。表示専用・非永続のため DTO 分離なし。
@freezed
abstract class ActivityDashboardState with _$ActivityDashboardState {
  const factory ActivityDashboardState({
    /// CPU 使用率（0–1）。差分が取れるまでは null。
    double? cpu,

    /// コア別 CPU 使用率（0–1）。取得できない環境では空。
    @Default(<double>[]) List<double> cores,

    /// 論理コア数（ロードアベレージの満点に使う）。不明なら 0。
    @Default(0) int coreCount,

    @Default(0) int memoryUsedBytes,
    @Default(0) int memoryTotalBytes,
    int? swapUsedBytes,
    int? swapTotalBytes,

    /// ディスク読み込み / 書き込み（B/s）。
    double? diskReadRate,
    double? diskWriteRate,

    /// ネットワーク受信 / 送信（B/s）。
    double? netRxRate,
    double? netTxRate,

    /// ロードアベレージ `[1 分, 5 分, 15 分]`。macOS のみ。
    List<double>? loadAverage,

    int? uptimeSeconds,
  }) = _ActivityDashboardState;

  const ActivityDashboardState._();

  /// メモリ使用率（0–1）。
  double get memory =>
      memoryTotalBytes <= 0 ? 0 : memoryUsedBytes / memoryTotalBytes;

  /// スワップ使用率（0–1）。容量が不明・0 なら null。
  double? get swap {
    final total = swapTotalBytes;
    final used = swapUsedBytes;
    if (total == null || used == null || total <= 0) {
      return null;
    }
    return used / total;
  }

  /// 全コア表示に必要なコア別の値があるか。
  bool get hasPerCore => cores.isNotEmpty;
}
