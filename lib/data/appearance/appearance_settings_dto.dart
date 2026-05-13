import 'package:json_annotation/json_annotation.dart';
import 'package:roola/data/appearance/appearance_settings.dart';

part 'appearance_settings_dto.g.dart';

/// `AppearanceSettings` の JSON 永続化 DTO。
@JsonSerializable()
class AppearanceSettingsDto {
  AppearanceSettingsDto({
    required this.mode,
    this.solidColor,
    this.imagePath,
    this.transparencyOpacity,
    this.transparentCenterImagePath,
    this.transparentCenterImageMtime,
  });

  factory AppearanceSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$AppearanceSettingsDtoFromJson(json);

  factory AppearanceSettingsDto.fromEntity(AppearanceSettings entity) =>
      AppearanceSettingsDto(
        mode: entity.mode.name,
        solidColor: entity.solidColor,
        imagePath: entity.imagePath,
        transparencyOpacity: entity.transparencyOpacity,
        transparentCenterImagePath: entity.transparentCenterImagePath,
        transparentCenterImageMtime: entity.transparentCenterImageMtime,
      );

  final String mode;
  final int? solidColor;
  final String? imagePath;

  /// 旧バージョンの設定ファイルには存在しないため nullable。
  /// `toEntity` で fallback として既定値（0.8）を当てる。
  final double? transparencyOpacity;

  /// 透過モード時に中央に重ねる画像。未設定なら null。
  final String? transparentCenterImagePath;

  /// 中央画像の更新時刻（millisecondsSinceEpoch）。
  /// state の equality 破りに使う。
  final int? transparentCenterImageMtime;

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
      transparentCenterImagePath: transparentCenterImagePath,
      transparentCenterImageMtime: transparentCenterImageMtime,
    );
  }
}
