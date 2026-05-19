import 'package:freezed_annotation/freezed_annotation.dart';

part 'system_metrics.freezed.dart';

/// システム全体の CPU / メモリ使用状況（ADR-0039）。
///
/// トップバーのアクティビティモニタが 1 秒ポーリングで更新する表示専用の
/// 状態。永続化を伴わないため DTO 分離はしない。
@freezed
abstract class SystemMetrics with _$SystemMetrics {
  const factory SystemMetrics({
    /// システム全体の CPU 使用率（0–100）。
    required double cpuPercent,

    /// 使用中メモリ（bytes）。
    required int memoryUsedBytes,

    /// 物理メモリ総容量（bytes）。
    required int memoryTotalBytes,
  }) = _SystemMetrics;

  const SystemMetrics._();

  /// 取得前 / 取得失敗時に使うゼロ値。
  static const SystemMetrics zero = SystemMetrics(
    cpuPercent: 0,
    memoryUsedBytes: 0,
    memoryTotalBytes: 0,
  );

  /// メモリ使用率（0–100）。総容量が不明なときは 0。
  double get memoryPercent => memoryTotalBytes <= 0
      ? 0
      : memoryUsedBytes / memoryTotalBytes * 100;
}
