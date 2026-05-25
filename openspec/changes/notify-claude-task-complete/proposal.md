## Why

Roola で Claude Code を起動すると、応答生成中はユーザーが他の作業に移ることが
多い。だが「タスクが終わって入力待ちに戻った」ことを知る手段はアプリ内になく、
ユーザーは定期的にターミナルタブを覗きに行く必要がある。長い処理ほど待ち時間が
読めず、注意の分散コストが高い。Claude Code が応答を完了した瞬間を macOS 通知で
知らせれば、ユーザーはタブから目を離して安心して別作業に集中できる。

## What Changes

- Roola が起動する Claude Code セッションについて、**Claude のターン完了（応答
  完了→ユーザー入力待ち復帰）** を検知して macOS のローカル通知を出す。
- 検知は **Claude Code の Stop フック** を用いる（PTY 出力のアイドル推定ではなく、
  意味的に正確なターン完了イベントを使う）。Notification(idle_prompt) は 1 タスク
  中に複数回発火しうるため採用しない。
- Roola は PTY 起動時に **識別子（タブ ID + 起動ごとのランダムトークン）を環境
  変数として注入** する。フックはこの値を読んで Roola のローカル受信口へ送るため、
  Roola 外で起動した Claude セッションや別アプリからの偽通知と区別できる。
- Roola アプリ内に **ローカル HTTP 受信口（127.0.0.1 限定・Dart `dart:io`
  HttpServer）** を立て、Stop フックからの POST を受ける。トークンと有効セッション
  を照合し、一致したときだけ通知を発射する。
- macOS 通知の発射は **Swift の `UNUserNotificationCenter`** で行う（既存
  `roola/trash` 等と同じ `MethodChannel` パターン）。`flutter_local_notifications`
  は導入しない（ADR-0005 自己完結方針・既存ネイティブ連携前例との整合）。
- フックは Roola が勝手に書き込まず、**ユーザーが手で `~/.claude/settings.json`
  に登録** する。設定画面に使用ポートとコピペ用 JSON スニペット、通知許可状態と
  許可導線、機能の ON/OFF を表示する。
- 設計判断（Stop フック採用・環境変数によるセッション照合・ローカル HTTP 受信口・
  通知のネイティブ実装）を ADR として `docs/adr/` に 1 件追加する。

## Capabilities

### New Capabilities

- `claude-task-notification`: Roola 起動の Claude Code セッションのターン完了を
  Stop フック経由で検知し、対象セッションを環境変数トークンで照合した上で macOS
  ローカル通知を発射する仕組み。フック登録手順・使用ポート・通知許可・ON/OFF を
  扱う設定 UI を含む。

### Modified Capabilities

<!-- 既存 spec の要件変更なし。PTY 起動時の環境変数注入は実装詳細であり、
     ターミナル実行 capability の要件は変えない。 -->

## Impact

- **ネイティブ (macOS)**: `macos/Runner/MainFlutterWindow.swift` に通知発射用の
  新規 `MethodChannel`（例 `roola/notification`）を登録。`UNUserNotificationCenter`
  での通知要求と初回の許可リクエストを行う Swift 実装を追加。`Info.plist` に
  必要な通知許可設定を追加。
- **data 層**: ローカル HTTP 受信口とセッション照合を `lib/data/` 配下の新規
  サービス（例 `lib/data/task_notification/`）に隔離。通知発射は MethodChannel を
  ラップした Repository に閉じ込める。
- **PTY 起動**: `lib/data/terminal_runner/pty_terminal_runner.dart` の
  `Pty.start()` に環境変数（`ROOLA_TAB_ID` + トークン）注入を追加。
- **状態管理**: 受信口の起動・ポート確定・有効セッション照合を Riverpod の
  Notifier/AsyncNotifier で保持。`ActiveSessions`（`lib/data/skill_session/`）の
  セッション情報と突き合わせる。
- **UI（設定）**: 設定画面に「Claude Code タスク完了通知」セクションを追加
  （ON/OFF・使用ポート表示・コピペ用 JSON スニペット・通知許可状態と再許可導線）。
  Polaris デザインシステム（ADR-0038 / ADR-0054）に準拠。
- **ドキュメント**: ADR を 1 件追加（設計判断の記録）。CLAUDE.md の ADR 一覧に追記。
- **権限/セキュリティ**: ローカル受信口は 127.0.0.1 のみにバインドし、起動ごとの
  ランダムトークン照合で他ローカルプロセスからの偽通知を排除する。
