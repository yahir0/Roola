## ADDED Requirements

### Requirement: GitTab タブ種別

ワークスペースのタブ種別 union に `GitTab` を追加する。`GitTab` は `ExplorerTab` / `TerminalTab` と並ぶ第 3 のタブ種別で、リポジトリルートの絶対パス（`repoRoot`）を保持する。

#### Scenario: GitTab を任意ペインに配置できる

- **WHEN** `GitTab` が生成される
- **THEN** `GitTab` は他のタブ種別と同様に 3 ペインスロットのいずれにも配置でき、ペインタブストリップに表示される

#### Scenario: GitTab をペイン間で DnD 移動できる

- **WHEN** ユーザーが `GitTab` を別ペインへドラッグ&ドロップする
- **THEN** タブ id は不変のまま移動先ペインへ移り、`family(tabId)` で保持された Git ビューの状態（履歴・選択）は失われない

#### Scenario: GitTab をペインタブストリップで識別できる

- **WHEN** ペインタブストリップに `GitTab` が表示される
- **THEN** `GitTab` は Git を示すアイコンとリポジトリ名で、他のタブ種別と区別できる形で表示される

### Requirement: GitTab の永続化と復元

`GitTab` はワークスペースレイアウトの一部として `workspace.json` に永続化され、起動時に復元される。

#### Scenario: GitTab を保存する

- **WHEN** ワークスペースに `GitTab` が存在する状態でレイアウトが永続化される
- **THEN** `workspace.json` に `GitTab` が種別 `git` と `repoRoot` とともに記録される

#### Scenario: GitTab を復元する

- **WHEN** 起動時に `workspace.json` から `GitTab` を含むレイアウトを読み込む
- **THEN** `repoRoot` が現存する Git リポジトリであれば `GitTab` を復元する

#### Scenario: 復元不能な GitTab をスキップする

- **WHEN** 復元対象の `GitTab` の `repoRoot` が存在しない、または Git リポジトリでなくなっている
- **THEN** システムは当該 `GitTab` を復元せずスキップし、残りのレイアウトは既存の崩し再フローに従って構成する

#### Scenario: 旧スキーマとの後方互換

- **WHEN** `git` 種別を含まない旧バージョンの `workspace.json` を読み込む
- **THEN** システムは従来どおりレイアウトを復元し、エラーにならない
