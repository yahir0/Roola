// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terminal_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TerminalSettingsDto _$TerminalSettingsDtoFromJson(Map<String, dynamic> json) =>
    TerminalSettingsDto(
      windowsShell: $enumDecodeNullable(
        _$WindowsShellEnumMap,
        json['windowsShell'],
        unknownValue: WindowsShell.powershell,
      ),
    );

Map<String, dynamic> _$TerminalSettingsDtoToJson(
  TerminalSettingsDto instance,
) => <String, dynamic>{
  'windowsShell': _$WindowsShellEnumMap[instance.windowsShell],
};

const _$WindowsShellEnumMap = {
  WindowsShell.cmd: 'cmd',
  WindowsShell.powershell: 'powershell',
  WindowsShell.pwsh: 'pwsh',
};
