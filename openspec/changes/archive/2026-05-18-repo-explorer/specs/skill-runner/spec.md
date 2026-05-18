## MODIFIED Requirements

### Requirement: 対話的入力のサポート

システムは、`claude` 側の承認プロンプト（y/n）・選択 UI（矢印キー）・パスワード入力など、TTY 前提の対話的入力を一通りサポートする SHALL。**Skill を指定せずに `claude` 単独で起動した場合の対話モードも同様にサポート対象とする**。

#### Scenario: Skill 指定なしで起動する

- **WHEN** ユーザーがエクスプローラ右クリックメニューから「このディレクトリで Claude Code を開く」を選び、`PtySkillRunner` が Skill 引数なしで起動される
- **THEN** `claude` は対話モードで起動し、PTY 経由で承認プロンプト・矢印キー・ANSI 制御を通常通り扱える

## ADDED Requirements

### Requirement: Skill 名なしの起動経路

システムは、`PtySkillRunner` のコンストラクタに渡された Skill 名が空文字の場合、`claude` を引数なしで起動する SHALL。

#### Scenario: 空文字での起動

- **WHEN** `PtySkillRunner(skillName: '')` が `start()` される
- **THEN** `Pty.start('claude', arguments: [], workingDirectory: ...)` 相当で起動される

#### Scenario: 空でない Skill 名

- **WHEN** `PtySkillRunner(skillName: 'foo')` が `start()` される
- **THEN** 既存仕様通り `Pty.start('claude', arguments: ['/foo'], ...)` で起動される（スラッシュコマンド経由）
