import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:roola_activity/ui/activity_dashboard/activity_meter_palette.dart';
import 'package:roola_activity/ui/activity_dashboard/meter_text.dart';

/// タコの目盛りの始点（真下）と全角（時計回り 270°）。0 が真下、
/// 全体の 1/3 が左、2/3 が真上、終点が右に来る（実車の 0 / 3 / 6 / 9 と同じ）。
const double _start = math.pi / 2;
const double _sweep = math.pi * 1.5;

/// 目盛りの赤い範囲（9〜10 ×10 %）。
const double _redFrom = 0.9;

double _angle(double v) => _start + v.clamp(0.0, 1.0) * _sweep;

Offset _polar(Offset c, double radius, double angle) =>
    c + Offset(math.cos(angle) * radius, math.sin(angle) * radius);

/// RACE 1 の中央に置く GR86 / BRZ 通常モード風の丸型タコ（CPU・0–10 ×10 %）。
///
/// 実車の通常表示（取扱説明書の図）をなぞる。針は無く、外周の細かい目盛りの
/// 内側を帯が CPU の位置まで伸びる。中央に大きな数値（実車の速度）と単位、
/// 横線の下にギア表示の位置でロードアベレージ（1 分）。RACE 2 の外枠の円の
/// 内側に収める前提で、[r] は円の縁取りより小さく渡す。
void paintRaceRoundTach(
  Canvas canvas,
  Offset c,
  double r, {
  required double cpu,
  required String cpuNumber,
  required String? loadText,
  required ActivityMeterPalette palette,
  required MeterTextCache textCache,
}) {
  final value = cpu.clamp(0.0, 1.0);

  // 外周の細かい目盛り（櫛状）。10 単位ごとに長く、赤い範囲は赤。
  const fine = 100;
  final tick = Paint()..strokeWidth = math.max(1, r * 0.008);
  for (var i = 0; i <= fine; i++) {
    final v = i / fine;
    final a = _angle(v);
    final major = i % 10 == 0;
    tick.color = v >= _redFrom
        ? palette.redZone
        : major
        ? palette.tickMajor
        : palette.tickMinor.withValues(alpha: 0.75);
    canvas.drawLine(
      _polar(c, r * (major ? 0.86 : 0.9), a),
      _polar(c, r * 0.98, a),
      tick,
    );
  }

  // 回転数の帯（目盛りの内側）。未点灯の溝と、CPU 値までの明るい帯。
  final bandRect = Rect.fromCircle(center: c, radius: r * 0.77);
  final bandWidth = r * 0.1;
  canvas.drawArc(
    bandRect,
    _start,
    _sweep,
    false,
    Paint()
      ..color = palette.raceUnlit
      ..style = PaintingStyle.stroke
      ..strokeWidth = bandWidth,
  );
  if (value > 0) {
    canvas
      ..drawArc(
        bandRect,
        _start,
        _sweep * value,
        false,
        Paint()
          ..shader = SweepGradient(
            // 終点（_start + _sweep）は 2π で、SweepGradient の既定と同じ。
            startAngle: _start,
            colors: [palette.tickMinor, palette.raceFill, palette.raceFill],
            stops: const [0, 0.5, 1],
          ).createShader(bandRect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = bandWidth,
      )
      // 帯の先端を一段明るくして、今の位置を読みやすくする。
      ..drawArc(
        bandRect,
        _angle(value) - 0.03,
        0.03,
        false,
        Paint()
          ..color = value >= _redFrom ? palette.ledPeak : palette.tickMajor
          ..style = PaintingStyle.stroke
          ..strokeWidth = bandWidth,
      );
  }

  // 数字（帯の内側）。
  for (var i = 0; i <= 10; i++) {
    final v = i / 10;
    paintMeterText(
      canvas,
      textCache.get(
        '$i',
        font: meterNumberFont,
        size: r * 0.12,
        color: v >= _redFrom ? palette.redZoneText : palette.tickMajor,
      ),
      _polar(c, r * 0.6, _angle(v)),
    );
  }

  // 中央: 大きな数値（実車の速度）と単位、横線。
  final number = textCache.get(
    cpuNumber,
    font: meterNumberFont,
    size: r * 0.4,
    color: palette.tickMajor,
  );
  paintMeterText(canvas, number, c.translate(0, -r * 0.1));
  paintMeterText(
    canvas,
    textCache.get(
      '%',
      font: meterLabelFont,
      size: r * 0.08,
      color: palette.tickMajor,
    ),
    c.translate(0, r * 0.13),
  );
  canvas.drawLine(
    c.translate(-r * 0.32, r * 0.2),
    c.translate(r * 0.32, r * 0.2),
    Paint()
      ..color = palette.tickMinor
      ..strokeWidth = math.max(1, r * 0.006),
  );

  // 横線の下: ギア表示の位置にロードアベレージ（1 分）。
  if (loadText != null) {
    paintMeterText(
      canvas,
      textCache.get(
        loadText,
        font: meterNumberFont,
        size: r * 0.17,
        color: palette.tickMajor,
      ),
      c.translate(-r * 0.04, r * 0.34),
    );
    paintMeterText(
      canvas,
      textCache.get(
        'LOAD',
        font: meterLabelFont,
        size: r * 0.045,
        color: palette.tickMinor,
        letterSpacing: r * 0.008,
      ),
      c.translate(r * 0.2, r * 0.38),
      anchor: MeterTextAnchor.left,
    );
  }

  // 右下の空き: 単位表記（実車の ×1000r/min）。
  paintMeterText(
    canvas,
    textCache.get(
      '×10 %',
      font: meterLabelFont,
      size: r * 0.055,
      color: palette.tickMinor,
    ),
    c.translate(r * 0.45, r * 0.68),
    anchor: MeterTextAnchor.left,
  );
}
