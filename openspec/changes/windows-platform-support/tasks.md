## 1. ADR・ドキュメント追加

- [ ] 1.1 ADR-0058「Windows 対応（ADR-0001 Supersede）」を `docs/adr/0058-windows-platform-support.md` に追加する。macOS SwiftTerm は変更せず、Windows は OS ごとの並存方針（ADR-0031 §将来拡張経路 (a)）を採用した経緯を記載する
- [ ] 1.2 CLAUDE.md の ADR リストに ADR-0058 を追記する

## 2. Windows Bootstrap

- [ ] 2.1 `fvm flutter create --platforms=windows .` で `windows/` ディレクトリを生成する
- [ ] 2.2 `windows/runner/Runner.rc` のアプリ名・会社名を `Roola` / `tech.yahiro` に設定する
- [ ] 2.3 ブランドアイコンから ICO ファイルを生成し `windows/runner/resources/app_icon.ico` に配置する（256×256 以上のサイズを含む）
- [ ] 2.4 `windows/` を git に追加し `flutter build windows` がエラーなく通ることを確認する（ターミナルタブ以外の機能が起動する状態）
- [ ] 2.5 macOS ビルド（`flutter build macos`）が壊れていないことを確認する

## 3. クロスプラットフォーム ファイルパス・コマンド修正

- [ ] 3.1 `pubspec.yaml` に `package:path` が依存に含まれることを確認する（未追加なら追加）
- [ ] 3.2 `lib/core/system/explorer_file_ops.dart` の `copyInto` を `dart:io` 再帰コピー（`Directory.list(recursive: true)` + `File.copy`）に置き換え `cp -R` 呼び出しを削除する
- [ ] 3.3 `ExplorerFileOps._join` / `_parentOf` / `_basename` のパス区切りを `package:path` の `join` / `dirname` / `basename` に置き換える
- [ ] 3.4 `lib/data/fs_watcher/directory_watcher.dart` の `_relativize` で `/` を `Platform.pathSeparator` に差し替える
- [ ] 3.5 `ExplorerFileOps` のユニットテストに Windows 形式パス（`C:\foo\bar`）を使ったコピー・リネームのテストケースを追加する
- [ ] 3.6 `lib/app/app_menu_bar.dart` で macOS 専用 `PlatformProvidedMenuItem`（`servicesSubmenu`・`hide`・`hideOtherApplications`・`showAllApplications`）と Sparkle「アップデートを確認」を `if (Platform.isMacOS)` で条件分岐する。Windows では `UpdateChecker` Windows 実装を呼ぶ「アップデートを確認」項目に置き換える

## 4. プラットフォームサービス抽象化

- [ ] 4.1 `lib/core/system/trash_service.dart` を `abstract interface class TrashService` に変更し、既存実装を `trash_service_macos.dart` に移動する
- [ ] 4.2 `lib/core/system/trash_service_windows.dart` を作成し、method channel で Win32 `SHFileOperationW` を呼ぶ実装を書く
- [ ] 4.3 `windows/runner/` に `TrashService` の C++ MethodChannel ハンドラを実装する（`SHFileOperation` + `FOF_ALLOWUNDO`）
- [ ] 4.4 `lib/core/system/file_opener.dart` を `abstract interface class FileOpener` に変更し、macOS 実装を `file_opener_macos.dart`、Windows 実装（`explorer.exe` / `explorer /select,`）を `file_opener_windows.dart` に分ける
- [ ] 4.5 `lib/core/system/update_checker.dart` を `abstract interface class UpdateChecker` として定義し、macOS は `update_checker_macos.dart`（SparkleUpdater ラッパー）、Windows は `update_checker_windows.dart`（GitHub Releases API 参照）に実装する
- [ ] 4.6 `lib/data/activity_metrics/system_metrics_repository.dart` の具象クラスを interface に変え、既存実装を `system_metrics_repository_macos.dart` に移動する
- [ ] 4.7 `lib/data/activity_metrics/system_metrics_repository_windows.dart` を作成し、method channel で C++ ハンドラを呼ぶ実装を書く
- [ ] 4.8 `windows/runner/` に SystemMetrics の C++ ハンドラを実装する（`GlobalMemoryStatusEx` でメモリ、PDH で CPU 取得）
- [ ] 4.9 `lib/data/task_notification/` の通知実装を `abstract interface NotificationService` 経由に変更し、macOS 実装（`UNUserNotificationCenter`）と Windows 実装（`local_notifier`）に分ける
- [ ] 4.10 `pubspec.yaml` に `local_notifier` を追加する
- [ ] 4.11 `lib/core/platform_factory.dart` を作成し、各サービスの Provider factory を `Platform.isMacOS` / `Platform.isWindows` 分岐で 1 ファイルに集約する

## 5. Windows シェル選択

- [ ] 5.1 `lib/data/terminal_runner/windows_shell.dart` に `enum WindowsShell { cmd, powershell, pwsh }` を定義する
- [ ] 5.2 `lib/data/terminal_settings/terminal_settings.dart` を Freezed モデルとして新規作成する（`windowsShell` フィールドのみ、デフォルトは `WindowsShell.powershell`）
- [ ] 5.3 `terminal_settings_dto.dart` / `terminal_settings_repository.dart` / `terminal_settings_repository_impl.dart` を作成する
- [ ] 5.4 `lib/core/storage/app_paths.dart` に `terminalSettingsFile` を追加する
- [ ] 5.5 `PtyTerminalRunner._resolveExecutable` に Windows 分岐を追加する。`OpenHereAction` はシェル直接起動、`RunCommandAction` はシェル構文に応じた起動、`ClaudeSkillAction` は `SkillRunState.failed` でエラーを返す
- [ ] 5.6 `PtyTerminalRunner.fromAction` が Windows のとき `TerminalSettings` を参照してシェルを決定するよう変更する（`windowsShell` パラメータを追加するか provider 経由で注入する）
- [ ] 5.7 `lib/ui/settings/settings_page.dart` に「ターミナル」セクションを追加し、Windows のみ `WindowsShellSection` ウィジェットを表示する（`Platform.isWindows` 判定）
- [ ] 5.8 `WindowsShellSection` に pwsh.exe の存在チェック（`Process.run('pwsh', ['--version'])` で確認）を行い、未インストール時に警告を表示する実装を追加する

## 6. xterm.js ターミナルレンダラ（Windows 専用）

- [ ] 6.1 WebView パッケージを評価して採否を決定する（`webview_windows` の pub score・issue 数・最終更新日を確認。問題なければ `pubspec.yaml` に追加）
- [ ] 6.2 xterm.js（`xterm.js`・`xterm.css`・`xterm-addon-fit.js`）を `assets/js/xterm/` にベンダリングし `pubspec.yaml` の assets に追加する
- [ ] 6.3 xterm.js 初期化 HTML（SarasaTermJ `@font-face`・`term.onData`・ResizeObserver・fit addon）を `assets/js/xterm/terminal.html` として作成する
- [ ] 6.4 `lib/ui/explorer/terminal_surface_windows.dart` を新規作成する。WebView2 で `terminal.html` をロードし、`runner.output` → `runJavaScript('term.write(...)')` の配線と `onData` → `runner.write` の配線を実装する
- [ ] 6.5 `lib/ui/explorer/terminal_surface.dart` の `build` で `Platform.isWindows` を判定し、Windows は `TerminalSurfaceWindows`、それ以外は既存の `AppKitView`（SwiftTerm）を返すよう変更する
- [ ] 6.6 Windows 実機または VM で xterm.js ターミナルを検証する: (a) WebView2 が起動する、(b) プロンプト表示・テキスト入力・Ctrl+C が動く、(c) リサイズが PTY に伝わる、(d) 日本語文字が文字化けしない、(e) ANSI カラーが正しく表示される

## 7. Windows 全機能テスト・最終確認

- [ ] 7.1 Windows でエクスプローラタブが起動し、ファイル一覧表示・ダブルクリック展開・ディレクトリ移動が動作することを確認する
- [ ] 7.2 Windows でファイルのゴミ箱移動・コピー・移動・リネーム・新規作成が動作することを確認する
- [ ] 7.3 Windows でアクティビティモニタが CPU% とメモリを表示することを確認する
- [ ] 7.4 Windows で Git タブが起動しログ・ブランチ一覧が表示されることを確認する
- [ ] 7.5 Windows でノートパッドパネルが開き入力内容が永続化されることを確認する
- [ ] 7.6 Windows でランチャー管理画面からエントリを追加・編集・削除できることを確認する
- [ ] 7.7 Windows でアップデート確認ダイアログが表示されることを確認する（ネットワーク有無両方）
- [ ] 7.8 Windows でタスク完了通知（ADR-0057）が Toast で表示されることを確認する
- [ ] 7.9 macOS ビルドが壊れていないことを最終確認する（SwiftTerm ターミナルが従来通り動作する）
- [ ] 7.10 `flutter build windows` が CI（GitHub Actions `windows-latest`）で成功するワークフローを追加する
