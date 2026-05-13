import 'package:json_annotation/json_annotation.dart';
import 'package:roola/data/repo_explorer/explorer_settings.dart';

part 'explorer_settings_dto.g.dart';

/// `ExplorerSettings` の JSON 永続化 DTO。
@JsonSerializable(explicitToJson: true)
class ExplorerSettingsDto {
  ExplorerSettingsDto({this.rootPath, this.favorites = const []});

  factory ExplorerSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$ExplorerSettingsDtoFromJson(json);

  factory ExplorerSettingsDto.fromEntity(ExplorerSettings entity) =>
      ExplorerSettingsDto(
        rootPath: entity.rootPath,
        favorites: entity.favorites
            .map(ExplorerFavoriteDto.fromEntity)
            .toList(growable: false),
      );

  final String? rootPath;
  final List<ExplorerFavoriteDto> favorites;

  Map<String, dynamic> toJson() => _$ExplorerSettingsDtoToJson(this);

  ExplorerSettings toEntity() => ExplorerSettings(
    rootPath: rootPath,
    favorites: favorites.map((dto) => dto.toEntity()).toList(growable: false),
  );
}

/// `ExplorerFavorite` の JSON 永続化 DTO。
@JsonSerializable()
class ExplorerFavoriteDto {
  ExplorerFavoriteDto({
    required this.id,
    required this.path,
    required this.name,
  });

  factory ExplorerFavoriteDto.fromJson(Map<String, dynamic> json) =>
      _$ExplorerFavoriteDtoFromJson(json);

  factory ExplorerFavoriteDto.fromEntity(ExplorerFavorite entity) =>
      ExplorerFavoriteDto(id: entity.id, path: entity.path, name: entity.name);

  final String id;
  final String path;
  final String name;

  Map<String, dynamic> toJson() => _$ExplorerFavoriteDtoToJson(this);

  ExplorerFavorite toEntity() =>
      ExplorerFavorite(id: id, path: path, name: name);
}
