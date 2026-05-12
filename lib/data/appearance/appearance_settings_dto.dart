import 'package:claude_skills_launcher/data/appearance/appearance_settings.dart';
import 'package:json_annotation/json_annotation.dart';

part 'appearance_settings_dto.g.dart';

/// `AppearanceSettings` の JSON 永続化 DTO。
@JsonSerializable()
class AppearanceSettingsDto {
  AppearanceSettingsDto({
    required this.mode,
    this.solidColor,
    this.imagePath,
    this.transparencyOpacity,
  });

  factory AppearanceSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$AppearanceSettingsDtoFromJson(json);

  factory AppearanceSettingsDto.fromEntity(AppearanceSettings entity) =>
      AppearanceSettingsDto(
        mode: entity.mode.name,
        solidColor: entity.solidColor,
        imagePath: entity.imagePath,
        transparencyOpacity: entity.transparencyOpacity,
      );

  final String mode;
  final int? solidColor;
  final String? imagePath;

  /// 旧バージョンの設定ファイルには存在しないため nullable。
  /// `toEntity` で fallback として既定値（0.8）を当てる。
  final double? transparencyOpacity;

  Map<String, dynamic> toJson() => _$AppearanceSettingsDtoToJson(this);

  AppearanceSettings toEntity() {
    final defaults = AppearanceSettings.defaults();
    return AppearanceSettings(
      mode: AppearanceMode.values.firstWhere(
        (m) => m.name == mode,
        orElse: () => AppearanceMode.transparent,
      ),
      solidColor: solidColor,
      imagePath: imagePath,
      transparencyOpacity: transparencyOpacity ?? defaults.transparencyOpacity,
    );
  }
}
