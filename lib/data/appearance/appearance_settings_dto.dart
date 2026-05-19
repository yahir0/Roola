import 'package:json_annotation/json_annotation.dart';
import 'package:roola/data/appearance/appearance_settings.dart';
import 'package:roola/data/appearance/polaris_accent.dart';

part 'appearance_settings_dto.g.dart';

/// `AppearanceSettings` の JSON 永続化 DTO。
@JsonSerializable()
class AppearanceSettingsDto {
  AppearanceSettingsDto({
    required this.mode,
    this.transparencyOpacity,
    this.transparentCenterImagePath,
    this.transparentCenterImageMtime,
    this.accent,
  });

  factory AppearanceSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$AppearanceSettingsDtoFromJson(json);

  factory AppearanceSettingsDto.fromEntity(AppearanceSettings entity) =>
      AppearanceSettingsDto(
        mode: entity.mode.name,
        transparencyOpacity: entity.transparencyOpacity,
        transparentCenterImagePath: entity.transparentCenterImagePath,
        transparentCenterImageMtime: entity.transparentCenterImageMtime,
        accent: entity.accent.name,
      );

  final String mode;

  /// 旧バージョンの設定ファイルには存在しないため nullable。
  /// `toEntity` で fallback として既定値（0.8）を当てる。
  final double? transparencyOpacity;

  /// 透過モード時に中央に重ねる画像。未設定なら null。
  final String? transparentCenterImagePath;

  /// 中央画像の更新時刻（millisecondsSinceEpoch）。
  /// state の equality 破りに使う。
  final int? transparentCenterImageMtime;

  /// アクセント色（`PolarisAccent` の名前）。旧バージョンの設定ファイルには
  /// 存在しないため nullable。`toEntity` で既定（gold）にフォールバックする。
  final String? accent;

  Map<String, dynamic> toJson() => _$AppearanceSettingsDtoToJson(this);

  AppearanceSettings toEntity() {
    final defaults = AppearanceSettings.defaults();
    return AppearanceSettings(
      // 旧 solid / image / gradient が保存されていた設定ファイルは、未知の
      // モード名として不透明（opaque）にフォールバックする。
      mode: AppearanceMode.values.firstWhere(
        (m) => m.name == mode,
        orElse: () => AppearanceMode.opaque,
      ),
      transparencyOpacity: transparencyOpacity ?? defaults.transparencyOpacity,
      transparentCenterImagePath: transparentCenterImagePath,
      transparentCenterImageMtime: transparentCenterImageMtime,
      accent: PolarisAccent.values.firstWhere(
        (a) => a.name == accent,
        orElse: () => PolarisAccent.gold,
      ),
    );
  }
}
