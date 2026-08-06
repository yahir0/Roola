# ADR-0067: git worktree をファイラーの語彙で統合する

- **Status**: Accepted
- **Date**: 2026-06-12

> 検討の経緯は `docs/notes/2026-06-11-ai-era-concept-review.md`（第 2 優先の 3）と
> OpenSpec change `add-git-worktree-integration` を参照。

## Context

並列エージェント時代の作業単位は「作業 1 件 = ブランチ 1 本 = ディレクトリ 1 個」で、
その標準作法が git worktree。Claude Code 公式デスクトップ等の既存ツールは
「セッション一覧」を起点に worktree を隠れた実装詳細として扱うのに対し、Roola の
差別化軸は「ディレクトリ／ファイルを起点」とするワークフローにある。worktree を
ファイラーの語彙（タイル・右クリック・フォルダ）で直接扱えるようにすることが、
この軸を体現する中核機能になる。

技術レビュー（notes）で実現可能性「高」を確認済み: `GitRepository` interface +
`ProcessGitRepository`（git CLI / `Process.run`）への worktree サブコマンド追加は
既存構造の自然な延長で、Windows も同一コードパスで動く。

## Decision

1. **作成の起点はエクスプローラのタイル右クリック**「Worktree を切って開く…」
   （git リポジトリ配下のフォルダのみ表示）と、Git ビュー worktree セクションの
   「+」の 2 箇所とする。
2. **置き場所は兄弟ディレクトリ `../<repo>.worktrees/<branch-slug>/` 固定**。
   ブランチ名のスラッシュはハイフンに置換（slug 化）し、衝突時はサフィックスで回避。
   - 代替案 B（リポジトリ内 `.worktrees/`）: `.git/info/exclude` への追記で repo を
     汚さず実現できるが、**本体での `git clean -dfx` が worktree を全滅させる罠**
     （Flutter のビルド不調時にやりがち）と、Roola 自身の FSEvents 監視（ADR-0041）
     への除外実装が必要になる点で却下。
   - 代替案 C（アプリ管理領域 `~/.roola/worktrees/`）: 技術的には最も安全だが、
     worktree がファイラーから見えなくなり「ディレクトリ起点」の思想と正面衝突する。
     ユーザーの作業コード（未コミットの財産）がアプリ領域に住む原則違反、パスの
     人間工学の悪さもあり却下。これは「worktree をユーザーから隠したいセッション
     中心ツール」の正解であって Roola の正解ではない。
3. **ブランチ意味論は 3 形態すべて対応**: 新規ブランチ（`-b`・分岐元の既定は
   現在の HEAD）/ 既存ローカルブランチ / リモート追跡（`origin/x` →
   `--track -b x`）。チェックアウト済みブランチ（本体含む）は git が拒否するため、
   ダイアログのピッカー側で事前にグレーアウト + 理由表示する。
4. **作成後アクション**としてシェル / Claude を選択でき、worktree を作業
   ディレクトリにしたターミナルタブを隣ペインに開く（既存の `AdhocRunArgs` +
   `workspace.addTerminalTab()` 動線。新規機構なし）。
5. **一覧・状態は Git ビュー（ADR-0030）に worktree セクション**として表示する
   （ブランチ・dirty・ahead/behind・マージ済み・孤児。FSEvents 自動更新に乗る）。
   一覧の正本は `git worktree list --porcelain`、dirty / ahead/behind は worktree
   ごとの軽量 status（少数前提の逐次実行）。
6. **エクスプローラのタイルに worktree バッジ**（ブランチ名）を表示する。判定は
   git プロセスを起動せず、`.git` が**ファイル**であること → `gitdir:` ポインタ先の
   `HEAD` を読む FS アクセスのみ（`WorktreeScanner`。`SkillScanner` と同型）。
   detached HEAD は短縮ハッシュを表示する。
7. **掃除のライフサイクルを全部持つ**:
   - 削除: dirty なら警告し「変更ごと削除」（`--force`）を明示選択。
     「ブランチも削除」は既定 OFF のチェックボックス（未マージは `-D` 相当になる旨を警告）
   - マージ済み検出: 既定ブランチ（`origin/HEAD` → `main` → `master` で解決）への
     `git branch --merged` で判定し、「掃除」1 操作で worktree + ブランチ（`-d`）を削除
   - 孤児（Finder 等で直接削除）: `--porcelain` の `prunable` を検出して表示し、
     「整理」で `git worktree prune`。リポジトリ移動によるリンク切れには
     `git worktree repair` の導線を出す

## Why

- ファイラー主役（ADR-0014）・ディレクトリ起点の差別化軸が最も活きる機能。
  「タイルから worktree を切ってその場でエージェントを起動」は公式デスクトップの
  セッション起点 UI では再現できない動線
- worktree は clone 複製と違いオブジェクトを共有し（軽い・速い）、コミットが
  push なしで全 worktree から見える＝エージェント成果物の取り込みがローカルで完結する
- git CLI 経由のため Windows（ADR-0058）も追加実装なしで対称に動く

## Trade-offs

- **親ディレクトリに `<repo>.worktrees/` が増える**: リポジトリ 1 つにつき 1 フォルダの
  割り切り。置き場所の設定化は要望が出たら別 ADR で検討
- **`git branch --merged` は squash マージを検出できない**: GitHub の squash merge
  運用では「マージ済み」ラベルが付かないことがある。その場合は通常削除
  （未マージ警告つき）を使う
- **worktree 内のファイル編集だけでは Git ビューの一覧が自動更新されない**:
  FSEvents 監視はリポジトリルート配下のみで、兄弟ディレクトリの worktree は監視外。
  ただしコミット等の git 操作は共有 `.git` に書き込むため監視が発火する。
  dirty 状態の取りこぼしは手動 Refresh で回収できる
- **依存物（`node_modules` / `build/` 等）は worktree にコピーされない**: git の
  仕様どおり。セットアップは作成後に開くセッション内で行う運用とし、Roola は関与しない
- **リポジトリ移動で worktree リンクが切れる**: 絶対パス参照のため。`repair` 導線で吸収

## References

- ADR-0030（Git ビュー）/ ADR-0041（FSEvents 自動更新）/ ADR-0044（タイル右クリック）/
  ADR-0058（Windows 対応）
- OpenSpec change: `add-git-worktree-integration`（proposal / design / specs / tasks）
- 構想と技術レビュー: `docs/notes/2026-06-11-ai-era-concept-review.md`
