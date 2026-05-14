import 'package:json_annotation/json_annotation.dart';
import 'package:roola/data/repo_explorer/explorer_settings.dart';

part 'explorer_settings_dto.g.dart';

/// `ExplorerSettings` の JSON 永続化 DTO。
///
/// スキーマ: `{"rootPath", "favorites", "listDensity"}`。
/// `listDensity` キーが無いデータは `comfortable` として解釈する（ADR-0024）。
@JsonSerializable(explicitToJson: true)
class ExplorerSettingsDto {
  ExplorerSettingsDto({
    this.rootPath,
    this.favorites = const [],
    this.listDensity = ExplorerListDensity.comfortable,
  });

  factory ExplorerSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$ExplorerSettingsDtoFromJson(json);

  factory ExplorerSettingsDto.fromEntity(ExplorerSettings entity) =>
      ExplorerSettingsDto(
        rootPath: entity.rootPath,
        favorites: entity.favorites
            .map(ExplorerFavoriteDto.fromEntity)
            .toList(growable: false),
        listDensity: entity.listDensity,
      );

  final String? rootPath;
  final List<ExplorerFavoriteDto> favorites;
  final ExplorerListDensity listDensity;

  Map<String, dynamic> toJson() => _$ExplorerSettingsDtoToJson(this);

  ExplorerSettings toEntity() => ExplorerSettings(
    rootPath: rootPath,
    favorites: favorites.map((dto) => dto.toEntity()).toList(growable: false),
    listDensity: listDensity,
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
