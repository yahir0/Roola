import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/exceptions/app_exception.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/launcher_entry/launcher_entry_dto.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository.dart';

/// `<appSupport>/launcher_entries.json` を保存先とする実装。
///
/// JSON のスキーマは `{"entries": [LauncherEntryDto, ...]}` の単純形式。
/// 書き込みは「上書き保存」で、配列差分更新は行わない（件数が少ない前提）。
class LauncherEntryRepositoryImpl implements LauncherEntryRepository {
  LauncherEntryRepositoryImpl({required this.paths});

  final AppPaths paths;

  @override
  Future<List<LauncherEntry>> loadAll() async {
    final file = paths.launcherEntriesFile;
    if (!file.existsSync()) {
      return const [];
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return const [];
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        // 破損ファイル: 空として扱う（起動を妨げない）
        return const [];
      }
      final entriesJson = decoded['entries'];
      if (entriesJson is! List) {
        return const [];
      }
      // 個別エントリの parse 失敗はそのエントリだけ読み飛ばす。
      // 不正な action.type 値（spec: launcher-config / 動作タイプの相互排他性）
      // や旧スキーマの欠落フィールドで 1 件壊れても、残り全件は復元できる。
      final entries = <LauncherEntry>[];
      for (final raw in entriesJson.whereType<Map<String, dynamic>>()) {
        try {
          entries.add(LauncherEntryDto.fromJson(raw).toEntity());
        } on Object catch (e) {
          developer.log(
            'launcher entry parse failed, skipping: $e',
            name: 'LauncherEntryRepository',
            error: e,
          );
        }
      }
      entries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return entries;
    } on FormatException {
      // JSON として不正: 空として扱う
      return const [];
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }

  @override
  Future<void> add(LauncherEntry entry) async {
    final entries = await loadAll();
    if (entries.any((e) => e.id == entry.id)) {
      throw StateError('LauncherEntry already exists: ${entry.id}');
    }
    await _saveAll([...entries, entry]);
  }

  @override
  Future<void> update(LauncherEntry entry) async {
    final entries = await loadAll();
    final index = entries.indexWhere((e) => e.id == entry.id);
    if (index < 0) {
      throw StateError('LauncherEntry not found: ${entry.id}');
    }
    final updated = [...entries]..[index] = entry;
    await _saveAll(updated);
  }

  @override
  Future<void> delete(String id) async {
    final entries = await loadAll();
    final filtered = entries.where((e) => e.id != id).toList();
    if (filtered.length == entries.length) {
      return;
    }
    await _saveAll(filtered);
  }

  Future<void> _saveAll(List<LauncherEntry> entries) async {
    await paths.ensureDirectories();
    final json = {
      'entries': entries
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
}

/// `AppPaths` を提供する Provider。
///
/// アプリ起動時に `main()` で `AppPaths.resolve()` を await し、
/// `appPathsProvider.overrideWithValue(paths)` で注入する。
/// デフォルトは未初期化エラーで、テスト・本番の双方で必ず override する。
final appPathsProvider = Provider<AppPaths>(
  (ref) => throw UnimplementedError(
    'appPathsProvider must be overridden in main() with a resolved AppPaths.',
  ),
);

/// `LauncherEntryRepository` の Riverpod Provider。
final launcherEntryRepositoryProvider = Provider<LauncherEntryRepository>((
  ref,
) {
  return LauncherEntryRepositoryImpl(paths: ref.watch(appPathsProvider));
});
