# Sparkle 自動更新セットアップ

Roola は [Sparkle 2](https://sparkle-project.org/) で「アプリ起動時に新バージョンを
自動チェック → ユーザー確認のもとダウンロード + 置き換え」する仕組みを持つ。

このドキュメントは **Phase B（公開後）の有効化手順** をまとめる。Phase A
（Pod 追加 + AppDelegate 初期化）は実装済みで、Info.plist の `SUFeedURL` /
`SUPublicEDKey` が空のため現状は no-op になっている。

## アーキテクチャ概要

```
ユーザーの Roola.app                            メンテナ
   │                                              │
   │  起動時 / 定期的に                            │ 1. EdDSA 鍵ペア生成 (1 回だけ)
   │                                              │ 2. 公開鍵を Info.plist に焼く
   ├── HTTPS GET ──> https://yahir0.github.io     │ 3. 秘密鍵を Secrets に登録
   │                  /Roola/appcast.xml          │
   │                  （新バージョンの情報）       │
   │                                              │
   │  appcast.xml に新エントリがあれば            │
   │                                              │
   ├── HTTPS GET ──> Releases の DMG               │
   │                                              │
   │  DMG の EdDSA 署名を                         │
   │  公開鍵で検証 → インストール                  │
```

## Phase B のセットアップ手順

### 1. EdDSA 鍵ペアを生成（1 回だけ）

Sparkle に同梱されている `generate_keys` ツールを使う。これは
`Pods/Sparkle/bin/generate_keys`（あるいは GitHub Release の `Sparkle-x.y.z.tar.xz`
を展開すると入っている）。

```bash
# Sparkle Release から tarball を取得
curl -L -o /tmp/sparkle.tar.xz \
  https://github.com/sparkle-project/Sparkle/releases/latest/download/Sparkle-2.6.0.tar.xz
mkdir -p /tmp/sparkle && tar -xJf /tmp/sparkle.tar.xz -C /tmp/sparkle

# 鍵生成（Keychain に保存される）
/tmp/sparkle/bin/generate_keys

# 公開鍵（base64）を表示
/tmp/sparkle/bin/generate_keys -p
```

最後に出力される **base64 公開鍵** を控える。秘密鍵は **macOS Keychain** に
保存される（`Sparkle EdDSA Private Key` という名前）。

### 2. 公開鍵を Info.plist に焼く

`macos/Runner/Info.plist` の `</dict>` の直前に以下を追加:

```xml
<key>SUFeedURL</key>
<string>https://yahir0.github.io/Roola/appcast.xml</string>
<key>SUPublicEDKey</key>
<string>BASE64_PUBLIC_KEY_HERE</string>
<key>SUEnableAutomaticChecks</key>
<true/>
```

これでアプリ起動時に `updaterController` が初期化され、Sparkle が自動チェック
を開始する。

### 3. GitHub Pages で appcast.xml を配信

Settings → Pages → Source を `Deploy from a branch` にし、`gh-pages` ブランチ
の root を選ぶ。Phase B 後のリリース時に `appcast.xml` をこのブランチに push
すれば `https://yahir0.github.io/Roola/appcast.xml` で配信される。

### 4. リリースワークフローに appcast 生成を組み込む

`.github/workflows/release.yml` の `Upload DMG to GitHub Releases` ステップの
後に以下相当を追加（鍵管理 + `generate_appcast` ツール呼び出し）:

```yaml
- name: Generate and publish appcast
  env:
    SPARKLE_PRIVATE_KEY_BASE64: ${{ secrets.SPARKLE_PRIVATE_KEY_BASE64 }}
  run: |
    # 秘密鍵を一時 Keychain に注入
    echo "$SPARKLE_PRIVATE_KEY_BASE64" | base64 --decode | \
      security import /dev/stdin -k "$RUNNER_TEMP/build.keychain-db" \
      -P "" -T "$SPARKLE_BIN_PATH/generate_appcast"

    # 全 Releases から DMG を取得
    mkdir -p /tmp/appcast-cache
    gh release list --limit 100 --json tagName -q '.[].tagName' | while read tag; do
      gh release download "$tag" --dir "/tmp/appcast-cache" --pattern "*.dmg" || true
    done

    # appcast.xml 生成 + 秘密鍵で署名
    "$SPARKLE_BIN_PATH/generate_appcast" /tmp/appcast-cache \
      --link "https://github.com/yahir0/Roola/releases" \
      --download-url-prefix "https://github.com/yahir0/Roola/releases/download/"

    # gh-pages ブランチに push
    git checkout gh-pages
    cp /tmp/appcast-cache/appcast.xml .
    git add appcast.xml
    git -c user.email=actions@github.com -c user.name=GitHub commit \
      -m "chore: update appcast for $GITHUB_REF_NAME"
    git push origin gh-pages
```

必要な追加 Secret:

| Secret | 取得方法 |
|---|---|
| `SPARKLE_PRIVATE_KEY_BASE64` | Keychain から `Sparkle EdDSA Private Key` を抽出して base64。`security find-generic-password -s "https://sparkle-project.org" -a "ed25519" -w \| base64 \| pbcopy` |

### 5. "Check for Updates..." メニューの追加（任意）

`PlatformMenuBar`（Flutter 側）と Sparkle（Swift 側）の橋渡しに
MethodChannel を 1 本噛ませる必要がある。手順:

1. `lib/app/app_menu_bar.dart` の Roola メニューに `PlatformMenuItem` を追加
2. `onSelected` で `MethodChannel('tech.yahiro.Roola/updater').invokeMethod('checkForUpdates')`
3. `AppDelegate.swift` 側で channel handler を立て、`updaterController?.checkForUpdates(nil)` を呼ぶ
4. ARB に `appMenuCheckForUpdates` を追加

メニュー項目なしでも、起動時 + 定期的にバックグラウンドチェックが走るので
最低限の自動更新は動く。手動チェック導線が必要になったら別 Issue で追加する。

## 動作確認

1. 旧バージョンの Roola をインストール（例: `v0.0.7`）
2. 新バージョンをリリース（例: `v0.0.8`）してワークフローを完走させる
3. 旧版アプリを起動 → 数十秒以内に「アップデートがあります」ダイアログが出る
4. ダウンロード → 置き換え → 自動再起動

## トラブルシューティング

| 症状 | 対処 |
|---|---|
| `Sparkle: SUFeedURL or SUPublicEDKey is not configured` がログに出る | Info.plist の 2 キーを設定してビルドし直す |
| `EdDSA signature did not validate` | 公開鍵と秘密鍵がペアになっていない。Phase B の手順 1 をやり直し、Info.plist と Secrets の両方を更新 |
| アップデートダイアログが出ない | (a) appcast.xml が `version` に新バージョンを記載しているか確認 (b) アプリの `CFBundleShortVersionString` / `CFBundleVersion` が古いバージョンになっているか確認 |
