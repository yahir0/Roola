// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explorer_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExplorerSettingsDto _$ExplorerSettingsDtoFromJson(Map<String, dynamic> json) =>
    ExplorerSettingsDto(
      rootPath: json['rootPath'] as String?,
      favorites:
          (json['favorites'] as List<dynamic>?)
              ?.map(
                (e) => ExplorerFavoriteDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ExplorerSettingsDtoToJson(
  ExplorerSettingsDto instance,
) => <String, dynamic>{
  'rootPath': instance.rootPath,
  'favorites': instance.favorites.map((e) => e.toJson()).toList(),
};

ExplorerFavoriteDto _$ExplorerFavoriteDtoFromJson(Map<String, dynamic> json) =>
    ExplorerFavoriteDto(
      id: json['id'] as String,
      path: json['path'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$ExplorerFavoriteDtoToJson(
  ExplorerFavoriteDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'path': instance.path,
  'name': instance.name,
};
