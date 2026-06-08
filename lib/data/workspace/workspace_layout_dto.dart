import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/skill_session/adhoc_run_args.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/workspace/workspace_seed.dart';
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
    // `toEntity` が null を返すタブ（復元不能な GitTab 等）は除外する。
    tabs: tabs
        .map((t) => t.toEntity())
        .whereType<WorkspaceTab>()
        .toList(growable: false),
    activeIndex: activeIndex,
  );
}

/// `WorkspaceTab` の JSON 永続化 DTO。
///
/// `kind` で種別を判別する。`explorer` は `currentPath`、`terminal` は
/// `workingDirectory` / `displayName` / `action`、`git` は `repoRoot` を
/// 持つ（ADR-0030）。未知の `kind` は `toEntity` でエクスプローラタブに
/// フォールバックし、旧スキーマとの後方互換を保つ。
@JsonSerializable(explicitToJson: true)
class WorkspaceTabDto {
  WorkspaceTabDto({
    required this.kind,
    required this.id,
    this.currentPath,
    this.workingDirectory,
    this.displayName,
    this.action,
    this.repoRoot,
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
    GitTab(:final id, :final repoRoot) => WorkspaceTabDto(
      kind: 'git',
      id: id,
      repoRoot: repoRoot,
    ),
    // ノートパッドタブは永続化対象外（ADR-0042 に従い workspace は毎回 seed）。
    // switch を exhaustive にするためエントリを作るが、toEntity で除外される。
    NotepadTab(:final id, :final noteId) => WorkspaceTabDto(
      kind: 'notepad',
      id: id,
      currentPath: noteId,
    ),
  };

  final String kind;
  final String id;
  final String? currentPath;
  final String? workingDirectory;
  final String? displayName;
  final LauncherAction? action;
  final String? repoRoot;

  Map<String, dynamic> toJson() => _$WorkspaceTabDtoToJson(this);

  /// DTO をドメインモデルへ変換する。
  ///
  /// 復元できない `git` タブ（`repoRoot` が無い / 現存しない / Git 管理下で
  /// なくなっている）は `null` を返し、呼び出し側で除外される（ADR-0030）。
  WorkspaceTab? toEntity() {
    if (kind == 'terminal') {
      return WorkspaceTab.terminal(
        id: id,
        // adhocId は永続化しない。再 spawn のたびに新規払い出し（ADR-0028）。
        args: AdhocRunArgs(
          adhocId: 'adhoc-${_uuid.v4()}',
          workingDirectory: workingDirectory ?? defaultWorkspaceHome(),
          displayName: displayName ?? 'ターミナル',
          action: action ?? const LauncherAction.openHere(),
        ),
      );
    }
    if (kind == 'git') {
      final root = repoRoot;
      if (root == null || !_isGitRepository(root)) {
        return null;
      }
      return WorkspaceTab.git(id: id, repoRoot: root);
    }
    if (kind == 'notepad') {
      // ワークスペース永続化は ADR-0042 で廃止済み。このパスは旧 json からの
      // 読み込みのみ。復元は行わず null を返して除外する。
      return null;
    }
    return WorkspaceTab.explorer(id: id, currentPath: currentPath ?? '/');
  }

  /// [root] が現存し、Git リポジトリ（`.git` を持つ）かを同期判定する。
  static bool _isGitRepository(String root) {
    if (!Directory(root).existsSync()) {
      return false;
    }
    final dotGit = '$root/.git';
    // `.git` は通常ディレクトリ。worktree / submodule ではファイル。
    return Directory(dotGit).existsSync() || File(dotGit).existsSync();
  }
}
