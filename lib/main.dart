import 'package:claude_skills_launcher/app/app.dart';
import 'package:claude_skills_launcher/core/storage/app_paths.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1024, 720),
    minimumSize: Size(640, 480),
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Claude Skills Launcher',
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setBackgroundColor(Colors.transparent);
    await windowManager.show();
    await windowManager.focus();
  });

  // `appPathsProvider` を解決済みの値で上書きするため、ここで先に
  // path_provider のサポートディレクトリを取得する。これにより data 層の
  // Provider 群（リポジトリ）が同期的に初期化でき、loading 起因の error
  // 伝播を回避できる。
  final paths = await AppPaths.resolve();
  await paths.ensureDirectories();

  runApp(
    ProviderScope(
      overrides: [appPathsProvider.overrideWithValue(paths)],
      child: const App(),
    ),
  );
}
