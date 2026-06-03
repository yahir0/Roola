// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_notification_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskNotificationSettingsDto _$TaskNotificationSettingsDtoFromJson(
  Map<String, dynamic> json,
) => TaskNotificationSettingsDto(
  enabled: json['enabled'] as bool?,
  preferredPort: (json['preferredPort'] as num?)?.toInt(),
);

Map<String, dynamic> _$TaskNotificationSettingsDtoToJson(
  TaskNotificationSettingsDto instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'preferredPort': instance.preferredPort,
};
