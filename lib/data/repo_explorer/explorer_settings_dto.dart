import 'package:claude_skills_launcher/data/repo_explorer/explorer_settings.dart';
import 'package:json_annotation/json_annotation.dart';

part 'explorer_settings_dto.g.dart';

/// `ExplorerSettings` の JSON 永続化 DTO。
@JsonSerializable()
class ExplorerSettingsDto {
  ExplorerSettingsDto({this.rootPath});

  factory ExplorerSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$ExplorerSettingsDtoFromJson(json);

  factory ExplorerSettingsDto.fromEntity(ExplorerSettings entity) =>
      ExplorerSettingsDto(rootPath: entity.rootPath);

  final String? rootPath;

  Map<String, dynamic> toJson() => _$ExplorerSettingsDtoToJson(this);

  ExplorerSettings toEntity() => ExplorerSettings(rootPath: rootPath);
}
