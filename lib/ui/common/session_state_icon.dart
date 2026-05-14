import 'package:flutter/material.dart';
import 'package:roola/data/terminal_runner/terminal_run_state.dart';
import 'package:roola/ui/common/pulsing_icon.dart';

/// 状態に応じたアイコン形状と色のペア。`Chip.avatar` の `Icon` や、
/// バッジで描画する小アイコンの基礎情報として複数のフィーチャーから参照する。
(IconData, Color) sessionStateIcon(SkillRunState state) {
  return switch (state) {
    SkillRunIdle() => (Icons.hourglass_empty, Colors.grey),
    SkillRunStarting() => (Icons.play_circle_outline, Colors.blue),
    SkillRunRunning() => (Icons.circle, Colors.green),
    SkillRunWaitingInput() => (Icons.circle, Colors.amber),
    SkillRunCompleted(:final exitCode) =>
      exitCode == 0
          ? (Icons.check_circle, Colors.green)
          : (Icons.warning, Colors.orange),
    SkillRunFailed() => (Icons.error, Colors.red),
    SkillRunCancelled() => (Icons.stop_circle, Colors.grey),
  };
}

/// 状態に応じたアイコン Widget を返す。`SkillRunRunning` のみ
/// `PulsingIcon` で呼吸させ、それ以外は静止アイコン。
Widget sessionStateAvatar(SkillRunState state, {double size = 16}) {
  final (icon, color) = sessionStateIcon(state);
  if (state is SkillRunRunning) {
    return PulsingIcon(icon: icon, color: color, size: size);
  }
  return Icon(icon, size: size, color: color);
}
