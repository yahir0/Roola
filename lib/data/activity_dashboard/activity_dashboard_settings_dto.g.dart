// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_dashboard_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityDashboardSettingsDto _$ActivityDashboardSettingsDtoFromJson(
  Map<String, dynamic> json,
) => ActivityDashboardSettingsDto(
  mode: json['mode'] as String?,
  tachoStyle: json['tachoStyle'] as String?,
  showAllCores: json['showAllCores'] as bool?,
);

Map<String, dynamic> _$ActivityDashboardSettingsDtoToJson(
  ActivityDashboardSettingsDto instance,
) => <String, dynamic>{
  'mode': instance.mode,
  'tachoStyle': instance.tachoStyle,
  'showAllCores': instance.showAllCores,
};
