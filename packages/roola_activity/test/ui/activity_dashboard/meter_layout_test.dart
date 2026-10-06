import 'package:flutter_test/flutter_test.dart';
import 'package:roola_activity/ui/activity_dashboard/meter_layout.dart';

void main() {
  group('fitDials', () {
    test('標準的な右ペイン（560×640）で大 2・小 5 が全部収まる', () {
      final sizes = fitDials(
        width: 560,
        height: 640,
        mainCount: 2,
        subCount: 5,
        coreCount: 0,
      );

      expect(sizes.fits, isTrue);
      expect(
        dialBoardHeight(
          big: sizes.big,
          width: 560,
          mainCount: 2,
          subCount: 5,
          coreCount: 0,
        ),
        lessThanOrEqualTo(640),
      );
    });

    test('広いほど大きく、上限は 400', () {
      final small = fitDials(
        width: 600,
        height: 600,
        mainCount: 2,
        subCount: 5,
        coreCount: 0,
      );
      final large = fitDials(
        width: 2400,
        height: 1600,
        mainCount: 2,
        subCount: 5,
        coreCount: 0,
      );

      expect(large.big, greaterThan(small.big));
      expect(large.big, lessThanOrEqualTo(400));
    });

    test('全コア表示の分も含めて高さに収める', () {
      final sizes = fitDials(
        width: 800,
        height: 900,
        mainCount: 2,
        subCount: 5,
        coreCount: 10,
      );

      expect(sizes.fits, isTrue);
      expect(
        dialBoardHeight(
          big: sizes.big,
          width: 800,
          mainCount: 2,
          subCount: 5,
          coreCount: 10,
        ),
        lessThanOrEqualTo(900),
      );
    });

    test('極端に小さいと収まらず、最小サイズでスクロールになる', () {
      final sizes = fitDials(
        width: 200,
        height: 150,
        mainCount: 2,
        subCount: 5,
        coreCount: 0,
      );

      expect(sizes.fits, isFalse);
      expect(sizes.big, 64);
    });

    test('高さを縮めるとメーターも縮み、スクロールせずに収まる', () {
      final tall = fitDials(
        width: 560,
        height: 640,
        mainCount: 2,
        subCount: 5,
        coreCount: 0,
      );
      final short = fitDials(
        width: 560,
        height: 200,
        mainCount: 2,
        subCount: 5,
        coreCount: 0,
      );

      expect(short.fits, isTrue);
      expect(short.big, lessThan(tall.big));
    });

    test('横長で背の低いペインは大・小メーターを 1 段に並べる', () {
      final sizes = fitDials(
        width: 1400,
        height: 280,
        mainCount: 2,
        subCount: 5,
        coreCount: 0,
      );

      expect(sizes.fits, isTrue);
      expect(sizes.inline, isTrue);
      expect(sizes.big, lessThanOrEqualTo(280));
      expect(
        dialInlineWidth(big: sizes.big, mainCount: 2, subCount: 5),
        lessThanOrEqualTo(1400),
      );
      // 段に積むより大きく描ける。
      expect(sizes.big, greaterThan((280 - dialSectionGap) / 1.5));
    });

    test('縦長のペインは段に積む', () {
      final sizes = fitDials(
        width: 560,
        height: 900,
        mainCount: 2,
        subCount: 5,
        coreCount: 0,
      );

      expect(sizes.inline, isFalse);
    });
  });

  group('fitRace', () {
    test('広いペインは横長で、高さに収まるよう縮める', () {
      final fit = fitRace(width: 1400, height: 400);

      expect(fit.layout, RaceLayout.wide);
      expect(fit.height, lessThanOrEqualTo(400));
      expect(fit.width, closeTo(400 / raceWideAspect, 1e-9));
    });

    test('標準的な右ペイン（560×640）は縦長レイアウトで収まる', () {
      final fit = fitRace(width: 560, height: 640);

      expect(fit.layout, RaceLayout.compact);
      expect(fit.fits, isTrue);
      expect(fit.width, lessThanOrEqualTo(560));
      expect(fit.height, lessThanOrEqualTo(640));
    });

    test('横長で背の低いペインは横長レイアウトに縮めて収める', () {
      final fit = fitRace(width: 1200, height: 200);

      expect(fit.layout, RaceLayout.wide);
      expect(fit.fits, isTrue);
      expect(fit.height, lessThanOrEqualTo(200));
    });

    test('極端に小さいと収まらずスクロールになる', () {
      final fit = fitRace(width: 200, height: 120);

      expect(fit.fits, isFalse);
      expect(fit.width, raceMinWidth);
    });
  });

  group('fitLevel', () {
    test('広ければ詰めずに 1 段', () {
      final fit = fitLevel(
        width: 1200,
        height: 400,
        channelCounts: [1, 2, 2, 2, 3],
      );

      expect(fit.channelScale, 1);
      expect(fit.fits, isTrue);
      expect(fit.meterHeight, 400 - levelHeaderHeight);
    });

    test('標準的な右ペイン（560×640）はチャンネルを詰めて収める', () {
      final fit = fitLevel(
        width: 560,
        height: 640,
        channelCounts: [1, 2, 2, 2, 3],
      );

      expect(fit.fits, isTrue);
      expect(fit.channelScale, lessThan(1));
      expect(fit.channelScale, greaterThanOrEqualTo(0.6));
    });

    test('極端に低いと収まらずスクロールになる', () {
      final fit = fitLevel(width: 300, height: 200, channelCounts: [10, 2, 2]);

      expect(fit.fits, isFalse);
    });
  });
}
