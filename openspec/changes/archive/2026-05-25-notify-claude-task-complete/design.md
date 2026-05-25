## Context

Roola は PTY 上で Claude Code（`claude` CLI）を起動できる（ADR-0014 / ADR-0016）。
PTY のプロセス終了は `lib/data/terminal_runner/pty_terminal_runner.dart` が
`Pty.exitCode` で検知し `SkillRunState.completed` に遷移するが、これは「claude
プロセス自体の終了」であり「claude が 1 ターンの応答を終えて入力待ちに戻った」
という意味イベントとは別物である。後者は PTY 出力ストリームからは確実に判定でき
ない（長考・ツール実行待ちと入力待ちの区別がつかない）。

Claude Code には **Stop フック**があり、claude が応答を完了してユーザー入力待ちに
戻る直前にターン単位で 1 回発火する。Esc 中断時は発火しない、API エラー終了は
`StopFailure` で別イベントになる、という性質も確認済み。フックの stdin には
`session_id` / `cwd` / `transcript_path` / `hook_event_name` / `stop_hook_active`
を含む JSON が渡る。フックの `command` は claude のサブプロセスとして動くため、
Roola が PTY 起動時に注入した環境変数を継承できる。

ターミナル描画は SwiftTerm ネイティブビューへ移行済み（ADR-0031）で、PTY と UI は
分離されている。Dart ⇔ ネイティブ連携は `roola/trash` / `roola/updater` /
`roola/system/metrics` 等の `MethodChannel` 前例がある（ADR-0039 など）。

## Goals / Non-Goals

**Goals:**

- Roola が起動した Claude Code セッションのターン完了を、誤検知なく検知する。
- 完了時に macOS のローカル通知を出し、どのタブ/作業ディレクトリかが分かる本文に
  する。
- どのタブの完了かを確実に対応づける（同一 cwd の複数タブでも区別できる）。
- Roola 外の claude セッションや他ローカルプロセスからの通知混入を排除する。
- フック設定はユーザーの明示的な手作業とし、設定画面に手順・ポート・許可状態を
  提示する（Roola が `~/.claude/settings.json` を勝手に書き換えない）。

**Non-Goals:**

- PTY 出力アイドルによる完了推定（精度不足のため不採用）。
- Claude Code 以外（素のシェル / 任意コマンド）の完了通知。将来拡張余地は残すが
  本 change では対象外。
- 通知クリックで該当タブをフォーカスする挙動（任意・後続 change。ADR-0055 の機構と
  組み合わせ可能）。
- Roola による `~/.claude/settings.json` の自動編集。
- Windows / Linux 対応（Roola は macOS 専用）。

## Decisions

### D1: 検知トリガに Stop フックを採用（Notification / 出力アイドルではなく）

ターン完了の意味イベントを正確に取れるのは Stop フックのみ。Notification の
`idle_prompt` は権限待ち等で 1 タスク中に複数回発火しうるため「完了通知」には
過剰発火する。PTY 出力アイドル推定は長考・ツール実行待ちを完了と誤判定する。
→ **Stop フックを採用**。中断時（Esc）は通知が出ないが、これは望ましい挙動
（ユーザーが手元にいるため）。

**代替案**: Notification(idle_prompt) → 過剰発火で却下。出力アイドル推定 →
誤検知で却下。

### D2: セッション照合に環境変数（タブ ID + 起動ごとトークン）を注入

claude の `session_id` は claude 側採番で Roola は事前に知らない。cwd 照合は同一
ディレクトリ複数タブで曖昧。フック command は PTY の子プロセスなので、Roola が
PTY 起動時に環境変数を注入すればフックから読める。

- `ROOLA_TAB_ID`: 完了したセッション（タブ/エントリ）を一意に指す。
- `ROOLA_NOTIFY_TOKEN`: アプリ起動ごとに生成するランダムトークン。受信口で照合し、
  Roola が注入していない（=Roola 外 / 偽）リクエストを排除する。

フックはこの 2 値 + stdin の `session_id` / `cwd` を受信口へ送る。受信側は
`ROOLA_NOTIFY_TOKEN` が当該起動のトークンと一致し、かつ `ROOLA_TAB_ID` が現在
有効なセッション（`ActiveSessions`）に存在する場合のみ通知する。

`pty_terminal_runner.dart` の `Pty.start()` に `environment` を渡して注入する
（起動箇所で実装確認）。

**代替案**: cwd のみで照合 → 多重タブで曖昧、却下。transcript_path 照合 → Roola が
事前に知り得ず却下。

### D3: 受信口は Dart 側ローカル HTTP サーバ（127.0.0.1 限定）

タブ照合に必要な状態（`ActiveSessions` / entryId）は Dart にある。受信ロジックを
Dart に置けば照合が素直。`dart:io` の `HttpServer.bind(InternetAddress.loopbackIPv4,
port)` で完結し外部依存ゼロ。

- バインドは **127.0.0.1 のみ**（ループバック）。LAN には一切公開しない。
- ポートは固定既定値を持ちつつ、競合時はフォールバックする（確定ポートを設定画面に
  表示）。フックスニペットには確定ポートを埋め込む。
- エンドポイントは単一（例 `POST /hook/stop`）。ボディは JSON
  `{tab_id, token, session_id, cwd}`。

**代替案**: Unix ドメインソケット → `nc -U` 依存・スニペットが複雑化。HTTP +
トークンで十分なため採用見送り（将来オプション）。ファイル + FSEvents →
リアルタイム性に劣る、却下。Swift 側に HTTP サーバ → 照合状態が Dart にあるため
往復が増える、却下。

### D4: 通知発射は Swift `UNUserNotificationCenter`（MethodChannel 経由）

`flutter_local_notifications` は導入しない（ADR-0005 自己完結方針・既存ネイティブ
連携前例との整合）。`macos/Runner/MainFlutterWindow.swift` に新規 `MethodChannel`
（例 `roola/notification`）を登録し、Dart からタイトル/本文を渡して通知要求する。
初回に `UNUserNotificationCenter.requestAuthorization` で許可を求め、許可状態の
照会も同チャンネルで提供する。macOS 13+（ADR-0031 で最小バージョン引き上げ済み）
なので `UserNotifications` framework は標準装備。

**代替案**: `flutter_local_notifications` → 依存追加、却下。

### D5: フック登録はユーザー手作業 + 設定画面で案内

Roola が `~/.claude/settings.json` を自動編集すると外部設定への依存・破壊リスクが
生じ ADR-0005 と緊張する。設定画面に「コピペ用 JSON スニペット（確定ポート埋め込み
済み）」「使用ポート」「通知許可状態と再許可導線」「機能 ON/OFF」を表示し、ユーザー
が自分で `~/.claude/settings.json` に貼る運用とする。スニペットは stdin JSON を
`jq` で抜き、環境変数 `$ROOLA_TAB_ID` / `$ROOLA_NOTIFY_TOKEN` と合わせて `curl` で
受信口へ POST する形（末尾 `|| true` で claude 側に影響を与えない）。

## Risks / Trade-offs

- **ユーザーがフック設定を行わないと機能しない** → 設定画面でコピペ用スニペットと
  手順を提示。通知許可状態と合わせて「未設定/未許可」を可視化し導線を明確にする。
- **`jq` 依存（スニペット内）** → macOS には標準同梱されないが Claude Code 利用者の
  多くは導入済み。スニペットに前提を明記し、`jq` 不要の素の sed/シェル版も併記
  検討（タスクで判断）。
- **ローカルポートへの偽 POST** → 127.0.0.1 限定バインド + 起動ごとランダムトークン
  照合で、トークンを知らないローカルプロセスからの偽通知を排除。
- **ポート競合** → 既定ポートが使用中なら空きへフォールバックし、確定ポートを設定
  画面とスニペットに反映。アプリ再起動でポートが変わりうる点はスニペット再取得で
  対応（設定画面に「コピーし直し」を促す）。
- **トークンが起動ごとに変わる** → 旧トークンの POST は照合で弾かれ無害。ただし
  ユーザーがスニペットを貼り直さないと通知が来ないため、トークンを `settings.json`
  に埋め込ませず「ポートのみ埋め込み + トークンは環境変数参照」にすることで再貼付
  不要にする（スニペットは `$ROOLA_NOTIFY_TOKEN` を参照するだけ）。
- **`stop_hook_active` による多重発火** → Stop フックがブロックを返さない（通知のみ
  で `exit 0`）限りループしない。受信側も同一 turn の重複 POST を短時間デデュープ
  する余地を残す。
- **Esc 中断で通知が出ない** → 仕様どおり（ユーザーが手元にいる）。Non-Goal。
- **`stop_reason` 等の未確定フィールドに依存しない** → 設計は `session_id` / `cwd`
  と注入環境変数のみに依存させ、調査で「推測」だったフィールドは使わない。
