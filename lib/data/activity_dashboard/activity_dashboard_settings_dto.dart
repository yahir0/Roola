import 'package:json_annotation/json_annotation.dart';
import 'package:roola/data/activity_dashboard/activity_dashboard_settings.dart';

part 'activity_dashboard_settings_dto.g.dart';

/// `ActivityDashboardSettings` の JSON 永続化 DTO。
///
/// enum は `name` で保存し、未知の値・欠けたキーは既定値にフォールバックする
/// （将来スタイルを増減しても設定ファイルが壊れないように）。
@JsonSerializable()
class ActivityDashboardSettingsDto {
  ActivityDashboardSettingsDto({this.mode, this.tachoStyle, this.showAllCores});

  factory ActivityDashboardSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$ActivityDashboardSettingsDtoFromJson(json);

  factory ActivityDashboardSettingsDto.fromEntity(
    ActivityDashboardSettings entity,
  ) => ActivityDashboardSettingsDto(
    mode: entity.mode.name,
    tachoStyle: entity.tachoStyle.name,
    showAllCores: entity.showAllCores,
  );

  final String? mode;
  final String? tachoStyle;
  final bool? showAllCores;

  Map<String, dynamic> toJson() => _$ActivityDashboardSettingsDtoToJson(this);

  ActivityDashboardSettings toEntity() {
    final defaults = ActivityDashboardSettings.defaults();
    return ActivityDashboardSettings(
      mode: ActivityDisplayMode.values.firstWhere(
        (m) => m.name == mode,
        orElse: () => defaults.mode,
      ),
      tachoStyle: TachoStyle.values.firstWhere(
        (s) => s.name == tachoStyle,
        orElse: () => defaults.tachoStyle,
      ),
      showAllCores: showAllCores ?? defaults.showAllCores,
    );
  }
}
