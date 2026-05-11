# ADR-0003: 状態管理に Riverpod + Hooks を採用

- **Status**: Accepted
- **Date**: 2026-05-11

## Context

本アプリは以下の状態を扱う:

- グローバル状態: ランチャーエントリ一覧、外観設定、`claude` CLI のヘルスチェック結果
- 画面ごとの状態: 設定画面のフォーム値、ホーム画面の選択状態、実行画面のターミナル状態
- 非同期取得を伴う状態: 永続化ファイルの読み込み、PTY 起動結果
- リソース寿命の管理が必要な状態: `xterm` の `Terminal` インスタンス、PTY 出力ストリームの購読、`TextEditingController` / `FocusNode`

これらを統一的に管理する仕組みが必要。

Flutter 公式 [App architecture guide](https://docs.flutter.dev/app-architecture) は ViewModel に ChangeNotifier、ローカル状態に StatefulWidget を例示している。本アプリは公式ガイドを基盤としつつ、Flutter エコシステムで事実上の標準となっているライブラリを採用する立場で判断する（詳細は `docs/architecture.md` の「規範ソース」節）。

## Decision

- **グローバル状態は Riverpod**（`Notifier` / `AsyncNotifier`、必要なら family modifier）
- **ローカル状態は flutter_hooks**（`useState` / `useEffect` / `useMemoized` / `useTextEditingController` / `useFocusNode` 等）
- ViewModel は Riverpod の `Notifier` を採用し、Flutter 公式 architecture guide の ChangeNotifier の代替とする
- 上記 2 つを統合するため Widget 基底は `HookConsumerWidget`（`hooks_riverpod`）を使う
- コード生成は `riverpod_generator` を採用（boilerplate を削減）

## Why

### 代替案 1: provider + ChangeNotifier（Flutter 公式ガイドのデフォルト）

却下。理由:

- ChangeNotifier は可変オブジェクト前提で、型安全性とテスト容易性で劣る
- 非同期状態の表現が手薄（`isLoading` / `error` を自前で持つ必要がある）
- 依存の宣言が暗黙的になりがちで、リファクタリングが難しい

### 代替案 2: bloc

却下。理由:

- イベント駆動の恩恵が出るほどの状態遷移複雑度が本アプリには無い
- 学習コストが高く、ボイラープレート量が多い

### 代替案 3: setState のみ

却下。グローバル共有が必要な状態（エントリ一覧）を扱えない。

### 代替案 4: Riverpod + StatefulWidget（Hooks 不採用）

検討したが却下。本アプリでは以下のローカル状態管理がリソース寿命に強く依存し、Hooks のほうが堅い:

| ケース | StatefulWidget で書くと | Hooks で書くと |
|---|---|---|
| `RunPage` で `xterm` の `Terminal` を 1 度生成 → PTY 出力購読 → 画面破棄で dispose | `initState` 生成 / `late StreamSubscription` 保持 / `dispose` で cancel + close。entryId 変更時の rebuild は `didUpdateWidget` で対応 | `useMemoized` で生成、`useEffect` で購読と cleanup を 1 箇所に集約。custom `useTerminal` hook として再利用可能 |
| `EntryEditPage` の `TextEditingController` × 3、`FocusNode` × 3 | 各々 late で初期化、`dispose` で全部 dispose。dispose 漏れリスクあり | `useTextEditingController()` / `useFocusNode()` を 1 行ずつ。dispose 漏れ不可能 |
| ターミナルリサイズ追従 | `initState` / `dispose` でリスナー登録解除 | `useEffect` の return で cleanup |

dispose 漏れは Flutter 開発でよく見るリーク要因であり、本アプリの中核（`RunPage` の PTY ライフサイクル）で発生すると致命的。Hooks はこれを言語レベルで防ぐ。

### 採用理由（Riverpod + Hooks）

- **Riverpod**: `Notifier` は ChangeNotifier の置き換えとして自然に機能し、Flutter 公式 MVVM パターンに矛盾しない。`AsyncValue` で非同期の loading / data / error を型安全に扱える。family modifier でパラメータ依存の状態（entryId ごとの実行状態）を綺麗に表現できる。`ProviderContainer.test()` でテストしやすい
- **flutter_hooks**: リソース寿命管理（特に `xterm.Terminal` と PTY ストリーム購読）が StatefulWidget より堅く書ける。`TextEditingController` / `FocusNode` の dispose 漏れリスクを排除できる
- **hooks_riverpod**: 両者を `HookConsumerWidget` 1 つに統合でき、`ConsumerStatefulWidget` + StatefulWidget の二段重ねを避けられる
- 両ライブラリとも Flutter エコシステムで事実上の標準で、外部協力者の参入障壁も低い

## 使い分けの指針

- **永続化が必要 / 複数画面で共有 / ライフサイクルを跨ぐ** → Riverpod Provider
- **画面内で完結 / 一時的なフォーム値・トグル状態 / リソース寿命を持つオブジェクト** → Hooks（`useState` / `useTextEditingController` / `useMemoized` + `useEffect` 等）

詳細は `docs/architecture.md` の「状態管理パターン」節を参照。

## Trade-offs

- 公式 architecture guide の例示（StatefulWidget + ChangeNotifier）から外れるため、参照時に「Hooks / Riverpod に置き換えて読む」必要がある
- 開発者は Riverpod と Hooks の両方の API を理解する必要がある
- コード生成（`riverpod_generator`）のため初期セットアップ（`build_runner` 構成）が必要
- Hooks の「呼び出し順序が固定」「条件分岐内で呼べない」というルールを守る必要がある（リンタ `custom_lint` + `riverpod_lint` + flutter_hooks 同梱の lint で検出可能）

## References

- Riverpod: https://riverpod.dev/docs/introduction/why_riverpod
- riverpod_generator: https://pub.dev/packages/riverpod_generator
- flutter_hooks: https://pub.dev/packages/flutter_hooks
- hooks_riverpod: https://pub.dev/packages/hooks_riverpod
- Flutter App architecture guide: https://docs.flutter.dev/app-architecture
