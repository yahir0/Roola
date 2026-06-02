## Context

macOS は Sparkle 2 による完全な自動アップデートを `AppDelegate` + MethodChannel で実現している。Windows 側は `UpdateCheckerWindows` が GitHub Releases API でバージョン比較するだけの最小実装で、ダウンロード・インストール・バックグラウンドチェックはいずれも行われない。

現状の Windows runner は C++ (Win32)。ネイティブチャンネルは `roola_channels.cpp` で一元管理しており、新規チャンネルの追加パターンが確立されている（`roola/trash`、`roola/system/metrics`）。

## Goals / Non-Goals

**Goals:**
- WinSparkle をネイティブ層に組み込み、バックグラウンド自動チェックを実現する
- メニューの「アップデートを確認…」から手動チェックを呼べるようにする（macOS と同等）
- appcast.xml を CI で生成して GitHub に公開し、WinSparkle が参照できるようにする
- `UpdateCheckerWindows` を MethodChannel 呼び出しに整理し、Material ダイアログ依存を除去する

**Non-Goals:**
- コード署名（別 change で対応予定。SmartScreen 警告は現状維持）
- macOS 側の変更（ADR-0043 実装は完成済み）
- appcast の EdDSA 署名（Phase A では省略。Phase B で追加予定）
- Windows Store / MSIX 配布

## Decisions

### 1. WinSparkle を選択する（Velopack / カスタム実装を採らない）

**WinSparkle:**
- Sparkle と同じ appcast XML 形式。macOS と対称な設計になる
- C API（`win_sparkle_init` / `win_sparkle_check_update_with_ui` 等）で Win32 C++ から直接呼べる
- DLL 配布。Inno Setup の `recursesubdirs` で自動同梱される

**Velopack:**
- より近代的で Flutter SDK もあるが、専用 CLI でインストーラをラップする手順が必要
- 既存の Inno Setup 構成を大幅に変更する必要がある

**カスタム実装（現行）:**
- ダウンロード・インストール誘導・バックグラウンドチェックを自前で実装する必要がある
- 既に GitHub API 呼び出し + Material ダイアログの実装があるが、不完全

**決定:** WinSparkle を採用。

### 2. WinSparkle DLL のベンダリング方法

WinSparkle は GitHub Releases に `WinSparkle-x.y.z.zip` を配布している（ヘッダ + import lib + DLL）。

**オプション A: `windows/third_party/winsparkle/` に静的ベンダリング**
- import lib とヘッダをリポジトリに含める（DLL は含めず、CI でダウンロード）
- CI の `build-windows.yml` / `release-windows.yml` にダウンロードステップを追加

**オプション B: CMake FetchContent / vcpkg**
- 環境依存を減らせるが、vcpkg は Flutter の flutter build windows フローと統合しにくい

**決定:** オプション A。import lib とヘッダはリポジトリに置き、DLL は CI でダウンロードする方式。ローカルビルド時も同様に手動で配置する手順をドキュメント化する。

### 3. appcast.xml のホスティング

WinSparkle は起動時に appcast URL を定期ポーリングする。URL が変わるとすべての既存インストールが更新を受け取れなくなるため、**永続的な URL** が必要。

**オプション A: `https://raw.githubusercontent.com/yahiro0/Roola/main/appcast-windows.xml`**
- CI がリリースごとにファイルを更新して main にコミット
- URL が固定でシンプル
- GitHub の raw URL は CDN キャッシュがあるが通常 5 分以内に反映

**オプション B: GitHub Pages**
- 別途 Pages 設定が必要

**オプション C: GitHub Releases の特定ファイル**
- `latest/download/` は存在しない（latest は release を指すが individual file は最新リリースにしか紐付かない）

**決定:** オプション A。CI がリリース後に `appcast-windows.xml` を更新して main に push する。

### 4. appcast の署名（Phase A では省略）

WinSparkle は EdDSA 署名を強制しない（`win_sparkle_set_dsa_pub_pem` / `win_sparkle_set_eddsa_pub_key` は任意）。Phase A では署名なしで動作させ、コード署名対応の change と合わせて Phase B で署名を追加する。

### 5. Dart 側の責務

`UpdateCheckerWindows` は MethodChannel の薄いラッパーに変更する（macOS の `UpdateCheckerMacos` と同パターン）。現行の Dio 呼び出し・PackageInfo 取得・Material AlertDialog はすべて削除する。UI は WinSparkle が描画する。

### 6. ADR 追加

本 change の判断を ADR-0059 として記録する。

## Risks / Trade-offs

- **WinSparkle の UI が Polaris と一致しない** → WinSparkle は独自ウィンドウを使う。Sparkle（macOS）と同様「ネイティブ UI に任せる」と割り切る（ADR-0043 と同じ方針）。
- **appcast CI コミットが無限ループを起こす** → 既存の PAT 設定（`RELEASE_TRIGGER_PAT`）を使い、`release-windows.yml` からの push がさらに release を起動しないよう `[skip ci]` タグまたは専用ワークフロー条件を使う。
- **WinSparkle DLL が SmartScreen にブロックされる可能性** → WinSparkle.dll 自体は署名済み配布物。ただし本アプリが未署名のため、インストーラ全体として警告が出る状況は変わらない（コード署名 change で解決）。
- **ローカルビルドで DLL が無い場合** → `win_sparkle_init()` は DLL が見つからなければリンクエラーになる。ドキュメントに DLL 配置手順を明記し、DLL 未設置時のビルドエラーを明確にする。
- **appcast URL が設定されていない Debug ビルド** → `win_sparkle_set_appcast_url` に空文字列を渡した場合 WinSparkle は no-op になる設計。Debug ビルドではマクロで URL を空にして自動チェックを無効化する（macOS の SUFeedURL 未設定と同様の扱い）。

## Migration Plan

1. WinSparkle ヘッダ・import lib をリポジトリに追加
2. `roola_channels.cpp` に `roola/updater` チャンネルを追加
3. `main.cpp` で WinSparkle 初期化・クリーンアップ
4. `runner/CMakeLists.txt` にリンク設定追加
5. `windows/CMakeLists.txt` に DLL コピーインストールルール追加
6. `UpdateCheckerWindows` を MethodChannel 実装に変更
7. CI に WinSparkle DLL ダウンロードステップ追加
8. CI に appcast.xml 生成・コミットステップ追加
9. ADR-0059 追加

ロールバック: 各ステップは git で revert 可能。WinSparkle は DLL を削除すれば無効化できる。

## Open Questions

- appcast-windows.xml を main ブランチへ commit するワークフローでは既存の `RELEASE_TRIGGER_PAT` を流用するか、別の仕組みにするか（`[skip ci]` コミットメッセージで十分か検討）
- WinSparkle のバージョンを `0.8.3`（現在の安定版）に固定するか、常に最新を取得するか
