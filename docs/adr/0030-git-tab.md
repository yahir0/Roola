# ADR-0030: Git ビューをワークスペースタブとして追加する

- **Status**: Accepted
- **Date**: 2026-05-17

## Context

Roola はエクスプローラ中心の汎用ターミナルランチャーで、開発者は日常的に Git
リポジトリ配下のディレクトリを閲覧・操作している。しかしリポジトリの状態確認・
コミット・同期は外部の Git クライアントやターミナルへ切り替える必要があった。
VSCode の Git Graph 拡張と SCM パネルに相当する Git ビューをアプリ内に持ちたい
という要望が入った。

`/explorer` は 3 ペインスロット × タブ群のワークスペースで、タブ種別は
`ExplorerTab` / `TerminalTab` の 2 種（ADR-0026）。per-tab 状態は `family(tabId)`
でルートスコープに保持し（ADR-0027）、レイアウトは `workspace.json` に永続化
される（ADR-0028）。

## Decision

**Git ビューを第 3 のタブ種別 `GitTab` としてワークスペースに追加する。**
Git アクセスは `git` CLI を `dart:io` の `Process` で実行する薄い Repository
（`data/git/`）に隔離する。

- `WorkspaceTab.git({id, repoRoot})` を sealed union に追加。`repoRoot` は
  `git rev-parse --show-toplevel` で正規化した絶対パス
- 同一リポジトリの `GitTab` は 1 つに集約（重複オープン時は既存タブをフォーカス）
- per-tab 状態は他タブ同様 `family(tabId)`。ペイン間 DnD でも id 不変で無損失
- `workspace.json` に `type: "git"` + `repoRoot` を永続化。旧スキーマは後方互換
- エクスプローラタブのツールバーから、カレントパスが Git 管理下のとき
  「Git ビューを開く」で隣ペインに `GitTab` を生成する
- 機能スコープ: 履歴グラフ・ステージング/コミット・fetch/pull/push・ブランチ
  操作・diff・stash/discard

## Why

### `git` CLI ラッパーを採用した理由（libgit2 を採らない）

ADR-0005 の「リポジトリ単体で完結し、外部依存を増やさない」方針に従う。`git`
コマンドは開発機にほぼ確実に存在し、Roola 自体ターミナルランチャーで PATH 上
のコマンド実行が前提（ADR-0002）。`git` の認証（credential helper / SSH agent）
をそのまま利用でき、認証情報管理を自前実装しなくてよい。

### 代替案 1: libgit2 バインディング（`libgit2dart` 等）

ネイティブ依存が増え、macOS バンドルへの同梱・コード署名が複雑化する。ADR-0005
の自己完結方針に反する。却下。

### 代替案 2: `process_run` パッケージでラップ

当初 proposal/design では `process_run` の採用を想定したが、`dart:io` の
`Process.run` / `Process.start` で要件（環境変数 `LC_ALL=C` 固定・終了コード
取得・stdout/stderr 取得）は十分に満たせる。新規パッケージ依存をゼロにできる
方が ADR-0005 の方針に強く整合するため、`dart:io` を直接使う。

### 代替案 3: サイドバーパネル / 専用画面

サイドバーは幅が狭く履歴グラフの描画に窮屈。専用 `/git` ルートはワークスペース
のタブモデル（ペイン配置・DnD・永続化・per-tab 状態）から外れ、既存機構を再利用
できない。`GitTab` 方式はエクスプローラと Git を左右に並べられ、ADR-0026/0027/0028
の機構にそのまま乗る。却下。

## Trade-offs

- **`git` 非依存環境では機能しない**: `git` が PATH に無い場合は `GitTab` 内に
  「git コマンドが見つかりません」を表示し、クラッシュさせない
- **CLI 出力パースの脆さ**: 機械可読オプション（`--porcelain=v1 -z`・固定
  `--pretty=format`・`for-each-ref`）と `LC_ALL=C` でロケール非依存にする
- **BREAKING（限定的）**: `workspace.json` スキーマに `git` 種別が増える。追加
  のみで後方互換。旧バージョンの Roola が新ファイルを読むと `GitTab` がスキップ
  されるのみ（ダウングレード時のみ・データ破損なし）
- **部分ステージング未対応**: hunk / 行単位の stage は初期スコープ外。ファイル
  単位のみ。必要になったら別 ADR で扱う
- **コンフリクト解決 GUI なし**: コンフリクトの検出・通知まで。解決はターミナル
  誘導（ADR-0002 のターミナル中心方針と整合）
- **作業ツリーの自動更新なし**: FileWatcher による変更検知は入れず、手動再読込
  ＋操作後更新で済ませる。必要になったら別 change で追加
- **diff は GitTab 内ダイアログ**: 当初 design では「隣ペインに開く軽量ビュー」
  を想定したが、初期実装ではダイアログ表示とし、二度目の DTO migration を避ける

## References

- ADR-0002（PTY ベースのターミナル統合）— `git` CLI 実行の前提
- ADR-0005（外部依存に頼らない自己完結方針）— CLI ラッパー採用の根拠
- ADR-0026（3 画面タブ式ワークスペース）— `GitTab` が乗るタブモデル
- ADR-0027（per-tab 状態を family(tabId) で実現）— `GitViewModel` の family 化
- ADR-0028（ワークスペース永続化）— `workspace.json` スキーマ拡張
- OpenSpec change: `openspec/changes/git-tab/`
