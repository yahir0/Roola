import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/repo_explorer/explorer_settings.dart';
import 'package:roola/data/repo_explorer/explorer_settings_repository_impl.dart';

void main() {
  late Directory tempDir;
  late ExplorerSettingsRepositoryImpl repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_explorer_');
    repo = ExplorerSettingsRepositoryImpl(paths: AppPaths(root: tempDir));
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('load returns defaults when file is missing', () async {
    final settings = await repo.load();
    expect(settings.rootPath, isNull);
    expect(settings.favorites, isEmpty);
  });

  test('save then load round-trips rootPath', () async {
    await repo.save(const ExplorerSettings(rootPath: '/Users/foo/repos'));
    final loaded = await repo.load();
    expect(loaded.rootPath, '/Users/foo/repos');
  });

  test('save then save again overrides the previous value', () async {
    await repo.save(const ExplorerSettings(rootPath: '/Users/foo'));
    await repo.save(const ExplorerSettings(rootPath: '/Users/bar'));
    final loaded = await repo.load();
    expect(loaded.rootPath, '/Users/bar');
  });

  test('load returns defaults for malformed JSON', () async {
    await tempDir.create(recursive: true);
    await File(
      '${tempDir.path}/repo_explorer_settings.json',
    ).writeAsString('{not valid');
    final settings = await repo.load();
    expect(settings.rootPath, isNull);
    expect(settings.favorites, isEmpty);
  });

  test('save then load round-trips favorites list', () async {
    await repo.save(
      const ExplorerSettings(
        rootPath: '/Users/foo',
        favorites: [
          ExplorerFavorite(id: 'a', path: '/Users/foo/repos', name: 'Repos'),
          ExplorerFavorite(id: 'b', path: '/Users/foo/Downloads', name: 'DL'),
        ],
      ),
    );
    final loaded = await repo.load();
    expect(loaded.favorites, hasLength(2));
    expect(loaded.favorites.map((f) => f.id).toList(), ['a', 'b']);
    expect(loaded.favorites.map((f) => f.name).toList(), ['Repos', 'DL']);
    expect(loaded.favorites.first.path, '/Users/foo/repos');
  });

  test(
    'legacy settings file without favorites loads with empty list',
    () async {
      // 旧バージョンが書いた favorites を持たない JSON も問題なく読める
      // ことを検証する（後方互換）。
      await tempDir.create(recursive: true);
      await File(
        '${tempDir.path}/repo_explorer_settings.json',
      ).writeAsString('{"rootPath": "/Users/foo"}');
      final loaded = await repo.load();
      expect(loaded.rootPath, '/Users/foo');
      expect(loaded.favorites, isEmpty);
    },
  );
}
