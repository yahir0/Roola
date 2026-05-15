## Context

現状の `/explorer`（`ExplorerPage`）は単一ペインで、`explorerSelectionProvider`（`directory` / `entrySession` / `adhocSession` の sealed union）が「本体に何を描くか」を排他的に切替えている。`ExplorerViewModel`（ディレクトリ履歴・カレントパス）と `explorerItemSelectionProvider`（アイテム選択）はいずれもシングルトンの Riverpod プロバイダ。PTY セッションは `RunViewModel` / `AdhocRunViewModel` の keep-alive family に保持される。

3 画面化では「表示単位」をペイン × タブに分解する必要があり、シングルトン前提の上記 3 プロバイダがそのままでは複数並行に対応できない。本設計はその刷新方針を定める。

制約:
- アーキテクチャは Flutter 公式 MVVM ベース 3 グループ構成（`ui/` / `data/` / `core/`）。Use Case 層は作らない（CLAUDE.md / ADR-0006）
- 状態管理は Riverpod（`Notifier` / `AsyncNotifier`）+ flutter_hooks。差し替え可能性のある永続化のみ Repository + interface
- 新規ライブラリ追加は避ける。DnD は Flutter 標準 `Draggable` / `DragTarget`

## Goals / Non-Goals

**Goals:**
- 上 2 + 下 1 の 3 ペインスロットに、種別固定タブ（エクスプローラ / ターミナル）を複数持てる
- ペインを空にすると崩れて 2 ペイン → 単一ペインへ再フローし、単一時は従来の見た目に戻る
- タブを DnD でストリップ内並べ替え・ペイン間移動でき、移動で状態（履歴 / PTY）を失わない
- レイアウトを永続化し、再起動でエクスプローラはパス復元・ターミナルは再 spawn する
- 初回起動時は既定 3 ペインを表示する

**Non-Goals:**
- ペイン本体（タブストリップ外）へのドロップによる動的スプリット生成
- 3 を超えるペインスロット数や任意グリッドレイアウト
- PTY セッションそのものの永続化（出力履歴・プロセス状態のプロセス跨ぎ復元）
- マルチウィンドウ間でのワークスペース同期（各ウィンドウ独立、永続化は last-write-wins）
- タブ DnD のウィンドウ跨ぎ移動

## Decisions

### Decision 1: 表示単位をタブにし `explorerSelectionProvider` を廃止する

現状の `explorerSelectionProvider` は「1 ペインがディレクトリかセッションのどちらか」を表すが、3 ペイン × 複数タブでは破綻する。タブ自体に種別（`explorer` / `terminal`）を持たせ、ペインスロットがタブ群を保持する構造にする。

`WorkspaceTab`（freezed sealed union）:
- `ExplorerTab`: `id`、初期パス（復元用）
- `TerminalTab`: `id`、`AdhocRunArgs`（adhoc）または `entryId`（永続エントリ）

`PaneSlot`（freezed）: `List<WorkspaceTab> tabs` + `int activeIndex`。
`WorkspaceLayout`（freezed）: `topLeft` / `topRight` / `bottom` の 3 スロット（空可）+ スプリッタ比率（`topRatio`：上下、`leftRatio`：上段左右）。

**代替案**: `explorerSelectionProvider` を family 化して残す案も検討したが、「ディレクトリ ⇄ セッション」の動的切替ロジック（戻る矢印で session→directory に戻す等）がタブ種別固定モデルと噛み合わず、かえって複雑化するため廃止を選択。

### Decision 2: per-tab 状態は `family(tabId)`、tabId 配布は scoped Provider

`ExplorerViewModel` と `explorerItemSelectionProvider` を `family` 化する。

- `ExplorerViewModel.family(ExplorerTabArgs)`: `ExplorerTabArgs = (tabId, initialPath)`。`build()` は `initialPath` を直接使い、`explorerSettingsProvider` の `rootPath` は **watch しない**（root 変更で全タブがリセットされるのを防ぐ）。`rootPath` は「新規エクスプローラタブの既定パス」としてのみ機能する。`changeRoot` は廃止。
- `explorerItemSelectionProvider.family(tabId)`。
- family プロバイダはすべて**ルートスコープ**に置き、`keepAlive`。タブ切替で破棄せず、タブ閉時に `ref.invalidate` で明示破棄する。

子 widget（`explorer_node_tile` / `explorer_path_bar` / ディレクトリ一覧等）へ tabId を渡す手段として、`currentTabIdProvider`（既定で throw する `Provider<String>`）を用意し、各タブ body を包む `ProviderScope(overrides: [currentTabIdProvider.overrideWithValue(tabId)])` で注入する。子は `ref.watch(currentTabIdProvider)` で tabId を得て family にアクセスする。

**代替案**: tabId を全 widget のコンストラクタに通す案は、`explorer_node_tile` など末端まで引数追加が波及し変更量が大きいため不採用。`ProviderScope` override は局所的で、family 本体はルートに残るため状態の生存も両立できる。

**注意**: override するのは `currentTabIdProvider`（ID 配布のみ）。`ExplorerViewModel` family 本体を nested scope に置くと scope unmount で破棄されるため、本体は必ずルートスコープに置く。

### Decision 3: `workspaceProvider` がレイアウトの単一の真実

`workspaceProvider`（`Notifier<WorkspaceLayout>`, `keepAlive`）が 3 スロット・タブ群・activeIndex・スプリッタ比率を保持し、次の操作を提供する:
- `addTab(slot, tab)` / `closeTab(tabId)` / `activateTab(tabId)`
- `moveTab(tabId, toSlot, toIndex)`（DnD のストリップ内並べ替え・ペイン間移動を統一的に表現）
- `setSplitRatio(...)`

崩し再フローは `closeTab` / `moveTab` 後に純粋関数で再計算する:
- タブ 0 のスロットは「空」扱い
- 描画時、コンテンツを持つスロット数が 1 ならそのスロットを全画面（単一ペイン）描画
- 2 なら、空きが `bottom` のみ → 上段左右 2 分割を全高に。空きが上段の片方 → 残った上段 1 つ + `bottom` の上下 2 分割
- 3 つ揃えば通常の上 2 + 下 1

タブ閉時は対応する family プロバイダ（`ExplorerViewModel` / `RunViewModel` / `AdhocRunViewModel` / `explorerItemSelectionProvider`）を `invalidate` し、ターミナルタブなら `ActiveSessions` から `unregister` する。

`closeTab` の最後の 1 タブ全消し時の扱い: 全スロットが空になったら、`bottom` 相当に新規エクスプローラタブ（$HOME）を 1 つ seed して「最低 1 タブは常にある」状態を保つ（空ウィンドウを作らない）。

### Decision 4: フォーカス追跡でサイドバー操作の遷移先を決める

サイドバー（場所 / お気に入り / 「現在のディレクトリを登録」）はこれまでシングルトンの `ExplorerViewModel` を操作していた。複数エクスプローラタブがあると遷移先が曖昧になるため、`focusedTabProvider`（最後にフォーカスしたタブ id）と、その派生で `lastFocusedExplorerTabId`（最後にフォーカスしたエクスプローラ種別タブ id）を保持する。

- 場所 / お気に入りクリック・「現在のディレクトリを登録」→ `lastFocusedExplorerTabId` のエクスプローラに対して `navigateTo`
- エクスプローラタブが 1 つも無い場合 → `topLeft` に新規エクスプローラタブを作って遷移
- フォーカス更新は各ペイン body の最上位に `Focus` / タップ検出を置いて `workspaceProvider` 経由で記録する

### Decision 5: ランチャー / Skill 起動は bottom ペインへターミナルタブ追加

`launchLauncherEntry` は現状 `explorerSelectionProvider` を書き換えて本体をセッションに切替えていた。新方式では `bottom` スロットに `TerminalTab` を `addTab` してアクティブ化する。`bottom` スロットが空（崩れている）なら再生成する。連番付き ad-hoc 起動ロジック（`generateUniqueDisplayName`）はそのまま流用する。「実行中」タイルのクリックは、該当セッションのタブが存在すればフォーカス、無ければ `bottom` に再作成する。

### Decision 6: 永続化は専用 `workspace.json`、ターミナルは再 spawn

`WorkspaceLayout` を `ExplorerSettings`（`repo_explorer_settings.json`）とは分離し、新規 `workspace.json` に保存する（責務分離・スキーマ肥大回避）。`AppPaths` に保存先を追加し、DTO + Repository + `AsyncNotifier` を立てる。

- 保存トリガ: タブ開閉 / アクティブ変更 / エクスプローラの `navigateTo` / スプリッタ比率変更
- エクスプローラタブ: カレントパスを保存し、起動時はそのパスで復元
- ターミナルタブ: 作業ディレクトリ + `LauncherAction`（`type` 含む）+ `displayName` を保存。PTY はプロセス跨ぎで復元不可のため、起動時に同じ args で**再 spawn**する（出力履歴は引き継がない）
- `workspace.json` が無い / 壊れている / 全スロット空 → 既定 3 ペインを seed
- `navigateTo` 起点の保存は、`ExplorerViewModel` が `workspaceProvider.notifier.updateTabPath(tabId, path)` を呼んで反映する

### Decision 7: スプリッタは自前実装、DnD は Flutter 標準

スプリッタ（リサイズ可能な分割線）は `LayoutBuilder` + `GestureDetector`（ドラッグでハンドルを動かし比率を更新）で自前実装する。専用パッケージは導入しない。タブ DnD は Flutter 標準 `Draggable<WorkspaceTab>` / `DragTarget`。タブストリップ全体を `DragTarget` にし、ドロップ x 座標から挿入 index を算出、ドロップ位置インジケータを描く。`moveTab` 1 本に集約することでストリップ内並べ替えとペイン間移動を同一経路で扱う。

## Risks / Trade-offs

- **`explorerSelectionProvider` 廃止の波及範囲が広い** → `explorer_page` / `explorer_sidebar` / `explorer_node_tile` / `explorer_path_bar` / `launcher_actions` / `session_view` / `run_view_model` / `adhoc_run_view_model` の `onClosed` 経路を最初に参照グラフ化し、Phase A で一括移行する。移行中の中間状態でビルドが通らない期間が出るため、フェーズ内で閉じる
- **family 本体を nested ProviderScope に置く誤り** → 状態が scope unmount で消える。Decision 2 の注意点をコードコメントと architecture.md に明記する
- **タブ移動直後の activeIndex 不整合** → `moveTab` / `closeTab` 後に activeIndex を範囲内へクランプし、移動したタブを追従アクティブにするか否かを `moveTab` の仕様として固定する（移動したタブを移動先でアクティブにする）
- **ターミナル再 spawn でユーザーが「履歴が消えた」と感じる** → 既定の素のシェルは再 spawn で十分。`RunCommandAction` の one-shot 系は再実行になる旨を受け入れ仕様に明記。出力履歴の永続化は Non-Goal
- **マルチウィンドウで `workspace.json` を複数プロセスが書く** → last-write-wins で許容（ADR に明記）。各ウィンドウは起動時に 1 回読み、以後は自プロセスのレイアウトを書き戻すだけ
- **3 分割で各ターミナルの表示領域が小さくなる** → `xterm` の `TerminalView` は領域に追従リサイズするため機能上の問題はない。スプリッタで調整可能
- **`WindowCloseGuard` が複数ターミナルタブを跨いだ終了確認** → `ActiveSessions` は既に全セッションを一元管理しているため、タブ数に依存せず既存ロジックで動く。Phase C で回帰確認する
