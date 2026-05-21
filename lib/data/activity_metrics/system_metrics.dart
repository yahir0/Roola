import 'package:freezed_annotation/freezed_annotation.dart';

part 'system_metrics.freezed.dart';

/// ネイティブ層から取得したシステムメトリクスの素データ（ADR-0039 / ADR-0048）。
///
/// CPU / メモリは完成値（%・bytes）、ディスク / ネットワークは累積カウンタ
/// （system boot 以降の総バイト）。レート（B/s）への変換は ViewModel 側で
/// 前回 snapshot との差分から行う（ADR-0048 D4）。永続化を伴わないため DTO
/// 分離はしない。
@freezed
abstract class SystemMetrics with _$SystemMetrics {
  const factory SystemMetrics({
    /// システム全体の CPU 使用率（0–100）。
    required double cpuPercent,

    /// 使用中メモリ（bytes）。
    required int memoryUsedBytes,

    /// 物理メモリ総容量（bytes）。
    required int memoryTotalBytes,

    /// ディスクからの累積読み込みバイト数（IOBlockStorageDriver 合計）。
    required int diskReadBytes,

    /// ディスクへの累積書き込みバイト数（IOBlockStorageDriver 合計）。
    required int diskWrittenBytes,

    /// ネットワーク受信の累積バイト数（loopback 除く全インターフェイス）。
    required int networkInBytes,

    /// ネットワーク送信の累積バイト数（loopback 除く全インターフェイス）。
    required int networkOutBytes,
  }) = _SystemMetrics;

  const SystemMetrics._();

  /// 取得前 / 取得失敗時に使うゼロ値。
  static const SystemMetrics zero = SystemMetrics(
    cpuPercent: 0,
    memoryUsedBytes: 0,
    memoryTotalBytes: 0,
    diskReadBytes: 0,
    diskWrittenBytes: 0,
    networkInBytes: 0,
    networkOutBytes: 0,
  );

  /// メモリ使用率（0–100）。総容量が不明なときは 0。
  double get memoryPercent =>
      memoryTotalBytes <= 0 ? 0 : memoryUsedBytes / memoryTotalBytes * 100;
}
