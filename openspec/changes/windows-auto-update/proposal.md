## Why

macOS は Sparkle による完全な自動アップデート（バックグラウンドチェック・ダウンロード・インストール）を持つが、Windows は GitHub Releases API を叩いてバージョンを比較するだけの最小実装にとどまっており、ダウンロードもインストールも行われない。Windows ユーザーに同等の体験を提供するため、WinSparkle を使った自動アップデート機構を実装する。

## What Changes

- **Windows インラインメニューバー**（`WindowsTopMenuBar`）を新設し、`AppBar.title` スロットに Flutter `MenuBar` でロゴ + ファイル / 編集 / 表示 / ターミナル / Git / ペインを実装する。ロゴボタンが「Roola」メニュー（About / アップデートを確認 / 設定）を兼ねる
- ワードマーク（`_AppWordmark`）を Windows では非表示にし、ロゴアイコンに置き換える
- **WinSparkle** を Windows ネイティブ層に追加し、macOS の `SPUStandardUpdaterController` に相当するバックグラウンド自動チェック・ダウンロード・インストールフローを実現する（Phase B）
- `roola_channels.cpp` に `roola/updater` MethodChannel を追加し、`UpdateCheckerWindows.checkForUpdates()` から手動チェックを呼べるようにする
- `UpdateCheckerWindows` を WinSparkle MethodChannel 経由の薄いラッパーに置き換える（GitHub API 直接呼び出し + Material ダイアログを削除）
- appcast XML を GitHub Releases に合わせた形式で提供し、WinSparkle が参照できるようにする
- `release-windows.yml` に appcast 生成・アップロードステップを追加する

## Capabilities

### New Capabilities

- `windows-winsparkle-updater`: WinSparkle を C++ runner に組み込み、バックグラウンド自動チェック・手動チェックトリガを提供する
- `windows-appcast`: Windows 向け appcast.xml を GitHub Releases に配置し、WinSparkle がバージョン比較・ダウンロード URL を取得できるようにする

### Modified Capabilities

（なし）

## Impact

- **`windows/runner/`**: WinSparkle DLL をリンク、`roola_channels.cpp` に updater channel 追加、`flutter_window.cpp` または `main.cpp` で WinSparkle 初期化
- **`lib/core/system/update_checker_windows.dart`**: MethodChannel 呼び出しに切り替え（GitHub API 直接呼び出しを削除）
- **`.github/workflows/release-windows.yml`**: appcast.xml 生成・GitHub Releases へのアップロードステップ追加
- **依存追加**: WinSparkle（`winsparkle.dll` + ヘッダ）を `windows/` 以下にベンダリング、または vcpkg / FetchContent で取得
- **appcast**: `https://github.com/yahiro0/Roola/releases/latest/download/appcast.xml` 相当の URL に署名済み XML を配置
