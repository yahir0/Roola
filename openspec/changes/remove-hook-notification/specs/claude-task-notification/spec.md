# claude-task-notification — Delta

> 対象 capability の正本: `openspec/changes/archive/2026-05-25-notify-claude-task-complete/specs/claude-task-notification/spec.md`
> ADR-0066 Decision 7（フック経路の撤去）の実行。

## REMOVED Requirements

### Requirement: Claude Code セッションへの識別子注入

**Reason**: フック経路（ADR-0057）の撤去。OSC（in-band）通知は受信ペイン = 送信元で
あり、出所照合のための識別子（`ROOLA_TAB_ID` / `ROOLA_NOTIFY_TOKEN`）を必要としない。
**Migration**: なし（OSC 用の `TERM_PROGRAM` / `TERM_PROGRAM_VERSION` 注入は
`task-notification` capability の「Claude Code のネイティブ通知の設定ゼロ有効化」が引き続き規定する）。

### Requirement: ローカル通知受信口

**Reason**: フック経路の撤去。HTTP 受信口・ポート管理は out-of-band 信号の出所確認の
ためのコストであり、OSC 移行で不要になった（ADR-0066 Why 節）。
**Migration**: 通知は OSC 9 / 777 の解釈（`task-notification` capability）で行う。

### Requirement: セッション照合とトークン検証

**Reason**: フック経路の撤去。in-band 信号は受信ペインが送信元そのものであり、
照合レイヤーは存在しない（ADR-0066 Decision 1）。
**Migration**: なし。

## MODIFIED Requirements

### Requirement: 通知機能の設定 UI

Roola SHALL 設定画面に通知セクションを提供し、OS の通知許可状態と再許可への導線を
表示しなければならない。機能の ON/OFF トグル・待受ポート・フック設定スニペット・
フック自動インストールの UI を提供してはならない（MUST NOT）。UI は Polaris
デザインシステムに準拠する。

#### Scenario: 許可状態を表示する

- **WHEN** ユーザーが設定画面の通知セクションを開く
- **THEN** 現在の OS 通知許可状態（許可 / 拒否 / 未決定）が表示される

#### Scenario: 未決定時に許可導線を示す

- **WHEN** 通知許可が未決定の状態で設定画面を開く
- **THEN** 許可をリクエストするボタンが表示され、押下で OS の許可ダイアログが出る

#### Scenario: 拒否時にシステム設定へ誘導する

- **WHEN** 通知許可が拒否済みの状態で設定画面を開く
- **THEN** OS のシステム設定（通知設定）を開く導線が表示される

#### Scenario: フック関連 UI が存在しない

- **WHEN** ユーザーが設定画面を開く
- **THEN** タスク通知の ON/OFF トグル・ポート設定・`~/.claude/settings.json` 向け
  スニペット・自動インストールボタンは表示されない
