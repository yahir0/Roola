import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:roola/app/activity_meter_palette.dart';
import 'package:roola/ui/activity_dashboard/meter_animator.dart';
import 'package:roola/ui/activity_dashboard/meter_specs.dart';
import 'package:roola/ui/activity_dashboard/meter_text.dart';

/// LEVEL モード: 放送用レベルゲージ風の縦 LED バー（ADR-0067 D2 / design D6）。
///
/// グループ（CPU / MEMORY / NETWORK / DISK / LOAD）ごとに 1 枚の
/// [CustomPaint] を横に並べ、幅が足りなければ折り返す。
class LevelBoard extends StatelessWidget {
  const LevelBoard({
    required this.groups,
    required this.animator,
    required this.textCache,
    super.key,
  });

  final List<MeterGroup> groups;
  final MeterAnimator animator;
  final MeterTextCache textCache;

  @override
  Widget build(BuildContext context) {
    final palette = ActivityMeterPalette.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // グループ見出しとパディングを除いた高さをメーターに充てる。
        final height = (constraints.maxHeight - 64).clamp(220.0, 420.0);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Center(
            child: Wrap(
              spacing: 26,
              runSpacing: 18,
              alignment: WrapAlignment.center,
              children: [
                for (final g in groups)
                  _LevelGroup(
                    group: g,
                    height: height,
                    animator: animator,
                    textCache: textCache,
                    palette: palette,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LevelGroup extends StatelessWidget {
  const _LevelGroup({
    required this.group,
    required this.height,
    required this.animator,
    required this.textCache,
    required this.palette,
  });

  final MeterGroup group;
  final double height;
  final MeterAnimator animator;
  final MeterTextCache textCache;
  final ActivityMeterPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: group.title,
            style: TextStyle(
              fontFamily: meterLabelFont,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 2.4,
              color: palette.labelText,
            ),
            children: [
              TextSpan(
                text: '  ${group.note}',
                style: TextStyle(
                  fontFamily: meterNumberFont,
                  fontSize: 11,
                  letterSpacing: 0,
                  color: palette.dimText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        RepaintBoundary(
          child: CustomPaint(
            size: Size(LevelGroupPainter.widthFor(group), height),
            painter: LevelGroupPainter(
              group: group,
              animator: animator,
              palette: palette,
              textCache: textCache,
            ),
          ),
        ),
      ],
    );
  }
}

/// レベルゲージ 1 グループ（目盛り＋チャンネル群）の描画。
class LevelGroupPainter extends CustomPainter {
  LevelGroupPainter({
    required this.group,
    required this.animator,
    required this.palette,
    required this.textCache,
  }) : super(repaint: animator);

  final MeterGroup group;
  final MeterAnimator animator;
  final ActivityMeterPalette palette;
  final MeterTextCache textCache;

  static const int segments = 40;
  static const double _scaleWidth = 34;
  static const double _channelWidth = 20;
  static const double _channelGap = 8;
  static const double _segmentGap = 2;
  static const double _top = 12;
  static const double _bottomArea = 46;

  static double widthFor(MeterGroup group) =>
      _scaleWidth + group.channels.length * (_channelWidth + _channelGap) + 6;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(4),
    );
    canvas
      ..drawRRect(rrect, Paint()..color = palette.meterWell)
      ..drawRRect(
        rrect,
        Paint()
          ..color = palette.meterWellEdge
          ..style = PaintingStyle.stroke,
      );

    final bottom = size.height - _bottomArea;
    final meterHeight = bottom - _top;
    final segHeight = (meterHeight - (segments - 1) * _segmentGap) / segments;

    _paintScale(canvas, meterHeight);

    for (var i = 0; i < group.channels.length; i++) {
      final ch = group.channels[i];
      final x = _scaleWidth + 4 + i * (_channelWidth + _channelGap);
      final state = animator.level(ch.key);
      _paintChannel(canvas, x, bottom, segHeight, state.level, state.peak);
      paintMeterText(
        canvas,
        textCache.get(
          ch.short,
          font: meterNumberFont,
          size: 11,
          color: palette.readout,
        ),
        Offset(x + _channelWidth / 2, bottom + 14),
      );
      paintMeterText(
        canvas,
        textCache.get(
          ch.name,
          font: meterLabelFont,
          size: 9,
          color: palette.labelText,
        ),
        Offset(x + _channelWidth / 2, bottom + 31),
      );
    }
  }

  void _paintScale(Canvas canvas, double meterHeight) {
    final labels = switch (group.scale) {
      MeterScale.percent => const ['100', '80', '60', '40', '20', '0'],
      MeterScale.log => const ['1G', '100M', '10M', '1M', '100K', '10K', '1K'],
      MeterScale.load => _loadLabels(),
    };
    final tick = Paint()..color = palette.meterWellEdge;
    for (var i = 0; i < labels.length; i++) {
      final y = _top + meterHeight * i / (labels.length - 1);
      canvas.drawRect(Rect.fromLTWH(_scaleWidth - 5, y - 0.5, 4, 1), tick);
      if (labels[i].isEmpty) {
        continue;
      }
      paintMeterText(
        canvas,
        textCache.get(
          labels[i],
          font: meterNumberFont,
          size: 10,
          weight: FontWeight.w500,
          color: palette.scaleText,
        ),
        Offset(_scaleWidth - 8, y),
        anchor: MeterTextAnchor.right,
      );
    }
  }

  /// ロードアベレージの目盛り（満点はグループ注記の `max N`）。
  List<String> _loadLabels() {
    final full = int.tryParse(group.note.replaceFirst('max ', '')) ?? 8;
    return ['$full', '', '${(full / 2).round()}', '', '0'];
  }

  void _paintChannel(
    Canvas canvas,
    double x,
    double bottom,
    double segHeight,
    double level,
    double peak,
  ) {
    // 発光: 点灯部分をゾーンごとにぼかした矩形で下敷きにする（セグメント毎に
    // ぼかすより軽い）。
    if (level > 0.005) {
      const cuts = [0.0, 0.7, 0.9, 1.0];
      for (var z = 0; z < 3; z++) {
        final from = cuts[z];
        final to = math.min(cuts[z + 1], level);
        if (to <= from) {
          break;
        }
        final meterHeight = segments * (segHeight + _segmentGap);
        canvas.drawRect(
          Rect.fromLTRB(
            x,
            bottom - to * meterHeight,
            x + _channelWidth,
            bottom - from * meterHeight,
          ),
          Paint()
            ..color = palette.ledZone(from).withValues(alpha: 0.45)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }

    final peakSeg = math.min(segments - 1, (peak * segments - 1e-6).floor());
    final paint = Paint();
    for (var k = 0; k < segments; k++) {
      final f = (k + 0.5) / segments;
      final y = bottom - (k + 1) * segHeight - k * _segmentGap;
      final color = palette.ledZone(f);
      final lit = f <= level;
      final isPeak = k == peakSeg && peak > 0.02;
      paint.color = lit
          ? color
          : isPeak
          ? Color.lerp(color, Colors.white, 0.25)!
          : color.withValues(alpha: 0.09);
      canvas.drawRect(Rect.fromLTWH(x, y, _channelWidth, segHeight), paint);
    }
  }

  @override
  bool shouldRepaint(LevelGroupPainter old) =>
      old.group != group || old.palette != palette;
}
