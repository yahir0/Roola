import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// アプリの永続化用ディレクトリ・ファイルパス解決をまとめたヘルパー。
///
/// `path_provider.getApplicationSupportDirectory()` を起点に、本アプリで
/// 使うファイルパスを集約する。テストでは `AppPaths(root: tempDir)` で
/// 任意のディレクトリに切り替えられる。
class AppPaths {
  AppPaths({required this.root});

  /// 既定の `Application Support` ディレクトリを使う [AppPaths] を作る。
  static Future<AppPaths> resolve() async {
    final root = await getApplicationSupportDirectory();
    return AppPaths(root: root);
  }

  /// 全ファイルの起点となるルートディレクトリ。
  final Directory root;

  /// ランチャーエントリ一覧の永続化先。
  File get launcherEntriesFile => File('${root.path}/launcher_entries.json');

  /// 外観設定の永続化先。
  File get appearanceSettingsFile => File('${root.path}/appearance.json');

  /// エクスプローラ画面の状態（最後に開いていたルートパス等）の永続化先。
  File get repoExplorerSettingsFile =>
      File('${root.path}/repo_explorer_settings.json');

  /// アイコン画像保存ディレクトリ。
  Directory get iconsDir => Directory('${root.path}/icons');

  /// 背景画像の保存先。
  File get backgroundImageFile => File('${root.path}/background.png');

  /// 透過モード時の中央画像の保存先。
  File get transparentCenterImageFile =>
      File('${root.path}/transparent_center.png');

  /// ディレクトリが存在しない場合に作る（再帰的）。
  Future<void> ensureDirectories() async {
    if (!root.existsSync()) {
      await root.create(recursive: true);
    }
    if (!iconsDir.existsSync()) {
      await iconsDir.create(recursive: true);
    }
  }
}
