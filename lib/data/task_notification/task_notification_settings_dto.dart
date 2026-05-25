import 'package:json_annotation/json_annotation.dart';
import 'package:roola/data/task_notification/task_notification_settings.dart';

part 'task_notification_settings_dto.g.dart';

/// `TaskNotificationSettings` の JSON 永続化 DTO（ADR-0057）。
@JsonSerializable()
class TaskNotificationSettingsDto {
  TaskNotificationSettingsDto({this.enabled});

  factory TaskNotificationSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$TaskNotificationSettingsDtoFromJson(json);

  factory TaskNotificationSettingsDto.fromEntity(
    TaskNotificationSettings entity,
  ) => TaskNotificationSettingsDto(enabled: entity.enabled);

  /// 旧バージョンの設定ファイルには存在しないため nullable。
  /// `toEntity` で既定値（false）にフォールバックする。
  final bool? enabled;

  Map<String, dynamic> toJson() => _$TaskNotificationSettingsDtoToJson(this);

  TaskNotificationSettings toEntity() {
    final defaults = TaskNotificationSettings.defaults();
    return TaskNotificationSettings(enabled: enabled ?? defaults.enabled);
  }
}
