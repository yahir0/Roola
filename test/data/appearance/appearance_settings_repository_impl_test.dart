import 'dart:io';

import 'package:claude_skills_launcher/core/storage/app_paths.dart';
import 'package:claude_skills_launcher/data/appearance/appearance_settings.dart';
import 'package:claude_skills_launcher/data/appearance/appearance_settings_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late AppearanceSettingsRepositoryImpl repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cskl_app_');
    repo = AppearanceSettingsRepositoryImpl(paths: AppPaths(root: tempDir));
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('load returns transparent default when file does not exist', () async {
    final settings = await repo.load();
    expect(settings.mode, AppearanceMode.transparent);
    expect(settings.solidColor, isNull);
    expect(settings.imagePath, isNull);
  });

  test('save then load round-trips solid color', () async {
    const settings = AppearanceSettings(
      mode: AppearanceMode.solid,
      solidColor: 0xFFABCDEF,
    );
    await repo.save(settings);
    final loaded = await repo.load();
    expect(loaded.mode, AppearanceMode.solid);
    expect(loaded.solidColor, 0xFFABCDEF);
  });

  test('load returns defaults for malformed JSON', () async {
    await AppPaths(root: tempDir).ensureDirectories();
    await File('${tempDir.path}/appearance.json').writeAsString('not json');
    final loaded = await repo.load();
    expect(loaded.mode, AppearanceMode.transparent);
  });
}
