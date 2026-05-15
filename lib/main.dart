import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/app.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:roola/data/workspace/workspace_repository_impl.dart';
import 'package:roola/ui/workspace/workspace_seed.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1024, 720),
    minimumSize: Size(640, 480),
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Roola',
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setBackgroundColor(Colors.transparent);
    await windowManager.show();
    await windowManager.focus();
  });

  // セッションが残っている状態での誤終了を防ぐため、close 操作を抑止して
  // `WindowCloseGuard` で確認ダイアログ → `windowManager.destroy()` に
  // 取り回す。詳細は `lib/app/window_close_guard.dart` を参照。
  await windowManager.setPreventClose(true);

  // `appPathsProvider` を解決済みの値で上書きするため、ここで先に
  // path_provider のサポートディレクトリを取得する。これにより data 層の
  // Provider 群（リポジトリ）が同期的に初期化でき、loading 起因の error
  // 伝播を回避できる。
  final paths = await AppPaths.resolve();
  await paths.ensureDirectories();

  // ワークスペースレイアウトを起動時に 1 度だけ読み込み、`workspaceProvider`
  // の初期値として注入する。永続データが無い / 壊れている / 全スロット空の
  // 場合は `load()` が null を返すので、既定 3 ペインを seed する（ADR-0028）。
  final loadedWorkspace = await WorkspaceRepositoryImpl(paths: paths).load();
  final initialWorkspace = loadedWorkspace ?? seedDefaultWorkspace();

  runApp(
    ProviderScope(
      overrides: [
        appPathsProvider.overrideWithValue(paths),
        workspaceInitialLayoutProvider.overrideWithValue(initialWorkspace),
      ],
      child: const App(),
    ),
  );
}
