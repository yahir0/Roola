import 'package:json_annotation/json_annotation.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/skill_session/adhoc_run_args.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:uuid/uuid.dart';

part 'workspace_layout_dto.g.dart';

const _uuid = Uuid();

/// `WorkspaceLayout` の JSON 永続化 DTO（ADR-0028）。
///
/// ターミナルタブの `AdhocRunArgs.adhocId` は永続化しない。PTY はプロセス
/// 跨ぎで復元できないため、復元時は新しい `adhocId` で再 spawn する。
@JsonSerializable(explicitToJson: true)
class WorkspaceLayoutDto {
  WorkspaceLayoutDto({
    required this.topLeft,
    required this.topRight,
    required this.bottom,
    this.topRatio = 0.62,
    this.leftRatio = 0.5,
  });

  factory WorkspaceLayoutDto.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceLayoutDtoFromJson(json);

  factory WorkspaceLayoutDto.fromEntity(WorkspaceLayout entity) =>
      WorkspaceLayoutDto(
        topLeft: PaneSlotDto.fromEntity(entity.topLeft),
        topRight: PaneSlotDto.fromEntity(entity.topRight),
        bottom: PaneSlotDto.fromEntity(entity.bottom),
        topRatio: entity.topRatio,
        leftRatio: entity.leftRatio,
      );

  final PaneSlotDto topLeft;
  final PaneSlotDto topRight;
  final PaneSlotDto bottom;
  final double topRatio;
  final double leftRatio;

  Map<String, dynamic> toJson() => _$WorkspaceLayoutDtoToJson(this);

  WorkspaceLayout toEntity() => WorkspaceLayout(
    topLeft: topLeft.toEntity(),
    topRight: topRight.toEntity(),
    bottom: bottom.toEntity(),
    topRatio: topRatio,
    leftRatio: leftRatio,
  );
}

/// `PaneSlot` の JSON 永続化 DTO。
@JsonSerializable(explicitToJson: true)
class PaneSlotDto {
  PaneSlotDto({this.tabs = const [], this.activeIndex = 0});

  factory PaneSlotDto.fromJson(Map<String, dynamic> json) =>
      _$PaneSlotDtoFromJson(json);

  factory PaneSlotDto.fromEntity(PaneSlot entity) => PaneSlotDto(
    tabs: entity.tabs.map(WorkspaceTabDto.fromEntity).toList(growable: false),
    activeIndex: entity.activeIndex,
  );

  final List<WorkspaceTabDto> tabs;
  final int activeIndex;

  Map<String, dynamic> toJson() => _$PaneSlotDtoToJson(this);

  PaneSlot toEntity() => PaneSlot(
    tabs: tabs.map((t) => t.toEntity()).toList(growable: false),
    activeIndex: activeIndex,
  );
}

/// `WorkspaceTab` の JSON 永続化 DTO。
///
/// `kind` で種別を判別する。`explorer` は `currentPath`、`terminal` は
/// `workingDirectory` / `displayName` / `action` を持つ。
@JsonSerializable(explicitToJson: true)
class WorkspaceTabDto {
  WorkspaceTabDto({
    required this.kind,
    required this.id,
    this.currentPath,
    this.workingDirectory,
    this.displayName,
    this.action,
  });

  factory WorkspaceTabDto.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceTabDtoFromJson(json);

  factory WorkspaceTabDto.fromEntity(WorkspaceTab entity) => switch (entity) {
    ExplorerTab(:final id, :final currentPath) => WorkspaceTabDto(
      kind: 'explorer',
      id: id,
      currentPath: currentPath,
    ),
    TerminalTab(:final id, :final args) => WorkspaceTabDto(
      kind: 'terminal',
      id: id,
      workingDirectory: args.workingDirectory,
      displayName: args.displayName,
      action: args.action,
    ),
  };

  final String kind;
  final String id;
  final String? currentPath;
  final String? workingDirectory;
  final String? displayName;
  final LauncherAction? action;

  Map<String, dynamic> toJson() => _$WorkspaceTabDtoToJson(this);

  WorkspaceTab toEntity() {
    if (kind == 'terminal') {
      return WorkspaceTab.terminal(
        id: id,
        // adhocId は永続化しない。再 spawn のたびに新規払い出し（ADR-0028）。
        args: AdhocRunArgs(
          adhocId: 'adhoc-${_uuid.v4()}',
          workingDirectory: workingDirectory ?? '/',
          displayName: displayName ?? 'ターミナル',
          action: action ?? const LauncherAction.openHere(),
        ),
      );
    }
    return WorkspaceTab.explorer(id: id, currentPath: currentPath ?? '/');
  }
}
