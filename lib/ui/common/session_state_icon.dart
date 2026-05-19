import 'package:flutter/material.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/terminal_runner/terminal_run_state.dart';
import 'package:roola/ui/common/pulsing_icon.dart';

/// 状態に応じたアイコン形状と色のペア（Polaris / ADR-0038）。`Chip.avatar`
/// の `Icon` やバッジで描画する小アイコンの基礎情報として複数のフィーチャー
/// から参照する。色は信号色トークンで運ぶ — 実行中・完了=新規色（green）、
/// 入力待ち=アクセント、失敗・異常終了=コンフリクト色（red）。
(IconData, Color) sessionStateIcon(PolarisTokens tokens, SkillRunState state) {
  return switch (state) {
    SkillRunIdle() => (Icons.hourglass_empty, tokens.textFaint),
    SkillRunStarting() => (Icons.play_circle_outline, tokens.textDim),
    SkillRunRunning() => (Icons.circle, tokens.signalNew),
    SkillRunWaitingInput() => (Icons.circle, tokens.accent),
    SkillRunCompleted(:final exitCode) =>
      exitCode == 0
          ? (Icons.check_circle, tokens.signalNew)
          : (Icons.warning, tokens.signalConflict),
    SkillRunFailed() => (Icons.error, tokens.signalConflict),
    SkillRunCancelled() => (Icons.stop_circle, tokens.textFaint),
  };
}

/// 状態に応じたアイコン Widget を返す。`SkillRunRunning` のみ
/// `PulsingIcon` で呼吸させ、それ以外は静止アイコン。
Widget sessionStateAvatar(
  PolarisTokens tokens,
  SkillRunState state, {
  double size = 16,
}) {
  final (icon, color) = sessionStateIcon(tokens, state);
  if (state is SkillRunRunning) {
    return PulsingIcon(icon: icon, color: color, size: size);
  }
  return Icon(icon, size: size, color: color);
}
