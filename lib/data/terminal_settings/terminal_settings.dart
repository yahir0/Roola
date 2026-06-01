import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:roola/data/terminal_runner/windows_shell.dart';

part 'terminal_settings.freezed.dart';

/// ターミナル動作設定（Windows シェル選択 等）。
///
/// 外観設定（`AppearanceSettings`）とは責務が異なるため分離して保持する。
@freezed
abstract class TerminalSettings with _$TerminalSettings {
  const factory TerminalSettings({
    /// Windows でターミナルタブを開くときに使うシェル。
    /// デフォルトは PowerShell 5 (powershell.exe)。
    @Default(WindowsShell.powershell) WindowsShell windowsShell,
  }) = _TerminalSettings;

  static TerminalSettings defaults() => const TerminalSettings();
}
