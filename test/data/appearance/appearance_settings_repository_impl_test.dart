import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/appearance/appearance_settings.dart';
import 'package:roola/data/appearance/appearance_settings_repository_impl.dart';

void main() {
  late Directory tempDir;
  late AppearanceSettingsRepositoryImpl repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_app_');
    repo = AppearanceSettingsRepositoryImpl(paths: AppPaths(root: tempDir));
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('load returns opaque default when file does not exist', () async {
    final settings = await repo.load();
    expect(settings.mode, AppearanceMode.opaque);
  });

  test('save then load round-trips transparent settings', () async {
    const settings = AppearanceSettings(
      mode: AppearanceMode.transparent,
      transparencyOpacity: 0.5,
    );
    await repo.save(settings);
    final loaded = await repo.load();
    expect(loaded.mode, AppearanceMode.transparent);
    expect(loaded.transparencyOpacity, 0.5);
  });

  test('load returns defaults for malformed JSON', () async {
    await AppPaths(root: tempDir).ensureDirectories();
    await File('${tempDir.path}/appearance.json').writeAsString('not json');
    final loaded = await repo.load();
    expect(loaded.mode, AppearanceMode.opaque);
  });

  test('legacy solid mode falls back to opaque', () async {
    // 旧バージョンの solid / image / gradient は廃止済み。未知のモード名は
    // 不透明（opaque）にフォールバックする（ADR-0038）。
    await AppPaths(root: tempDir).ensureDirectories();
    await File(
      '${tempDir.path}/appearance.json',
    ).writeAsString('{"mode":"solid","solidColor":4290000000}');
    final loaded = await repo.load();
    expect(loaded.mode, AppearanceMode.opaque);
  });
}
