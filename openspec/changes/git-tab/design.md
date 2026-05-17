## Context

Roola はエクスプローラ中心の汎用ターミナルランチャー（Flutter Desktop / macOS）。メイン画面 `/explorer` は 3 ペインスロット × タブ群のワークスペースで、タブ種別は `ExplorerTab` / `TerminalTab` の 2 種（ADR-0026）。per-tab 状態は `family(tabId)` でルートスコープに保持し（ADR-0027）、レイアウトは `workspace.json` に永続化される（ADR-0028）。

本 change はここに第 3 のタブ種別 `GitTab` を追加する。Git 操作のための通信層 `data/git/` は存在せず、新規に起こす。リポジトリは AI ツール非依存・自己完結を設計目標とする（ADR-0005）ため、Git アクセス手段の選定が設計上の主要論点になる。

## Goals / Non-Goals

**Goals:**

- ワークスペース内に Git ビュー（`GitTab`）を持ち、ファイル閲覧と Git 操作を 1 アプリで完結させる
- 履歴グラフ・ステージング/コミット・fetch/pull/push・ブランチ操作・diff・stash を提供する
- 既存のワークスペース機構（ペイン配置・DnD 移動・永続化・per-tab 状態）に `GitTab` を無改造に近い形で乗せる
- Git アクセスを差し替え可能な Repository として隔離し、ViewModel / UI から実装詳細を切る

**Non-Goals:**

- hunk / 行単位の部分ステージング（初期スコープはファイル単位のみ）
- マージコンフリクトの GUI 解決エディタ（コンフリクト検出と通知まで。解決はターミナル誘導）
- rebase（interactive 含む）/ cherry-pick / revert / reset の網羅。履歴行コンテキストメニューに将来追加余地を残すが初期スコープ外
- リモート管理（remote の追加・削除・URL 変更）
- 複数アカウント・認証情報管理。認証は `git` の既存設定（credential helper / SSH agent）に委ねる
- Git LFS、submodule、worktree の専用 UI

## Decisions

### D1: Git アクセスは `git` CLI を `dart:io` の `Process` でラップする

`git` コマンドを子プロセスで実行し、porcelain / プラミングコマンドの出力をパースする。

- **代替案 A**: `libgit2` バインディング（`libgit2dart` 等）。ネイティブ依存が増え macOS バンドルへの同梱・署名が複雑化する。ADR-0005 の「リポジトリ単体で完結」「外部依存を増やさない」方針に反する。却下
- **代替案 B**: `process_run` パッケージ。当初想定したが、`dart:io` の `Process.run` / `Process.start` で要件（環境変数固定・終了コード・stdout/stderr 取得）は十分に満たせる。新規パッケージ依存をゼロにできる方が ADR-0005 に強く整合するため不採用
- **採用理由**: 依存パッケージを増やさず `dart:io` のみで完結する。`git` は開発機にほぼ確実に存在し、Roola 自体ターミナルランチャーで PATH 上のコマンド実行が前提（ADR-0002）。`git` の認証（credential helper / SSH agent）をそのまま利用でき、認証情報管理を自前実装しなくてよい
- 機械可読出力を優先する: `git status --porcelain=v1 -z`、`git log --pretty=format:...`、`git for-each-ref` 等。人間向け出力のパースは避ける

### D2: `WorkspaceTab` union に `GitTab` を追加し、キーは repoRoot

`WorkspaceTab.git({required String id, required String repoRoot})` を追加する。`repoRoot` は `git rev-parse --show-toplevel` で正規化した絶対パス。

- 同一リポジトリの `GitTab` は 1 つに集約する。重複オープン要求時は既存タブをフォーカスする（`workspaceProvider` 側で repoRoot 一致を探索）
- `id` は他タブ同様ワークスペース内一意で、`GitViewModel` の `family` キーになる。ペイン間 DnD でも `id` 不変のため履歴・選択状態は無損失（ADR-0027）

### D3: 永続化スキーマ拡張と migration

`workspace_layout_dto` のタブ DTO は種別を `type` 文字列で判別する想定。`type: "git"` を追加し、`repoRoot` フィールドを持たせる。

- 旧 `workspace.json`（`git` 種別を含まない）は従来どおり読める（追加のみ・後方互換）
- 復元時に `repoRoot` が現存しない / Git リポジトリでなくなっている場合、その `GitTab` は復元せず黙ってスキップする（タブ 0 個になるスロットの扱いは既存の崩し再フロー `workspace_layout_mode` に従う）

### D4: `GitViewModel` は `AsyncNotifier.family(tabId)`、状態は単一の `GitViewState`

per-tab 状態を `family(tabId)` でルートスコープに保持（ADR-0027）。`GitViewState`（Freezed）に status / 履歴グラフ / ブランチ一覧 / 選択コミット / stash 一覧 / 進行中操作フラグをまとめる。

- 初回ロードと「再読込」で `git status` / `git log` / ブランチ一覧をまとめて取得
- fetch/pull/push/commit/branch 操作の後は当該データのみ再取得（全リロードしない）
- 進行中の Git 操作は `runningOperation` フィールドで表現し、UI はボタンを無効化＋スピナー表示
- ファイルシステム監視（FileWatcher による自動更新）は初期スコープでは入れず、明示「再読込」ボタン＋操作後自動更新で済ませる（Open Question O1）

### D5: コミットグラフは `CustomPainter` でレーン描画

`git log --pretty` で取得した各コミットの親子関係から、ViewModel 側でレーン割り当て（`GitGraphRow` に lane index・着色・エッジ情報）を計算し、`CustomPainter` がグラフ列のみ描画する。メッセージ / 作者 / 日付列は通常の Flutter Widget。

- **代替案**: グラフも含め全行 Widget で描画。マージエッジの曲線描画が困難
- レーン最適化（VSCode Git Graph 並みの交差最小化）は初期は素朴なアルゴリズムでよく、見やすさ改善は後追い

### D6: diff ビューアの配置

diff はファイル単位で、`GitTab` 内のオーバーレイではなく**隣ペインに開く軽量ビュー**として表示する。Changes 行 / コミット詳細のファイル行のダブルクリックで開く。

- unified / split 切替、行単位 add/del 着色
- diff の取得は `git diff` / `git diff --staged` / `git show <sha> -- <path>`

### D7: 長時間・対話的操作のターミナル誘導

pull/push/fetch は構造化実行（`process_run`）を基本とするが、認証プロンプトやコンフリクトなど対話が要るケースに備え、通知バーに「ターミナルで実行 / 解決」リンクを出し、`repoRoot` を作業ディレクトリにした `TerminalTab` を開く（ADR-0002 のターミナル中心方針と整合）。

### D8: エクスプローラからの起動導線

`ExplorerTab` のツールバー / コンテキストメニューに「Git ビューを開く」を追加。カレントパスが Git 管理下か（`git rev-parse --show-toplevel` の成否）で活性/非活性を切り替える。リポジトリ判定結果はパス単位でキャッシュし、毎描画でのプロセス起動を避ける。

## Risks / Trade-offs

- **[`git` CLI 非依存環境] → 緩和**: `git` が PATH に無い場合、`GitTab` を開く時点で検出し「git コマンドが見つかりません」を表示。クラッシュさせない。`ProcessGitRepository` 初期化時に `git --version` で存在確認
- **[CLI 出力パースの脆さ] → 緩和**: 機械可読オプション（`--porcelain=v2`、`-z` 区切り、固定 `--pretty=format`）のみ使用し、ロケール非依存にするため `LC_ALL=C` を環境変数で固定する
- **[大規模リポジトリで `git log` が重い] → 緩和**: 履歴は初期取得件数を制限（例 200 件）し、スクロール末尾で追加取得（ページング）。グラフのレーン計算も取得済み範囲のみ
- **[並行操作の競合] → 緩和**: `GitViewModel` で同一タブの Git 操作を直列化（`runningOperation` 中は新規操作を弾く）。リポジトリの index ロックは `git` 側に委ねる
- **[破壊的操作の誤爆] → 緩和**: discard（複数・all）、ブランチ削除、stash drop、force push は確認ダイアログ必須。force push は `--force-with-lease` をデフォルトにする
- **[BREAKING: workspace.json スキーマ変更] → 緩和**: 追加フィールドのみで後方互換。旧バージョンの Roola で新 `workspace.json` を読むと `git` タブが落ちるが、これはダウングレード時のみで許容範囲

## Migration Plan

- `workspace_layout_dto` に `git` 種別を追加。デシリアライズは未知種別を無視できる実装にしておき、シリアライズ時のみ新種別を書く
- 既存ユーザーの `workspace.json` は変更不要でそのまま読める。`GitTab` を初めて作った時点で新スキーマで上書き保存される
- ロールバック: `git` タブを含む `workspace.json` を旧バージョンが読むと当該タブがスキップされるのみ。データ破損はしない

## Open Questions

- **O1**: 作業ツリーの変更を FileWatcher で自動検知して Changes を更新するか。初期は手動再読込＋操作後更新で進め、必要なら別 change で追加
- **O2**: pull のデフォルトを merge とするか rebase とするか。`git config pull.rebase` を尊重し、未設定時は merge をデフォルトとする方針で進めるか要確認
- **O3**: コミットグラフのレーン最適化アルゴリズムをどこまで作り込むか（初期は素朴実装で可）
