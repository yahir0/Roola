import 'package:flutter/material.dart';
import 'package:roola/app/theme.dart';

/// フォルダ／ファイルの型アイコン（Polaris / ADR-0038 D10）。
///
/// 既製アイコン（Material / Cupertino）は consumer 向けで丸み・親しみが強く、
/// 精密な計器 UI の中で温度が合わない。幾何学モノライン（ヘアラインの
/// ストローク）を `CustomPaint` で自前描画する。
class PolarisTypeIcon extends StatelessWidget {
  const PolarisTypeIcon({
    super.key,
    required this.isDir,
    required this.color,
    this.size = PolarisIconSize.small,
  });

  /// ディレクトリなら `true`、ファイルなら `false`。
  final bool isDir;

  /// ストロークの色。
  final Color color;

  /// アイコンの一辺（px）。
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TypeIconPainter(isDir: isDir, color: color),
      ),
    );
  }
}

class _TypeIconPainter extends CustomPainter {
  const _TypeIconPainter({required this.isDir, required this.color});

  final bool isDir;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeJoin = StrokeJoin.miter
      ..strokeCap = StrokeCap.square;

    if (isDir) {
      final top = s * 0.34;
      final bottom = s * 0.80;
      final left = s * 0.10;
      final right = s * 0.90;
      final tabTop = s * 0.20;
      final tabEnd = s * 0.42;
      final path = Path()
        ..moveTo(left, tabTop)
        ..lineTo(tabEnd, tabTop)
        ..lineTo(tabEnd + (top - tabTop), top)
        ..lineTo(right, top)
        ..lineTo(right, bottom)
        ..lineTo(left, bottom)
        ..close();
      canvas.drawPath(path, p);
    } else {
      final top = s * 0.12;
      final bottom = s * 0.88;
      final left = s * 0.22;
      final right = s * 0.78;
      final fold = s * 0.26;
      final body = Path()
        ..moveTo(left, top)
        ..lineTo(right - fold, top)
        ..lineTo(right, top + fold)
        ..lineTo(right, bottom)
        ..lineTo(left, bottom)
        ..close();
      final foldMark = Path()
        ..moveTo(right - fold, top)
        ..lineTo(right - fold, top + fold)
        ..lineTo(right, top + fold);
      canvas
        ..drawPath(body, p)
        ..drawPath(foldMark, p);
    }
  }

  @override
  bool shouldRepaint(_TypeIconPainter old) =>
      old.isDir != isDir || old.color != color;
}

/// パンくず等で使う小さな山括弧（モノライン・Polaris / ADR-0038 D10）。
class PolarisChevron extends StatelessWidget {
  const PolarisChevron({
    super.key,
    required this.color,
    this.width = 6,
    this.height = 10,
  });

  /// ストロークの色。
  final Color color;

  /// 山括弧の幅（px）。
  final double width;

  /// 山括弧の高さ（px）。
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _ChevronPainter(color: color)),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeJoin = StrokeJoin.miter;
    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.1)
      ..lineTo(size.width * 0.9, size.height * 0.5)
      ..lineTo(size.width * 0.1, size.height * 0.9);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => old.color != color;
}
