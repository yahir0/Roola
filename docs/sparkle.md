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

### 3. GitHub Repository Secret に秘密鍵を登録

CI が appcast.xml を署名するために、Keychain に保存された秘密鍵を base64 で
`SPARKLE_PRIVATE_KEY_BASE64` という Secret に登録する。

```bash
# Keychain から秘密鍵を base64 で取り出してクリップボードへ
security find-generic-password -s "https://sparkle-project.org" -a "ed25519" -w \
  | base64 | pbcopy
```

→ GitHub Settings → Secrets and variables → Actions → New repository secret
で `SPARKLE_PRIVATE_KEY_BASE64` として登録。

> ⚠️ 秘密鍵は **絶対に公開しない**。Repository Secret に入っているぶんは
> Actions の log 上でもマスクされる。

### 4. GitHub Pages で appcast.xml を配信できるようにする

リリースワークフローは appcast.xml を **`gh-pages` ブランチ** に push する。
GitHub Pages 側で当該ブランチを source にすると、初回 push の数十秒後に
`https://yahir0.github.io/Roola/appcast.xml` で配信される。

手順:

1. Settings → Pages → Source = `Deploy from a branch`
2. Branch = `gh-pages`、Folder = `/ (root)`
3. Save

> 💡 `gh-pages` ブランチはリリースワークフローが初回 tag push 時に自動で
> 作成する（orphan branch）ので、事前に手動で作る必要はない。
> ただし **GitHub Pages の Source 選択は Pages 設定 UI 上での手動操作が必要**。
> 初回 push 後に上記設定を行うと反映される。

### 5. リリースワークフロー（自動）

`.github/workflows/release.yml` には既に **appcast 生成 + gh-pages push の
ステップが組み込まれている**。`SPARKLE_PRIVATE_KEY_BASE64` Secret が未設定
のときは no-op で素通りするので、Phase A 状態でも安全。Secret 登録後の
最初のタグ push から appcast.xml が gh-pages に出始める。

ローカルで appcast.xml の見た目を確認したいときは:

```bash
# 既にローカル make dist で build/Roola.dmg ができている前提
./tools/release/generate-appcast.sh \
  build/Roola.dmg \
  https://github.com/yahir0/Roola/releases/download/v0.0.7/ \
  /tmp/appcast-output

cat /tmp/appcast-output/appcast.xml
```

### 6. "Check for Updates..." メニューの追加（任意）

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
