import 'package:flutter/material.dart';

/// 状態インジケーター（Polaris / ADR-0038 D11）。
///
/// 単色の塗り点でなく、機械の「ベゼルに嵌った表示灯」として描く — 同色の
/// ヘアラインのリング（淡）＋塗りのコア（濃）の同心円。小さな点にも精密さと
/// 素材感を与える。Git 状態・電源灯・Ready 表示などに使う。
class PolarisIndicator extends StatelessWidget {
  const PolarisIndicator({super.key, required this.color, this.size = 10});

  /// 表示灯の色。意味（信号色）はこの色で運ぶ。
  final Color color;

  /// 同心円の外径（px）。
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _IndicatorPainter(color: color)),
    );
  }
}

class _IndicatorPainter extends CustomPainter {
  const _IndicatorPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // ベゼル: 同色の淡いヘアラインリング。
    final ring = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, size.width / 2 - 0.5, ring);
    // 表示灯のコア: 同色の塗り。
    final core = Paint()..color = color;
    canvas.drawCircle(center, size.width * 0.19, core);
  }

  @override
  bool shouldRepaint(_IndicatorPainter old) => old.color != color;
}
