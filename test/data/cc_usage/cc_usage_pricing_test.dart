import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/cc_usage/cc_usage_pricing.dart';

void main() {
  group('pricingForModel', () {
    test('ファミリ名で opus / sonnet / haiku を引ける（バージョン差を含む）', () {
      expect(pricingForModel('claude-opus-4-8'), isNotNull);
      expect(pricingForModel('claude-sonnet-4-6'), isNotNull);
      expect(pricingForModel('claude-haiku-4-5-20251001'), isNotNull);
    });

    test('未知モデルは null を返す', () {
      expect(pricingForModel('gpt-4o'), isNull);
      expect(pricingForModel(null), isNull);
    });
  });

  group('CcModelPricing.cost', () {
    test('トークン種別ごとに単価を適用して合算する', () {
      const pricing = CcModelPricing(
        inputPerMtok: 15,
        outputPerMtok: 75,
        cacheReadPerMtok: 1.5,
        cacheCreationPerMtok: 18.75,
      );

      // 100 万トークンずつ → 各単価がそのまま加算される。
      final cost = pricing.cost(
        inputTokens: 1000000,
        outputTokens: 1000000,
        cacheReadTokens: 1000000,
        cacheCreationTokens: 1000000,
      );

      expect(cost, closeTo(15 + 75 + 1.5 + 18.75, 1e-9));
    });

    test('トークンが 0 ならコストも 0', () {
      const pricing = CcModelPricing(
        inputPerMtok: 15,
        outputPerMtok: 75,
        cacheReadPerMtok: 1.5,
        cacheCreationPerMtok: 18.75,
      );
      expect(
        pricing.cost(
          inputTokens: 0,
          outputTokens: 0,
          cacheReadTokens: 0,
          cacheCreationTokens: 0,
        ),
        0,
      );
    });
  });
}
