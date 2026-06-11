// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivacySettingsDto _$PrivacySettingsDtoFromJson(Map<String, dynamic> json) =>
    PrivacySettingsDto(
      acceptedTermsVersion: (json['acceptedTermsVersion'] as num?)?.toInt(),
      analyticsEnabled: json['analyticsEnabled'] as bool?,
    );

Map<String, dynamic> _$PrivacySettingsDtoToJson(PrivacySettingsDto instance) =>
    <String, dynamic>{
      'acceptedTermsVersion': instance.acceptedTermsVersion,
      'analyticsEnabled': instance.analyticsEnabled,
    };
