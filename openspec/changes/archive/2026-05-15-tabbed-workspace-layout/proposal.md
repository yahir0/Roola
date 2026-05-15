## Why

現在の `/explorer` は単一ペインで、`explorerSelectionProvider` によりディレクトリ一覧かセッション 1 件のどちらかを排他表示するだけ。複数ディレクトリの並行参照や、ファイル操作をしながらのターミナル併用ができず、ターミナルランチャーアプリとしての作業効率が頭打ちになっている。上 2 + 下 1 の 3 画面タブ式ワークスペースにすることで、2 つのエクスプローラとターミナルを同時に扱えるようにする。

## What Changes

- **BREAKING**: `/explorer` を単一ペインから 3 ペインスロット（`topLeft` / `topRight` / `bottom`）× タブ群のレイアウトに刷新する
- **BREAKING**: `explorerSelectionProvider`（directory / entrySession / adhocSession の排他切替）を廃止し、表示単位を「タブ」にする
- 各ペインスロットはタブ群 + `activeIndex` を持つ。タブは種別固定（エクスプローラ or ターミナル）
- 初回起動 / 永続データ無し時に既定 3 ペインを seed: `topLeft`=エクスプローラ($HOME)、`topRight`=エクスプローラ($HOME)、`bottom`=ターミナル(素のシェル / `OpenHereAction` @ $HOME)
- スプリッタ 2 本（上段左右・上下）をドラッグでリサイズし、比率を永続化
- 崩し再フロー: タブ 0 のスロットは消滅。コンテンツを持つスロットが 1 つだけになったら従来どおり単一ペイン全画面で描画。下スロットを空にすると上 2 ペインの左右 2 分割になる
- 各ペインのタブストリップの「+」からエクスプローラ / ターミナルを種別選択で追加可能（上ペインにターミナル・下ペインにエクスプローラも許可）
- タブ DnD: ストリップ内並べ替え + ペイン間移動。`tabId` キーの family プロバイダにより移動しても履歴 / PTY は無損失
- サイドバーのランチャー / Skill 起動は `bottom` ペインに新規ターミナルタブとして開く
- `ExplorerViewModel` / `explorerItemSelectionProvider` をシングルトンから `family(tabId)` 化
- `MacosWindowAppBar` から戻る / 進むを撤去し、エクスプローラタブのペインヘッダへ移設
- `WorkspaceLayout` を新規 `workspace.json` に永続化。エクスプローラタブはパス復元、ターミナルタブは作業ディレクトリ + action を保存し起動時に再 spawn（PTY はプロセス跨ぎ復元不可）

## Capabilities

### New Capabilities
- `workspace-layout`: 3 ペインスロット構成、スロット崩し再フロー、スプリッタとリサイズ、初回 seed、`workspace.json` への永続化と起動時復元
- `pane-tabs`: タブのライフサイクル（生成 / アクティブ化 / 閉じる）、種別（エクスプローラ / ターミナル）、タブ DnD（ストリップ内並べ替え・ペイン間移動）
- `explorer-tab`: ペインごとに独立したエクスプローラ（`family(tabId)` 化した履歴・カレントパス・アイテム選択）、ペインヘッダ（戻る / 進む / パスバー）、サイドバー操作の遷移先決定
- `terminal-tab`: ターミナルタブの描画とライフサイクル、$HOME 固定の素のシェル既定、ランチャー / Skill 起動の `bottom` ペインへのタブ追加、起動時の再 spawn

### Modified Capabilities
<!-- openspec/specs/ への spec promote は運用していない（運用方針はこの artifact の context 参照）。
     既存 change の spec はすべて当 change 配下に新規作成するため、ここは空。 -->

## Impact

- **ルーティング**: `lib/app/router.dart` の `ExplorerRoute` が描画する画面を差し替え
- **状態管理（新規）**: `workspaceProvider`、`WorkspaceTab` / `PaneSlot` / `WorkspaceLayout` モデル、`currentTabIdProvider`（ProviderScope override 用）、`focusedTabProvider` / `lastFocusedExplorerTabId`
- **状態管理（改変）**: `ExplorerViewModel` / `explorerItemSelectionProvider` の family 化、`explorerSelectionProvider` 廃止
- **UI**: `ExplorerPage` → `WorkspacePage` 化、`PaneWidget` / タブストリップ新設、`MacosWindowAppBar`・`ExplorerSidebar`・`explorer_path_bar`・`explorer_node_tile`・`launcher_actions`・`session_view`・`MouseNavigationListener` の改修
- **永続化（新規）**: `workspace.json`、`AppPaths` への保存先追加、DTO + Repository
- **セッション**: `launchLauncherEntry` / `RunViewModel` / `AdhocRunViewModel` の `onClosed` 経路、`WindowCloseGuard` の複数ターミナルタブ下での挙動
- **ADR**: 3 件追加（3 画面タブ式ワークスペース採用 / family による per-tab 状態 + scoped tabId / レイアウト永続化とターミナル再 spawn）。マルチウィンドウ時の `workspace.json` 競合は last-write-wins で許容
- **依存ライブラリ**: 新規追加なし（DnD は Flutter 標準 `Draggable` / `DragTarget`、スプリッタは自前実装）
