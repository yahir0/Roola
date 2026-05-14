import 'package:json_annotation/json_annotation.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';

part 'launcher_entry_dto.g.dart';

/// `LauncherEntry` の JSON 永続化用 DTO。
///
/// 永続化スキーマは `{"id", "displayName", "workingDirectory", "action",
/// "folderId", "createdAt"}`。`action` は [LauncherAction] の sealed union を
/// `type` キー付き JSON で表現する。`createdAt` は ISO 8601 文字列、
/// `folderId` は null 許容（ADR-0019）。
///
/// 旧スキーマ（`repositoryPath` / `skillName` の 2 フィールド）も [fromJson]
/// で受理する。`action` キーが無いか旧 key が存在する場合は新スキーマへ自動
/// 変換する（ADR-0016 の lazy migration on read）。`folderId` キーが無い古い
/// 新スキーマ JSON は null として読み込む（ADR-0019）。旧 `iconPath` キーは
/// 単純に無視される（ADR-0023）。書き戻しは新スキーマ固定。
@JsonSerializable()
class LauncherEntryDto {
  LauncherEntryDto({
    required this.id,
    required this.displayName,
    required this.workingDirectory,
    required this.action,
    required this.createdAt,
    this.folderId,
  });

  factory LauncherEntryDto.fromJson(Map<String, dynamic> json) {
    // 旧スキーマ判定: 新スキーマなら必ず action / workingDirectory を持つ。
    // 旧スキーマには repositoryPath / skillName がある。
    final hasNewSchema = json.containsKey('action');
    if (hasNewSchema) {
      return _$LauncherEntryDtoFromJson(json);
    }
    final repositoryPath = json['repositoryPath'] as String? ?? '';
    final skillName = (json['skillName'] as String? ?? '').trim();
    final action = skillName.isEmpty
        ? const LauncherAction.openHere()
        : LauncherAction.claudeSkill(skillName: skillName);
    return LauncherEntryDto(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      workingDirectory: repositoryPath,
      action: action,
      createdAt: json['createdAt'] as String,
    );
  }

  factory LauncherEntryDto.fromEntity(LauncherEntry entity) => LauncherEntryDto(
    id: entity.id,
    displayName: entity.displayName,
    workingDirectory: entity.workingDirectory,
    action: entity.action,
    folderId: entity.folderId,
    createdAt: entity.createdAt.toIso8601String(),
  );

  final String id;
  final String displayName;
  final String workingDirectory;
  final LauncherAction action;
  final String? folderId;
  final String createdAt;

  Map<String, dynamic> toJson() => _$LauncherEntryDtoToJson(this);

  LauncherEntry toEntity() => LauncherEntry(
    id: id,
    displayName: displayName,
    workingDirectory: workingDirectory,
    action: action,
    folderId: folderId,
    createdAt: DateTime.parse(createdAt),
  );
}
