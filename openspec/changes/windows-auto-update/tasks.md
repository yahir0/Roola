## 1. ADR 追加

- [x] 1.1 `docs/adr/0059-windows-winsparkle-auto-update.md` を追加し、WinSparkle 採用・appcast ホスティング・Phase A 署名省略の決定を記録する

## 2. Windows インラインメニューバー ✅

- [x] 2.1 `lib/ui/common/windows_top_menu_bar.dart` を新設する（Flutter `MenuBar` + ロゴ + Roola / ファイル / 編集 / 表示 / ターミナル / Git / ペインの各サブメニュー）
- [x] 2.2 `workspace_page.dart` の `title` を Windows では `WindowsTopMenuBar`、macOS では `_AppWordmark` に分岐する
- [x] 2.3 `UpdateCheckerWindows` を MethodChannel 薄ラッパーに変更する（GitHub API + Material ダイアログを削除）

## 3. MethodChannel `roola/updater` の追加 ✅（Phase A: no-op）

- [x] 3.1 `roola_channels.cpp` に `SetupUpdaterChannel` を追加し、`checkForUpdates` で `win_sparkle_check_update_with_ui()` を呼ぶハンドラを実装する（`ROOLA_WINSPARKLE` guard で Phase B まで no-op）
- [x] 3.2 `main.cpp` に WinSparkle init / cleanup コードを追加する（`ROOLA_WINSPARKLE` guard）

## 4. WinSparkle ライブラリのセットアップ ✅

- [x] 4.1 `windows/third_party/winsparkle/` ディレクトリを作成し、`.gitignore` でバイナリを除外する（CI がダウンロード、ローカル手順は `docs/release.md` 参照）
- [x] 4.2 `windows/runner/CMakeLists.txt` に WinSparkle インクルードパス・`WinSparkle.lib` リンク設定・`ROOLA_WINSPARKLE` 定義を追加する（`if(EXISTS ...)` で有無を自動判定）
- [x] 4.3 `windows/CMakeLists.txt` の install ルールに `WinSparkle.dll` を `${BUILD_BUNDLE_DIR}` へコピーするステップを追加する（`if(EXISTS ...)` guard）

## 5. CI — WinSparkle DLL ダウンロード ✅

- [x] 5.1 `.github/workflows/release-windows.yml` に WinSparkle ダウンロードステップを追加する（`build-windows.yml` は Phase A no-op のため変更不要）

## 6. CI — appcast.xml 生成・公開 ✅

- [x] 6.1 `release-windows.yml` に appcast 生成ステップを追加する（バージョン番号・インストーラ URL・pubDate・ファイルサイズを埋めた `appcast-windows.xml` を生成）
- [x] 6.2 生成した `appcast-windows.xml` を main ブランチに commit・push するステップを追加する（`RELEASE_TRIGGER_PAT` 使用、コミットメッセージ: `chore: update appcast-windows.xml [skip ci]`）

## 7. 初期 appcast ファイルの追加 ✅

- [x] 7.1 `appcast-windows.xml` の初期ファイルをリポジトリルートに追加する（v0.0.29）

## 8. ドキュメント更新 ✅

- [x] 8.1 `docs/release.md` の Windows セクションに WinSparkle DLL のローカル配置手順を追記する
