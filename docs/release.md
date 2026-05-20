# Release ガイド

このドキュメントは Roola のメンテナ向け。タグ push をトリガーに GitHub Actions
で署名 + 公証された DMG を Releases に自動アップロードする仕組み
（[.github/workflows/release.yml](../.github/workflows/release.yml)）の
セットアップと運用手順を記載する。

通常のリリース手順は [リリース手順](#リリース手順) を参照。

## 必要な Repository Secrets

`Settings → Secrets and variables → Actions → New repository secret` から
以下の 7 つを登録する。

| 名前 | 値 | 取得方法 |
|---|---|---|
| `MACOS_CERT_BASE64` | Developer ID Application 証明書（`.p12`）の base64 | [手順 1](#1-macos_cert_base64--macos_cert_password) |
| `MACOS_CERT_PASSWORD` | `.p12` のエクスポート時に設定したパスワード | 上記と同時 |
| `MACOS_KEYCHAIN_PASSWORD` | CI 上で一時 keychain を作る際の任意パスワード | [手順 2](#2-macos_keychain_password) |
| `MACOS_SIGN_IDENTITY` | 証明書識別子 | [手順 3](#3-macos_sign_identity) |
| `APPLE_ID` | Apple ID（メールアドレス） | あなたの Apple ID |
| `APPLE_TEAM_ID` | 10 文字の Team ID | [手順 4](#4-apple_team_id) |
| `APPLE_APP_PASSWORD` | App-specific password | [手順 5](#5-apple_app_password) |

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

## リリース手順

1. **バージョンを bump**: `pubspec.yaml` の `version: 0.0.x+x` を更新してコミット
2. **タグを切って push**:
   ```bash
   git tag v0.0.x
   git push origin v0.0.x
   ```
3. **CI を待つ**: GitHub Actions の "Release" ワークフローが自動実行され、約
   10〜15 分でビルド → 署名 → 公証 → ステープル → DMG アップロードまで完了する
4. **Release ノートを編集**: GitHub Releases ページで自動生成された変更履歴を必要に応じて整える
5. **動作確認**: 別 Mac もしくは別ユーザーで DMG をダウンロードして起動確認

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
