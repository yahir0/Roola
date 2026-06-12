# remove-hook-notification — Tasks

## 1. data 層: フック経路の削除

- [x] 1.1 `lib/data/task_notification/task_notification_server.dart` を削除し、`lib/app/app.dart` の `taskNotificationServerProvider` 常駐起動（import 含む）を撤去する
- [x] 1.2 `task_notification_receiver.dart` / `hook_stop_payload.dart` / `notify_token.dart` / `hook_installer.dart` を削除する
- [x] 1.3 `task_notification_settings.dart`（freezed 生成物含む）/ `task_notification_settings_dto.dart`（g.dart 含む）/ `task_notification_settings_repository.dart` / `task_notification_settings_repository_impl.dart` を削除する
- [x] 1.4 `lib/core/storage/app_paths.dart` から `taskNotificationSettingsFile` を削除する
- [x] 1.5 `notification_environment.dart` から `ClaudeSkillAction` 分岐（`ROOLA_TAB_ID` / `ROOLA_NOTIFY_TOKEN` 注入）と `token` パラメータを削除し、`TERM_PROGRAM` / `TERM_PROGRAM_VERSION` 注入のみ残す
- [x] 1.6 `lib/ui/run/adhoc_run_view_model.dart` から `notifyTokenProvider` の読み出し・`token:` 引数・関連 import を削除する

## 2. UI 層: 設定画面の縮退

- [x] 2.1 通知許可セクション（許可状態表示 + 許可リクエスト / システム設定を開く導線）を `lib/ui/settings/notification_section.dart` として作成する（旧 `_AuthorizationRow` を移植・Polaris 準拠）
- [x] 2.2 `lib/ui/settings/task_notification_section.dart` を削除し、`settings_page.dart` の参照を新セクションへ差し替える
- [x] 2.3 セクションのタイトル / 説明の l10n 文言を OSC 前提（Roola 内で起動したセッションからの通知・設定不要）へ更新する

## 3. l10n

- [x] 3.1 `app_en.arb` / `app_ja.arb` からフック専用キー（Setup / Port / Jq / Copy / AutoSetup / Install / Uninstall / Backup / StalePort 系・約 25 キー）を削除する。`settingsTaskNotificationOn` / `Off`（privacy_section が共用）と許可状態系キーは残す
- [x] 3.2 `flutter gen-l10n` を実行し、未使用キー参照が残っていないことを analyze で確認する

## 4. テスト

- [x] 4.1 `test/data/task_notification/task_notification_receiver_test.dart` / `hook_stop_payload_test.dart` を削除する
- [x] 4.2 `notification_environment_test.dart` を新シグネチャに追従させる（`ROOLA_TAB_ID` / `ROOLA_NOTIFY_TOKEN` のケースを削除し、`TERM_PROGRAM` 系のケースを残す）
- [x] 4.3 `flutter test` 全件グリーンを確認する

## 5. 検証

- [x] 5.1 `grep` で削除漏れを確認する（`notifyToken` / `HookInstaller` / `hook/stop` / `ROOLA_NOTIFY_TOKEN` / `ROOLA_TAB_ID` / `preferredPort` / `taskNotificationSettings` が lib/・test/ に残っていないこと。docs/openspec の履歴は対象外）
- [x] 5.2 `flutter analyze` クリーン・`flutter build macos --debug` 成功を確認する
- [x] 5.3 実機（macOS）で手動確認: OSC 通知（許可待ち・入力待ち）が従来どおり動く / 設定画面に許可セクションのみ表示される / 通知クリックでペインフォーカス復帰が動く

## 6. ドキュメント

- [x] 6.1 ADR-0066 の Decision 7 に撤去完了（日付・本 change 名）を追記する
- [x] 6.2 CLAUDE.md の ADR-0066 要約行を「フック経路は撤去済み」へ更新する
- [x] 6.3 README のフック経路への言及を確認し、残っていれば除去する（残置フックの手動削除案内を追記）
- [x] 6.4 `docs/notes/2026-06-11-ai-era-concept-review.md` の引き継ぎチェックリスト（フック撤去 change）を完了に更新する
