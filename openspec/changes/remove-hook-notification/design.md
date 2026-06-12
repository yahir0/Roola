# remove-hook-notification — Design

## Context

ADR-0057 のフック経路と ADR-0066 の OSC 経路は現在並走している。両者は
`lib/data/task_notification/` に同居しているが、依存関係は調査済みで明確に分離できる:

- **フック経路専用**（撤去対象）: `task_notification_server.dart`（HTTP 受信口）、
  `task_notification_receiver.dart`（トークン / タブ照合・デデュープ）、
  `hook_stop_payload.dart`、`notify_token.dart`、`hook_installer.dart`、
  `task_notification_settings*.dart`（`enabled` / `preferredPort` の永続化一式）
- **OSC 経路専用**（存続）: `osc_notification_controller.dart`、`osc_notification_policy.dart`
- **共通基盤**（存続）: `task_notification_repository.dart`（通知発射・許可の interface +
  provider）、`notification_service_macos.dart` / `notification_service_windows.dart`、
  macOS の `roola/notification` MethodChannel（`MainFlutterWindow.swift`）、
  `notification_click_provider.dart`（通知クリック → ペインフォーカス復帰）

`OscNotificationController` は `TaskNotificationSettings.enabled` を参照せず（コード内
コメントで明示済み）、通知許可も初回発射時に lazy に要求する。つまり OSC 経路は設定の
永続化に依存していない。

## Goals / Non-Goals

**Goals:**

- フック経路の実装一式（受信口・照合・トークン・インストーラ・設定永続化・設定 UI）を撤去する
- OSC 経路と通知共通基盤（発射・許可・クリック復帰）を無傷で残す
- 設定画面に通知許可状態の表示と導線だけを残す
- ADR-0066 / CLAUDE.md / notes の記述を「撤去済み」に更新する

**Non-Goals:**

- OSC 経路の挙動変更（ポリシー・レート制限・フォーカス転送は一切触らない）
- ユーザーの `~/.claude/settings.json` の自動クリーンアップ（後述）
- ディスク上の旧設定ファイル（`task_notification_settings.json`）の削除マイグレーション
- ADR-0057 ドキュメント自体の削除（Superseded として履歴に残す）

## Decisions

### D1. 設定の永続化（`TaskNotificationSettings`）を丸ごと撤去する

`enabled` はフック経路の発射制御専用で、OSC 経路は spec 要件（設定ゼロ有効化）として
参照しない。`preferredPort` はフック専用。撤去後に残しても使途がないため、モデル・DTO・
リポジトリ・provider・`AppPaths.taskNotificationSettingsFile` を全て削除する。

- 代替案: `enabled` を OSC 通知の ON/OFF として転用する → **不採用**。ADR-0066 の
  「設定ゼロ」原則に反する上、既定 off の旧値を読むと既存ユーザーの OSC 通知が止まる。
  無効化したいユーザーには OS の通知設定（アプリ単位オフ）があり、これは
  `osc_notification_controller.dart` のコメントに既に明文化された設計判断。

ディスク上の旧設定ファイルは参照されなくなるだけで残置する（数十バイトの JSON で実害なし。
削除コードを書く方がリスク）。

### D2. 設定画面は「通知許可セクション」へ縮退する

`task_notification_section.dart` のうちフック UI（トグル・ポート・スニペット・自動
インストール・バックアップダイアログ）を削除し、`_AuthorizationRow` 相当（許可状態表示 +
許可リクエスト / システム設定を開く導線）だけを `notification_section.dart` 等に再構成して
`settings_page.dart` に残す。OSC 通知が出ない原因（OS 許可の拒否）をユーザーが自己診断
できる唯一の場所であるため、セクションごと消すことはしない。

- 許可状態が `notDetermined` のままでも OSC 初回発射時に lazy 要求されるため、
  設定画面からの事前許可は任意の導線（必須ではない）。
- セクションのタイトル / 説明文はフック前提の文言から OSC 前提（「Roola 内で起動した
  セッションからの通知」）へ書き換える。

### D3. 環境変数注入は `TERM_PROGRAM` 系のみ残す

`notification_environment.dart` から `ClaudeSkillAction` 分岐（`ROOLA_TAB_ID` /
`ROOLA_NOTIFY_TOKEN`）を削除し、全アクション共通の `TERM_PROGRAM` /
`TERM_PROGRAM_VERSION` 注入だけにする。`adhoc_run_view_model.dart` から
`notifyTokenProvider` の読み出しと `token:` 引数を削除する。関数シグネチャが
変わるためテスト（`notification_environment_test.dart`）も追従する。

### D4. ユーザーの `~/.claude/settings.json` には触れない

自動インストール済みユーザーの設定には Roola のフックが残るが、撤去しない。

- 残置フックは `curl ... || true`（Windows は `r.on('error',...)` + `|| true`）で
  dead ポートへの POST に静かに失敗するだけで、claude の動作に影響しない
- ADR-0066 の方針は「Claude Code 設定への書き込みをやめる」であり、撤去のための
  書き込み（自動クリーンアップ）はその方針と矛盾する
- 手動削除の案内はリリースノート / README で行う
- 代替案: 起動時に Roola 署名のフックを検出して一度だけ削除提案する → **不採用**。
  対象ユーザーがごく少数の現段階では、settings.json 書き換えコードを残すコストの方が大きい

### D5. ネイティブ側は変更しない

macOS の `roola/notification` MethodChannel（`notify` / `requestAuthorization` /
`authorizationStatus`）と通知クリックハンドリングは OSC 経路が同じ実装を使うため、
`MainFlutterWindow.swift` は変更しない。HTTP サーバーは Dart 実装なので
ネイティブ側にフック専用コードは存在しない。Windows も同様（`local_notifier` 経由）。

### D6. l10n はフック専用キーのみ削除する

ポート・スニペット・インストール関連キー（約 25 キー）を `app_en.arb` / `app_ja.arb`
から削除する。`settingsTaskNotificationOn` / `Off` は `privacy_section.dart` が
アナリティクストグルで共用しているため残す。タイトル / 説明キーは文言を OSC 前提に更新する。

### D7. 新規 ADR は起こさず、ADR-0066 に追記する

撤去自体は ADR-0066 Decision 7 で決定済みの実行であり、新しい設計判断ではない。
ADR-0066 の該当箇所に撤去完了（日付・change 名）を追記し、CLAUDE.md の ADR-0066
要約行の「フック経路は安定確認後に撤去」を撤去済みへ更新する。

## Risks / Trade-offs

- [「完了の瞬間」通知の喪失] → ADR-0066 で受容済みのトレードオフ。claude 標準の
  `messageIdleNotifThresholdMs` で 60 秒を縮められることを README 等で案内
- [自動インストール済みユーザーに dead フックが残る] → 実害なし（`|| true`）。
  リリースノートで手動削除（または旧バージョンでのアンインストールボタン使用）を案内
- [設定ファイルの孤児化] → 残置で害なし。将来設定スキーマを再導入する場合は
  別ファイル名 / バージョンキーで衝突を避ける
- [削除漏れによる未使用コード残存] → `flutter analyze`（unused import / element）と
  `grep`（`notifyToken` / `HookInstaller` / `hook/stop` / `ROOLA_NOTIFY_TOKEN` 等）で
  機械的に確認する

## Migration Plan

単一 PR で削除する。ロールバックは PR の revert で完結する（DB / 永続データの
スキーマ変更なし。旧設定ファイルは読み手が消えるだけで破壊しない）。

## Open Questions

（なし — 判断はすべて上記 Decisions で確定）
