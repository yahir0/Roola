import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/privacy/privacy_settings.dart';
import 'package:roola/data/privacy/privacy_settings_repository_impl.dart';

void main() {
  late Directory tempDir;
  late PrivacySettingsRepositoryImpl repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_privacy_');
    repo = PrivacySettingsRepositoryImpl(paths: AppPaths(root: tempDir));
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('load returns defaults (未同意・アナリティクス ON) when file does not exist',
      () async {
    final settings = await repo.load();
    expect(settings.acceptedTermsVersion, isNull);
    expect(settings.analyticsEnabled, isTrue);
  });

  test('save then load round-trips acceptance and opt-out', () async {
    const settings = PrivacySettings(
      acceptedTermsVersion: 2,
      analyticsEnabled: false,
    );
    await repo.save(settings);
    final loaded = await repo.load();
    expect(loaded.acceptedTermsVersion, 2);
    expect(loaded.analyticsEnabled, isFalse);
  });

  test('load returns defaults for malformed JSON', () async {
    await AppPaths(root: tempDir).ensureDirectories();
    await File(
      '${tempDir.path}/privacy_settings.json',
    ).writeAsString('not json');
    final loaded = await repo.load();
    expect(loaded.acceptedTermsVersion, isNull);
    expect(loaded.analyticsEnabled, isTrue);
  });

  test('analyticsEnabled missing in file falls back to true', () async {
    // 将来フィールドを増やした際の後方互換と同じ経路。既存ファイルに無い
    // フィールドは既定値にフォールバックする。
    await AppPaths(root: tempDir).ensureDirectories();
    await File(
      '${tempDir.path}/privacy_settings.json',
    ).writeAsString('{"acceptedTermsVersion": 1}');
    final loaded = await repo.load();
    expect(loaded.acceptedTermsVersion, 1);
    expect(loaded.analyticsEnabled, isTrue);
  });
}
