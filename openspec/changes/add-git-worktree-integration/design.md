# add-git-worktree-integration — Design

## Context

探索（2026-06-12）で確定済みの判断と、コード調査で確認済みの拡張ポイントを前提とする。

- 既存 Git 層: `GitRepository`（abstract interface・`lib/data/git/git_repository.dart`）+
  `ProcessGitRepository`（`Process.run` で git CLI 実行・`LC_ALL=C`・
  `repositoryRoot()` によるルート解決）。テストは一時ディレクトリに実リポジトリを
  作って実 CLI 経路を検証する方式
- Git ビュー: `GitViewModel`（`family(tabId)` + keepAlive）が `GitViewState`
  （status / branches / graph / stashes）を保持し、`DirectoryWatcher` で自動更新
  （ADR-0041。300ms デバウンス・自プロセス git 実行中はスキップ）
- エクスプローラ: `ExplorerDirectoryLoader` は直下をフィルタなしで全列挙（ドット
  フォルダも見える）。タイルごとの追加情報は `SkillScanner` と同じ「loader で
  ディレクトリ単位の安価なスキャンを付与する」パターンが既にある。
  右クリックメニューは `ExplorerNodeAction`（sealed・14 種）+
  `showExplorerContextMenu`。git リポジトリ判定は `gitRepositoryRoot` provider で
  キャッシュ済み
- セッション起動: `AdhocRunArgs` + `workspace.addTerminalTab(slotId, args)` で
  任意ディレクトリのシェル / Claude タブを開ける（変更不要）

## Goals / Non-Goals

**Goals:**

- 「タイル右クリック → worktree を切る → 隣ペインでエージェント起動」の一気通貫
- worktree の一覧・状態（dirty / ahead/behind）の常時可視化と、掃除（削除・
  マージ済みワンクリック掃除・孤児 prune / repair）までの完全なライフサイクル管理
- macOS / Windows 同一コードパス（git CLI 経由）

**Non-Goals:**

- worktree 置き場所の設定化（兄弟ディレクトリ固定。要望が出たら別 change）
- worktree 内セッションの状態検知・ダッシュボード（OSC 133 の別テーマ）
- マージ操作そのものの提供（既存 Git ビューの機能。本 change は「マージ済みの掃除」のみ）
- `<repo>.worktrees/` コンテナフォルダの特別な描画（通常フォルダとして表示）

## Decisions

### D1. 置き場所は兄弟ディレクトリ `../<repo>.worktrees/<branch-slug>/` 固定

- 代替案 B（リポジトリ内 `.worktrees/`）: ignore 対応（`.git/info/exclude`）で repo を
  汚さず実現可能だが、**`git clean -dfx` で worktree が全滅する罠**（Flutter で
  ビルド不調時にやりがち）と、Roola 自身の Git ビュー監視に除外実装が要る点で却下
- 代替案 C（アプリ管理領域）: 技術的には最も安全だが、worktree がファイラーから
  見えなくなり「ディレクトリ起点」という Roola の差別化軸と正面衝突。ユーザーの
  作業コードがアプリ領域に住む原則違反・パスの人間工学も悪い。却下
- ブランチ名 `feat/x` はフォルダ名 `feat-x` にスラッシュ変換（slug 化）。衝突時は
  サフィックス `-2` 等を付与
- 経緯の詳細は ADR-0067（本 change で起草）に記録する

### D2. ブランチ意味論は 3 形態すべて対応

1. **新規**: `git worktree add -b <name> <path> <base>`（base 既定 = 現在の HEAD）
2. **既存ローカル**: `git worktree add <path> <branch>`。チェックアウト済みブランチ
   （本体含む）は git が拒否するため、ダイアログ側で `git worktree list` の結果から
   事前にグレーアウト + 理由表示
3. **リモート追跡**: `origin/x` 選択時は `git worktree add --track -b x <path> origin/x`
   （ローカルブランチを作成してトラッキング）。fetch はダイアログ表示時には行わず、
   リモートブランチ一覧は fetch 済みの参照から出す（明示 fetch は Git ビューの既存機能）

### D3. worktree 一覧は `--porcelain` + worktree ごとの軽量 status

- 一覧の正本は `git worktree list --porcelain`（パス・HEAD・ブランチ・prunable / locked
  が機械可読で取れる）
- dirty 判定は worktree ごとに `git status --porcelain`（cwd = worktree パス）、
  ahead/behind は `git rev-list --left-right --count <branch>...<upstream>`。
  worktree 数は実用上少数（〜10）なので逐次実行で十分。`GitViewModel._load()` に組み込み、
  FSEvents 自動更新に乗せる
- 本体（main worktree）は一覧に含めるが「現在のリポジトリ」として区別表示し、
  削除操作を出さない

### D4. タイルバッジは git コマンドなしの FS 判定

- worktree 判定: `.git` が**ディレクトリではなくファイル**であること（2 つの FS stat）
- ブランチ名: `.git` ファイルの `gitdir:` ポインタ → その先の `HEAD`
  （`ref: refs/heads/<branch>`）を読む。**ファイル読み 2 回・git プロセス起動なし**
- `ExplorerDirectoryLoader` に `SkillScanner` と同型の `WorktreeScanner` を追加し、
  `ExplorerDirectoryNode` に `worktreeBranch: String?` を持たせる。バッジは
  タイル上にブランチ名を Polaris 準拠（トークン参照・ハードコード禁止）で表示
- detached HEAD の worktree は HEAD のコミット短縮ハッシュをバッジにする

### D5. 掃除のライフサイクル

- **削除**: `git worktree remove`（dirty なら git が拒否 → エラーメッセージを整形して
  警告ダイアログ・「変更ごと削除」を選んだ場合のみ `--force`）。削除ダイアログに
  「ブランチも削除する」チェックボックス（既定 OFF。マージ済みなら `-d`、未マージなら
  `-D` が要る旨を警告）
- **マージ済み検出**: リポジトリの既定ブランチ（`origin/HEAD` → 無ければ
  `main` / `master` の順でフォールバック）に対する `git branch --merged` で判定。
  Git ビューの worktree 行に「マージ済み」ラベルを出し、「掃除」ボタン 1 回で
  worktree remove + branch -d を実行
- **孤児 / 破損**: `git worktree list --porcelain` の `prunable` を検出して一覧に
  表示し、「整理」で `git worktree prune`。リポジトリ移動でリンク切れした場合は
  `git worktree repair` を提案する行を表示
- Roola 内の削除動線はゴミ箱でなく `git worktree remove` を使う（git の管理情報と
  整合させるため）。エクスプローラの通常のゴミ箱削除を妨げない（孤児化は prune で回収）

### D6. 作成ダイアログと起動アクション

- 起点は 2 つ: タイル右クリック「Worktree を切って開く…」（repo 判定は
  `gitRepositoryRoot` provider）と、Git ビュー worktree セクションの「+」ボタン
- ダイアログ（Polaris 準拠・`lib/ui/git/worktree_create_dialog.dart`）:
  モード切替（新規 / 既存）・ブランチ名 or ブランチピッカー・分岐元・
  作成後アクション（何もしない / シェル / Claude）
- 起動は `AdhocRunArgs(workingDirectory: <worktreePath>, action: OpenHereAction or
  ClaudeSkillAction)` + `workspace.addTerminalTab()`。新規コードは引数を組むだけ

### D7. Git 層の追加メソッド

`GitRepository` interface に追加（実装は `ProcessGitRepository`）:

- `listWorktrees(repoRoot)` → `List<GitWorktree>`（path / branch / head /
  isMain / isPrunable / isLocked）
- `addWorktree(repoRoot, path, {newBranch?, base?, existingBranch?, trackRemote?})`
- `removeWorktree(repoRoot, path, {force})`
- `pruneWorktrees(repoRoot)` / `repairWorktrees(repoRoot)`
- `mergedBranches(repoRoot, into)` / `defaultBranch(repoRoot)`
- `worktreeStatusSummary(path)` → dirty / ahead / behind（既存 `status` の軽量版）

モデル `GitWorktree` は Freezed。DTO 分離は不要（永続化しない・表示専用）。

### D8. 新規 ADR-0067 を起草する

置き場所の選定経緯（A/B/C 比較と却下理由）・ブランチ意味論・掃除のライフサイクル・
タイルバッジの判定方式を ADR-0067 として記録する（CLAUDE.md の ADR リストにも追記）。

## Risks / Trade-offs

- [兄弟ディレクトリが親を汚す] → リポジトリ 1 つにつき `<repo>.worktrees/` 1 個に
  集約される割り切り。探索で本体オーナーが許容済み
- [worktree ごとの status 実行が一覧更新を遅くする] → worktree 数は少数前提。
  逐次 `Process.run` でも体感影響は小さい見込み。問題が出たら並列化・キャッシュで対処
- [依存物（node_modules / build 等）は worktree にコピーされない] → git の仕様どおり。
  作成後に起動するシェル / Claude セッション内でユーザー（またはエージェント）が
  セットアップする運用とし、Roola は関与しない
- [`git branch --merged` は squash マージを検出できない] → GitHub の squash merge 運用
  ではマージ済みラベルが付かない場合がある。v1 はこの限界を許容し、その場合は
  通常削除（未マージ警告つき）を使ってもらう
- [Windows のパス長制限] → 兄弟ディレクトリ + slug でパスは深くならない。
  `core.longpaths` の案内はトラブルシューティングに記載
- [タイルバッジの FS 読みがリスト描画に乗る] → loader は既に SkillScanner で
  ディレクトリごとのスキャンをしており、同型・同コスト帯（stat + 小ファイル read ×2）。
  ボトルネック化したら loader 側のキャッシュで対処

## Migration Plan

追加のみで破壊的変更なし。単一 PR。ロールバックは revert で完結
（永続データ・スキーマ変更なし）。

## Open Questions

（なし — 主要判断は探索セッションで確定済み。実装中の微調整は本 design の範囲内で行う）
