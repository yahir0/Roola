// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_layout_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkspaceLayoutDto _$WorkspaceLayoutDtoFromJson(Map<String, dynamic> json) =>
    WorkspaceLayoutDto(
      topLeft: PaneSlotDto.fromJson(json['topLeft'] as Map<String, dynamic>),
      topRight: PaneSlotDto.fromJson(json['topRight'] as Map<String, dynamic>),
      bottom: PaneSlotDto.fromJson(json['bottom'] as Map<String, dynamic>),
      topRatio: (json['topRatio'] as num?)?.toDouble() ?? 0.62,
      leftRatio: (json['leftRatio'] as num?)?.toDouble() ?? 0.5,
    );

Map<String, dynamic> _$WorkspaceLayoutDtoToJson(WorkspaceLayoutDto instance) =>
    <String, dynamic>{
      'topLeft': instance.topLeft.toJson(),
      'topRight': instance.topRight.toJson(),
      'bottom': instance.bottom.toJson(),
      'topRatio': instance.topRatio,
      'leftRatio': instance.leftRatio,
    };

PaneSlotDto _$PaneSlotDtoFromJson(Map<String, dynamic> json) => PaneSlotDto(
  tabs:
      (json['tabs'] as List<dynamic>?)
          ?.map((e) => WorkspaceTabDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  activeIndex: (json['activeIndex'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PaneSlotDtoToJson(PaneSlotDto instance) =>
    <String, dynamic>{
      'tabs': instance.tabs.map((e) => e.toJson()).toList(),
      'activeIndex': instance.activeIndex,
    };

WorkspaceTabDto _$WorkspaceTabDtoFromJson(Map<String, dynamic> json) =>
    WorkspaceTabDto(
      kind: json['kind'] as String,
      id: json['id'] as String,
      currentPath: json['currentPath'] as String?,
      workingDirectory: json['workingDirectory'] as String?,
      displayName: json['displayName'] as String?,
      action: json['action'] == null
          ? null
          : LauncherAction.fromJson(json['action'] as Map<String, dynamic>),
      repoRoot: json['repoRoot'] as String?,
    );

Map<String, dynamic> _$WorkspaceTabDtoToJson(WorkspaceTabDto instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'id': instance.id,
      'currentPath': instance.currentPath,
      'workingDirectory': instance.workingDirectory,
      'displayName': instance.displayName,
      'action': instance.action?.toJson(),
      'repoRoot': instance.repoRoot,
    };
