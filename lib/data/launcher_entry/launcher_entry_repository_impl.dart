import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:claude_skills_launcher/core/exceptions/app_exception.dart';
import 'package:claude_skills_launcher/core/storage/app_paths.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry_dto.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
      final entries =
          entriesJson
              .whereType<Map<String, dynamic>>()
              .map(LauncherEntryDto.fromJson)
              .map((dto) => dto.toEntity())
              .toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
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

/// `AppPaths` を非同期初期化して提供する Provider。
final appPathsProvider = FutureProvider<AppPaths>((ref) => AppPaths.resolve());

/// `LauncherEntryRepository` の Riverpod Provider。
///
/// `AppPaths` が解決済み前提で生成するため、初期化フェーズで
/// `await ref.read(appPathsProvider.future)` を呼んでから使う。
final launcherEntryRepositoryProvider = Provider<LauncherEntryRepository>((
  ref,
) {
  final paths = ref
      .watch(appPathsProvider)
      .maybeWhen(
        data: (value) => value,
        orElse: () => throw StateError(
          'AppPaths is not initialized yet. '
          'Wait for appPathsProvider before reading this provider.',
        ),
      );
  return LauncherEntryRepositoryImpl(paths: paths);
});
