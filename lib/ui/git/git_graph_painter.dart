import 'package:flutter/material.dart';
import 'package:roola/data/git/git_graph_row.dart';

/// 履歴グラフ 1 行分のレーン・線分を描く [CustomPainter]（ADR-0030 / design
/// D5）。
///
/// 1 行 = 高さ [rowHeight] の固定セル。線分は行上端の `fromLane` から行下端の
/// `toLane` へ直線で引き、コミットの丸印を `dotLane` の行中央に打つ。レーン
/// 交差の最適化は行わない簡易描画。
class GitGraphPainter extends CustomPainter {
  const GitGraphPainter({
    required this.row,
    required this.laneWidth,
    required this.dotRadius,
    required this.lineWidth,
  });

  final GitGraphRow row;
  final double laneWidth;
  final double dotRadius;
  final double lineWidth;

  /// レーンごとの色。レーン番号をこの配列長で剰余して使う。
  static const List<Color> laneColors = [
    Color(0xFF5080C0),
    Color(0xFF4CAF50),
    Color(0xFFE0A030),
    Color(0xFFC0504D),
    Color(0xFF8E6FBF),
    Color(0xFF3FA8A0),
  ];

  static Color colorForLane(int lane) => laneColors[lane % laneColors.length];

  double _laneCenterX(int lane) => laneWidth / 2 + lane * laneWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // 線分を先に描き、丸印を最後に重ねる。
    for (final route in row.routes) {
      final paint = Paint()
        ..color = colorForLane(route.toLane)
        ..strokeWidth = lineWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final from = Offset(_laneCenterX(route.fromLane), 0);
      final to = Offset(_laneCenterX(route.toLane), size.height);
      if (route.fromLane == route.toLane) {
        canvas.drawLine(from, to, paint);
      } else {
        // 行中央で曲げて、コミット行で枝分かれ / 合流するように見せる。
        final mid = size.height / 2;
        final path = Path()
          ..moveTo(from.dx, from.dy)
          ..lineTo(from.dx, mid)
          ..lineTo(to.dx, mid)
          ..lineTo(to.dx, to.dy);
        canvas.drawPath(path, paint);
      }
    }

    final center = Offset(_laneCenterX(row.dotLane), size.height / 2);
    canvas
      ..drawCircle(
        center,
        dotRadius,
        Paint()..color = colorForLane(row.dotLane),
      )
      ..drawCircle(
        center,
        dotRadius - lineWidth,
        Paint()..color = const Color(0xFFFFFFFF),
      )
      ..drawCircle(
        center,
        dotRadius - lineWidth,
        Paint()
          ..color = colorForLane(row.dotLane)
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineWidth,
      );
  }

  @override
  bool shouldRepaint(GitGraphPainter oldDelegate) =>
      oldDelegate.row != row ||
      oldDelegate.laneWidth != laneWidth ||
      oldDelegate.dotRadius != dotRadius ||
      oldDelegate.lineWidth != lineWidth;
}
