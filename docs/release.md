# Release ガイド

このドキュメントは Roola のメンテナ向け。タグ push をトリガーに GitHub Actions
で署名 + 公証された DMG を Releases に自動アップロードする仕組み
（[.github/workflows/release.yml](../.github/workflows/release.yml)）の
セットアップと運用手順を記載する。

通常のリリース手順は [リリース手順](#リリース手順) を参照。

## 必要な Repository Secrets

`Settings → Secrets and variables → Actions → New repository secret` から
以下を登録する（7 つは署名・公証用で必須、1 つは Sparkle Phase B 用で
任意）。

| 名前 | 値 | 取得方法 |
|---|---|---|
| `MACOS_CERT_BASE64` | Developer ID Application 証明書（`.p12`）の base64 | [手順 1](#1-macos_cert_base64--macos_cert_password) |
| `MACOS_CERT_PASSWORD` | `.p12` のエクスポート時に設定したパスワード | 上記と同時 |
| `MACOS_KEYCHAIN_PASSWORD` | CI 上で一時 keychain を作る際の任意パスワード | [手順 2](#2-macos_keychain_password) |
| `MACOS_SIGN_IDENTITY` | 証明書識別子 | [手順 3](#3-macos_sign_identity) |
| `APPLE_ID` | Apple ID（メールアドレス） | あなたの Apple ID |
| `APPLE_TEAM_ID` | 10 文字の Team ID | [手順 4](#4-apple_team_id) |
| `APPLE_APP_PASSWORD` | App-specific password | [手順 5](#5-apple_app_password) |
| `SPARKLE_PRIVATE_KEY_BASE64`（任意） | Sparkle EdDSA 秘密鍵の base64。**未設定なら appcast 生成は no-op** | [docs/sparkle.md](./sparkle.md) |

### 1. `MACOS_CERT_BASE64` / `MACOS_CERT_PASSWORD`

Developer ID Application 証明書をローカルの Keychain Access から `.p12`
形式でエクスポートし、base64 エンコードして Secrets に登録する。

```bash
# Keychain Access で「Developer ID Application: ...」を選択し、ファイル →
# 書き出し → 形式 "p12" で保存（パスワードを設定）。仮に developer_id.p12 とする。

# base64 エンコード（クリップボードに送る）
base64 -i developer_id.p12 | pbcopy
# → これを MACOS_CERT_BASE64 にペースト

# パスワードは .p12 エクスポート時に設定したもの
# → これを MACOS_CERT_PASSWORD にペースト
```

### 2. `MACOS_KEYCHAIN_PASSWORD`

CI 上の一時 keychain を作るためのパスワード。任意のランダム文字列で OK。

```bash
openssl rand -base64 32 | pbcopy
# → MACOS_KEYCHAIN_PASSWORD にペースト
```

### 3. `MACOS_SIGN_IDENTITY`

証明書の識別子文字列。ローカルで確認:

```bash
security find-identity -v -p codesigning
# 例: 1) ABCD1234... "Developer ID Application: NAME (TEAMID)"
```

Secrets には `"Developer ID Application: NAME (TEAMID)"` の部分（ダブルクォート
不要）をそのまま登録。

### 4. `APPLE_TEAM_ID`

Apple Developer Portal の [Membership](https://developer.apple.com/account/#/membership/) で確認できる
10 文字の英数字。Roola の現在の Team ID は配布済み DMG から `codesign -dvv`
で確認可能（`5NDCZDZ75J`）。

### 5. `APPLE_APP_PASSWORD`

公証用の App-specific password を [appleid.apple.com](https://appleid.apple.com/account/manage)
→ 「サインインとセキュリティ」→「App 用パスワード」 で生成。

> ⚠️ 通常の Apple ID パスワードではなく **App-specific** が必要。

## ワークフローの 2 つの起動経路

| 起動経路 | 目的 | Release 作成 | DMG の取得方法 |
|---|---|---|---|
| `workflow_dispatch`（手動実行） | パイプライン検証 / 動作確認 | ❌ しない | Actions の Run 詳細 → Artifacts から `Roola-dmg` をダウンロード |
| `git push --tags`（`v*` タグ push） | 正規リリース | ✅ する | GitHub Releases ページ |

手動実行は **タグ無しで安全に dry-run できる** ように、Release アップロードのステップだけスキップする設計（[release.yml](../.github/workflows/release.yml) の `if: startsWith(github.ref, 'refs/tags/')` を参照）。

## リリース手順（本番）

### A. ブラウザだけで完結する方法（推奨）

1. **Actions タブ → "Bump version" ワークフロー → Run workflow**
   - `bump_type`: `patch` / `minor` / `major` / `manual` から選択
   - `manual_version`: `bump_type=manual` のときだけ `0.1.0` 等の semver を入力
2. ワークフローが `pubspec.yaml` を更新 → main に commit + push → `vX.Y.Z` タグを push
3. タグ push をトリガに Release ワークフローが自動連鎖（[後述の PAT 設定](#自動連鎖のための-pat-設定) が前提）
4. 完了後、GitHub Releases ページで自動生成された変更履歴を必要に応じて整える
5. 動作確認: 別 Mac もしくは別ユーザーで DMG をダウンロードして起動確認

#### 自動連鎖のための PAT 設定

GitHub Actions のデフォルト `GITHUB_TOKEN` で push したイベントは **他のワークフローを起動しない** 仕様（無限ループ防止）のため、Bump version → Release の自動連鎖には Personal Access Token (PAT) が必要。

設定手順:

1. [https://github.com/settings/personal-access-tokens](https://github.com/settings/personal-access-tokens) で **Fine-grained personal access token** を新規作成
2. **Resource owner**: あなた、**Repository access**: Roola のみ
3. **Repository permissions**: `Contents` を **Read and write**
4. 生成された token をコピー
5. Repository Settings → Secrets and variables → Actions で `RELEASE_TRIGGER_PAT` という名前で登録

PAT 未設定でも Bump version は動きますが、その場合は Release を Actions タブから手動で起動する必要があります（Bump version の Summary に案内が出ます）。

### B. ローカルから tag push する方法（緊急時）

1. `pubspec.yaml` の `version: X.Y.Z+N` を手動で更新 → コミット → push
2. `git tag vX.Y.Z && git push origin vX.Y.Z` で Release ワークフローが起動

### 失敗時の典型パターン

| 症状 | 原因 / 対処 |
|---|---|
| `codesign` で `errSecInternalComponent` | Keychain インポート時の `set-key-partition-list` が効いていない。ワークフロー失敗ログから keychain セットアップ段階を確認 |
| `notarytool submit` がタイムアウト | Apple 側の遅延の場合あり。`workflow_dispatch` で再実行 |
| `Could not find a signing identity` | `MACOS_SIGN_IDENTITY` が不正、または `MACOS_CERT_BASE64` の証明書が期限切れ |
| `xcrun stapler validate` 失敗 | 公証が完了していない。ログで notarytool の `status: Accepted` を確認 |

### 手動でローカルから配布したい場合

CI を使わず手元で配布 DMG を作る場合は、Secrets と同じ値を環境変数で
渡せば `make dist` がそのまま動く（Makefile のヘッダコメントを参照）:

```bash
make dist \
  SIGN_IDENTITY="Developer ID Application: NAME (TEAMID)" \
  NOTARY_PROFILE=roola-notary
```

ローカル keychain に `notarytool store-credentials` で `roola-notary` を
事前登録しておくこと。

---

## Windows リリース

### 概要

Windows は `release-windows.yml` ワークフローが `v*` タグ push をトリガーに
自動実行され、Inno Setup で `.exe` インストーラを生成して GitHub Releases に
アップロードする。macOS の `release.yml` と並列実行される。

### WinSparkle のローカルセットアップ（自動アップデート有効化）

自動アップデート機能（ADR-0059）は WinSparkle DLL の配置後に有効化される。
配置しなくてもビルドは通るが、アップデート確認は no-op になる。

1. [WinSparkle GitHub Releases](https://github.com/vslavik/winsparkle/releases) から
   最新の `WinSparkle-x.y.z.zip` をダウンロードして展開する
2. 以下のファイルを所定の場所に配置する:

   ```
   windows/third_party/winsparkle/
   ├── include/
   │   └── winsparkle.h          ← zip の include/ から
   └── x64/
       └── Release/
           ├── WinSparkle.lib    ← zip の x64/Release/ から
           └── WinSparkle.dll    ← zip の x64/Release/ から
   ```

3. CMake が自動検出して `ROOLA_WINSPARKLE` を定義し、リンクする

> **Note**: `windows/third_party/winsparkle/include/` 等は `.gitignore` で除外されている。
> CI（`release-windows.yml`）はビルド前に自動ダウンロードする。

### ローカルでインストーラを手動ビルドする

事前条件:
- [Inno Setup 6](https://jrsoftware.org/isdl.php) がインストールされており、`iscc` が PATH に通っていること
- Flutter の Developer Mode が有効であること（`make build-windows` を一度実行すると確認できる）

```cmd
make installer-windows
```

`build\RoolaSetup-<version>.exe` に出力される。

### GitHub Actions による自動リリース手順

macOS と同様、以下のいずれかでリリースを行う:

**A. Actions タブから "Bump version" → 自動連鎖（推奨）**

1. Actions タブ → "Bump version" → Run workflow でバージョンを上げる
2. タグ push をトリガーに `release.yml`（macOS）と `release-windows.yml`（Windows）が並列起動
3. 完了後、GitHub Releases に DMG と `RoolaSetup-<version>.exe` の両方が追加される

**B. 手動タグ push**

```bash
git tag v0.1.0 && git push origin v0.1.0
```

### workflow_dispatch による動作確認

タグを切らずにパイプラインを検証したい場合:

1. Actions タブ → "Release Windows" → Run workflow
2. ビルド完了後、実行詳細の Artifacts から `RoolaSetup-windows` をダウンロード
3. GitHub Releases へのアップロードはスキップされる

### SmartScreen 警告への対処

現在インストーラはコード署名なしのため、初回実行時に Windows SmartScreen が
「発行元不明の警告」を表示することがある。ユーザーは以下の手順で実行できる:

1. 警告ダイアログで **「詳細情報」** をクリック
2. **「実行」** をクリック

コード署名証明書を取得した場合は `release-windows.yml` に `signtool.exe` による
署名ステップを追加することで警告を解消できる（別 change で対応予定）。
