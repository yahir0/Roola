import 'package:json_annotation/json_annotation.dart';
import 'package:roola/data/privacy/privacy_settings.dart';

part 'privacy_settings_dto.g.dart';

/// `PrivacySettings` の JSON 永続化 DTO。
@JsonSerializable()
class PrivacySettingsDto {
  PrivacySettingsDto({this.acceptedTermsVersion, this.analyticsEnabled});

  factory PrivacySettingsDto.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsDtoFromJson(json);

  factory PrivacySettingsDto.fromEntity(PrivacySettings entity) =>
      PrivacySettingsDto(
        acceptedTermsVersion: entity.acceptedTermsVersion,
        analyticsEnabled: entity.analyticsEnabled,
      );

  /// 未同意は null（Entity と同じ意味論）。
  final int? acceptedTermsVersion;

  /// 旧バージョンの設定ファイルには存在しないため nullable。
  /// `toEntity` で fallback として既定値（true）を当てる。
  final bool? analyticsEnabled;

  Map<String, dynamic> toJson() => _$PrivacySettingsDtoToJson(this);

  PrivacySettings toEntity() {
    final defaults = PrivacySettings.defaults();
    return PrivacySettings(
      acceptedTermsVersion: acceptedTermsVersion,
      analyticsEnabled: analyticsEnabled ?? defaults.analyticsEnabled,
    );
  }
}
