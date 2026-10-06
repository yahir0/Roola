import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola_activity/data/activity_dashboard/activity_dashboard_settings.dart';
import 'package:roola_activity/data/activity_dashboard/activity_dashboard_settings_repository_impl.dart';

void main() {
  late Directory tempDir;
  late File file;
  late ActivityDashboardSettingsRepositoryImpl repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_activity_');
    // 親ディレクトリが無い状態から保存できることも併せて確かめる。
    file = File('${tempDir.path}/nested/activity_dashboard.json');
    repo = ActivityDashboardSettingsRepositoryImpl(file: file);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('未保存なら既定値（LEVEL・CLASSIC・全コア表示オフ）', () async {
    expect(await repo.load(), ActivityDashboardSettings.defaults());
  });

  test('保存して読み戻すと同じ設定になる', () async {
    const settings = ActivityDashboardSettings(
      mode: ActivityDisplayMode.tacho,
      tachoStyle: TachoStyle.race,
      showAllCores: true,
    );
    await repo.save(settings);

    expect(await repo.load(), settings);
  });

  test('未知の値・欠けたキーは既定値にフォールバックする', () async {
    await file.parent.create(recursive: true);
    await file.writeAsString('{"mode":"tacho","tachoStyle":"hologram"}');

    final loaded = await repo.load();

    expect(loaded.mode, ActivityDisplayMode.tacho);
    expect(loaded.tachoStyle, TachoStyle.classic);
    expect(loaded.showAllCores, isFalse);
  });

  test('壊れた JSON は既定値', () async {
    await file.parent.create(recursive: true);
    await file.writeAsString('{not json');

    expect(await repo.load(), ActivityDashboardSettings.defaults());
  });
}
