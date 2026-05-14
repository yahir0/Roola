import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/launcher_entry/launcher_catalog_store.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:roola/data/launcher_entry/launcher_folder.dart';
import 'package:roola/data/launcher_entry/launcher_folder_repository.dart';

/// `<appSupport>/launcher_entries.json` の `folders` 配列を扱う実装。
///
/// 書き込みは必ず `LauncherCatalogStore` 経由で全体を上書きするので、
/// `entries` 配列は自動で温存される。フォルダ削除時には中身のエントリの
/// `folderId` を null に戻す副作用がある（ADR-0019）。
class LauncherFolderRepositoryImpl implements LauncherFolderRepository {
  LauncherFolderRepositoryImpl({required this.store});

  final LauncherCatalogStore store;

  @override
  Future<List<LauncherFolder>> loadAll() async {
    final snapshot = await store.load();
    return snapshot.folders;
  }

  @override
  Future<void> add(LauncherFolder folder) async {
    final snapshot = await store.load();
    if (snapshot.folders.any((f) => f.id == folder.id)) {
      throw StateError('LauncherFolder already exists: ${folder.id}');
    }
    await store.save(
      LauncherCatalogSnapshot(
        folders: [...snapshot.folders, folder],
        entries: snapshot.entries,
      ),
    );
  }

  @override
  Future<void> update(LauncherFolder folder) async {
    final snapshot = await store.load();
    final index = snapshot.folders.indexWhere((f) => f.id == folder.id);
    if (index < 0) {
      throw StateError('LauncherFolder not found: ${folder.id}');
    }
    final updated = [...snapshot.folders]..[index] = folder;
    await store.save(
      LauncherCatalogSnapshot(folders: updated, entries: snapshot.entries),
    );
  }

  @override
  Future<void> delete(String id) async {
    final snapshot = await store.load();
    final filtered = snapshot.folders.where((f) => f.id != id).toList();
    if (filtered.length == snapshot.folders.length) {
      return;
    }
    // 中身のエントリは root に出す（folderId を null に戻す）。
    final entries = [
      for (final e in snapshot.entries)
        if (e.folderId == id) e.copyWith(folderId: null) else e,
    ];
    await store.save(
      LauncherCatalogSnapshot(folders: filtered, entries: entries),
    );
  }
}

/// `LauncherFolderRepository` の Riverpod Provider。
final launcherFolderRepositoryProvider = Provider<LauncherFolderRepository>((
  ref,
) {
  return LauncherFolderRepositoryImpl(
    store: ref.watch(launcherCatalogStoreProvider),
  );
});
