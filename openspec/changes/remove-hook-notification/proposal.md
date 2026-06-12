# remove-hook-notification — Proposal

## Why

ADR-0066 は OSC（in-band）通知への移行を決定し、旧フック経路（ADR-0057: Stop フック →
jq/curl → ローカル HTTP 受信口 → トークン照合 → OS 通知)は「OSC 版の安定を確認するまで
並走させ、その後撤去する」（Decision 7）とした。OSC 通知はオーナー実機運用で安定を確認
できたため、並走期間を終了し、フック経路の実装一式を撤去する。撤去により HTTP サーバー
常駐・ポート管理・トークン生成・`~/.claude/settings.json` 関連 UI が消え、通知経路が
OSC 一本に単純化される。

## What Changes

- **BREAKING**: フック経路によるタスク完了通知（Stop フックの「完了の瞬間」通知）を廃止する。
  完了通知は claude ネイティブの入力待ちアイドル通知（既定 60 秒・`messageIdleNotifThresholdMs`
  で調整可）が代替となる（ADR-0066 Trade-offs に記載済みの挙動）
- HTTP 受信サーバー（`TaskNotificationServerNotifier`）と app 起動時の常駐を撤去
- 受理判定（トークン照合・タブ照合・デデュープ）/ POST ペイロードパースを撤去
- 通知トークン生成（`notifyTokenProvider`）と PTY への `ROOLA_TAB_ID` / `ROOLA_NOTIFY_TOKEN`
  注入を撤去（OSC 用の `TERM_PROGRAM` / `TERM_PROGRAM_VERSION` 注入は存続）
- `HookInstaller`（`~/.claude/settings.json` への自動インストール / 削除 / バックアップ）を撤去
- タスク通知設定の永続化（`TaskNotificationSettings`: `enabled` / `preferredPort`、DTO・
  リポジトリ・設定ファイル）を撤去。OSC 経路は設計上この設定を参照しておらず（設定ゼロ有効化が
  spec 要件）、無効化手段は OS の通知設定に委ねる
- 設定画面の「タスク通知」セクションを縮退: ON/OFF トグル・ポート設定・フックスニペット・
  自動インストール UI を削除し、**通知許可状態の表示と導線**（許可リクエスト / システム設定を
  開く）だけを残す
- フック専用 l10n キーを削除（`privacy_section.dart` が共用する On/Off キー等は残す）
- 既に自動インストール済みのユーザーの `~/.claude/settings.json` は**触らない**。残置フックは
  `|| true` 付きで dead ポートへの POST に静かに失敗するだけで実害がない（手動削除の案内は
  リリースノートで行う）

## Capabilities

### New Capabilities

（なし）

### Modified Capabilities

- `claude-task-notification`（2026-05-25-notify-claude-task-complete で定義）:
  フック経路の要件「Claude Code セッションへの識別子注入」「ローカル通知受信口」
  「セッション照合とトークン検証」を REMOVED。「通知機能の設定 UI」を許可状態の
  表示・導線のみへ MODIFIED。「macOS ローカル通知の発射」「通知許可の取得」は
  OSC 経路の共通基盤として存続（要件変更なし）
- `task-notification`（2026-06-11-osc-task-notification で定義）:
  「完了通知の意味論」からフック経路との並走条項（互いに抑止しない）を削除する MODIFIED

## Impact

- **削除**: `lib/data/task_notification/` の `task_notification_server.dart` /
  `task_notification_receiver.dart` / `hook_stop_payload.dart` / `notify_token.dart` /
  `hook_installer.dart` / `task_notification_settings*.dart`（DTO・freezed・g 含む）、
  対応テスト（`task_notification_receiver_test.dart` / `hook_stop_payload_test.dart`）
- **修正**: `notification_environment.dart`（トークン注入の削除）、
  `lib/ui/run/adhoc_run_view_model.dart`、`lib/app/app.dart`（サーバー常駐の削除）、
  `lib/core/storage/app_paths.dart`、`lib/ui/settings/task_notification_section.dart`
  （許可セクションへ縮退）、l10n ARB、`notification_environment_test.dart`
- **存続（変更なし）**: OSC 経路一式（`osc_notification_controller.dart` /
  `osc_notification_policy.dart`）、通知発射基盤（`task_notification_repository.dart` /
  `notification_service_macos.dart` / `notification_service_windows.dart`、macOS の
  `roola/notification` MethodChannel）、通知クリック復帰（`notification_click_provider.dart`）
- **ドキュメント**: ADR-0066 に撤去完了を追記、CLAUDE.md の ADR-0066 行を更新、
  README のフック言及を確認・除去、`docs/notes/2026-06-11-ai-era-concept-review.md` の
  引き継ぎチェックリストを更新
- **依存関係**: 削除のみで新規依存なし。`jq` / `curl` / Node.js への言及（UI 文言）が消える
