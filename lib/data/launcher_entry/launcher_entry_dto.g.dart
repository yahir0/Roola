// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launcher_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LauncherEntryDto _$LauncherEntryDtoFromJson(Map<String, dynamic> json) =>
    LauncherEntryDto(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      workingDirectory: json['workingDirectory'] as String,
      action: LauncherAction.fromJson(json['action'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as String,
      folderId: json['folderId'] as String?,
    );

Map<String, dynamic> _$LauncherEntryDtoToJson(LauncherEntryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'workingDirectory': instance.workingDirectory,
      'action': instance.action,
      'folderId': instance.folderId,
      'createdAt': instance.createdAt,
    };
