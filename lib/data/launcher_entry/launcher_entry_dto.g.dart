// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launcher_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LauncherEntryDto _$LauncherEntryDtoFromJson(Map<String, dynamic> json) =>
    LauncherEntryDto(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      repositoryPath: json['repositoryPath'] as String,
      skillName: json['skillName'] as String,
      createdAt: json['createdAt'] as String,
      iconPath: json['iconPath'] as String?,
    );

Map<String, dynamic> _$LauncherEntryDtoToJson(LauncherEntryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'repositoryPath': instance.repositoryPath,
      'skillName': instance.skillName,
      'iconPath': instance.iconPath,
      'createdAt': instance.createdAt,
    };
