import 'package:claude_skills_launcher/data/appearance/appearance_settings.dart';
import 'package:json_annotation/json_annotation.dart';

part 'appearance_settings_dto.g.dart';

/// `AppearanceSettings` の JSON 永続化 DTO。
@JsonSerializable()
class AppearanceSettingsDto {
  AppearanceSettingsDto({required this.mode, this.solidColor, this.imagePath});

  factory AppearanceSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$AppearanceSettingsDtoFromJson(json);

  factory AppearanceSettingsDto.fromEntity(AppearanceSettings entity) =>
      AppearanceSettingsDto(
        mode: entity.mode.name,
        solidColor: entity.solidColor,
        imagePath: entity.imagePath,
      );

  final String mode;
  final int? solidColor;
  final String? imagePath;

  Map<String, dynamic> toJson() => _$AppearanceSettingsDtoToJson(this);

  AppearanceSettings toEntity() => AppearanceSettings(
    mode: AppearanceMode.values.firstWhere(
      (m) => m.name == mode,
      orElse: () => AppearanceMode.transparent,
    ),
    solidColor: solidColor,
    imagePath: imagePath,
  );
}
