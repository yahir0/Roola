# ADR-0027: per-tab 状態を family(tabId) + scoped Provider で実現する

- **Status**: Accepted
- **Date**: 2026-05-15

## Context

ADR-0026 で `/explorer` を 3 ペイン × タブ群のワークスペースにする。これに伴い、
これまでシングルトンだった次のプロバイダを「タブごとに独立」させる必要がある。

- `ExplorerViewModel`（ディレクトリ履歴・カレントパス）
- `explorerItemSelectionProvider`（アイテム選択）

同時に、末端 widget（`explorer_node_tile` / `explorer_path_bar` / ディレクトリ
一覧など）はどのタブに属するかを知らないと family へアクセスできない。

## Decision

### 1. per-tab 状態は family(tabId)

`ExplorerViewModel` を `family(ExplorerTabArgs)` 化する。`ExplorerTabArgs` は
`(tabId, initialPath)`。`build()` は `initialPath` を直接初期パスに使い、
`explorerSettingsProvider` の `rootPath` は **watch しない**。`changeRoot` は廃止し、
`rootPath` は「新規エクスプローラタブの既定パス」としてのみ機能させる。

`explorerItemSelectionProvider` も `family(tabId)` 化する。

family プロバイダはすべて**ルートスコープ**に置き `keepAlive` にする。タブ切替で
破棄せず、タブを閉じたときだけ `ref.invalidate(provider(args))` で明示破棄する。

### 2. tabId 配布は scoped Provider

`currentTabIdProvider`（既定で `throw` する `Provider<String>`）を定義する。各タブ
body を `ProviderScope(overrides: [currentTabIdProvider.overrideWithValue(tabId)])`
で包み、子 widget は `ref.watch(currentTabIdProvider)` で tabId を得て family に
アクセスする。

**重要**: `ProviderScope` で override するのは `currentTabIdProvider`（ID 配布のみ）。
`ExplorerViewModel` 等の family 本体を nested scope に置いてはならない（scope の
unmount で状態が破棄される）。family 本体は必ずルートスコープに置く。

## Why

- **family が「タブごとに独立した状態」の素直な表現**: Riverpod の family は
  引数ごとに別インスタンスを作るため、タブ ID をキーにすればそのまま per-tab 状態
  になる。タブ間で履歴・選択が干渉しない
- **ルートスコープ + keepAlive で移動に強い**: タブを別ペインへ DnD 移動しても、
  family 本体は tabId キーのままルートスコープに残るので、履歴も PTY も無損失で
  引き継げる（ADR-0026 のタブ移動要件）
- **scoped Provider で引数の波及を止める**: tabId を全 widget のコンストラクタに
  通すと `explorer_node_tile` など末端まで引数追加が波及する。`currentTabIdProvider`
  の override なら注入点はタブ body 1 箇所で済む
- **`rootPath` を watch しない**: watch すると起動ディレクトリ変更で全エクスプローラ
  タブのカレントパスがリセットされる。各タブは独立して navigate するので、root は
  「新規タブの初期値」に留めるのが正しい

## 代替案

### 代替案 1: tabId を全 widget の引数で渡す

`currentTabIdProvider` を使わず、コンストラクタ引数で tabId を伝搬する。

- `explorer_node_tile` / `explorer_path_bar` / 一覧 sliver など末端まで引数追加が
  波及し、変更量・将来の保守コストが大きい
- 却下。

### 代替案 2: family 本体を nested ProviderScope に置く

タブ body の `ProviderScope` で `ExplorerViewModel` family ごとスコープする。

- scope が unmount されると状態が破棄される。`IndexedStack` で mount を維持しても、
  タブの DnD 移動で widget サブツリーが作り直されると履歴・PTY が失われる
- ルートスコープ + 明示 invalidate のほうがライフサイクルを制御しやすい
- 却下。

### 代替案 3: 1 個の Notifier が `Map<tabId, State>` を保持する

family を使わず、単一 Notifier が全タブ状態を Map で持つ。

- どのタブの変更でも Notifier 全体が再評価され、購読側の比較コストが上がる
- family なら Riverpod が ID 単位の購読・破棄を自動で面倒見る
- 却下。

## Trade-offs

- **「family 本体をルートに置く」規約が暗黙知になりやすい**: nested scope に置く
  誤りは静かに状態を失わせる。`docs/architecture.md` とコード内コメントに明記する
- **タブを閉じたときの明示 invalidate を忘れるとリークする**: `workspaceProvider`
  の `closeTab` に invalidate 処理を集約し、閉じ経路を 1 本にする
- **`currentTabIdProvider` を override 外で読むと throw する**: タブ body 配下以外
  で誤読すると実行時エラー。エラーメッセージで誤用箇所が分かるようにする

## References

- ADR-0003（Riverpod + Hooks 状態管理）
- ADR-0008（keep-alive セッション。本 ADR の keepAlive 方針と同系統）
- ADR-0026（3 画面タブ式ワークスペース）
