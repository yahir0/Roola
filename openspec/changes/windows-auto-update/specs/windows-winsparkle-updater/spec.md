## ADDED Requirements

### Requirement: WinSparkle バックグラウンド自動チェック
アプリ起動時に WinSparkle がバックグラウンドで appcast を確認し、新しいバージョンがあれば WinSparkle 標準 UI でユーザーに通知する。

#### Scenario: 起動時バックグラウンドチェック（新バージョンあり）
- **WHEN** アプリが起動する（`win_sparkle_init()` が呼ばれる）
- **THEN** WinSparkle が appcast URL をバックグラウンドポーリングし、新バージョン検出時に独自ウィンドウでアップデートを案内する

#### Scenario: 起動時バックグラウンドチェック（最新版）
- **WHEN** アプリが起動し WinSparkle がチェックを完了する
- **THEN** 最新バージョンの場合は何も表示しない（ユーザーの邪魔をしない）

#### Scenario: appcast URL 未設定（Debug ビルド等）
- **WHEN** `WINSPARKLE_APPCAST_URL` マクロが空文字列の状態でアプリが起動する
- **THEN** WinSparkle の自動チェックは開始されず、アプリは正常に起動する

### Requirement: 手動アップデートチェック MethodChannel
Dart 側から `roola/updater` MethodChannel 経由で `checkForUpdates` を呼ぶと、WinSparkle の手動チェック UI が起動する。

#### Scenario: 手動チェック呼び出し
- **WHEN** Dart コードが `UpdateCheckerWindows.checkForUpdates()` を呼ぶ
- **THEN** MethodChannel `roola/updater` の `checkForUpdates` ハンドラが `win_sparkle_check_update_with_ui()` を呼び出し、WinSparkle UI が表示される

#### Scenario: アプリ終了時クリーンアップ
- **WHEN** アプリが終了する
- **THEN** `win_sparkle_cleanup()` が呼ばれ WinSparkle のバックグラウンドスレッドが正常終了する

### Requirement: UpdateCheckerWindows の MethodChannel 移行
`UpdateCheckerWindows` は MethodChannel 呼び出しのみを行う薄いラッパーとなり、GitHub API 呼び出し・PackageInfo 取得・Material ダイアログは持たない。

#### Scenario: UpdateCheckerWindows.checkForUpdates 呼び出し
- **WHEN** `UpdateCheckerWindows.checkForUpdates()` が呼ばれる
- **THEN** `MethodChannel('roola/updater').invokeMethod('checkForUpdates')` のみを呼び出し、結果を待たずに返る

#### Scenario: Material ダイアログの排除
- **WHEN** アップデートチェック結果が返る
- **THEN** Dart 層は一切のダイアログを表示しない（UI は WinSparkle が担う）

### Requirement: WinSparkle DLL バンドル
リリースビルドに `WinSparkle.dll` が同梱され、インストール先に配置される。

#### Scenario: インストーラ経由のインストール
- **WHEN** Inno Setup インストーラを実行する
- **THEN** `WinSparkle.dll` が `{app}` ディレクトリにコピーされ、アプリが起動可能になる

#### Scenario: フラッターリリースビルド
- **WHEN** `flutter build windows --release` を実行する
- **THEN** `build/windows/x64/runner/Release/` に `WinSparkle.dll` がコピーされている
