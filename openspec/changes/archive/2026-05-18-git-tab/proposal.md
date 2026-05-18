## Why

Roola はエクスプローラ中心の汎用ターミナルランチャーで、開発者は日常的に Git リポジトリ配下のディレクトリを閲覧・操作している。しかし現状リポジトリの状態確認・コミット・同期はすべて外部の Git クライアントやターミナルに切り替える必要がある。VSCode の Git Graph 拡張と SCM パネルに相当する Git ビューをワークスペース内に持つことで、ファイル閲覧から履歴確認・コミット・同期までを 1 アプリ内で完結できる。

## What Changes

- ワークスペースに **新しいタブ種別 `GitTab`** を追加する。`ExplorerTab` / `TerminalTab` と並ぶ第 3 のタブ種別で、任意ペインに配置・DnD 移動でき、per-tab 状態を `family(tabId)` で持つ（ADR-0026 / 0027 に準拠）
- エクスプローラタブのカレントパスが Git リポジトリ配下のとき、ツールバー / コンテキストメニューに「Git ビューを開く」を出し、隣ペインに `GitTab` を生成する
- `GitTab` 内に 3 段構成 UI を持つ:
  - **ツールバー**: ブランチセレクタ、ahead/behind 表示、Fetch / Pull / Push ボタン、オーバーフローメニュー
  - **Changes セクション**: Staged / Unstaged のファイル一覧、stage / unstage / discard、コミットメッセージ欄と Commit ボタン
  - **History セクション**: コミットグラフ（レーン描画）、コミット詳細・変更ファイル一覧
- **ブランチ操作**: 切替 / 作成 / マージ / 削除をブランチセレクタから実行
- **diff ビューア**: ファイル単位の差分を行単位着色で表示（hunk 単位 stage は対象外）
- **stash / discard**: 変更の退避・適用・破棄
- Git 操作は **`git` CLI を `process_run` でラップ** して実行する。libgit2 等のネイティブ依存は使わない（ADR-0005 の自己完結方針と整合）
- 長時間・対話的になりうる操作（Pull / Push の認証等）の詳細出力はターミナルタブにストリームできる導線を持つ（ADR-0002 のターミナル中心方針と整合）
- `workspace.json` のスキーマに `GitTab` を追加し、起動時に復元する（**BREAKING**: `workspace_layout_dto` の tab 種別 union に新値が増えるため、旧スキーマ読み込み時の migration が必要）

## Capabilities

### New Capabilities

- `git-integration`: Git リポジトリの状態取得・ステージング・コミット・同期（fetch/pull/push）・ブランチ操作・履歴グラフ・diff・stash を提供する通信層（`data/git/`）と、それを操作する `GitTab` の UI / ViewModel（`ui/git/`）

### Modified Capabilities

- `tabbed-workspace-layout`: ワークスペースのタブ種別 union に `GitTab` を追加する。タブの永続化・復元・ペイン間移動の対象に `GitTab` を含める

## Impact

- **新規コード**: `data/git/`（`GitRepository` interface + `ProcessGitRepository` 実装、`GitStatus` / `GitFileChange` / `GitCommit` / `GitGraphRow` / `GitBranch` / `GitStashEntry` 等の Freezed モデル）、`ui/git/`（`GitTab` View、`GitViewModel` = `AsyncNotifier.family(tabId)`、グラフ描画 `CustomPainter`、diff ビュー、セクション分割 widget）
- **既存コード変更**: `data/workspace/workspace_tab.dart`（`WorkspaceTab.git` 追加）、`data/workspace/workspace_layout_dto.dart`（DTO 拡張 + migration）、`ui/workspace/pane_tab_strip.dart`（GitTab のタブ表示）、エクスプローラの「Git ビューを開く」導線
- **依存追加**: `process_run`（または同等のプロセス実行ライブラリ）。`git` CLI が PATH 上に存在することを前提とする
- **永続化**: `workspace.json` のスキーマ変更（旧バージョン migration 必須）
- **ドキュメント**: ADR-0030「Git ビューをワークスペースタブとして追加」を追加
