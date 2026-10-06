import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:roola_activity/activity_licenses.dart';
import 'package:roola_activity/data/activity_dashboard/activity_dashboard_settings_repository_impl.dart';
import 'package:roola_monitor/app/monitor_app.dart';

/// Roola Monitor のエントリポイント（ADR-0069）。
///
/// 計器盤は共通パッケージ roola_activity のものをそのまま使う。ここでは表示設定の
/// 保存先（自アプリの Application Support）を決め、計器書体のライセンスを登録
/// するだけ。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerActivityLicenses();

  final support = await getApplicationSupportDirectory();
  runApp(
    ProviderScope(
      overrides: [
        activityDashboardSettingsFileProvider.overrideWithValue(
          File('${support.path}/activity_dashboard.json'),
        ),
      ],
      child: const MonitorApp(),
    ),
  );
}
