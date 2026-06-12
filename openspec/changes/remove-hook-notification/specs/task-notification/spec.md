# task-notification — Delta

> 対象 capability の正本: `openspec/changes/archive/2026-06-11-osc-task-notification/specs/task-notification/spec.md`
> フック経路（ADR-0057）の撤去に伴い、並走条項を削除する。

## MODIFIED Requirements

### Requirement: 完了通知の意味論

タスク完了の通知は claude ネイティブの「入力待ちアイドル通知」
（完了から `messageIdleNotifThresholdMs`・既定 60 秒後）を正とする。
「完了の瞬間」の通知は提供しない（Ghostty / iTerm2 等のネイティブ通知と
同一の挙動）。

#### Scenario: 完了から約 60 秒後に入力待ち通知が出る

- **WHEN** claude のタスクが完了し、ユーザーが（非フォーカスのまま）
  60 秒以上放置する
- **THEN** 完了の瞬間には通知が出ず、約 60 秒後に
  「Claude is waiting for your input」の通知が表示される

#### Scenario: フック経路による完了の瞬間の通知は発生しない

- **WHEN** `~/.claude/settings.json` に旧 Roola フック（Stop → HTTP POST）が
  残ったまま claude のタスクが完了する
- **THEN** Roola は HTTP 受信口を持たないため通知は発射されず、フックは
  `|| true` により claude の動作にも影響しない
