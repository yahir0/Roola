## MODIFIED Requirements

### Requirement: サイドバーの構成

システムは、エクスプローラ画面の左サイドバーを Finder 流の 4 セクション構造で提供する SHALL。上から順に: 場所 / お気に入り / ランチャー / 実行中。

#### Scenario: 場所セクション

- **WHEN** エクスプローラを開く
- **THEN** サイドバー最上部に「場所」セクションが表示され、以下 5 件の固定エントリが並ぶ: ホーム / ダウンロード / デスクトップ / ドキュメント / アプリケーション
- **AND** 末尾に「別のフォルダを開く…」エントリがあり、クリックすると file_picker が開く

#### Scenario: 場所エントリのクリック

- **WHEN** 場所セクションのいずれかをクリックする
- **THEN** body のディレクトリビューが該当パスに切替わる（`~/Downloads` 等の絶対パス）

#### Scenario: 「別のフォルダを開く…」

- **WHEN** ユーザーが「別のフォルダを開く…」をクリックし、file_picker で任意のディレクトリを選ぶ
- **THEN** body がそのディレクトリに navigate する

#### Scenario: お気に入りが空でも詰まない

- **WHEN** お気に入りに 1 件も登録されていない初期状態でエクスプローラを開く
- **THEN** 場所セクションから任意の標準的な場所に飛べる（初心者が navigate に詰まらない）

#### Scenario: ランチャーセクション

- **WHEN** エクスプローラを開く
- **THEN** 「ランチャー」セクションに登録済みの LauncherEntry が縦リストで表示される
- **AND** クリックすると当該 Skill のセッションが起動する（Phase 1: 既存の `/run/:id` ルート遷移、Phase 2: body 切替）

#### Scenario: 実行中セクション（空のとき）

- **WHEN** 実行中の Skill / Terminal セッションが 0 件
- **THEN** 「実行中」セクションが「なし」プレースホルダで常時表示される

#### Scenario: 実行中セクション（セッションがあるとき）

- **WHEN** 1 件以上の実行中セッションがある
- **THEN** 各セッションが状態アイコン + 表示名で並ぶ
- **AND** ✕ ボタンで完全破棄できる
- **AND** クリックで当該セッションに遷移（Phase 1: `/run/:id`、Phase 2: body 切替）

### Requirement: root ceiling の廃止

システムは、`ExplorerSettings.rootPath` を「起動時の開始位置」としてのみ扱い、ユーザーの上方向ナビゲーションを root で制限しない SHALL。

#### Scenario: root より上に登れる

- **WHEN** `rootPath` が `/Users/yahir0/Projects` の状態で、ユーザーが「上の階層へ」タイルをクリックする
- **THEN** `currentPath` が `/Users/yahir0` に切替わる（root を上に超える）

#### Scenario: ファイルシステム root を超えない

- **WHEN** `currentPath` が `/` の状態で「上の階層へ」をクリックする
- **THEN** 「上の階層へ」タイルは表示されておらず、操作不能（filesystem root は超えられない）

#### Scenario: 起動時の開始位置

- **WHEN** アプリを再起動する
- **THEN** `currentPath` は `rootPath`（保存値）で初期化される

#### Scenario: ルートを変更

- **WHEN** ユーザーが AppBar の「起動時のディレクトリを変更」アイコンから新ディレクトリを選ぶ
- **THEN** `rootPath` が更新され、次回起動時の開始位置に反映される
- **AND** 既存の `currentPath` も同パスに更新される

## ADDED Requirements

### Requirement: body の selection 駆動切替 (Phase 2)

システムは、サイドバーの選択（場所 / お気に入り / ランチャー / 実行中）に応じて、エクスプローラ body エリアにディレクトリ一覧 OR PTY ターミナルを切替表示する SHALL。

#### Scenario: ディレクトリ選択

- **WHEN** 場所 / お気に入り / 「上の階層へ」/ 子ディレクトリのいずれかをクリックする
- **THEN** body にそのディレクトリの一覧が描画される

#### Scenario: セッション選択

- **WHEN** ランチャーまたは実行中セクションのエントリをクリックする
- **THEN** body に該当セッションの PTY ターミナルが描画される
- **AND** ディレクトリビューと PTY は同一の body エリアに排他的に表示される

#### Scenario: セッションは破棄されない

- **WHEN** PTY ターミナル表示中にサイドバーからディレクトリを選び、再度同じセッションに戻る
- **THEN** PTY プロセスは破棄されておらず、出力が引き続き蓄積されている（keepAlive の挙動）

#### Scenario: AppBar の表示

- **WHEN** body がディレクトリビュー
- **THEN** AppBar はパスバーを表示
- **WHEN** body がセッション
- **THEN** AppBar はセッション名 + 状態を表示

### Requirement: AppBar の ⚡ Popover (Phase 2)

システムは、エクスプローラ画面の AppBar に `⚡` ボタンを置き、登録済み LauncherEntry のタイルグリッドを popover で表示する SHALL。

#### Scenario: popover を開く

- **WHEN** AppBar の ⚡ をクリックする
- **THEN** popover が開き、登録済み LauncherEntry のタイルグリッドが表示される

#### Scenario: タイルクリック

- **WHEN** popover 内のタイルをクリックする
- **THEN** 該当 Skill のセッションが起動し、body が PTY ターミナルに切替わる、popover は閉じる

## REMOVED Requirements

### Requirement: Home / Explorer タブ並列構造 (Phase 2 で削除)

タブで両画面を同列に扱う `StatefulShellRoute` 構造は撤去する。Explorer を唯一のメイン画面とする。

**Migration**: Home の機能は Explorer サイドバーのランチャーセクション + AppBar ⚡ popover に統合される。
