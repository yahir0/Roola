## 1. 準備・ドキュメント

- [x] 1.1 Git アクセスは新規依存を増やさず `dart:io` の `Process` を使う（`process_run` 不採用、ADR-0030 / design D1）
- [x] 1.2 ADR-0030「Git ビューをワークスペースタブとして追加」を `docs/adr/` に作成（CLI ラッパー採用理由を含む）
- [x] 1.3 `docs/adr/README.md` と `CLAUDE.md` の ADR 一覧に ADR-0030 を追記
- [x] 1.4 `docs/architecture.md` のディレクトリ構成に `data/git/` / `ui/git/` を追記

## 2. data 層: Git モデル

- [x] 2.1 `data/git/git_status.dart` に `GitStatus` / `GitFileChange`（パス・変更種別 M/A/D/R/?・staged/unstaged）を Freezed で定義
- [x] 2.2 `data/git/git_commit.dart` に `GitCommit`（sha・親 sha・メッセージ・作者・日時・ref ラベル）を Freezed で定義
- [x] 2.3 `data/git/git_graph_row.dart` に `GitGraphRow`（コミット + lane index・着色・エッジ情報）を Freezed で定義
- [x] 2.4 `data/git/git_branch.dart` に `GitBranch`（名前・ローカル/リモート・current・upstream・ahead/behind）を Freezed で定義
- [x] 2.5 `data/git/git_stash_entry.dart` に `GitStashEntry`（index・メッセージ）を Freezed で定義
- [x] 2.6 `build_runner` を実行し Freezed 生成物を出力・commit

## 3. data 層: GitRepository

- [x] 3.1 `data/git/git_repository.dart` に `GitRepository` interface を定義（status 取得・stage/unstage・commit・fetch/pull/push・ブランチ操作・log 取得・diff 取得・stash 操作・リポジトリルート解決・git 存在確認）
- [x] 3.2 `data/git/process_git_repository.dart` で `git` CLI を `dart:io` の `Process` で実行する実装。`LC_ALL=C` 固定・機械可読オプション（`--porcelain=v1 -z`・`--pretty=format`・`for-each-ref`）を使用
- [x] 3.3 `process_git_repository.dart` に履歴ページング（初期 200 件・続き取得）を実装
- [x] 3.4 ViewModel 側で使うグラフレーン割り当て純粋関数を実装（`data/git/git_graph_layout.dart` の `buildGitGraph`）
- [x] 3.5 `core/exceptions/app_exception.dart` に Git 操作失敗用の例外型を追加（`gitNotFound` / `gitCommandFailure`）

## 4. data 層: WorkspaceTab 拡張

- [x] 4.1 `data/workspace/workspace_tab.dart` に `WorkspaceTab.git({id, repoRoot})` を追加
- [x] 4.2 `data/workspace/workspace_layout_dto.dart` に `type: "git"` + `repoRoot` のシリアライズ/デシリアライズを追加（未知種別を無視できる後方互換実装）
- [x] 4.3 `build_runner` を実行し workspace 系の生成物を更新・commit
- [x] 4.4 `workspace_repository_impl` 経由の保存・復元で `GitTab` が往復することを確認（テスト 8.4）

## 5. ui 層: GitViewModel

- [x] 5.1 `ui/git/git_view_state.dart` に `GitViewState`（status・graph rows・branches・選択コミット・stash 一覧・runningOperation）を Freezed で定義
- [x] 5.2 `ui/git/git_view_model.dart` に `GitViewModel`（`AsyncNotifier.family(tabId)`）を実装。初回ロードで status/log/branches をまとめて取得
- [x] 5.3 stage/unstage/commit アクションを実装（操作後は再取得）
- [x] 5.4 fetch/pull/push アクションを実装（`runningOperation` で直列化・多重実行防止）
- [x] 5.5 ブランチ切替/作成/マージ/削除アクションを実装
- [x] 5.6 履歴ページング・コミット選択・stash 退避/適用/破棄・discard アクションを実装
- [x] 5.7 `git` 不在検出と「git コマンドが見つかりません」状態への遷移を実装

## 6. ui 層: GitTab View

- [x] 6.1 `ui/git/git_tab.dart` に 3 段構成（ツールバー / Changes / History）の `GitTab` View を実装。狭幅時のセグメント切替を含む
- [x] 6.2 `ui/git/git_toolbar.dart`: ブランチセレクタ・ahead/behind 表示・Fetch/Pull/Push・オーバーフローメニュー
- [x] 6.3 `ui/git/git_changes_section.dart`: Staged/Unstaged 一覧・stage/unstage/discard 操作・コミットメッセージ欄・Commit ボタン
- [x] 6.4 `ui/git/git_history_section.dart` + `ui/git/git_graph_painter.dart`: コミットグラフ（`CustomPainter` でレーン列描画）・コミット詳細
- [x] 6.5 `ui/git/git_branch_menu.dart`: ブランチ一覧ダイアログ（切替/作成/マージ/削除、ローカル/リモート分類、フィルタ）
- [x] 6.6 `ui/git/git_diff_view.dart`: ファイル単位 diff のダイアログ表示（unified/split 切替・行着色）※当初の「隣ペイン表示」はダイアログに変更（ADR-0030 Trade-offs）
- [x] 6.7 破壊的操作（複数 discard・ブランチ削除・stash drop・force push）の確認ダイアログを実装（`ui/git/git_dialogs.dart`）
- [x] 6.8 同期失敗時の通知バー + ターミナル誘導導線を実装

## 7. ワークスペース統合

- [x] 7.1 `workspaceProvider` に `openGitTab` を追加（repoRoot 一致での既存タブ集約を含む）
- [x] 7.2 `ui/workspace/pane_tab_strip.dart` に `GitTab` のタブ表示（Git アイコン + リポジトリ名）を追加
- [x] 7.3 `pane_widget` で `GitTab` を `GitTabBody` にディスパッチ。`focusedTabProvider` に `focusGit` を追加
- [x] 7.4 エクスプローラのツールバーに「Git ビューを開く」ボタンを追加。Git 管理下判定（`gitRepositoryRootProvider` が family(パス) 単位でキャッシュ）で活性/非活性を切替

## 8. テスト

- [x] 8.1 `ProcessGitRepository` のテスト: 一時ディレクトリに実リポジトリを作り status/commit/log/branch/diff/stash の実 CLI 経路を検証
- [x] 8.2 グラフレーン割り当て純粋関数のユニットテスト（直線・分岐・マージのケース）
- [x] 8.3 `GitViewModel` のテスト: `GitRepository` を Mocktail でモックし `ProviderContainer` でアクションを検証
- [x] 8.4 `workspace_layout_dto` の `GitTab` シリアライズ往復・旧スキーマ後方互換のテスト
- [x] 8.5 `GitTab` View のウィジェットテスト: モック GitRepository でゴールデンパス + git 不在 + クリーン状態を検証

## 9. 仕上げ

- [x] 9.1 `flutter analyze` / `dart format` を通す
- [x] 9.2 全テストを実行しグリーンを確認（169 件 pass）
- [x] 9.3 実機（macOS）で GitTab の動作を確認（オーバーフロー / Changes 一覧の表示密度をユーザーフィードバックで修正済み）
- [x] 9.4 Conventional Commits（日本語サマリ可）でコミット
