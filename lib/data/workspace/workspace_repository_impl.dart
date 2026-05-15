import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/exceptions/app_exception.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_layout_dto.dart';
import 'package:roola/data/workspace/workspace_repository.dart';

/// `<appSupport>/workspace.json` を保存先とする [WorkspaceRepository] 実装。
class WorkspaceRepositoryImpl implements WorkspaceRepository {
  WorkspaceRepositoryImpl({required this.paths});

  final AppPaths paths;

  @override
  Future<WorkspaceLayout?> load() async {
    final file = paths.workspaceFile;
    if (!file.existsSync()) {
      return null;
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return null;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final layout = WorkspaceLayoutDto.fromJson(decoded).toEntity();
      // 全スロットが空のレイアウトは無効とみなし、既定 seed に倒す。
      if (layout.nonEmptySlots.isEmpty) {
        return null;
      }
      return layout;
    } on FormatException {
      // JSON として壊れている。既定 seed に倒す。
      return null;
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }

  @override
  Future<void> save(WorkspaceLayout layout) async {
    await paths.ensureDirectories();
    try {
      await paths.workspaceFile.writeAsString(
        const JsonEncoder.withIndent(
          '  ',
        ).convert(WorkspaceLayoutDto.fromEntity(layout).toJson()),
        flush: true,
      );
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }
}

/// [WorkspaceRepository] の Provider。
final workspaceRepositoryProvider = Provider<WorkspaceRepository>((ref) {
  return WorkspaceRepositoryImpl(paths: ref.watch(appPathsProvider));
});
