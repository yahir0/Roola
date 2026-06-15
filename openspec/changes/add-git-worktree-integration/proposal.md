# add-git-worktree-integration — Proposal

## Why

並列エージェント時代の作業単位は「作業 1 件 = ブランチ 1 本 = ディレクトリ 1 個」であり、
その標準作法が git worktree。現状の Roola では worktree の作成・管理はターミナルでの
手作業で、ファイラー（タイル・右クリック）の語彙で扱えない。公式 Claude Code デスクトップが
「セッション一覧を起点」とするのに対し、Roola の差別化軸は「ディレクトリ／ファイルを起点」
（docs/notes/2026-06-11-ai-era-concept-review.md）— タイルから worktree を切って
その場でエージェントを起動できることは、この軸を体現する中核機能になる。
技術レビューで実現可能性「高」（git CLI 経由・既存 `GitRepository` 構造の自然な延長・
Windows もそのまま動く）を確認済み。

## What Changes

段階分けせず完全形を 1 change で実装する（作成 → 起動 → 一覧 → 掃除の一気通貫）。

- **作成**: エクスプローラのタイル右クリック（git リポジトリのフォルダ）に
  「Worktree を切って開く…」を追加。ダイアログで:
  - 新規ブランチ（ブランチ名 + 分岐元、既定は現在の HEAD）
  - 既存ブランチ（ローカル一覧から選択。チェックアウト済みはグレーアウト + 理由表示）
  - リモートブランチ（`origin/x` を選ぶとトラッキングするローカルブランチを作成して展開）
  - 置き場所は兄弟ディレクトリ `../<repo>.worktrees/<branch>/` 固定
- **起動**: 作成後アクションとしてシェル / Claude を選択でき、隣ペインのターミナルタブ
  として起動する（既存の ad-hoc セッション動線に乗せる）
- **一覧・状態**: Git ビュー（ADR-0030）に worktree セクションを追加
  （パス・ブランチ・dirty・ahead/behind、「ここで開く」「削除」。FSEvents 自動更新に乗せる）
- **タイルバッジ**: エクスプローラ上で worktree ディレクトリのタイルにブランチ名バッジを
  表示する（`.git` がファイルかどうかの安価な FS 判定。git コマンド不要）
- **掃除**:
  - 削除: dirty なら警告（git 標準の拒否に乗る）、ブランチも一緒に消すかを選択
  - マージ済み検出 → 「worktree + ブランチをワンクリック掃除」
  - Finder 等で直接消された孤児の検出と prune、リポジトリ移動後の repair
- **Git 層**: `GitRepository` interface（実装は `ProcessGitRepository`・23 メソッド）に
  worktree add / list / remove / prune 等を追加
- 新規 ADR を 1 件追加（worktree 統合の設計判断: 置き場所の選定経緯・ブランチ意味論・
  掃除のライフサイクル）

## Capabilities

### New Capabilities

- `git-worktree`: worktree の作成（新規 / 既存 / リモート追跡ブランチ）・作成後の
  セッション起動・Git ビューでの一覧と状態表示・エクスプローラのタイルバッジ・
  削除とマージ済み掃除・孤児の prune / repair

### Modified Capabilities

（なし — 既存 capability（`git-integration` / `repo-explorer` 等）の既存要件は変更せず、
すべて追加要件として `git-worktree` に閉じる）

## Impact

- **Git 層**: `lib/data/git/git_repository.dart`（interface にメソッド追加）、
  `lib/data/git/process_git_repository.dart`（`git worktree` サブコマンド実装）、
  `test/data/git/process_git_repository_test.dart`（実リポジトリ方式のテスト追加）
- **Git ビュー**: `lib/ui/git/git_view_model.dart`（`GitViewState` に worktrees 追加・
  `_load()` 拡張）、`lib/ui/git/git_tab.dart`（worktree セクション UI）
- **エクスプローラ**: `lib/ui/explorer/explorer_node_tile.dart` /
  `explorer_commands.dart`（右クリックメニュー項目 + アクション）、
  `lib/data/repo_explorer/explorer_directory_loader.dart` 周辺（worktree 判定の付与）、
  タイルへのバッジ描画
- **セッション起動**: 既存の `AdhocRunArgs` + `workspace.addTerminalTab()` を利用（変更なし
  か最小限）
- **l10n**: ダイアログ・メニュー・確認文言の en / ja 追加
- **ドキュメント**: 新規 ADR 1 件、CLAUDE.md の ADR リスト追記、README の機能説明追加、
  notes のロードマップ更新
- **依存関係**: 新規パッケージなし（git CLI 経由）。Windows は同一コードパスで動作する想定
  （パス長制限のみ注意）
