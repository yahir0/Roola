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

  /// ワークスペースレイアウト（3 ペイン構成・タブ・スプリッタ比率）の
  /// 永続化先（ADR-0028）。
  File get workspaceFile => File('${root.path}/workspace.json');

  /// キーボードショートカットのユーザー上書きの永続化先（ADR-0033）。
  File get keybindingsFile => File('${root.path}/keybindings.json');

  /// 表示言語設定の永続化先（ADR-0034）。
  File get localeSettingsFile => File('${root.path}/locale_settings.json');

  /// ノートパッドの本文の永続化先（ADR-0036）。
  File get notepadFile => File('${root.path}/notepad.json');

  /// 背景画像の保存先。
  File get backgroundImageFile => File('${root.path}/background.png');

  /// Claude Code タスク完了通知の設定（ON/OFF）の永続化先（ADR-0057）。
  File get taskNotificationSettingsFile =>
      File('${root.path}/task_notification_settings.json');

  /// ディレクトリが存在しない場合に作る（再帰的）。
  Future<void> ensureDirectories() async {
    if (!root.existsSync()) {
      await root.create(recursive: true);
    }
  }
}
