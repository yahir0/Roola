// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explorer_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExplorerSettingsDto _$ExplorerSettingsDtoFromJson(
  Map<String, dynamic> json,
) => ExplorerSettingsDto(
  rootPath: json['rootPath'] as String?,
  favorites:
      (json['favorites'] as List<dynamic>?)
          ?.map((e) => ExplorerFavoriteDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  favoriteFolders:
      (json['favoriteFolders'] as List<dynamic>?)
          ?.map(
            (e) =>
                ExplorerFavoriteFolderDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  listDensity:
      $enumDecodeNullable(_$ExplorerListDensityEnumMap, json['listDensity']) ??
      ExplorerListDensity.comfortable,
);

Map<String, dynamic> _$ExplorerSettingsDtoToJson(
  ExplorerSettingsDto instance,
) => <String, dynamic>{
  'rootPath': instance.rootPath,
  'favorites': instance.favorites.map((e) => e.toJson()).toList(),
  'favoriteFolders': instance.favoriteFolders.map((e) => e.toJson()).toList(),
  'listDensity': _$ExplorerListDensityEnumMap[instance.listDensity]!,
};

const _$ExplorerListDensityEnumMap = {
  ExplorerListDensity.compact: 'compact',
  ExplorerListDensity.comfortable: 'comfortable',
};

ExplorerFavoriteDto _$ExplorerFavoriteDtoFromJson(Map<String, dynamic> json) =>
    ExplorerFavoriteDto(
      id: json['id'] as String,
      path: json['path'] as String,
      name: json['name'] as String,
      folderId: json['folderId'] as String?,
    );

Map<String, dynamic> _$ExplorerFavoriteDtoToJson(
  ExplorerFavoriteDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'path': instance.path,
  'name': instance.name,
  'folderId': instance.folderId,
};

ExplorerFavoriteFolderDto _$ExplorerFavoriteFolderDtoFromJson(
  Map<String, dynamic> json,
) => ExplorerFavoriteFolderDto(
  id: json['id'] as String,
  name: json['name'] as String,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$ExplorerFavoriteFolderDtoToJson(
  ExplorerFavoriteFolderDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'createdAt': instance.createdAt,
};
