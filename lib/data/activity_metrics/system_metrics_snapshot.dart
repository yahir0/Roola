import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:roola/data/activity_metrics/system_metrics.dart';

part 'system_metrics_snapshot.freezed.dart';

/// 1 サンプリング時点でのシステムメトリクスと、ディスク / ネットワーク I/O の
/// 計算済みレート（ADR-0048 D4）。
///
/// [SystemMetrics] は累積カウンタを含む素データ。レート（B/s）は前回 snapshot
/// との差分 ÷ 経過秒数で計算しないと表示できないので、計算済み値を
/// [diskBytesPerSec] / [networkBytesPerSec] として持たせる。CPU% / メモリ% は
/// 既に rate なのでそのまま [metrics] 側を参照する。
///
/// 表示専用の状態クラスのため DTO 分離はしない。
@freezed
abstract class SystemMetricsSnapshot with _$SystemMetricsSnapshot {
  const factory SystemMetricsSnapshot({
    /// この snapshot 時点の素データ（累積カウンタ含む）。
    required SystemMetrics metrics,

    /// ディスク I/O レート（read + write の合計、B/s）。初回 snapshot は 0。
    required double diskBytesPerSec,

    /// ネットワーク I/O レート（in + out の合計、B/s）。初回 snapshot は 0。
    required double networkBytesPerSec,
  }) = _SystemMetricsSnapshot;

  const SystemMetricsSnapshot._();

  /// 取得前 / 取得失敗時に使うゼロ値。
  static const SystemMetricsSnapshot zero = SystemMetricsSnapshot(
    metrics: SystemMetrics.zero,
    diskBytesPerSec: 0,
    networkBytesPerSec: 0,
  );
}
