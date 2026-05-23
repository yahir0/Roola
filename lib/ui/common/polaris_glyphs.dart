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

/// Polaris のモノライングリフ共通の描画コンテキスト。`size:` 一辺の正方形に
/// CustomPaint を流し込むだけの薄いラッパで、各種記号を統一の太さ・端処理で
/// 自前描画する（Material 既製アイコンの丸み・温度差を避ける / ADR-0038 D10）。
class PolarisGlyph extends StatelessWidget {
  const PolarisGlyph._({required this.painter, required this.size});

  /// チェックマーク（✓）。完了・成功・有効を表す。
  factory PolarisGlyph.check({
    required Color color,
    double size = PolarisIconSize.standard,
  }) => PolarisGlyph._(
    painter: _CheckGlyphPainter(color: color),
    size: size,
  );

  /// 情報（i）。中立的な状態・補足を表す。
  factory PolarisGlyph.info({
    required Color color,
    double size = PolarisIconSize.standard,
  }) => PolarisGlyph._(
    painter: _InfoGlyphPainter(color: color),
    size: size,
  );

  /// 警告（△!）。エラー・未検出を表す。
  factory PolarisGlyph.warn({
    required Color color,
    double size = PolarisIconSize.standard,
  }) => PolarisGlyph._(
    painter: _WarnGlyphPainter(color: color),
    size: size,
  );

  /// コピー（重なった 2 枚の紙）。クリップボードへの複製操作を表す。
  factory PolarisGlyph.copy({
    required Color color,
    double size = PolarisIconSize.standard,
  }) => PolarisGlyph._(
    painter: _CopyGlyphPainter(color: color),
    size: size,
  );

  /// キーボード（キートップを並べた筐体）。ショートカット導線に使う。
  factory PolarisGlyph.keyboard({
    required Color color,
    double size = PolarisIconSize.standard,
  }) => PolarisGlyph._(
    painter: _KeyboardGlyphPainter(color: color),
    size: size,
  );

  /// 行密度（横線の本数で密度を表す）。`rows` が多いほど密。
  factory PolarisGlyph.rows({
    required Color color,
    required int rows,
    double size = PolarisIconSize.standard,
  }) => PolarisGlyph._(
    painter: _RowsGlyphPainter(color: color, rows: rows),
    size: size,
  );

  /// 閉じる（✕）。モーダル / パネルを閉じる操作を表す。
  factory PolarisGlyph.close({
    required Color color,
    double size = PolarisIconSize.standard,
  }) => PolarisGlyph._(
    painter: _CloseGlyphPainter(color: color),
    size: size,
  );

  final CustomPainter painter;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: painter),
    );
  }
}

/// モノライングリフ用の標準ストローク。1.3px・マイター結合・角端。
Paint _glyphStroke(Color color) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.3
  ..strokeJoin = StrokeJoin.miter
  ..strokeCap = StrokeCap.square;

class _CheckGlyphPainter extends CustomPainter {
  const _CheckGlyphPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final path = Path()
      ..moveTo(s * 0.20, s * 0.52)
      ..lineTo(s * 0.42, s * 0.74)
      ..lineTo(s * 0.82, s * 0.28);
    canvas.drawPath(path, _glyphStroke(color)..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_CheckGlyphPainter old) => old.color != color;
}

class _InfoGlyphPainter extends CustomPainter {
  const _InfoGlyphPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = _glyphStroke(color);
    final center = Offset(s * 0.5, s * 0.5);
    canvas
      ..drawCircle(center, s * 0.38, stroke)
      // 'i' のステム。
      ..drawLine(Offset(s * 0.5, s * 0.46), Offset(s * 0.5, s * 0.68), stroke)
      // 'i' のドット。
      ..drawCircle(Offset(s * 0.5, s * 0.32), 0.9, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_InfoGlyphPainter old) => old.color != color;
}

class _WarnGlyphPainter extends CustomPainter {
  const _WarnGlyphPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = _glyphStroke(color);
    final tri = Path()
      ..moveTo(s * 0.5, s * 0.14)
      ..lineTo(s * 0.90, s * 0.82)
      ..lineTo(s * 0.10, s * 0.82)
      ..close();
    canvas
      ..drawPath(tri, stroke)
      ..drawLine(Offset(s * 0.5, s * 0.40), Offset(s * 0.5, s * 0.62), stroke)
      ..drawCircle(Offset(s * 0.5, s * 0.73), 0.9, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_WarnGlyphPainter old) => old.color != color;
}

class _CopyGlyphPainter extends CustomPainter {
  const _CopyGlyphPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = _glyphStroke(color);
    final r = Radius.circular(s * 0.08);
    // 背面の紙（右上にずらす）。
    final back = RRect.fromLTRBR(s * 0.34, s * 0.14, s * 0.84, s * 0.64, r);
    // 前面の紙（左下）。
    final front = RRect.fromLTRBR(s * 0.16, s * 0.34, s * 0.66, s * 0.86, r);
    canvas
      ..drawRRect(back, stroke)
      ..drawRRect(front, stroke);
  }

  @override
  bool shouldRepaint(_CopyGlyphPainter old) => old.color != color;
}

class _KeyboardGlyphPainter extends CustomPainter {
  const _KeyboardGlyphPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = _glyphStroke(color);
    final body = RRect.fromLTRBR(
      s * 0.08,
      s * 0.26,
      s * 0.92,
      s * 0.74,
      Radius.circular(s * 0.08),
    );
    canvas.drawRRect(body, stroke);
    // キートップ: 上段 3 つの点 + 下段のスペースバー。
    final dot = Paint()..color = color;
    for (final dx in [0.28, 0.5, 0.72]) {
      canvas.drawCircle(Offset(s * dx, s * 0.44), 0.9, dot);
    }
    canvas.drawLine(
      Offset(s * 0.32, s * 0.60),
      Offset(s * 0.68, s * 0.60),
      stroke,
    );
  }

  @override
  bool shouldRepaint(_KeyboardGlyphPainter old) => old.color != color;
}

class _CloseGlyphPainter extends CustomPainter {
  const _CloseGlyphPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = _glyphStroke(color);
    canvas
      ..drawLine(Offset(s * 0.26, s * 0.26), Offset(s * 0.74, s * 0.74), stroke)
      ..drawLine(
        Offset(s * 0.74, s * 0.26),
        Offset(s * 0.26, s * 0.74),
        stroke,
      );
  }

  @override
  bool shouldRepaint(_CloseGlyphPainter old) => old.color != color;
}

class _RowsGlyphPainter extends CustomPainter {
  const _RowsGlyphPainter({required this.color, required this.rows});

  final Color color;
  final int rows;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = _glyphStroke(color)..strokeCap = StrokeCap.round;
    // rows 本の横線を縦方向に等間隔で配置する。
    final top = s * 0.30;
    final bottom = s * 0.70;
    final gap = rows > 1 ? (bottom - top) / (rows - 1) : 0.0;
    for (var i = 0; i < rows; i++) {
      final y = rows > 1 ? top + gap * i : s * 0.5;
      canvas.drawLine(Offset(s * 0.22, y), Offset(s * 0.78, y), stroke);
    }
  }

  @override
  bool shouldRepaint(_RowsGlyphPainter old) =>
      old.color != color || old.rows != rows;
}
