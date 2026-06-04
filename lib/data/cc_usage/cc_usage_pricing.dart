/// Claude Code 使用量の推定コスト算定に使うモデル別単価（ADR-0060）。
///
/// 単価は USD / 100 万トークン。外部取得すると自己完結方針（ADR-0005）に
/// 反しオフラインで壊れるため、リポジトリ内の定数として保持する。値は
/// Anthropic 公開価格を基にした**推定**で、厳密な請求額の算定には用いない。
library;

/// 1 モデルのトークン種別別単価（USD / 100 万トークン）。
class CcModelPricing {
  const CcModelPricing({
    required this.inputPerMtok,
    required this.outputPerMtok,
    required this.cacheReadPerMtok,
    required this.cacheCreationPerMtok,
  });

  /// 通常入力トークンの単価。
  final double inputPerMtok;

  /// 出力トークンの単価。
  final double outputPerMtok;

  /// キャッシュ読み取りトークンの単価。
  final double cacheReadPerMtok;

  /// キャッシュ生成（書き込み）トークンの単価。
  final double cacheCreationPerMtok;

  /// トークン種別ごとの数量から推定コスト（USD）を算定する。
  double cost({
    required int inputTokens,
    required int outputTokens,
    required int cacheReadTokens,
    required int cacheCreationTokens,
  }) {
    const perMtok = 1000000;
    return inputTokens / perMtok * inputPerMtok +
        outputTokens / perMtok * outputPerMtok +
        cacheReadTokens / perMtok * cacheReadPerMtok +
        cacheCreationTokens / perMtok * cacheCreationPerMtok;
  }
}

/// モデルファミリ別の単価表。`message.model`（例: `claude-opus-4-8`）の
/// バージョン差に強いよう、ファミリ名（opus / sonnet / haiku）で引く。
///
/// キャッシュ生成単価は 5 分 TTL（入力単価の 1.25 倍）を採用する。
const Map<String, CcModelPricing> _familyPricing = {
  'opus': CcModelPricing(
    inputPerMtok: 15,
    outputPerMtok: 75,
    cacheReadPerMtok: 1.5,
    cacheCreationPerMtok: 18.75,
  ),
  'sonnet': CcModelPricing(
    inputPerMtok: 3,
    outputPerMtok: 15,
    cacheReadPerMtok: 0.3,
    cacheCreationPerMtok: 3.75,
  ),
  'haiku': CcModelPricing(
    inputPerMtok: 0.8,
    outputPerMtok: 4,
    cacheReadPerMtok: 0.08,
    cacheCreationPerMtok: 1,
  ),
};

/// [model] 文字列に対応する単価を返す。単価表に無いモデルは null
/// （呼び出し側はコスト 0 として扱い、トークンは集計に算入する）。
CcModelPricing? pricingForModel(String? model) {
  if (model == null) return null;
  final lower = model.toLowerCase();
  for (final entry in _familyPricing.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }
  return null;
}
