import 'package:freezed_annotation/freezed_annotation.dart';

part 'cc_usage.freezed.dart';

/// Claude Code の使用量集計結果（ADR-0060）。
///
/// `~/.claude/projects/**/*.jsonl` を集計して得る、当日（ローカルタイム）の
/// トークン種別別合計と推定コスト。トップバーのアクティビティモニタが
/// イベント駆動で更新する表示専用の状態で、永続化を伴わないため DTO 分離は
/// しない。コストは単価表に基づく**推定**であり、厳密な請求額ではない。
@freezed
abstract class CcUsage with _$CcUsage {
  const factory CcUsage({
    /// 通常入力トークンの合計。
    required int inputTokens,

    /// 出力トークンの合計。
    required int outputTokens,

    /// キャッシュ読み取りトークンの合計。
    required int cacheReadTokens,

    /// キャッシュ生成（書き込み）トークンの合計。
    required int cacheCreationTokens,

    /// モデル別単価で算定した推定コスト（USD）。未知モデル分は 0 とする。
    required double estimatedCostUsd,
  }) = _CcUsage;

  const CcUsage._();

  /// 集計前 / データ不在時に使うゼロ値。
  static const CcUsage zero = CcUsage(
    inputTokens: 0,
    outputTokens: 0,
    cacheReadTokens: 0,
    cacheCreationTokens: 0,
    estimatedCostUsd: 0,
  );

  /// 全種別を合算したトークン総数。トップバーの要約値に使う。
  int get totalTokens =>
      inputTokens + outputTokens + cacheReadTokens + cacheCreationTokens;
}
