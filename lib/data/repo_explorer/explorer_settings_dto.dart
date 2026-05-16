import 'package:json_annotation/json_annotation.dart';
import 'package:roola/data/repo_explorer/explorer_settings.dart';

part 'explorer_settings_dto.g.dart';

/// `ExplorerSettings` の JSON 永続化 DTO。
///
/// スキーマ: `{"rootPath", "favorites", "favoriteFolders", "listDensity"}`。
/// `listDensity` キーが無いデータは `comfortable` として解釈する（ADR-0024）。
/// `favoriteFolders` キーが無い古い JSON は空配列扱い、`favorites` 各要素の
/// `folderId` キーが無ければ null（未分類）として読み込む（ADR-0029）。
@JsonSerializable(explicitToJson: true)
class ExplorerSettingsDto {
  ExplorerSettingsDto({
    this.rootPath,
    this.favorites = const [],
    this.favoriteFolders = const [],
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
        favoriteFolders: entity.favoriteFolders
            .map(ExplorerFavoriteFolderDto.fromEntity)
            .toList(growable: false),
        listDensity: entity.listDensity,
      );

  final String? rootPath;
  final List<ExplorerFavoriteDto> favorites;
  final List<ExplorerFavoriteFolderDto> favoriteFolders;
  final ExplorerListDensity listDensity;

  Map<String, dynamic> toJson() => _$ExplorerSettingsDtoToJson(this);

  ExplorerSettings toEntity() => ExplorerSettings(
    rootPath: rootPath,
    favorites: favorites.map((dto) => dto.toEntity()).toList(growable: false),
    favoriteFolders: favoriteFolders
        .map((dto) => dto.toEntity())
        .toList(growable: false),
    listDensity: listDensity,
  );
}

/// `ExplorerFavorite` の JSON 永続化 DTO。
///
/// `folderId` は null 許容（ADR-0029）。キーが無い古い JSON は null として
/// 読み込まれる。
@JsonSerializable()
class ExplorerFavoriteDto {
  ExplorerFavoriteDto({
    required this.id,
    required this.path,
    required this.name,
    this.folderId,
  });

  factory ExplorerFavoriteDto.fromJson(Map<String, dynamic> json) =>
      _$ExplorerFavoriteDtoFromJson(json);

  factory ExplorerFavoriteDto.fromEntity(ExplorerFavorite entity) =>
      ExplorerFavoriteDto(
        id: entity.id,
        path: entity.path,
        name: entity.name,
        folderId: entity.folderId,
      );

  final String id;
  final String path;
  final String name;
  final String? folderId;

  Map<String, dynamic> toJson() => _$ExplorerFavoriteDtoToJson(this);

  ExplorerFavorite toEntity() =>
      ExplorerFavorite(id: id, path: path, name: name, folderId: folderId);
}

/// `ExplorerFavoriteFolder` の JSON 永続化 DTO（ADR-0029）。
///
/// スキーマ: `{"id", "name", "createdAt"}`。`createdAt` は ISO 8601 文字列。
@JsonSerializable()
class ExplorerFavoriteFolderDto {
  ExplorerFavoriteFolderDto({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory ExplorerFavoriteFolderDto.fromJson(Map<String, dynamic> json) =>
      _$ExplorerFavoriteFolderDtoFromJson(json);

  factory ExplorerFavoriteFolderDto.fromEntity(ExplorerFavoriteFolder entity) =>
      ExplorerFavoriteFolderDto(
        id: entity.id,
        name: entity.name,
        createdAt: entity.createdAt.toIso8601String(),
      );

  final String id;
  final String name;
  final String createdAt;

  Map<String, dynamic> toJson() => _$ExplorerFavoriteFolderDtoToJson(this);

  ExplorerFavoriteFolder toEntity() => ExplorerFavoriteFolder(
    id: id,
    name: name,
    createdAt: DateTime.parse(createdAt),
  );
}
