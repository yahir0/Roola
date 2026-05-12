// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appearance_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppearanceSettingsDto _$AppearanceSettingsDtoFromJson(
  Map<String, dynamic> json,
) => AppearanceSettingsDto(
  mode: json['mode'] as String,
  solidColor: (json['solidColor'] as num?)?.toInt(),
  imagePath: json['imagePath'] as String?,
);

Map<String, dynamic> _$AppearanceSettingsDtoToJson(
  AppearanceSettingsDto instance,
) => <String, dynamic>{
  'mode': instance.mode,
  'solidColor': instance.solidColor,
  'imagePath': instance.imagePath,
};
