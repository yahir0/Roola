import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/launcher_entry/launcher_catalog_store.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:roola/data/launcher_entry/launcher_folder.dart';
import 'package:roola/data/launcher_entry/launcher_folder_repository_impl.dart';

void main() {
  late Directory tempDir;
  late LauncherCatalogStore store;
  late LauncherFolderRepositoryImpl folderRepo;
  late LauncherEntryRepositoryImpl entryRepo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_folder_repo_');
    store = LauncherCatalogStore(paths: AppPaths(root: tempDir));
    folderRepo = LauncherFolderRepositoryImpl(store: store);
    entryRepo = LauncherEntryRepositoryImpl(store: store);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  LauncherFolder buildFolder(String id, {String? name}) => LauncherFolder(
    id: id,
    name: name ?? 'Folder $id',
    createdAt: DateTime.utc(2026, 5, 14).add(Duration(minutes: id.hashCode)),
  );

  LauncherEntry buildEntry(String id, {String? folderId}) => LauncherEntry(
    id: id,
    displayName: 'Entry $id',
    workingDirectory: tempDir.path,
    action: const LauncherAction.openHere(),
    folderId: folderId,
    createdAt: DateTime.utc(2026, 5, 14).add(Duration(minutes: id.hashCode)),
  );

  test('loadAll returns empty when file does not exist', () async {
    expect(await folderRepo.loadAll(), isEmpty);
  });

  test('add then loadAll persists folder', () async {
    await folderRepo.add(buildFolder('f1', name: 'Dev'));

    final loaded = await folderRepo.loadAll();
    expect(loaded, hasLength(1));
    expect(loaded.first.id, 'f1');
    expect(loaded.first.name, 'Dev');
  });

  test('update replaces folder by id', () async {
    await folderRepo.add(buildFolder('f1', name: 'Dev'));
    await folderRepo.update(buildFolder('f1', name: 'Renamed'));

    final loaded = await folderRepo.loadAll();
    expect(loaded, hasLength(1));
    expect(loaded.first.name, 'Renamed');
  });

  test('update throws when folder id is missing', () async {
    expect(
      () => folderRepo.update(buildFolder('missing')),
      throwsA(isA<StateError>()),
    );
  });

  test('add throws on duplicate id', () async {
    await folderRepo.add(buildFolder('dup'));
    expect(
      () => folderRepo.add(buildFolder('dup')),
      throwsA(isA<StateError>()),
    );
  });

  test('delete removes folder and entries are preserved', () async {
    await folderRepo.add(buildFolder('f1'));
    await entryRepo.add(buildEntry('e1'));

    await folderRepo.delete('f1');

    expect(await folderRepo.loadAll(), isEmpty);
    expect(await entryRepo.loadAll(), hasLength(1));
  });

  test('delete clears folderId of contained entries (中身は root に戻る)', () async {
    await folderRepo.add(buildFolder('f1'));
    await entryRepo.add(buildEntry('e1', folderId: 'f1'));
    await entryRepo.add(buildEntry('e2', folderId: 'f1'));
    await entryRepo.add(buildEntry('e3'));

    await folderRepo.delete('f1');

    final entries = await entryRepo.loadAll();
    expect(entries, hasLength(3));
    expect(entries.every((e) => e.folderId == null), isTrue);
  });

  test(
    'entry repository が folders を上書きで失わない (cross-repo preservation)',
    () async {
      await folderRepo.add(buildFolder('keep-me'));
      await entryRepo.add(buildEntry('e1'));
      await entryRepo.add(buildEntry('e2'));
      await entryRepo.delete('e1');

      // entry の操作後も folders は残っている。
      expect(await folderRepo.loadAll(), hasLength(1));
      expect((await folderRepo.loadAll()).first.id, 'keep-me');
    },
  );
}
