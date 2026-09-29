import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:roola/app/activity_meter_palette.dart';
import 'package:roola/data/activity_dashboard/activity_dashboard_settings.dart';
import 'package:roola/ui/activity_dashboard/meter_animator.dart';
import 'package:roola/ui/activity_dashboard/meter_specs.dart';
import 'package:roola/ui/activity_dashboard/meter_text.dart';

/// TACHO モードの CLASSIC / DIGITAL（円形メーター）の盤面（design D6）。
///
/// 上段に CPU / メモリの大メーター、中段に I/O・ロードアベレージの小メーター、
/// 全コア表示時は下段にコア別の小メーターを並べる。狭いペインでは折り返し、
/// 高さが足りなければ縦スクロールする。
class DialBoard extends StatelessWidget {
  const DialBoard({
    required this.style,
    required this.main,
    required this.sub,
    required this.cores,
    required this.animator,
    required this.textCache,
    super.key,
  });

  final TachoStyle style;
  final List<DialSpec> main;
  final List<DialSpec> sub;
  final List<DialSpec> cores;
  final MeterAnimator animator;
  final MeterTextCache textCache;

  @override
  Widget build(BuildContext context) {
    final palette = ActivityMeterPalette.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - 32;
        final bigSize = ((width - 16) / 2).clamp(200.0, 380.0);
        Widget dial(DialSpec spec, double size) => RepaintBoundary(
          child: CustomPaint(
            size: Size.square(size),
            painter: DialPainter(
              spec: spec,
              style: style,
              animator: animator,
              palette: palette,
              textCache: textCache,
            ),
          ),
        );
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [for (final d in main) dial(d, bigSize)],
              ),
              if (sub.isNotEmpty) ...[
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [for (final d in sub) dial(d, 160)],
                ),
              ],
              if (cores.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'CPU CORES',
                  style: TextStyle(
                    fontFamily: meterLabelFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 2.4,
                    color: palette.labelText,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [for (final d in cores) dial(d, 120)],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// 270° スイープの円形メーター 1 つ。[style] で CLASSIC / DIGITAL を描き分ける。
class DialPainter extends CustomPainter {
  DialPainter({
    required this.spec,
    required this.style,
    required this.animator,
    required this.palette,
    required this.textCache,
  }) : super(repaint: animator);

  final DialSpec spec;
  final TachoStyle style;
  final MeterAnimator animator;
  final ActivityMeterPalette palette;
  final MeterTextCache textCache;

  /// スイープの開始角（左下 135°）と全角（270°）。
  static const double _start = math.pi * 0.75;
  static const double _sweep = math.pi * 1.5;

  static double _angle(double v) => _start + v * _sweep;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) / 2 * 0.97;
    final c = size.center(Offset.zero);
    _paintFace(canvas, c, r);
    final x = animator.needle(spec.channel.key).clamp(-0.01, 1.01);
    switch (style) {
      case TachoStyle.digital:
        _paintDigital(canvas, c, r, x);
      case TachoStyle.classic:
      case TachoStyle.race:
        _paintClassic(canvas, c, r, x);
    }
  }

  /// 文字盤: フラットな黒＋細い外周リング＋内側ヘアライン（ADR-0068 D3）。
  void _paintFace(Canvas canvas, Offset c, double r) {
    canvas
      ..drawCircle(c, r * 0.98, Paint()..color = palette.face)
      ..drawCircle(
        c,
        r * 0.98,
        Paint()
          ..color = palette.faceRing
          ..style = PaintingStyle.stroke,
      )
      ..drawCircle(
        c,
        r * 0.955,
        Paint()
          ..color = palette.faceHairline
          ..style = PaintingStyle.stroke,
      );
  }

  Offset _polar(Offset c, double radius, double angle) =>
      c + Offset(math.cos(angle) * radius, math.sin(angle) * radius);

  /// 数値と単位を並べて中央揃えで描く（ベースラインを揃える）。
  void _paintNumber(
    Canvas canvas,
    Offset c,
    double baselineY,
    double size,
    Color color,
    Color unitColor, {
    Color? glow,
  }) {
    final (num, unit) = spec.channel.parts;
    final n = textCache.get(
      num,
      font: meterNumberFont,
      size: size,
      color: color,
      glow: glow,
    );
    final u = unit.isEmpty
        ? null
        : textCache.get(
            unit,
            font: meterLabelFont,
            size: size * 0.3,
            color: unitColor,
          );
    final gap = u == null ? 0.0 : size * 0.1;
    final total = n.width + gap + (u?.width ?? 0);
    final x0 = c.dx - total / 2;
    paintMeterText(
      canvas,
      n,
      Offset(x0, baselineY),
      anchor: MeterTextAnchor.baselineLeft,
    );
    if (u != null) {
      paintMeterText(
        canvas,
        u,
        Offset(x0 + n.width + gap, baselineY),
        anchor: MeterTextAnchor.baselineLeft,
      );
    }
  }

  void _paintLabel(Canvas canvas, Offset c, double r, Color color) {
    paintMeterText(
      canvas,
      textCache.get(
        spec.label,
        font: meterLabelFont,
        size: r * 0.085,
        color: color,
        letterSpacing: r * 0.02,
      ),
      c.translate(0, -r * 0.3),
    );
  }

  // ---- CLASSIC: 白い目盛り・赤いレッドゾーン線・赤橙の針 ----

  void _paintClassic(Canvas canvas, Offset c, double r, double x) {
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.935),
      _angle(spec.redFrom),
      _angle(1) - _angle(spec.redFrom),
      false,
      Paint()
        ..color = palette.redZone
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, r * 0.025),
    );

    final n = spec.majors.length - 1;
    final minors = spec.size == DialSize.core ? 2 : spec.minorsPerMajor;
    final total = n * minors;
    final tick = Paint()..strokeCap = StrokeCap.butt;
    for (var i = 0; i <= total; i++) {
      final f = i / total;
      final a = _angle(f);
      final major = i % minors == 0;
      final red = f >= spec.redFrom - 1e-6;
      final r1 = r * 0.9;
      final r2 = r1 - (major ? r * 0.11 : r * 0.05);
      tick
        ..color = red
            ? palette.redZoneText
            : major
            ? palette.tickMajor
            : palette.tickMinor
        ..strokeWidth = major ? math.max(2, r * 0.022) : 1;
      canvas.drawLine(_polar(c, r1, a), _polar(c, r2, a), tick);
    }

    final numeralSize = math.max(
      9.0,
      r * (spec.majors.length > 8 ? 0.16 : 0.14),
    );
    for (var i = 0; i <= n; i++) {
      final f = i / n;
      paintMeterText(
        canvas,
        textCache.get(
          spec.majors[i],
          font: meterNumberFont,
          size: numeralSize,
          weight: FontWeight.w500,
          color: f >= spec.redFrom - 1e-6
              ? palette.redZoneText
              : palette.tickMajor,
        ),
        _polar(c, r * 0.68, _angle(f)),
      );
    }

    _paintLabel(canvas, c, r, palette.tickMajor.withValues(alpha: 0.82));
    if (spec.size == DialSize.big) {
      paintMeterText(
        canvas,
        textCache.get(
          spec.sub,
          font: meterLabelFont,
          size: r * 0.06,
          color: palette.scaleText,
        ),
        c.translate(0, -r * 0.19),
      );
    }
    if (spec.size != DialSize.core || r > 50) {
      _paintNumber(
        canvas,
        c,
        c.dy + r * 0.66,
        r * 0.24,
        palette.tickMajor,
        palette.labelText,
      );
    }

    // 針: 発光を下敷きにしてから本体を描く。
    final a = _angle(x);
    final needle = Path()
      ..moveTo(-r * 0.14, -r * 0.02)
      ..lineTo(r * 0.9, -r * 0.005)
      ..lineTo(r * 0.9, r * 0.005)
      ..lineTo(-r * 0.14, r * 0.02)
      ..close();
    canvas
      ..save()
      ..translate(c.dx, c.dy)
      ..rotate(a)
      ..drawPath(
        needle,
        Paint()
          ..color = palette.needle.withValues(alpha: 0.5)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.02),
      )
      ..drawPath(needle, Paint()..color = palette.needle)
      ..restore()
      ..drawCircle(c, r * 0.065, Paint()..color = palette.face)
      ..drawCircle(
        c,
        r * 0.065,
        Paint()
          ..color = palette.faceRing
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
  }

  // ---- DIGITAL: オレンジ蛍光表示管（VFD）風のセグメント円弧 ----

  void _paintDigital(Canvas canvas, Offset c, double r, double x) {
    final xv = x.clamp(0.0, 1.0);
    final segments = switch (spec.size) {
      DialSize.big => 72,
      DialSize.core => 30,
      DialSize.small => 44,
    };
    final step = _sweep / segments;
    final gap = step * 0.22;
    final inner = r * 0.76;
    final outer = r * 0.9;

    // 発光: 点灯範囲をぼかした太い円弧で下敷きにする。
    if (xv > 0.002) {
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.16
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.05);
      final rect = Rect.fromCircle(center: c, radius: (inner + outer) / 2);
      final safeEnd = math.min(xv, spec.redFrom);
      canvas.drawArc(
        rect,
        _start,
        safeEnd * _sweep,
        false,
        glow..color = palette.vfd.withValues(alpha: 0.35),
      );
      if (xv > spec.redFrom) {
        canvas.drawArc(
          rect,
          _angle(spec.redFrom),
          (xv - spec.redFrom) * _sweep,
          false,
          glow..color = palette.vfdRed.withValues(alpha: 0.4),
        );
      }
    }

    final seg = Paint();
    for (var k = 0; k < segments; k++) {
      final f = (k + 0.5) / segments;
      final lit = f <= xv;
      final color = f >= spec.redFrom ? palette.vfdRed : palette.vfd;
      final a1 = _start + k * step + gap / 2;
      final a2 = _start + (k + 1) * step - gap / 2;
      final path = Path()
        ..arcTo(Rect.fromCircle(center: c, radius: outer), a1, a2 - a1, true)
        ..arcTo(Rect.fromCircle(center: c, radius: inner), a2, a1 - a2, false)
        ..close();
      seg.color = lit ? color : color.withValues(alpha: 0.07);
      canvas.drawPath(path, seg);
    }

    final n = spec.majors.length - 1;
    final tick = Paint()..strokeWidth = 2;
    final numeralSize = math.max(8.0, r * 0.11);
    for (var i = 0; i <= n; i++) {
      final f = i / n;
      final a = _angle(f);
      final lit = f <= xv + 1e-6;
      final color = f >= spec.redFrom - 1e-6 ? palette.vfdRed : palette.vfd;
      tick.color = lit ? color : color.withValues(alpha: 0.18);
      canvas.drawLine(_polar(c, r * 0.94, a), _polar(c, r * 0.97, a), tick);
      paintMeterText(
        canvas,
        textCache.get(
          spec.majors[i],
          font: meterNumberFont,
          size: numeralSize,
          color: lit ? color : color.withValues(alpha: 0.16),
          glow: lit ? color.withValues(alpha: 0.6) : null,
        ),
        _polar(c, r * 0.63, a),
      );
    }

    _paintLabel(canvas, c, r, palette.vfd.withValues(alpha: 0.55));
    final numberColor = xv > spec.redFrom ? palette.vfdRed : palette.vfd;
    _paintNumber(
      canvas,
      c,
      c.dy + r * 0.2,
      r * (spec.size == DialSize.core ? 0.36 : 0.4),
      numberColor,
      numberColor.withValues(alpha: 0.6),
      glow: numberColor.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(DialPainter old) =>
      old.spec.channel.parts != spec.channel.parts ||
      old.spec.label != spec.label ||
      old.style != style ||
      old.palette != palette;
}
