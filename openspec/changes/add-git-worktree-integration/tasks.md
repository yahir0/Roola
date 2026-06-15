# add-git-worktree-integration — Tasks

## 1. Git 層（data/git）

- [x] 1.1 `GitWorktree` モデル（Freezed: path / branch / head / isMain / isPrunable / isLocked）と `WorktreeStatusSummary`（dirty / ahead / behind）を追加する
- [x] 1.2 `GitRepository` interface に `listWorktrees` / `addWorktree`（新規 `-b` / 既存 / `--track -b`） / `removeWorktree({force})` / `pruneWorktrees` / `repairWorktrees` / `defaultBranch` / `mergedBranches` / `worktreeStatusSummary` を追加し、`ProcessGitRepository` で実装する（`git worktree list --porcelain` のパース含む）
- [x] 1.3 ブランチ名 → フォルダ名の slug 化（スラッシュ→ハイフン・衝突時サフィックス）と兄弟ディレクトリ `../<repo>.worktrees/` のパス解決ヘルパーを追加する
- [x] 1.4 `process_git_repository_test.dart` に実リポジトリ方式のテストを追加する（作成 3 形態・チェックアウト済み衝突・一覧 porcelain パース・削除 / force・prune・mergedBranches・defaultBranch フォールバック・slug 化）

## 2. 作成ダイアログとセッション起動

- [x] 2.1 `worktree_create_dialog.dart` を作成する（Polaris 準拠。新規 / 既存モード切替・ブランチ名入力・分岐元・ブランチピッカー（チェックアウト済みグレーアウト + 理由、リモート追跡対応）・作成後アクション選択）
- [x] 2.2 作成実行 → 成否のフィードバック → 作成後アクション（シェル / Claude）を `AdhocRunArgs` + `workspace.addTerminalTab()` で隣ペインに起動する
- [x] 2.3 エクスプローラ右クリックメニューに `_ActionCreateWorktree`（「Worktree を切って開く…」）を追加する（`gitRepositoryRoot` provider で repo のときのみ表示。ADR-0044 のカレントフォルダメニューにも追加）

## 3. Git ビューの worktree セクション

- [x] 3.1 `GitViewState` に `worktrees` を追加し、`GitViewModel._load()` で一覧 + 各 worktree の status summary + マージ済み判定を読み込む（FSEvents 自動更新に乗せる）
- [x] 3.2 worktree セクション UI を `git_tab.dart` に追加する（本体の区別表示・ブランチ・dirty・ahead/behind・マージ済みラベル・prunable 表示、行アクション: ここで開く / 削除 / 掃除、ヘッダの「+」で作成ダイアログ）
- [x] 3.3 削除ダイアログ（dirty 警告・「変更ごと削除」・「ブランチも削除」チェックボックス）とマージ済みワンクリック掃除・「整理」（prune）・repair 導線を実装する

## 4. エクスプローラのタイルバッジ

- [x] 4.1 `WorktreeScanner`（`.git` ファイル判定 → `gitdir:` → `HEAD` 読みでブランチ名解決・git プロセス不使用・detached は短縮ハッシュ）を追加し、`ExplorerDirectoryNode` に `worktreeBranch` を持たせる
- [x] 4.2 タイルにブランチ名バッジを Polaris 準拠で描画する（compact / comfortable 両密度で確認）
- [x] 4.3 `WorktreeScanner` のユニットテストを追加する（worktree / 通常 repo / 非 repo / detached / 壊れた gitdir ポインタ）

## 5. l10n・検証

- [x] 5.1 メニュー・ダイアログ・警告・ラベルの l10n キーを en / ja に追加し `flutter gen-l10n` を実行する
- [x] 5.2 `flutter analyze` クリーン・`flutter test` 全件グリーン・`flutter build macos --debug` 成功を確認する
- [x] 5.3 実機（macOS）で手動確認: 右クリック → 新規 / 既存 / リモートで切る → Claude 起動 / Git ビューの一覧・状態・自動更新 / タイルバッジ / dirty 警告つき削除・ブランチ併せ削除 / マージ済み掃除 / Finder 直接削除 → prune

## 6. ドキュメント

- [x] 6.1 ADR-0067（git worktree 統合）を起草する（置き場所 A/B/C の比較と却下理由・ブランチ意味論・掃除ライフサイクル・タイルバッジ判定方式）
- [x] 6.2 CLAUDE.md の ADR リストに ADR-0067 を追記する
- [x] 6.3 README に worktree 機能の説明を追加する（Windows のパス長注意をトラブルシューティングへ）
- [x] 6.4 `docs/notes/2026-06-11-ai-era-concept-review.md` の引き継ぎチェックリスト（worktree 統合）を完了に更新する
