import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:roola_activity/ui/activity_dashboard/activity_meter_palette.dart';
import 'package:roola_activity/ui/activity_dashboard/meter_animator.dart';
import 'package:roola_activity/ui/activity_dashboard/meter_layout.dart';
import 'package:roola_activity/ui/activity_dashboard/meter_text.dart';

/// RACE クラスタに載せる表示内容（数値の文字列と、項目の有無）。
///
/// メーターの位置は [MeterAnimator] から読む。ここにあるのは 250ms ごとに
/// 変わる数値表示と、取得できない項目を出さないための有無の情報。
class RaceReadouts {
  const RaceReadouts({
    required this.cpuNumber,
    required this.memoryText,
    required this.clock,
    required this.meridiem,
    this.swapText,
    this.loadText,
    this.rxText,
    this.txText,
    this.readText,
    this.writeText,
    this.uptimeText,
  });

  final String cpuNumber;
  final String memoryText;
  final String clock;
  final String meridiem;
  final String? swapText;
  final String? loadText;
  final String? rxText;
  final String? txText;
  final String? readText;
  final String? writeText;
  final String? uptimeText;

  @override
  bool operator ==(Object other) =>
      other is RaceReadouts &&
      other.cpuNumber == cpuNumber &&
      other.memoryText == memoryText &&
      other.clock == clock &&
      other.meridiem == meridiem &&
      other.swapText == swapText &&
      other.loadText == loadText &&
      other.rxText == rxText &&
      other.txText == txText &&
      other.readText == readText &&
      other.writeText == writeText &&
      other.uptimeText == uptimeText;

  @override
  int get hashCode => Object.hash(
    cpuNumber,
    memoryText,
    clock,
    meridiem,
    swapText,
    loadText,
    rxText,
    txText,
    readText,
    writeText,
    uptimeText,
  );
}

/// TACHO モードの RACE: GR86 / BRZ の Track Mode 風クラスタ（design D6）。
///
/// 上部にシフトライト、中央に 1 枚のクラスタ、全コア表示時は下にコア別の小さな
/// 右肩上がりバーグラフを並べる。クラスタはペインの幅と高さに収まる大きさを選び
/// （[fitRace]）、狭いペインでは縦長レイアウトに切り替える。極端に小さいペインで
/// だけスクロールする。
class RaceBoard extends StatelessWidget {
  const RaceBoard({
    required this.readouts,
    required this.coreCount,
    required this.animator,
    required this.textCache,
    super.key,
  });

  final RaceReadouts readouts;

  /// コア別表示の数。0 ならコア別を出さない。
  final int coreCount;
  final MeterAnimator animator;
  final MeterTextCache textCache;

  static const double _padding = 16;
  static const double _gap = 12;
  static const double _coreCellWidth = 160;
  static const double _coreRowHeight = 72;

  @override
  Widget build(BuildContext context) {
    final palette = ActivityMeterPalette.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - _padding * 2;
        final cols = math.max(2, (width / _coreCellWidth).floor());
        final coresHeight = coreCount == 0
            ? 0.0
            : (coreCount / cols).ceil() * _coreRowHeight + _gap;
        final clusterHeight =
            constraints.maxHeight -
            _padding * 2 -
            ShiftLightsPainter.height -
            _gap -
            coresHeight;
        final fit = fitRace(width: width, height: clusterHeight);
        final contentWidth = math.max(fit.width, width);
        final column = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              child: CustomPaint(
                size: const Size(
                  ShiftLightsPainter.width,
                  ShiftLightsPainter.height,
                ),
                painter: ShiftLightsPainter(
                  animator: animator,
                  palette: palette,
                ),
              ),
            ),
            const SizedBox(height: _gap),
            RepaintBoundary(
              child: CustomPaint(
                size: Size(fit.width, fit.height),
                painter: RaceClusterPainter(
                  layout: fit.layout,
                  readouts: readouts,
                  animator: animator,
                  palette: palette,
                  textCache: textCache,
                ),
              ),
            ),
            if (coreCount > 0) ...[
              const SizedBox(height: _gap),
              RepaintBoundary(
                child: CustomPaint(
                  size: Size(
                    contentWidth,
                    (coreCount / cols).ceil() * _coreRowHeight,
                  ),
                  painter: RaceCoresPainter(
                    coreCount: coreCount,
                    columns: cols,
                    rowHeight: _coreRowHeight,
                    animator: animator,
                    palette: palette,
                    textCache: textCache,
                  ),
                ),
              ),
            ],
          ],
        );
        if (fit.fits) {
          return Padding(
            padding: const EdgeInsets.all(_padding),
            child: Center(child: column),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(_padding),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: column,
          ),
        );
      },
    );
  }
}

/// 低い値を詰め、高い値を広げる非線形目盛り（タコメータの 0–4 が詰まって
/// いるのと同じ）。0–40% を全幅の 18% に割り当てる。
double raceScale(double v) =>
    v <= 0.4 ? v / 0.4 * 0.18 : 0.18 + (v - 0.4) / 0.6 * 0.82;

double _raceScaleInverse(double p) =>
    p <= 0.18 ? p / 0.18 * 0.4 : 0.4 + (p - 0.18) / 0.82 * 0.6;

/// 0: 通常 / 1: 橙（70%〜）/ 2: 赤（85%〜）。
int _zone(double v) => v >= 0.85
    ? 2
    : v >= 0.7
    ? 1
    : 0;

/// CPU バーグラフの目盛り（×10 %）。
const List<(double, String)> _cpuLabels = [
  (0, '0'),
  (0.2, '2'),
  (0.4, '4'),
  (0.5, '5'),
  (0.6, '6'),
  (0.7, '7'),
  (0.8, '8'),
  (0.9, '9'),
  (1, '10'),
];

/// 右肩上がりのバーグラフを描く（クラスタ中央とコア別で共用）。
void _paintWedge(
  Canvas canvas,
  ActivityMeterPalette palette,
  MeterTextCache textCache, {
  required double x0,
  required double x1,
  required double baseline,
  required double minHeight,
  required double maxHeight,
  required double value,
  required int bars,
  double labelSize = 0,
}) {
  final lit = [palette.raceFill, palette.raceCaution, palette.ledPeak];
  final dark = [
    palette.raceUnlit,
    palette.raceCautionUnlit,
    palette.raceRedUnlit,
  ];
  final pv = raceScale(value.clamp(0.0, 1.0));
  final barWidth = (x1 - x0) / bars;
  final gap = maxHeight * 0.05;
  double heightAt(double p) => minHeight + (maxHeight - minHeight) * p;

  final bar = Paint();
  final glow = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
  for (var i = 0; i < bars; i++) {
    final p = (i + 0.5) / bars;
    final z = _zone(_raceScaleInverse(p));
    final on = p <= pv;
    final h = heightAt(p);
    final rect = Rect.fromLTWH(
      x0 + i * barWidth,
      baseline - h,
      barWidth * 0.56,
      h,
    );
    if (on && z > 0) {
      canvas.drawRect(rect, glow..color = lit[z].withValues(alpha: 0.6));
    }
    canvas.drawRect(rect, bar..color = on ? lit[z] : dark[z]);
  }

  // 上縁と基線（ゾーンごとに色が変わる）。
  final cuts = [0.0, raceScale(0.7), raceScale(0.85), 1.0];
  final edge = Paint()..strokeWidth = math.max(2, maxHeight * 0.025);
  final base = Paint()..strokeWidth = 1.5;
  final edgeColors = [palette.tickMajor, palette.raceCaution, palette.ledPeak];
  for (var z = 0; z < 3; z++) {
    final pa = cuts[z];
    final pb = cuts[z + 1];
    final xa = x0 + pa * (x1 - x0);
    final xb = x0 + pb * (x1 - x0);
    canvas
      ..drawLine(
        Offset(xa, baseline - heightAt(pa) - gap),
        Offset(xb, baseline - heightAt(pb) - gap),
        edge..color = edgeColors[z],
      )
      ..drawLine(
        Offset(xa, baseline + 3),
        Offset(xb, baseline + 3),
        base..color = z == 0 ? palette.dimText : edgeColors[z],
      );
  }

  if (labelSize <= 0) {
    return;
  }
  for (final (v, text) in _cpuLabels) {
    final p = raceScale(v);
    final z = _zone(v);
    final painter = textCache.get(
      text,
      font: meterNumberFont,
      size: labelSize,
      color: edgeColors[z],
    );
    paintMeterText(
      canvas,
      painter,
      Offset(
        x0 + p * (x1 - x0),
        baseline - heightAt(p) - gap - labelSize * 0.35 - painter.height / 2,
      ),
    );
  }
}

/// RACE クラスタ本体。
///
/// 横長（[RaceLayout.wide]）は実車どおり中央にバーグラフ・左右にパネル。
/// 縦長（[RaceLayout.compact]）は上にバーグラフ、下に左右パネルを並べる。
/// 文字や線の太さは各ブロックの基準寸法 `u` に比例させ、縮めても崩れないように
/// する。
class RaceClusterPainter extends CustomPainter {
  RaceClusterPainter({
    required this.layout,
    required this.readouts,
    required this.animator,
    required this.palette,
    required this.textCache,
  }) : super(repaint: animator);

  final RaceLayout layout;
  final RaceReadouts readouts;
  final MeterAnimator animator;
  final ActivityMeterPalette palette;
  final MeterTextCache textCache;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(6)),
      Paint()..color = palette.stage,
    );

    switch (layout) {
      case RaceLayout.wide:
        final u = h;
        _paintCenterBlock(canvas, w, 0, u);
        _paintLeftPanel(
          canvas,
          Rect.fromLTWH(w * 0.045, h * 0.26, w * 0.2, 0),
          u,
        );
        _paintRightPanel(
          canvas,
          Rect.fromLTWH(w * 0.74, h * 0.26, w * 0.215, 0),
          u,
        );
        _paintUptime(canvas, Offset(w * 0.045, h * 0.83), u);
      case RaceLayout.compact:
        // 上段（バーグラフ）の高さを基準寸法にする。
        final u = w * 0.5;
        _paintCenterBlock(canvas, w, 0, u);
        final top = u * 1.06;
        _paintLeftPanel(canvas, Rect.fromLTWH(w * 0.05, top, w * 0.42, 0), u);
        _paintRightPanel(canvas, Rect.fromLTWH(w * 0.53, top, w * 0.42, 0), u);
        _paintUptime(canvas, Offset(w * 0.05, h - u * 0.04), u);
    }
  }

  /// 中央ブロック: 円の縁取り・左右へ伸びる水平線・CPU バーグラフ・数値。
  /// [height] がこのブロックの基準寸法。
  void _paintCenterBlock(Canvas canvas, double w, double top, double height) {
    final cx = w / 2;
    final cy = top + height * 0.5;
    final radius = height * 0.47;
    final y1 = top + height * 0.2;
    final y2 = top + height * 0.76;

    final well = Paint()..color = palette.meterWell;
    canvas
      ..drawRect(Rect.fromLTRB(w * 0.02, y1, w * 0.98, y2), well)
      ..drawCircle(Offset(cx, cy), radius, well);
    _paintTrim(canvas, w, cx, cy, radius, y1);
    _paintTrim(canvas, w, cx, cy, radius, y2);

    final x0 = cx - radius;
    final x1 = cx + radius;
    final baseline = y2 - height * 0.07;
    _paintWedge(
      canvas,
      palette,
      textCache,
      x0: x0,
      x1: x1,
      baseline: baseline,
      minHeight: height * 0.05,
      maxHeight: height * 0.36,
      value: animator.needle('cpu'),
      bars: 72,
      labelSize: height * 0.075,
    );
    paintMeterText(
      canvas,
      textCache.get(
        'CPU  ×10 %',
        font: meterLabelFont,
        size: height * 0.036,
        color: palette.labelText,
      ),
      Offset(x0, baseline + height * 0.05),
      anchor: MeterTextAnchor.baselineLeft,
    );

    final number = textCache.get(
      readouts.cpuNumber,
      font: meterNumberFont,
      size: height * 0.12,
      color: palette.tickMajor,
    );
    final numberBaseline = top + height * 0.885;
    paintMeterText(
      canvas,
      number,
      Offset(cx - number.width / 2, numberBaseline),
      anchor: MeterTextAnchor.baselineLeft,
    );
    paintMeterText(
      canvas,
      textCache.get(
        '%',
        font: meterLabelFont,
        size: height * 0.045,
        color: palette.tickMajor.withValues(alpha: 0.8),
      ),
      Offset(cx + number.width / 2 + height * 0.02, numberBaseline),
      anchor: MeterTextAnchor.baselineLeft,
    );
  }

  void _paintTrim(
    Canvas canvas,
    double w,
    double cx,
    double cy,
    double radius,
    double y,
  ) {
    final dx = math.sqrt(radius * radius - (cy - y) * (cy - y));
    final a = math.atan2(y - cy, -dx);
    final b = math.atan2(y - cy, dx);
    final path = Path()
      ..moveTo(w * 0.02, y)
      ..lineTo(cx - dx, y)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        a,
        b - a,
        false,
      )
      ..lineTo(w * 0.98, y);
    canvas.drawPath(
      path,
      Paint()
        ..color = palette.raceTrim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final cap = Paint()..color = palette.raceTrimCap;
    canvas
      ..drawCircle(Offset(w * 0.02, y), 2.5, cap)
      ..drawCircle(Offset(w * 0.98, y), 2.5, cap);
  }

  /// 左パネル: メモリ / スワップの横バー。[panel] は左上と幅だけを使う。
  void _paintLeftPanel(Canvas canvas, Rect panel, double u) {
    const ticks = ['0', '25', '50', '75', '100%'];
    _paintHBar(
      canvas,
      Rect.fromLTWH(panel.left, panel.top + u * 0.07, panel.width, u * 0.065),
      animator.needle('mem'),
      'MEMORY',
      readouts.memoryText,
      ticks,
    );
    if (readouts.swapText != null) {
      _paintHBar(
        canvas,
        Rect.fromLTWH(panel.left, panel.top + u * 0.3, panel.width, u * 0.065),
        animator.needle('swap'),
        'SWAP',
        readouts.swapText!,
        ticks,
      );
    }
  }

  void _paintUptime(Canvas canvas, Offset baselineLeft, double u) {
    if (readouts.uptimeText == null) {
      return;
    }
    paintMeterText(
      canvas,
      textCache.get(
        'UPTIME  ${readouts.uptimeText}',
        font: meterNumberFont,
        size: u * 0.038,
        color: palette.tickMajor.withValues(alpha: 0.8),
      ),
      baselineLeft,
      anchor: MeterTextAnchor.baselineLeft,
    );
  }

  /// 電圧計・油温計のような横バー（左パネル）。
  void _paintHBar(
    Canvas canvas,
    Rect rect,
    double value,
    String label,
    String readout,
    List<String> ticks,
  ) {
    final fs = rect.height * 0.62;
    paintMeterText(
      canvas,
      textCache.get(
        label,
        font: meterLabelFont,
        size: fs,
        color: palette.tickMinor,
      ),
      Offset(rect.left, rect.top - rect.height * 0.3),
      anchor: MeterTextAnchor.baselineLeft,
    );
    final readoutPainter = textCache.get(
      readout,
      font: meterNumberFont,
      size: fs * 1.15,
      color: palette.tickMajor,
    );
    paintMeterText(
      canvas,
      readoutPainter,
      Offset(rect.right - readoutPainter.width, rect.top - rect.height * 0.3),
      anchor: MeterTextAnchor.baselineLeft,
    );
    final v = value.clamp(0.0, 1.0);
    canvas
      ..drawRect(rect, Paint()..color = palette.raceBarTrack)
      ..drawRect(
        Rect.fromLTWH(rect.left, rect.top, rect.width * v, rect.height),
        Paint()..color = _zone(v) == 2 ? palette.ledPeak : palette.raceFill,
      );
    final divider = Paint()..color = palette.face;
    for (var i = 0; i < ticks.length; i++) {
      final tx = rect.left + rect.width * i / (ticks.length - 1);
      if (i > 0 && i < ticks.length - 1) {
        canvas.drawRect(
          Rect.fromLTWH(tx - 0.5, rect.top, 1, rect.height),
          divider,
        );
      }
      final painter = textCache.get(
        ticks[i],
        font: meterNumberFont,
        size: fs * 0.85,
        weight: FontWeight.w500,
        color: palette.tickMinor,
      );
      final x = (tx - painter.width / 2).clamp(
        rect.left,
        rect.right - painter.width,
      );
      paintMeterText(
        canvas,
        painter,
        Offset(x, rect.bottom + fs * 1.05),
        anchor: MeterTextAnchor.baselineLeft,
      );
    }
    canvas.drawRect(
      rect.deflate(0.5),
      Paint()
        ..color = palette.tickMinor
        ..style = PaintingStyle.stroke,
    );
  }

  /// 右パネル: ロードアベレージ・時刻と I/O のブロックゲージ。[panel] は左上と
  /// 幅だけを使う。
  void _paintRightPanel(Canvas canvas, Rect panel, double u) {
    final x = panel.left;
    final width = panel.width;
    final small = u * 0.036;
    final big = u * 0.06;
    final headerBaseline = panel.top + u * 0.015;
    final valueBaseline = panel.top + u * 0.085;
    if (readouts.loadText != null) {
      paintMeterText(
        canvas,
        textCache.get(
          'LOAD 1m',
          font: meterLabelFont,
          size: small,
          color: palette.tickMinor,
        ),
        Offset(x, headerBaseline),
        anchor: MeterTextAnchor.baselineLeft,
      );
      paintMeterText(
        canvas,
        textCache.get(
          readouts.loadText!,
          font: meterNumberFont,
          size: big,
          color: palette.tickMajor,
        ),
        Offset(x, valueBaseline),
        anchor: MeterTextAnchor.baselineLeft,
      );
    }
    final meridiem = textCache.get(
      readouts.meridiem,
      font: meterLabelFont,
      size: small,
      color: palette.tickMinor,
    );
    paintMeterText(
      canvas,
      meridiem,
      Offset(x + width - meridiem.width, headerBaseline),
      anchor: MeterTextAnchor.baselineLeft,
    );
    final clock = textCache.get(
      readouts.clock,
      font: meterNumberFont,
      size: big,
      color: palette.tickMajor,
    );
    paintMeterText(
      canvas,
      clock,
      Offset(x + width - clock.width, valueBaseline),
      anchor: MeterTextAnchor.baselineLeft,
    );

    final rows = <(String, String, String)>[
      if (readouts.rxText != null) ('RX', 'netRx', readouts.rxText!),
      if (readouts.txText != null) ('TX', 'netTx', readouts.txText!),
      if (readouts.readText != null) ('READ', 'diskR', readouts.readText!),
      if (readouts.writeText != null) ('WRITE', 'diskW', readouts.writeText!),
    ];
    for (var i = 0; i < rows.length; i++) {
      final (label, key, text) = rows[i];
      _paintBlocks(
        canvas,
        Rect.fromLTWH(x, panel.top + u * (0.13 + i * 0.07), width, u * 0.052),
        animator.needle(key),
        label,
        text,
      );
    }
  }

  /// 燃料計のようなブロックゲージ（右パネル）。
  void _paintBlocks(
    Canvas canvas,
    Rect rect,
    double value,
    String label,
    String readout,
  ) {
    final fs = rect.height * 0.7;
    final labelWidth = fs * 3.9;
    final readoutWidth = fs * 3.4;
    const count = 10;
    paintMeterText(
      canvas,
      textCache.get(
        label,
        font: meterLabelFont,
        size: fs,
        color: palette.tickMinor,
      ),
      Offset(rect.left, rect.center.dy),
      anchor: MeterTextAnchor.left,
    );
    paintMeterText(
      canvas,
      textCache.get(
        readout,
        font: meterNumberFont,
        size: fs * 1.1,
        color: palette.tickMajor,
      ),
      Offset(rect.right, rect.center.dy),
      anchor: MeterTextAnchor.right,
    );
    final area = Rect.fromLTRB(
      rect.left + labelWidth,
      rect.top,
      rect.right - readoutWidth,
      rect.bottom,
    );
    canvas.drawRect(
      area.deflate(0.5),
      Paint()
        ..color = palette.tickMinor
        ..style = PaintingStyle.stroke,
    );
    final gap = area.width * 0.015;
    final cell = (area.width - gap * (count + 1)) / count;
    final block = Paint();
    for (var i = 0; i < count; i++) {
      final on = (i + 0.5) / count <= value;
      block.color = on
          ? (i >= 9 ? palette.ledPeak : palette.raceFill)
          : palette.raceBarTrack;
      canvas.drawRect(
        Rect.fromLTWH(
          area.left + gap + i * (cell + gap),
          area.top + gap + 1,
          cell,
          area.height - gap * 2 - 2,
        ),
        block,
      );
    }
  }

  @override
  bool shouldRepaint(RaceClusterPainter old) =>
      old.layout != layout ||
      old.readouts != readouts ||
      old.palette != palette;
}

/// コア別の小さな右肩上がりバーグラフのグリッド。
class RaceCoresPainter extends CustomPainter {
  RaceCoresPainter({
    required this.coreCount,
    required this.columns,
    required this.rowHeight,
    required this.animator,
    required this.palette,
    required this.textCache,
  }) : super(repaint: animator);

  final int coreCount;
  final int columns;
  final double rowHeight;
  final MeterAnimator animator;
  final ActivityMeterPalette palette;
  final MeterTextCache textCache;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / columns;
    final well = Paint()..color = palette.meterWell;
    for (var i = 0; i < coreCount; i++) {
      final col = i % columns;
      final row = i ~/ columns;
      final left = col * cellWidth;
      final top = row * rowHeight;
      canvas.drawRect(
        Rect.fromLTWH(left + 4, top + 4, cellWidth - 8, rowHeight - 8),
        well,
      );
      final v = animator.needle('core$i');
      final x0 = left + 14;
      final x1 = left + cellWidth - 14;
      _paintWedge(
        canvas,
        palette,
        textCache,
        x0: x0,
        x1: x1,
        baseline: top + rowHeight - 12,
        minHeight: 4,
        maxHeight: rowHeight * 0.45,
        value: v,
        bars: 30,
      );
      paintMeterText(
        canvas,
        textCache.get(
          'C${i + 1}',
          font: meterLabelFont,
          size: 11,
          color: palette.tickMinor,
        ),
        Offset(x0, top + 20),
        anchor: MeterTextAnchor.baselineLeft,
      );
      final pct = textCache.get(
        '${(animator.level('core$i').level * 100).round()}%',
        font: meterNumberFont,
        size: 16,
        color: palette.tickMajor,
      );
      paintMeterText(
        canvas,
        pct,
        Offset(x1 - pct.width, top + 22),
        anchor: MeterTextAnchor.baselineLeft,
      );
    }
  }

  @override
  bool shouldRepaint(RaceCoresPainter old) =>
      old.coreCount != coreCount ||
      old.columns != columns ||
      old.rowHeight != rowHeight ||
      old.palette != palette;
}

/// シフトライト（12 灯）。CPU が 50% を超えると左から点き、95% 超で全灯点滅。
class ShiftLightsPainter extends CustomPainter {
  ShiftLightsPainter({required this.animator, required this.palette})
    : super(repaint: animator);

  final MeterAnimator animator;
  final ActivityMeterPalette palette;

  static const int count = 12;
  static const double _led = 18;
  static const double _gap = 6;
  static const double width = count * _led + (count - 1) * _gap;
  static const double height = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final v = animator.needle('cpu');
    final blinkOn = (DateTime.now().millisecondsSinceEpoch ~/ 70).isEven;
    final top = (size.height - 10) / 2;
    for (var i = 0; i < count; i++) {
      final color = i < 5
          ? palette.ledSafe
          : i < 9
          ? palette.ledCaution
          : palette.ledPeak;
      final threshold = 0.5 + i * (0.45 / (count - 1));
      final on = v > 0.95 ? blinkOn : v >= threshold;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(i * (_led + _gap), top, _led, 10),
        const Radius.circular(2),
      );
      if (on) {
        canvas
          ..drawRRect(
            rect,
            Paint()
              ..color = color.withValues(alpha: 0.8)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
          )
          ..drawRRect(rect, Paint()..color = color);
      } else {
        canvas
          ..drawRRect(rect, Paint()..color = palette.meterWell)
          ..drawRRect(
            rect,
            Paint()
              ..color = palette.meterWellEdge
              ..style = PaintingStyle.stroke,
          );
      }
    }
  }

  @override
  bool shouldRepaint(ShiftLightsPainter old) => old.palette != palette;
}
