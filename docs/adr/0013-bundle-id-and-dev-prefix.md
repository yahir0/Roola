# ADR-0013: Bundle ID を `tech.yahiro.Roola` にし、Debug / Profile は `dev.` プレフィックスで分離する

- **Status**: Accepted
- **Date**: 2026-05-14

## Context

これまで Bundle ID は `io.github.yahir0.roola` を使っていた。これは GitHub Pages 由来の reverse-DNS で、所有ドメインではないため Apple 配布や他プロダクト群との整合性で課題があった。プロジェクト所有者は `yahiro.tech` ドメインを保有しており、他プロダクトも `tech.yahiro.<Product>` という Apple 流の reverse-DNS 規約で命名している。

加えて、`make run` で起動する開発ビルドと、`make dmg` でパッケージした製品版をユーザーが同一マシンにインストールしたとき、両者の永続化ディレクトリ（`~/Library/Application Support/<bundleID>/`）が衝突するのが煩わしいという要望があった。

## Decision

### 本番 Bundle ID

Release 構成の `PRODUCT_BUNDLE_IDENTIFIER` を **`tech.yahiro.Roola`** に変更する。所有ドメインに揃え、Apple 流の reverse-DNS（domain は小文字、Product 名は CamelCase）に従う。

### 開発ビルドの分離

Xcode の Debug / Profile 構成のみ、`project.pbxproj` の buildSettings で **`PRODUCT_BUNDLE_IDENTIFIER = dev.tech.yahiro.Roola`** に上書きする。これにより:

- `make run`（Debug 起動）の App Support は `~/Library/Application Support/dev.tech.yahiro.Roola/`
- `make dmg` でインストールした版の App Support は `~/Library/Application Support/tech.yahiro.Roola/`
- macOS の Launch Services は両者を別アプリとして扱う（Cmd-Tab・Activity Monitor・通知設定でも別扱い）
- 開発中に launcher entries / appearance を変更しても本番側の設定は無傷

`PRODUCT_NAME` は両構成とも `Roola` のまま（変えると `MainMenu.xib` の「Roola について」等の文字列と乖離する）。Dock 上はアイコンが同じ Roola として並ぶが、bundle ID は別なので動作・データは独立。

## Why

### 代替案 1: 末尾に `.dev` を付ける（`tech.yahiro.Roola.dev`）

却下。

- 多くのアプリで採用されている慣習ではあるが、所有者がこのプロジェクトに対して明示的に「`dev.` を頭につけて」と指定
- 「dev. が頭」のほうがソートしたときに視認性が高い（`dev.` で始まる開発系 bundle が一カ所にまとまる）

### 代替案 2: Xcode の Configuration を増やして scheme 分離

却下（当面）。

- `Debug-dev` のような config を新設して xcconfig を分離する方が「正しい」Xcode 流だが、`flutter run --flavor` の macOS サポートが限定的で、Flutter CLI と Xcode config の不整合に起因する事故が起きやすい
- 既存の Debug / Profile / Release の 3 構成のうち、開発用途は Debug / Profile の 2 つ。両方を `dev.*` に倒せば実用上十分

### 採用理由

- pbxproj の各構成の buildSettings に `PRODUCT_BUNDLE_IDENTIFIER` 1 行を足すだけで完結
- `flutter run` / `flutter build --release` の振る舞いを変えずに副作用ゼロで分離
- 後から代替案 2（config 増設）に移行する場合も、現状の上書きを消して新 config を作るだけで済む

## Trade-offs

### `make run` 中の Roola.app は Dock 上で本番版と区別しづらい

PRODUCT_NAME も AppIcon も同じため、Dock に両アイコンが並んでも見た目で区別できない。Cmd-Tab のラベルも両方「Roola」と表示される。

許容理由:
- 主目的は永続化データの分離。視覚的区別は副次的
- 視覚区別したい場合は将来「Roola Dev」表記化（要 `MainMenu.xib` の動的化）を別 ADR で扱う

### 旧 Bundle ID `io.github.yahir0.roola` の orphan データ

既存ユーザーの `~/Library/Application Support/io.github.yahir0.roola/` は新 ID に自動移行されない。手動で移行 or 廃棄してもらう。orphan は害がないので積極削除はしない。

### Apple Developer Program 登録時の影響

将来 Apple 配布する場合、Apple Developer の Identifier に `tech.yahiro.Roola` を登録する必要がある。`tech.yahiro` ドメインは所有しているので問題なし。

## References

- ADR-0001: Flutter Desktop（macOS）採用
- ADR-0012: マルチウィンドウは別プロセス起動で実現
- Apple Bundle ID 命名規約: https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html#//apple_ref/doc/uid/TP40009249-SW1
