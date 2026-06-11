# ADR-0057: Claude Code のタスク完了を Stop フック + ローカル受信口で macOS 通知する

- **Status**: Superseded by ADR-0066
- **Date**: 2026-05-25

> **Superseded**: 既定の通知経路は ADR-0066（通知エスケープシーケンス（OSC）
> 方式・設定ゼロ）に置き換えられた。ただし本 ADR の実装は撤去せず、
> 「タスク完了の瞬間に通知が欲しい」ユーザー向けのオプション機能として
> 存続する（OSC のネイティブ通知は許可待ちと入力待ち 60 秒アイドルのみで、
> 即時の完了通知を提供できないため。ADR-0066 Decision 7）。

## Context

Roola は PTY 上で Claude Code（`claude` CLI）を起動できる（ADR-0014 / ADR-0016）。
応答生成中はユーザーが他作業に移ることが多いが、「タスクが終わって入力待ちに
戻った」ことをアプリ内で知る手段がなく、ユーザーはターミナルタブを定期的に
覗きに行く必要がある。

PTY のプロセス終了は `pty_terminal_runner.dart` が `Pty.exitCode` で検知できるが、
これは「`claude` プロセス自体の終了」であって「1 ターンの応答を終えて入力待ちに
戻った瞬間」とは別物である。後者は PTY 出力ストリームからは確実に判定できない
（長考・ツール実行待ちと入力待ちの区別がつかない）。実際 runner には出力アイドル
による `waitingInput` 推定があるが、これは表示用の近似であり通知トリガには
精度が足りない。

## Decision

Claude Code の **Stop フック**を完了検知トリガに採用する。仕組みは以下:

1. Roola は `ClaudeSkillAction` の PTY 起動時に、当該セッションを一意に指す
   `ROOLA_TAB_ID` と、アプリ起動ごとに生成するランダムトークン
   `ROOLA_NOTIFY_TOKEN` を**環境変数として注入**する。フック command は
   `claude` のサブプロセスなのでこれらを継承して読める。
2. Roola はアプリ内に **ローカル HTTP 受信口**（`dart:io` の `HttpServer`、
   127.0.0.1 のみにバインド）を立てる。既定ポートが使用中なら空きポートへ
   フォールバックし、確定ポートを設定画面に表示する。
3. ユーザーは設定画面が提示するスニペットを `~/.claude/settings.json` に**手で
   登録**する。Stop フックは stdin の JSON（`session_id` / `cwd`）と環境変数
   `$ROOLA_TAB_ID` / `$ROOLA_NOTIFY_TOKEN` を受信口へ POST する。
4. 受信口は **トークンが当該アプリ起動のものと一致し、かつ `tab_id` が有効な
   セッションに存在する**場合のみ通知を発射する。
5. 通知発射は **Swift の `UNUserNotificationCenter`** を新規 `MethodChannel`
   （`roola/notification`）経由で呼ぶ。`flutter_local_notifications` は使わない。

## Why

Stop フックは「応答完了→入力待ち復帰」をターン単位で 1 回だけ知らせる意味的に
正確なイベントであり、ユーザーが Esc で中断した場合は発火しない（手元にいるので
通知不要という望ましい挙動）。環境変数注入により「Roola が起動したセッション」
だけを識別でき、同一ディレクトリの複数タブも区別できる。受信口を Dart 側に置く
のは、タブ照合に必要な状態（`ActiveSessions`）が Dart にあるため。

### 代替案 1: Notification(idle_prompt) フック

入力待ち状態への遷移で発火するが、権限待ち等で 1 タスク中に複数回発火しうる。
「タスク完了通知」としては過剰発火するため却下。

### 代替案 2: PTY 出力アイドル推定（既存 `waitingInput` を流用）

追加の外部設定が要らない利点はあるが、長考・ツール実行待ちを「完了」と誤判定
する。精度不足のため却下。

### 代替案 3: cwd / transcript_path によるセッション照合

cwd は同一ディレクトリ複数タブで曖昧。`transcript_path` は Roola が事前に知り得
ない。確実な対応づけには Roola 自身が注入した識別子が必要なため、環境変数方式を
採る。

### 代替案 4: Unix ドメインソケット受信口

権限分離は綺麗だがフックスニペットが `nc -U` 依存で複雑になる。127.0.0.1 +
トークン照合で偽通知は十分排除できるため、HTTP を採る（ソケットは将来オプション）。

### 代替案 5: `flutter_local_notifications` 導入

依存追加になる。`UNUserNotificationCenter` を既存 `MethodChannel` 前例
（`roola/trash` 等）と同じ形で直接叩けば自己完結方針（ADR-0005）と整合するため、
Swift 直書きを採る。

### 代替案 6: Roola が `~/.claude/settings.json` を自動編集

外部設定への暗黙依存・破壊リスクが生じ ADR-0005 と緊張する。設定画面で手順を
提示し、登録はユーザーの明示操作とする。

## Trade-offs

- ユーザーがフックを登録しないと機能しない。設定画面でスニペットと通知許可状態を
  可視化して導線を明確にする。
- スニペットは `jq` を用いる（macOS 標準同梱ではないが Claude Code 利用者は導入済み
  が多い）。前提を設定画面に明記する。
- ポートはアプリ再起動で変わりうる。トークンはスニペットに直書きせず環境変数
  `$ROOLA_NOTIFY_TOKEN` 参照にすることで、再起動でトークンが変わってもユーザーが
  貼り直す必要をなくす（ポート変更時のみ貼り直し）。
- 127.0.0.1 にローカルポートを開く。起動ごとランダムトークン照合で、トークンを
  知らない他ローカルプロセスからの偽通知を排除する。
- `stop_reason` 等の未確定なフック JSON フィールドには依存しない。設計は
  `session_id` / `cwd` と注入した環境変数のみに依存させる。

## References

- Claude Code Hooks: https://code.claude.com/docs/en/hooks.md
- Claude Code Hooks Guide: https://code.claude.com/docs/en/hooks-guide.md
- ADR-0005（自己完結方針）/ ADR-0016（汎用ランチャー）/ ADR-0039（ネイティブ
  MethodChannel 前例）
