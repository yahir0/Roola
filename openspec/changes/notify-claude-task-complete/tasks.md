## 1. ADR・前提整理

- [x] 1.1 ADR を 1 件追加（Stop フック採用 / 環境変数によるセッション照合 / ローカル HTTP 受信口 / 通知のネイティブ実装の設計判断）を `docs/adr/` に作成し、`docs/adr/README.md` と CLAUDE.md の ADR 一覧に追記する
- [x] 1.2 Stop フックの stdin JSON（`session_id` / `cwd` 等）と環境変数継承（フック command が PTY の子で `ROOLA_TAB_ID` / `ROOLA_NOTIFY_TOKEN` を読めること）を最小手元検証で確認する（`Pty.start` の environment マージは flutter_pty 0.4.2 ソースで確認、env 継承はシェル経由の POSIX 標準。ライブ確認は 7.1）

## 2. PTY への識別子注入

- [x] 2.1 `lib/data/terminal_runner/pty_terminal_runner.dart` の `Pty.start()` 起動箇所を確認し、`ClaudeSkillAction` セッションに `ROOLA_TAB_ID`（セッション一意 ID）と `ROOLA_NOTIFY_TOKEN`（アプリ起動ごとトークン）を環境変数として注入する
- [x] 2.2 アプリ起動ごとのランダムトークンを生成・保持する仕組み（Riverpod provider 等）を追加し、`ROOLA_NOTIFY_TOKEN` の供給元にする（`notify_token.dart` の `notifyTokenProvider`）
- [x] 2.3 注入が `ClaudeSkillAction` のときのみ行われ、他アクションに副作用がないことをユニットテストで確認する（`notification_environment.dart` に抽出し `notification_environment_test.dart` で検証）

## 3. ローカル HTTP 受信口（Dart data 層）

- [x] 3.1 `lib/data/task_notification/` に受信口サービスを新設（`dart:io` `HttpServer.bind(InternetAddress.loopbackIPv4, port)`、既定ポート + 競合時フォールバック、確定ポートを公開）
- [x] 3.2 単一エンドポイント `POST /hook/stop` を実装し、ボディ JSON `{tab_id, token, session_id, cwd}` をパースする（`hook_stop_payload.dart`）
- [x] 3.3 トークン照合（現在のアプリ起動のトークンと一致）と `tab_id` の有効セッション照合（`lib/data/skill_session/active_sessions.dart` の `ActiveSessions` と突き合わせ）を実装する
- [x] 3.4 短時間の重複 POST デデュープ（同一 turn の多重発火対策）を実装する（`task_notification_receiver.dart`）
- [x] 3.5 受信口の起動・確定ポート・照合結果を Riverpod の Notifier/AsyncNotifier で保持する（`task_notification_server.dart`）
- [x] 3.6 受信口とパース・照合ロジックのユニットテストを実装する（正常 / トークン不一致 / 未知 tab_id / 重複）（純粋ロジックのためモック不要）

## 4. macOS 通知（ネイティブ Swift）

- [x] 4.1 `macos/Runner/MainFlutterWindow.swift` に新規 `MethodChannel`（`roola/notification`）を登録（既存 `roola/trash` 等と同パターン）
- [x] 4.2 `UNUserNotificationCenter` で通知を発射する Swift 実装を追加（タイトル / 本文 / サウンド）。Info.plist は通知に専用のキーが不要なため変更なし（フォアグラウンド表示用に delegate を設定）
- [x] 4.3 `requestAuthorization`（初回許可要求）と許可状態照会のメソッドを同チャンネルに実装する（`openSystemSettings` も追加）
- [x] 4.4 Dart 側に通知発射 Repository を新設し、`MethodChannel` をラップ（タイトル / 本文 / 許可状態照会）。data 層にネイティブ依存を閉じ込める（`task_notification_repository.dart`）

## 5. 完了検知から通知までの結線

- [x] 5.1 受信口の照合成功時に、対象セッションのタブ名 / 作業ディレクトリを本文に含めて通知 Repository を呼ぶフローを実装する（`TaskNotificationServerNotifier._maybeNotify`）
- [x] 5.2 機能 ON/OFF 状態を参照し、無効時は照合成功でも通知を発射しないようにする
- [x] 5.3 通知未許可時は発射せず、状態を設定画面へ反映できるようにする（未許可時はネイティブ側で握り潰し、設定画面に許可状態を表示）

## 6. 設定 UI（Polaris 準拠）

- [x] 6.1 設定画面に「Claude Code タスク完了通知」セクションを追加（Polaris / ADR-0038・ADR-0054 準拠）（`task_notification_section.dart`）
- [x] 6.2 機能 ON/OFF トグルと永続化を実装する（`task_notification_settings*.dart`）
- [x] 6.3 確定ポートを埋め込み、トークンを `$ROOLA_NOTIFY_TOKEN` 環境変数参照にした Stop フック JSON スニペットを生成し、コピー可能に表示する（`buildHookSnippet`）
- [x] 6.4 通知許可状態の表示と、未許可時の許可要求 / システム設定誘導の導線を追加する

## 7. 検証・ドキュメント

- [x] 7.1 実機で end-to-end 確認（Roola で claude 起動 → settings.json にスニペット登録 → ターン完了で通知発火 → Roola 外 claude / トークン不一致が通知されないこと）
- [x] 7.2 ポート競合・アプリ再起動・通知未許可・Esc 中断（通知が出ない）の各ケースを確認する
- [x] 7.3 `flutter analyze` / `dart format` / 関連テストを通す（analyze: No issues / 全 304 テスト pass）
- [x] 7.4 必要に応じ `docs/` の関連記述を更新する（ADR-0057 追加・CLAUDE.md の ADR 一覧へ追記。design-system 等は変更不要）
