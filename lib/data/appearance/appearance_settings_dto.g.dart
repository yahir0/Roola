// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appearance_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppearanceSettingsDto _$AppearanceSettingsDtoFromJson(
  Map<String, dynamic> json,
) => AppearanceSettingsDto(
  mode: json['mode'] as String,
  transparencyOpacity: (json['transparencyOpacity'] as num?)?.toDouble(),
  transparentCenterImagePath: json['transparentCenterImagePath'] as String?,
  transparentCenterImageMtime: (json['transparentCenterImageMtime'] as num?)
      ?.toInt(),
  accent: json['accent'] as String?,
);

Map<String, dynamic> _$AppearanceSettingsDtoToJson(
  AppearanceSettingsDto instance,
) => <String, dynamic>{
  'mode': instance.mode,
  'transparencyOpacity': instance.transparencyOpacity,
  'transparentCenterImagePath': instance.transparentCenterImagePath,
  'transparentCenterImageMtime': instance.transparentCenterImageMtime,
  'accent': instance.accent,
};
