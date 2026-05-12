import 'dart:io';

import 'package:claude_skills_launcher/core/storage/app_paths.dart';
import 'package:claude_skills_launcher/data/repo_explorer/explorer_settings.dart';
import 'package:claude_skills_launcher/data/repo_explorer/explorer_settings_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late ExplorerSettingsRepositoryImpl repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cskl_explorer_');
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
  });
}
