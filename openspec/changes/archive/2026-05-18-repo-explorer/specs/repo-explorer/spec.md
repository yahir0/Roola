## ADDED Requirements

### Requirement: エクスプローラ画面とルート

システムは、AppBar から遷移可能な `/explorer` ルートにエクスプローラ画面を提供する SHALL。

#### Scenario: ホームから AppBar アイコンで開く

- **WHEN** ユーザーがホーム画面 AppBar のエクスプローラアイコンをタップする
- **THEN** システムは `/explorer` へ遷移し、エクスプローラ画面を描画する

#### Scenario: 別画面からも遷移できる

- **WHEN** ユーザーが設定画面 AppBar のエクスプローラアイコンをタップする
- **THEN** システムは `/explorer` へ遷移する

### Requirement: 起点ディレクトリの永続化

システムは、エクスプローラの起点ディレクトリ（ルート）を 1 件アプリ内に永続化し、次回起動時に同じ場所から開く SHALL。

#### Scenario: 初回起動

- **WHEN** ユーザーが初めてエクスプローラを開き、設定ファイルが存在しない
- **THEN** システムは macOS ホームディレクトリをルートとして描画する

#### Scenario: ユーザーが起点を変更する

- **WHEN** ユーザーがエクスプローラ画面の「ルート変更」操作（フォルダピッカー）でディレクトリを選ぶ
- **THEN** システムは選ばれたパスをルートとして即座に再描画し、`repo_explorer_settings.json` に保存する

#### Scenario: アプリを再起動する

- **WHEN** ユーザーがアプリを終了し、再度起動してエクスプローラを開く
- **THEN** システムは前回保存した起点パスを読み込み、そこから描画する

### Requirement: ディレクトリの直下リスト表示と Skill 検知

システムは、表示中のディレクトリ直下の子フォルダを一覧で描画し、`.claude/skills/<name>/SKILL.md` が見つかったフォルダにはバッジを重ねる SHALL。

#### Scenario: 通常のフォルダ

- **WHEN** あるディレクトリを表示し、その子フォルダに `.claude/skills/` が無い
- **THEN** 通常のフォルダアイコンで描画する（バッジなし）

#### Scenario: Skill を持つフォルダ

- **WHEN** ある子フォルダ `<child>/.claude/skills/<skill-name>/SKILL.md` が存在する
- **THEN** その子フォルダはフォルダアイコンと右上のバッジ（Skill アイコン + 件数）で描画される

#### Scenario: 親に戻る

- **WHEN** ユーザーが「親に戻る」ボタンを押す
- **THEN** 現在パスの 1 階層上を描画する（ルートより上には行けない）

#### Scenario: 子フォルダに入る

- **WHEN** ユーザーが子フォルダのアイコンをタップする
- **THEN** その子フォルダの直下を再描画する

### Requirement: 右クリックメニュー（コンテキストメニュー）

システムは、子フォルダの上で右クリック（または Control + クリック）が行われたとき、そのフォルダに対するアクションメニューを表示する SHALL。

#### Scenario: Skill を持たないフォルダの右クリック

- **WHEN** Skill 検知が無いフォルダで右クリックする
- **THEN** 「このディレクトリで Claude Code を開く」1 項目だけ表示される

#### Scenario: Skill を持つフォルダの右クリック

- **WHEN** Skill 検知ありのフォルダで右クリックする
- **THEN** 以下 3 種のメニューが表示される:
  - 「このディレクトリで Claude Code を開く」
  - 「Skill を即実行」（Skill 名サブメニュー、複数なら全 Skill 名を列挙）
  - 「Skill を登録」（Skill 名サブメニュー、複数なら全 Skill 名を列挙）

### Requirement: Skill 登録への導線

システムは、エクスプローラで検知された Skill を「登録」メニューから既存の `EntryEditPage` 初期値プリフィル付きで開く SHALL。

#### Scenario: 登録メニューから新規エントリ画面へ

- **WHEN** ユーザーが右クリックメニューで「Skill を登録」 → 特定の Skill 名を選ぶ
- **THEN** システムは `/settings/entries/new` へ遷移し、リポジトリパスと Skill 名がフォームに事前入力された状態で開く

#### Scenario: そのまま保存

- **WHEN** プリフィル状態でユーザーが表示名 / アイコンを入力して保存する
- **THEN** 通常の新規登録と同様に永続化され、ホームのアイコングリッドに追加される

### Requirement: Skill 即実行（ad-hoc）

システムは、エクスプローラから「Skill を即実行」を選んだとき、`LauncherEntry` の永続化を行わずに該当 Skill のセッションを起動し、`session-registry` に登録する SHALL。

#### Scenario: 即実行を選ぶ

- **WHEN** ユーザーが右クリックメニューで「Skill を即実行」 → Skill 名を選ぶ
- **THEN** システムは新しい `adhoc-<uuid>` を発行し、対応するディレクトリで PTY 上に `claude /<skill-name>` を起動する

#### Scenario: ホームの chip 列に表示される

- **WHEN** ad-hoc セッションが起動した
- **THEN** ホーム画面の chip 列に「ディレクトリ名 / Skill 名」ラベルで chip が並ぶ。タップで同じセッション画面に復帰できる

#### Scenario: 閉じると登録されないまま破棄

- **WHEN** ad-hoc セッションを ✕ ボタンで閉じる
- **THEN** chip と PTY が破棄される。`launcherEntriesProvider`（ホームアイコン）には何も追加されない

### Requirement: このディレクトリで Claude Code を開く

システムは、右クリックメニューから「このディレクトリで Claude Code を開く」を選んだとき、Skill 引数なしで `claude` を PTY 上に起動し、対話モードのセッションを `session-registry` に登録する SHALL。

#### Scenario: 起動

- **WHEN** ユーザーが該当メニューを選ぶ
- **THEN** システムは新しい `adhoc-<uuid>` を発行し、`claude` を引数なしでそのディレクトリで起動する

#### Scenario: ホームの chip 列に表示される

- **WHEN** Claude Code 対話セッションが起動した
- **THEN** ホーム画面の chip 列に「ディレクトリ名 (Claude)」ラベルで chip が並ぶ

#### Scenario: 閉じると破棄

- **WHEN** ✕ ボタンで閉じる
- **THEN** PTY と chip が破棄される
