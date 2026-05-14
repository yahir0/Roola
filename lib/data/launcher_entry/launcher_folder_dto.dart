import 'package:json_annotation/json_annotation.dart';
import 'package:roola/data/launcher_entry/launcher_folder.dart';

part 'launcher_folder_dto.g.dart';

/// `LauncherFolder` の JSON 永続化用 DTO。
///
/// スキーマ: `{"id", "name", "createdAt"}`。`createdAt` は ISO 8601 文字列。
/// 旧バージョンの JSON ファイルにはこのキー自体が存在しないため、
/// `LauncherEntryRepositoryImpl` 側で「folders キーが無ければ空配列扱い」と
/// する lazy migration を行っている（ADR-0019）。
@JsonSerializable()
class LauncherFolderDto {
  LauncherFolderDto({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory LauncherFolderDto.fromJson(Map<String, dynamic> json) =>
      _$LauncherFolderDtoFromJson(json);

  factory LauncherFolderDto.fromEntity(LauncherFolder entity) =>
      LauncherFolderDto(
        id: entity.id,
        name: entity.name,
        createdAt: entity.createdAt.toIso8601String(),
      );

  final String id;
  final String name;
  final String createdAt;

  Map<String, dynamic> toJson() => _$LauncherFolderDtoToJson(this);

  LauncherFolder toEntity() => LauncherFolder(
    id: id,
    name: name,
    createdAt: DateTime.parse(createdAt),
  );
}
