import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry.dart';
import 'package:json_annotation/json_annotation.dart';

part 'launcher_entry_dto.g.dart';

/// `LauncherEntry` の JSON 永続化用 DTO。
///
/// `DateTime` は ISO 8601 文字列で保持し、nullable な `iconPath` は
/// JSON 上は null を許容する。`LauncherEntry` ↔ `LauncherEntryDto` の
/// 変換は `toEntity` / `fromEntity` を介する。
@JsonSerializable()
class LauncherEntryDto {
  LauncherEntryDto({
    required this.id,
    required this.displayName,
    required this.repositoryPath,
    required this.skillName,
    required this.createdAt,
    this.iconPath,
  });

  factory LauncherEntryDto.fromJson(Map<String, dynamic> json) =>
      _$LauncherEntryDtoFromJson(json);

  factory LauncherEntryDto.fromEntity(LauncherEntry entity) => LauncherEntryDto(
    id: entity.id,
    displayName: entity.displayName,
    repositoryPath: entity.repositoryPath,
    skillName: entity.skillName,
    iconPath: entity.iconPath,
    createdAt: entity.createdAt.toIso8601String(),
  );

  final String id;
  final String displayName;
  final String repositoryPath;
  final String skillName;
  final String? iconPath;
  final String createdAt;

  Map<String, dynamic> toJson() => _$LauncherEntryDtoToJson(this);

  LauncherEntry toEntity() => LauncherEntry(
    id: id,
    displayName: displayName,
    repositoryPath: repositoryPath,
    skillName: skillName,
    iconPath: iconPath,
    createdAt: DateTime.parse(createdAt),
  );
}
