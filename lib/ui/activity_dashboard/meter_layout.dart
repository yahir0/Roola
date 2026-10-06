import 'dart:math' as math;

/// TACHO 盤面のサイズ決定（純粋関数）。ペインの大きさに合わせて全メーターが
/// 収まる最大サイズを選び、どうしても収まらない極端に小さいペインでだけ
/// スクロールさせる。

/// CLASSIC / DIGITAL の各メーターの一辺。
class DialSizes {
  const DialSizes({
    required this.big,
    required this.small,
    required this.core,
    required this.fits,
  });

  final double big;
  final double small;
  final double core;

  /// 与えられた領域に全メーターが収まったか（false ならスクロールが必要）。
  final bool fits;
}

/// 大メーター同士の間隔 / 小メーター同士 / コア別同士 / 段の間隔。
const double dialMainGap = 16;
const double dialSubGap = 12;
const double dialCoreGap = 10;
const double dialSectionGap = 16;

/// コア別の見出し（CPU CORES）の高さ。
const double dialCoreHeading = 24;

const double _maxBig = 400;
const double _minBig = 96;

double _smallFor(double big) => (big * 0.5).clamp(72.0, 200.0);
double _coreFor(double big) => (big * 0.36).clamp(60.0, 140.0);

int _rows(int count, double size, double gap, double width) {
  if (count == 0) {
    return 0;
  }
  final perRow = math.max(1, ((width + gap) / (size + gap)).floor());
  return (count / perRow).ceil();
}

double _block(int count, double size, double gap, double width) {
  final rows = _rows(count, size, gap, width);
  return rows == 0 ? 0 : rows * size + (rows - 1) * gap;
}

/// 盤面全体の高さ（[big] を選んだとき）。
double dialBoardHeight({
  required double big,
  required double width,
  required int mainCount,
  required int subCount,
  required int coreCount,
}) {
  var h = _block(mainCount, big, dialMainGap, width);
  if (subCount > 0) {
    h += dialSectionGap + _block(subCount, _smallFor(big), dialSubGap, width);
  }
  if (coreCount > 0) {
    h +=
        dialSectionGap +
        dialCoreHeading +
        _block(coreCount, _coreFor(big), dialCoreGap, width);
  }
  return h;
}

/// [width] × [height] に収まる最大のメーターサイズを選ぶ。
DialSizes fitDials({
  required double width,
  required double height,
  required int mainCount,
  required int subCount,
  required int coreCount,
}) {
  for (var big = math.min(_maxBig, width); big >= _minBig; big -= 4) {
    final h = dialBoardHeight(
      big: big,
      width: width,
      mainCount: mainCount,
      subCount: subCount,
      coreCount: coreCount,
    );
    if (h <= height) {
      return DialSizes(
        big: big,
        small: _smallFor(big),
        core: _coreFor(big),
        fits: true,
      );
    }
  }
  final big = math.max(_minBig, math.min(_minBig, width));
  return DialSizes(
    big: big,
    small: _smallFor(big),
    core: _coreFor(big),
    fits: false,
  );
}

/// RACE クラスタのレイアウト。
///
/// - `wide`: 実車と同じ横長（21:9）。中央にバーグラフ、左右にパネル
/// - `compact`: 狭いペイン向けの縦長。上にバーグラフ、下に左右パネルを並べる
enum RaceLayout { wide, compact }

/// RACE クラスタの大きさとレイアウト。
class RaceSize {
  const RaceSize({
    required this.layout,
    required this.width,
    required this.height,
    required this.fits,
  });

  final RaceLayout layout;
  final double width;
  final double height;
  final bool fits;
}

/// 横長レイアウトの縦横比（高さ / 幅）と、縦長レイアウトの縦横比。
const double raceWideAspect = 9 / 21;
const double raceCompactAspect = 0.84;

/// この幅未満は縦長レイアウトにする（横長だと文字が小さくなりすぎる）。
const double raceWideMinWidth = 600;

/// 縦長レイアウトでもこれ未満には縮めない（それ以下はスクロール）。
const double raceMinWidth = 320;

/// [width] × [height] に収まる RACE クラスタの大きさを選ぶ。
RaceSize fitRace({required double width, required double height}) {
  // 横長: 幅いっぱい、高さが足りなければ高さに合わせて縮める。
  final wideWidth = math.min(width, height / raceWideAspect);
  if (wideWidth >= raceWideMinWidth) {
    return RaceSize(
      layout: RaceLayout.wide,
      width: wideWidth,
      height: wideWidth * raceWideAspect,
      fits: true,
    );
  }
  final compactWidth = math.min(width, height / raceCompactAspect);
  if (compactWidth >= raceMinWidth) {
    return RaceSize(
      layout: RaceLayout.compact,
      width: compactWidth,
      height: compactWidth * raceCompactAspect,
      fits: true,
    );
  }
  final w = math.max(raceMinWidth, math.min(width, raceMinWidth));
  return RaceSize(
    layout: RaceLayout.compact,
    width: w,
    height: w * raceCompactAspect,
    fits: false,
  );
}

/// LEVEL の寸法。
const double levelScaleWidth = 34;
const double levelChannelWidth = 20;
const double levelChannelGap = 8;
const double levelGroupExtra = 6;
const double levelGroupSpacing = 26;
const double levelRunSpacing = 18;

/// グループ見出し（タイトル＋間隔）の高さ。
const double levelHeaderHeight = 24;

const double _levelMinScale = 0.6;
const double _levelMinHeight = 160;
const double _levelMaxHeight = 420;

/// LEVEL の各グループの描画寸法。
class LevelFit {
  const LevelFit({
    required this.channelScale,
    required this.meterHeight,
    required this.fits,
  });

  /// チャンネル幅・間隔の倍率（0.6–1）。
  final double channelScale;

  /// メーター（キャンバス）の高さ。
  final double meterHeight;

  final bool fits;
}

/// チャンネル数 [channels] のグループの幅（倍率 [scale]）。
double levelGroupWidth(int channels, double scale) =>
    levelScaleWidth +
    channels * (levelChannelWidth + levelChannelGap) * scale +
    levelGroupExtra;

/// [width] × [height] に LEVEL の全グループを収める。まずチャンネル幅を詰めて
/// 1 段に収まるか試し、無理なら折り返して段数ぶん高さを分け合う。
LevelFit fitLevel({
  required double width,
  required double height,
  required List<int> channelCounts,
}) {
  final n = channelCounts.length;
  final fixed =
      n * (levelScaleWidth + levelGroupExtra) + levelGroupSpacing * (n - 1);
  final variable =
      channelCounts.fold<int>(0, (a, c) => a + c) *
      (levelChannelWidth + levelChannelGap);
  final scale = variable <= 0
      ? 1.0
      : ((width - fixed) / variable).clamp(_levelMinScale, 1.0);

  var rows = 1;
  var line = 0.0;
  for (final c in channelCounts) {
    final w = levelGroupWidth(c, scale);
    if (line == 0) {
      line = w;
    } else if (line + levelGroupSpacing + w <= width) {
      line += levelGroupSpacing + w;
    } else {
      rows++;
      line = w;
    }
  }
  final perRow =
      (height - rows * levelHeaderHeight - (rows - 1) * levelRunSpacing) / rows;
  return LevelFit(
    channelScale: scale,
    meterHeight: perRow.clamp(_levelMinHeight, _levelMaxHeight),
    fits: perRow >= _levelMinHeight,
  );
}
