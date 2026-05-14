import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/launcher_entry/launcher_catalog_store.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository.dart';

/// `<appSupport>/launcher_entries.json` を保存先とする実装。
///
/// JSON のスキーマは `{"folders": [...], "entries": [...]}`（ADR-0019）。
/// 旧スキーマ（`entries` のみ）も lazy migration で読み込める。書き込みは
/// 必ず `LauncherCatalogStore` 経由で全体を上書きするため、`folders` 配列は
/// 自動で温存される（フォルダ用 repository と相互干渉しない）。
class LauncherEntryRepositoryImpl implements LauncherEntryRepository {
  LauncherEntryRepositoryImpl({required this.store});

  final LauncherCatalogStore store;

  @override
  Future<List<LauncherEntry>> loadAll() async {
    final snapshot = await store.load();
    return snapshot.entries;
  }

  @override
  Future<void> add(LauncherEntry entry) async {
    final snapshot = await store.load();
    if (snapshot.entries.any((e) => e.id == entry.id)) {
      throw StateError('LauncherEntry already exists: ${entry.id}');
    }
    await store.save(
      LauncherCatalogSnapshot(
        folders: snapshot.folders,
        entries: [...snapshot.entries, entry],
      ),
    );
  }

  @override
  Future<void> update(LauncherEntry entry) async {
    final snapshot = await store.load();
    final index = snapshot.entries.indexWhere((e) => e.id == entry.id);
    if (index < 0) {
      throw StateError('LauncherEntry not found: ${entry.id}');
    }
    final updated = [...snapshot.entries]..[index] = entry;
    await store.save(
      LauncherCatalogSnapshot(folders: snapshot.folders, entries: updated),
    );
  }

  @override
  Future<void> delete(String id) async {
    final snapshot = await store.load();
    final filtered = snapshot.entries.where((e) => e.id != id).toList();
    if (filtered.length == snapshot.entries.length) {
      return;
    }
    await store.save(
      LauncherCatalogSnapshot(folders: snapshot.folders, entries: filtered),
    );
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

/// `launcher_entries.json` 全体を扱う store の Provider。
final launcherCatalogStoreProvider = Provider<LauncherCatalogStore>((ref) {
  return LauncherCatalogStore(paths: ref.watch(appPathsProvider));
});

/// `LauncherEntryRepository` の Riverpod Provider。
final launcherEntryRepositoryProvider = Provider<LauncherEntryRepository>((
  ref,
) {
  return LauncherEntryRepositoryImpl(
    store: ref.watch(launcherCatalogStoreProvider),
  );
});
