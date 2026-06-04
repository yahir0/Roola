import 'package:intl/intl.dart' as intl;

/// 使用量メーターの数値整形ヘルパ（ADR-0060）。トップバーの狭い要約と
/// ポップオーバーの内訳で表示形式を統一する。
class CcUsageFormat {
  const CcUsageFormat._();

  /// トップバー要約用のコンパクトなトークン表記（例: 0 / 945 / 12.3K / 4.5M）。
  static String compactTokens(int tokens) {
    if (tokens < 1000) return '$tokens';
    if (tokens < 1000000) return '${(tokens / 1000).toStringAsFixed(1)}K';
    return '${(tokens / 1000000).toStringAsFixed(1)}M';
  }

  /// 内訳用の桁区切り付き整数（例: 1,234,567）。
  static String groupedTokens(int tokens) =>
      intl.NumberFormat.decimalPattern().format(tokens);

  /// 推定コスト（USD）。小さい額でも桁が見えるよう常に小数 2 桁。
  static String cost(double usd) => '\$${usd.toStringAsFixed(2)}';
}
