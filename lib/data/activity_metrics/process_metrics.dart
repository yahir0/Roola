import 'package:freezed_annotation/freezed_annotation.dart';

part 'process_metrics.freezed.dart';

/// 1 プロセスの CPU / メモリ / I/O 占有（ADR-0039 / ADR-0048）。
///
/// アクティビティモニタのポップオーバーに出す上位プロセス一覧の 1 行ぶん。
/// CPU / メモリ ソート時は [cpuPercent] / [memoryBytes] が埋まる
/// （[ioBytesPerSec] は 0）。ディスク / ネットワーク ソート時はネイティブ側で
/// 1 秒サンプリングして算出した per-second レートを [ioBytesPerSec] に
/// 持ち、CPU / メモリ列は 0 のままにする。
@freezed
abstract class ProcessMetrics with _$ProcessMetrics {
  const factory ProcessMetrics({
    /// プロセス ID。
    required int pid,

    /// プロセス名（実行ファイルの basename）。
    required String name,

    /// CPU 使用率（%）。マルチコアでは 100 を超えうる。
    @Default(0) double cpuPercent,

    /// 常駐メモリ（RSS, bytes）。
    @Default(0) int memoryBytes,

    /// I/O レート（B/s）。ディスク / ネットワーク ソート時のみ意味を持つ。
    @Default(0) int ioBytesPerSec,
  }) = _ProcessMetrics;
}
