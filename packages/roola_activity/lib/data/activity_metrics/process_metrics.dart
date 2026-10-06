import 'package:freezed_annotation/freezed_annotation.dart';

part 'process_metrics.freezed.dart';

/// 1 プロセスの CPU / メモリ占有（ADR-0039）。
///
/// アクティビティモニタのポップオーバーに出す上位プロセス一覧の 1 行ぶん。
@freezed
abstract class ProcessMetrics with _$ProcessMetrics {
  const factory ProcessMetrics({
    /// プロセス ID。
    required int pid,

    /// プロセス名（実行ファイルの basename）。
    required String name,

    /// CPU 使用率（%）。マルチコアでは 100 を超えうる。
    required double cpuPercent,

    /// 常駐メモリ（RSS, bytes）。
    required int memoryBytes,
  }) = _ProcessMetrics;
}
