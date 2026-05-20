# ADR-0040: About ダイアログと OSS ライセンス画面を提供する

- **Status**: Accepted
- **Date**: 2026-05-21

## Context

Roola はこれまでアプリ内に About / ライセンス画面を持たず、メニューバーの
「About Roola」は macOS 標準の `PlatformProvidedMenuItem.about` で Info.plist
の `CFBundleName` / `CFBundleShortVersionString` を素のダイアログで出すだけ
だった。OSS ライセンスへの導線はゼロで、設定画面にも About セクションは無い。

MIT ライセンスの通知義務は Roola 自身（`LICENSE` ファイルは存在）だけでなく、
依存している OSS パッケージにも掛かる。Roola は以下を頒布物（DMG / バンドル）
に含めて配布している:

- **pub 経由の Dart / Flutter パッケージ**（30+ パッケージ。MIT / Apache-2.0 /
  BSD 等）
- **CocoaPods 経由**: Sparkle（MIT）
- **Swift Package Manager 経由**: SwiftTerm（MIT）

Flutter には `LicenseRegistry` という仕組みがあり、pub のパッケージは
`showLicensePage` で自動収集・閲覧できる。一方、CocoaPods / SwiftPM 経由の
ネイティブ依存は `LicenseRegistry` に乗らないため、手動登録が必要になる。

## Decision

**Flutter 標準の `showAboutDialog` をメニューと設定画面の双方から呼べる単一
経路にし、ネイティブ依存のライセンスは起動時に `LicenseRegistry.addLicense()`
で明示登録する。**

### D1. About 画面は Flutter 標準 `showAboutDialog` を使う

`showAboutDialog` はアプリ名・バージョン・著作権を表示し、「ライセンスを表示」
ボタンから `showLicensePage` に遷移できる。`showLicensePage` は
`LicenseRegistry.licenses` から自動でパッケージ単位のリストを描き、検索・
スクロール・ライセンス全文表示まで標準ウィジェットが面倒を見る。

却下案: 自前のライセンス画面を 1 から作る。Polaris の見た目に合わせる
カスタマイズ余地は得られるが、検索・パッケージグルーピング・ライセンス全文
レンダリングを再実装するコストに見合わない。Material 標準の見た目で十分。

### D2. 起動口は 2 つ（アプリメニュー / 設定画面）にする

- **メニューバー**: 「Roola → Roola について…」。`PlatformProvidedMenuItem.about`
  は OS 既定のダイアログ（OSS ライセンス導線なし）を開くため、自前の
  `PlatformMenuItem` に置換し `showRoolaAboutDialog` を呼ぶ。
- **設定画面**: 末尾に「Roola について」セクションを追加し、`OutlinedButton`
  で同じダイアログを開く。メニューに辿り着けないユーザー向けの保険。

### D3. About はコマンドレジストリには登録しない

ADR-0033 のコマンドレジストリ（`CommandRegistry`）は **既定キーコンビ必須**・
**カテゴリ分類** を前提とした作りで、`CommandMetadata.defaultChord` は required。
About には標準的なショートカットがなく（macOS 慣習上も無い）、コマンド
パレット的に呼ばれる用途も無いため、レジストリに乗せる利益が無い。
`PlatformMenuItem.onSelected` から直接 `showRoolaAboutDialog` を呼ぶ。

### D4. ネイティブ依存は `assets/licenses/` にバンドルし起動時に登録する

CocoaPods / SwiftPM 経由のネイティブ依存（Sparkle / SwiftTerm）は
`LicenseRegistry` の自動収集に乗らない。これらのライセンス全文（公式リポジトリ
の `LICENSE` から取得）を `assets/licenses/sparkle.txt` /
`assets/licenses/swiftterm.txt` としてバンドルし、`main()` の早い段階で
`lib/app/license_bootstrap.dart` の `registerNativeLicenses()` を呼んで
`LicenseRegistry.addLicense()` で登録する。

`addLicense` の callback は遅延評価される（`showLicensePage` を開いた瞬間に
初めてアセットを読む）ので、起動時の同期コストは無い。

却下案: ネイティブ依存だけ別ページに静的に並べる。コストは似たり寄ったりだが
「pub のものは `showLicensePage`、ネイティブはこっち」と分かれると検索性が
悪く、ユーザーがどちらを見れば良いか分からなくなる。1 箇所に集約する方が
良い。

### D5. アプリバージョンは `package_info_plus` で実行時取得する

`showAboutDialog` の `applicationVersion` には `0.0.14 (14)` の形式で渡す
（`CFBundleShortVersionString (CFBundleVersion)`）。`package_info_plus` は
ネイティブのバンドル情報を読むため、`pubspec.yaml` の version 値を別経路で
複製する必要がない（version は Bump version ワークフロー / ADR で運用される
単一の真実）。

却下案: Dart 側に const としてバージョンを置く。pubspec とのズレを誰も検出
できず、リリース時に手で同期する手間が増える。

## Why

- **法的義務**: MIT・Apache-2.0・BSD いずれも頒布物に著作権表記とライセンス
  全文を含める義務がある。`LICENSE` ファイルをリポジトリに置くだけでは、
  バイナリ配布物（DMG）の同梱要件は満たされない。
- **macOS 慣習**: アプリメニューの先頭に「About アプリ名」が並ぶのは macOS の
  標準 UX。Flutter Mac アプリでも踏襲する。
- **設定画面の保険**: macOS のメニューバー操作に慣れないユーザー（ノートPC
  キーボードで上端メニューに辿り着けない・他 OS 慣習で設定内を探す等）への
  二重導線。

## Trade-offs

- **`showAboutDialog` は Material 標準スタイル**: Polaris デザインシステム
  （ADR-0038）の見た目とは厳密には揃わない。ただし `ThemeData` のダーク・
  アクセント色は反映されるため、極端な違和感は出ない。完全に揃えるコストは
  見合わない。
- **アセットの二重管理**: Sparkle / SwiftTerm の LICENSE は上流が更新される
  可能性がある（実際は MIT 本文がほぼ変わらないが、年号・著作権者は変わる）。
  上流バージョン更新時に手動で `assets/licenses/*.txt` を更新する運用が要る。
  自動同期は CI を組めば可能だが、CI 失敗時の意味が薄いので当面は手運用。
- **`PlatformProvidedMenuItem.about` から離れる**: OS 設定で挙動を変える将来の
  macOS 仕様変更（例: Apple Intelligence 連携など）から外れる可能性がある。
  影響は小さく、必要ならいつでも戻せる。
- **アプリアイコン**: 現状 `showAboutDialog` の `applicationIcon` には Material
  アイコン（`Icons.terminal`）を仮置きしている。プロパーなアイコンを
  `Image.asset` でバンドルしたら差し替える。アイコン PNG は `docs/images/`
  にしか無く、アプリバンドルに含まれていないため。

## References

- ADR-0033（コマンドレジストリとネイティブメニューバー — About は対象外と
  する判断）
- ADR-0034（多言語化を gen-l10n で実装 — About のラベルも ARB に追加）
- ADR-0038（Polaris デザインシステム — Material 標準との見た目の差は許容）
- [`assets/licenses/sparkle.txt`](../../assets/licenses/sparkle.txt) — Sparkle
  公式リポジトリ `2.x/LICENSE` のコピー
- [`assets/licenses/swiftterm.txt`](../../assets/licenses/swiftterm.txt) —
  SwiftTerm 公式リポジトリ `master/LICENSE` のコピー
