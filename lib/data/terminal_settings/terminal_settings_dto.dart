import 'package:json_annotation/json_annotation.dart';
import 'package:roola/data/terminal_runner/windows_shell.dart';
import 'package:roola/data/terminal_settings/terminal_settings.dart';

part 'terminal_settings_dto.g.dart';

@JsonSerializable()
class TerminalSettingsDto {
  const TerminalSettingsDto({this.windowsShell});

  factory TerminalSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$TerminalSettingsDtoFromJson(json);

  @JsonKey(unknownEnumValue: WindowsShell.powershell)
  final WindowsShell? windowsShell;

  Map<String, dynamic> toJson() => _$TerminalSettingsDtoToJson(this);

  TerminalSettings toModel() => TerminalSettings(
        windowsShell: windowsShell ?? WindowsShell.powershell,
      );

  static TerminalSettingsDto fromModel(TerminalSettings m) =>
      TerminalSettingsDto(windowsShell: m.windowsShell);
}
