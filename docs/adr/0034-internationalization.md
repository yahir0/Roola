# ADR-0034: 多言語化を Flutter 公式 gen-l10n（ARB）で実装する

- **Status**: Accepted
- **Date**: 2026-05-18

## Context

Roola は当初から UI 文字列を日本語でハードコードしてきた。日本語話者以外にも使えるよう、表示言語を切り替えられるようにしたい。当面は日本語・英語の 2 言語、既定は日本語、設定画面から切り替え可能とする。

現状の制約は次のとおり:

- UI に表示される日本語リテラルがウィジェット層を中心に 200 以上散在している。
- `MaterialApp.router` には `localizationsDelegates` / `supportedLocales` / `locale` の指定がない。
- メニューバー・コンテキストメニュー・設定画面のコマンドラベルは `CommandRegistry`（data 層）が静的な日本語文字列として保持している（ADR-0033）。
- 設定の永続化は `appearance.json` 等と同じく `<appSupport>` 配下の JSON ファイルで行う方式が確立している。

## Decision

多言語化は **Flutter 公式の gen-l10n（ARB ベース）** で実装する。

- **翻訳リソース**: `lib/l10n/app_ja.arb`（テンプレート）と `app_en.arb`。`flutter:` の `generate: true` と `l10n.yaml` により `AppLocalizations` を自動生成する。
- **依存**: `flutter_localizations`（SDK）と `intl` を追加する。
- **配線**: `MaterialApp.router` に `AppLocalizations.localizationsDelegates` / `supportedLocales` と、設定値由来の `locale` を渡す。
- **言語設定の永続化**: `<appSupport>/locale_settings.json` に保存する。差し替え可能性のため `LocaleSettingsRepository` interface を置く（PTY・他の永続化と同方針）。設定値は単一の enum（`AppLocale`）なので、`appearance` のような DTO ⇄ モデル分離は行わず、リポジトリが enum と JSON を直接変換する。
- **起動時読み込み**: 言語は初回フレームから確定している必要があるため、`AsyncNotifier` での遅延読み込みではなく `main()` で同期的に解決し、`localeSettingsInitialProvider` を `overrideWithValue` で注入する（ワークスペースの ADR-0028 と同方式）。切り替えは `AppLocaleNotifier`（`Notifier`）が担い、変更時に即永続化する。
- **コマンドラベル**: `CommandMetadata` / `CommandCategory` から日本語ラベルフィールドを除去し、`CommandId` / `CommandCategory` を安定キーとして UI 層（`AppLocalizations` の拡張）でラベルを解決する。data 層が表示文字列を持たない構造にする。
- **既定言語**: 日本語（`AppLocale.ja`）。未保存・壊れた設定ファイル時も日本語にフォールバックする。

## Why

### なぜ gen-l10n（ARB）か

ARB + `gen-l10n` は Flutter 公式の標準的な多言語化機構で、追加パッケージなし（`intl` のみ）で完結する。本リポジトリの自己完結方針（ADR-0005）と「Flutter エコシステムの事実上の標準を積極採用する」方針（CLAUDE.md）の双方に合致する。プレースホルダ・複数形・型安全な getter（`AppLocalizations`）が生成され、キーの参照漏れをコンパイル時に検出できる。

### なぜコマンドラベルを data 層から外すか

ADR-0033 の `CommandRegistry` は `const` の静的データであり、ロケールに応じて変化する文字列を保持できない。`CommandId` / `CommandCategory` という安定キーは既にあるため、ラベルの解決を UI 層へ移し、data 層は「何のコマンドか」だけを表す構造に保つ。これはレイヤー責務（data 層は表示文字列を持たない）とも整合する。

## 代替案

### 代替案 1: 自前の翻訳マップ

`Map<AppLocale, Map<String, String>>` を Riverpod で保持する軽量案。生成ステップが不要な一方、キーのタイポや参照漏れがコンパイル時に検出できず、プレースホルダ・複数形を自前で実装する必要がある。文字列数が 200 を超える規模では型安全性の欠如が保守コストに直結する。**却下。**

### 代替案 2: `easy_localization` 等のサードパーティ製パッケージ

ホットリロードや JSON リソースなど利便性はあるが、外部依存が増え、Flutter 公式機構で十分まかなえる。自己完結方針（ADR-0005）に照らし、公式の gen-l10n を優先する。**却下。**

### 代替案 3: 言語設定も `AsyncNotifier` で遅延読み込み

`appearance` と同じく `AsyncNotifier` で読み込む案。だが言語は初回フレームの描画に必要で、遅延読み込みだと英語ユーザーには起動のたびに日本語が一瞬見える。起動前に同期解決して注入する方式（ADR-0028）を採る。**却下。**

## Trade-offs

- **翻訳の二重管理** — 文字列を追加・変更するたび `app_ja.arb` と `app_en.arb` の両方を更新する必要がある。テンプレート（ja）にしかないキーは生成時に警告が出るため、抜けは検出できる。
- **言語切り替えで一部ネイティブ要素は即時反映されない可能性** — macOS ネイティブメニューバー（`PlatformMenuBar`）のラベルは Flutter のロケール変更で rebuild されるが、OS 側のキャッシュ挙動次第ではアプリ再起動が確実。必要なら将来 ADR を追加する。
- **`system` ロケール追従は対象外** — v1 は日本語・英語の明示選択のみ。OS 言語追従は将来課題。
- **enum 単一値ゆえ DTO を持たない** — `locale_settings.json` は他の設定ファイルと違い DTO クラスを介さない。将来言語以外の項目が増えたら DTO 化を検討する。

## References

- ADR-0005（外部 Skill / プラグインに依存しない自己完結方針）
- ADR-0028（ワークスペースの起動時読み込みと Provider 注入）
- ADR-0033（コマンドレジストリ）— 本 ADR でコマンドラベルを data 層から UI 層へ移す
- [Internationalizing Flutter apps — Flutter docs](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)
