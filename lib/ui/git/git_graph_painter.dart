import 'package:flutter/material.dart';
import 'package:roola/app/theme.dart';
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
    required this.laneColors,
    required this.dotInnerColor,
  });

  final GitGraphRow row;
  final double laneWidth;
  final double dotRadius;
  final double lineWidth;

  /// レーンごとの色。レーン番号をこの配列長で剰余して使う。Polaris の
  /// トークン由来のパレットを呼び出し側から渡す（ADR-0038）。
  final List<Color> laneColors;

  /// コミット node の中空部（リング内側）の色。`well` トーン。
  final Color dotInnerColor;

  /// Polaris トークンからレーンパレットを組み立てる。新規ハードコード色を
  /// 持ち込まず、アクセント・信号色・テキストトーンでレーンを描き分ける。
  static List<Color> paletteFor(PolarisTokens tokens) => [
    tokens.accent,
    tokens.signalNew,
    tokens.signalModified,
    tokens.signalConflict,
    tokens.textDim,
    tokens.text,
  ];

  Color colorForLane(int lane) => laneColors[lane % laneColors.length];

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
        Paint()..color = dotInnerColor,
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
      oldDelegate.lineWidth != lineWidth ||
      oldDelegate.dotInnerColor != dotInnerColor;
}
