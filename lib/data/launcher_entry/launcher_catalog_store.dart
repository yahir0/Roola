import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:roola/core/exceptions/app_exception.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/launcher_entry/launcher_entry_dto.dart';
import 'package:roola/data/launcher_entry/launcher_folder.dart';
import 'package:roola/data/launcher_entry/launcher_folder_dto.dart';

/// `<appSupport>/launcher_entries.json` を 1 ファイルで読み書きする store。
///
/// スキーマは `{"folders": [...], "entries": [...]}`（ADR-0019）。
/// 旧スキーマ（`entries` のみ）は `folders` キーを空配列扱いで lazy migrate
/// する。LauncherEntryRepositoryImpl / LauncherFolderRepositoryImpl は本 store
/// を介して読み書きすることで、片方の操作で他方のデータを失わない。
class LauncherCatalogStore {
  LauncherCatalogStore({required this.paths});

  final AppPaths paths;

  /// ファイル全体を読み込んで `(folders, entries)` を返す。ファイルが
  /// 存在しない / 壊れている場合は両方とも空のレコードを返す。
  Future<LauncherCatalogSnapshot> load() async {
    final file = paths.launcherEntriesFile;
    if (!file.existsSync()) {
      return const LauncherCatalogSnapshot(folders: [], entries: []);
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return const LauncherCatalogSnapshot(folders: [], entries: []);
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const LauncherCatalogSnapshot(folders: [], entries: []);
      }
      final folders = _parseFolders(decoded['folders']);
      final entries = _parseEntries(decoded['entries']);
      return LauncherCatalogSnapshot(folders: folders, entries: entries);
    } on FormatException {
      return const LauncherCatalogSnapshot(folders: [], entries: []);
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }

  /// 両配列を新スキーマで一括書き出し。
  /// ダウングレード非対応で、必ず `folders` / `entries` の 2 キー固定の
  /// 形で書き戻す。
  Future<void> save(LauncherCatalogSnapshot snapshot) async {
    await paths.ensureDirectories();
    final json = {
      'folders': snapshot.folders
          .map(LauncherFolderDto.fromEntity)
          .map((dto) => dto.toJson())
          .toList(),
      'entries': snapshot.entries
          .map(LauncherEntryDto.fromEntity)
          .map((dto) => dto.toJson())
          .toList(),
    };
    try {
      await paths.launcherEntriesFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
        flush: true,
      );
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }

  List<LauncherFolder> _parseFolders(dynamic raw) {
    if (raw is! List) {
      return const [];
    }
    final result = <LauncherFolder>[];
    for (final item in raw.whereType<Map<String, dynamic>>()) {
      try {
        result.add(LauncherFolderDto.fromJson(item).toEntity());
      } on Object catch (e) {
        developer.log(
          'launcher folder parse failed, skipping: $e',
          name: 'LauncherCatalogStore',
          error: e,
        );
      }
    }
    result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return result;
  }

  List<LauncherEntry> _parseEntries(dynamic raw) {
    if (raw is! List) {
      return const [];
    }
    final result = <LauncherEntry>[];
    for (final item in raw.whereType<Map<String, dynamic>>()) {
      try {
        result.add(LauncherEntryDto.fromJson(item).toEntity());
      } on Object catch (e) {
        developer.log(
          'launcher entry parse failed, skipping: $e',
          name: 'LauncherCatalogStore',
          error: e,
        );
      }
    }
    result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return result;
  }
}

/// `LauncherCatalogStore.load()` の戻り値。
class LauncherCatalogSnapshot {
  const LauncherCatalogSnapshot({
    required this.folders,
    required this.entries,
  });

  final List<LauncherFolder> folders;
  final List<LauncherEntry> entries;
}
