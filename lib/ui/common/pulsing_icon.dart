import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 実行中インジケータ用の、ゆっくり明滅するアイコン。
///
/// `SkillRunRunning` 状態を示すパイロットランプ等で使う。透明度を 2 秒
/// 周期で 0.35 ↔ 1.0 にフェード往復させ「動いている感」を出す。
class PulsingIcon extends HookWidget {
  const PulsingIcon({
    required this.icon,
    required this.color,
    this.size = 16,
    super.key,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(seconds: 2),
    );
    useEffect(() {
      controller.repeat(reverse: true);
      return null;
    }, const []);

    final opacity = useMemoized(
      () => Tween<double>(
        begin: 0.35,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut)),
      [controller],
    );

    return FadeTransition(
      opacity: opacity,
      child: Icon(icon, size: size, color: color),
    );
  }
}
