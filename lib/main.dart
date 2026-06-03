import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:roola/app/app.dart';
import 'package:roola/app/license_bootstrap.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:roola/data/locale/locale_settings_repository_impl.dart';
import 'package:roola/data/notepad/notepad_repository_impl.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // プレビューパネルの PDF 描画（pdfrx / ADR-0050）。engine API を使う前に
  // 1 度だけ呼ぶ必要がある。
  await pdfrxFlutterInitialize();
  await windowManager.ensureInitialized();
  // Windows Toast 通知（ADR-0057 / ADR-0058）。local_notifier は setup() で
  // AUMID を登録しないと notify() が silently fail する。
  if (Platform.isWindows) {
    await localNotifier.setup(
      appName: 'Roola',
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );
  }

  // ネイティブ依存（Sparkle / SwiftTerm）のライセンスを LicenseRegistry に
  // 追加する（ADR-0040）。`showLicensePage` までに登録されていればよいので
  // 同期的な await は不要（callback は遅延評価される）。
  await registerNativeLicenses();

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

  // ワークスペースは毎回既定 seed で開始する（ADR-0042）。旧バージョンで
  // 書き出された `workspace.json` が残っていればベストエフォートで削除し、
  // 次回以降に復元処理が混ざらないようにする。
  final legacyWorkspaceFile = paths.workspaceFile;
  if (legacyWorkspaceFile.existsSync()) {
    try {
      await legacyWorkspaceFile.delete();
    } on FileSystemException {
      // 削除できなくても致命ではない（次回も無視されるだけ）。握り潰す。
    }
  }

  // 表示言語も起動時に 1 度だけ読み込む。`MaterialApp` は初回フレームから
  // 確定したロケールで描画する必要があるため、Provider に注入する（ADR-0034）。
  final initialLocale = await LocaleSettingsRepositoryImpl(paths: paths).load();

  // ノートパッド本文も起動時に読み込み、初回オープン時に即表示できるよう
  // Provider に注入する（ADR-0036）。
  final initialNotepad = await NotepadRepositoryImpl(paths: paths).load();

  runApp(
    ProviderScope(
      overrides: [
        appPathsProvider.overrideWithValue(paths),
        localeSettingsInitialProvider.overrideWithValue(initialLocale),
        notepadInitialContentProvider.overrideWithValue(initialNotepad),
      ],
      child: const App(),
    ),
  );
}
