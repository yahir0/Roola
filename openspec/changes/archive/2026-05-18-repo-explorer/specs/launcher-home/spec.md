## MODIFIED Requirements

### Requirement: 実行中セッションの一覧表示

システムは、ホーム画面上部に `session-registry` 上の全セッションを chip 列として描画する SHALL。**`launcherEntriesProvider` に対応する entry が存在しない ad-hoc セッション（エクスプローラから起動）の chip は、別途登録された表示名をラベルとして用いる**。

#### Scenario: 通常のセッション

- **WHEN** ホームから登録済みエントリで起動されたセッションが `session-registry` に存在する
- **THEN** chip ラベルは `launcherEntriesProvider` から取得した `displayName` を使う

#### Scenario: ad-hoc セッション（Skill 即実行）

- **WHEN** エクスプローラから「Skill を即実行」で起動されたセッション（`adhoc-<uuid>`）が `session-registry` に存在し、`launcherEntriesProvider` には対応 entry が無い
- **THEN** chip ラベルは ad-hoc 登録時に渡された「ディレクトリ名 / Skill 名」を使う

#### Scenario: ad-hoc セッション（Claude Code 起動）

- **WHEN** エクスプローラから「このディレクトリで Claude Code を開く」で起動されたセッション
- **THEN** chip ラベルは「ディレクトリ名 (Claude)」を使う
