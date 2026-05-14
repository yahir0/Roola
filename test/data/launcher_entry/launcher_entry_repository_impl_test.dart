import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';

void main() {
  late Directory tempDir;
  late LauncherEntryRepositoryImpl repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_repo_');
    repo = LauncherEntryRepositoryImpl(paths: AppPaths(root: tempDir));
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  LauncherEntry buildEntry(String id) => LauncherEntry(
    id: id,
    displayName: 'Entry $id',
    workingDirectory: tempDir.path,
    action: const LauncherAction.claudeSkill(skillName: 'demo'),
    createdAt: DateTime.utc(2026, 5, 12).add(Duration(minutes: id.hashCode)),
  );

  test('loadAll returns empty when file does not exist', () async {
    expect(await repo.loadAll(), isEmpty);
  });

  test('add then loadAll persists entry', () async {
    final entry = buildEntry('a');
    await repo.add(entry);
    final loaded = await repo.loadAll();
    expect(loaded, hasLength(1));
    expect(loaded.first.displayName, 'Entry a');
  });

  test('update replaces existing entry by id', () async {
    final entry = buildEntry('a');
    await repo.add(entry);
    await repo.update(entry.copyWith(displayName: 'Renamed'));
    final loaded = await repo.loadAll();
    expect(loaded.first.displayName, 'Renamed');
  });

  test('update throws when id is not found', () async {
    expect(
      () => repo.update(buildEntry('missing')),
      throwsA(isA<StateError>()),
    );
  });

  test('delete removes entry by id', () async {
    final entry = buildEntry('a');
    await repo.add(entry);
    await repo.delete('a');
    expect(await repo.loadAll(), isEmpty);
  });

  test('add throws on duplicate id', () async {
    final entry = buildEntry('a');
    await repo.add(entry);
    expect(() => repo.add(entry), throwsA(isA<StateError>()));
  });

  test('loadAll returns empty list for malformed JSON', () async {
    await AppPaths(root: tempDir).ensureDirectories();
    await File(
      '${tempDir.path}/launcher_entries.json',
    ).writeAsString('not json');
    expect(await repo.loadAll(), isEmpty);
  });
}
