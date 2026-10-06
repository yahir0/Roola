import 'package:flutter/painting.dart';

/// 計器の数値用書体（Barlow Condensed）とラベル用書体（Chakra Petch）。
/// アクティビティタブの描画に限って使う（ADR-0067 D6）。
///
/// 書体はこのパッケージの `fonts:` で宣言しているため、使う側のアプリからは
/// `packages/roola_activity/` 付きの名前で参照する（ADR-0069）。
const String meterNumberFont = 'packages/roola_activity/BarlowCondensed';
const String meterLabelFont = 'packages/roola_activity/ChakraPetch';

/// Painter で毎フレーム描く文字のレイアウト済み [TextPainter] キャッシュ。
///
/// メーターは同じ文字列（目盛り数字・ラベル）を毎フレーム描くため、レイアウトを
/// 使い回して描画コストを抑える。キーは文字列・書体・サイズ・太さ・色・字間・発光色。
class MeterTextCache {
  final Map<String, TextPainter> _cache = {};

  static const int _maxEntries = 600;

  TextPainter get(
    String text, {
    required String font,
    required double size,
    required Color color,
    FontWeight weight = FontWeight.w600,
    double letterSpacing = 0,
    Color? glow,
  }) {
    final key =
        '$text|$font|${size.toStringAsFixed(1)}|${weight.value}|'
        '${color.toARGB32()}|${letterSpacing.toStringAsFixed(1)}|'
        '${glow?.toARGB32()}';
    final cached = _cache[key];
    if (cached != null) {
      return cached;
    }
    if (_cache.length >= _maxEntries) {
      for (final p in _cache.values) {
        p.dispose();
      }
      _cache.clear();
    }
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: font,
          fontSize: size,
          fontWeight: weight,
          color: color,
          letterSpacing: letterSpacing,
          height: 1,
          shadows: glow == null
              ? null
              : [Shadow(color: glow, blurRadius: size * 0.25)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    _cache[key] = painter;
    return painter;
  }

  void dispose() {
    for (final p in _cache.values) {
      p.dispose();
    }
    _cache.clear();
  }
}

/// 文字の配置基準。
enum MeterTextAnchor { center, left, right, baselineLeft }

/// [painter] を [anchor] に合わせて [offset] に描く。
void paintMeterText(
  Canvas canvas,
  TextPainter painter,
  Offset offset, {
  MeterTextAnchor anchor = MeterTextAnchor.center,
}) {
  final dx = switch (anchor) {
    MeterTextAnchor.center => -painter.width / 2,
    MeterTextAnchor.left || MeterTextAnchor.baselineLeft => 0.0,
    MeterTextAnchor.right => -painter.width,
  };
  final dy = anchor == MeterTextAnchor.baselineLeft
      ? -painter.computeDistanceToActualBaseline(TextBaseline.alphabetic)
      : -painter.height / 2;
  painter.paint(canvas, offset + Offset(dx, dy));
}
