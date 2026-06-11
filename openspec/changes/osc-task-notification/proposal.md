# Proposal: osc-task-notification

## Why

タスク通知（ADR-0057 / #83）は Stop フック → jq + curl → ローカル HTTP 受信口 →
トークン照合という経路で動いているが、(1) ユーザーが `~/.claude/settings.json` に
フックを手動登録しない限り一切動かない、(2) Stop 以外の通知（許可待ち等）に
広げるとフック登録面積が増えて Claude Code 設定を汚す、(3) HTTP サーバ・ポート競合・
トークンという照合インフラの保守コストが高い、という問題がある（Issue #85）。

スパイク検証（2026-06-11）で、通知エスケープシーケンス（OSC 9/777）方式なら
**ユーザー設定ゼロ・フックゼロ**で通知が成立し、照合インフラが丸ごと不要になることを
実機確認した。ADR-0066 でこの方式への移行を決定済み。本 change はその実装である。

## What Changes

- Roola が起動する PTY に `TERM_PROGRAM=iTerm.app` / `TERM_PROGRAM_VERSION` を注入し、
  Claude Code のネイティブ通知チャネル（OSC 9）を有効化する
- ターミナルレンダラが OSC 9 / OSC 777 通知シーケンスを解釈し、OS 通知に中継する
  - macOS: SwiftTerm の `notify` デリゲート実装（777 ネイティブ）+ `registerOscHandler(9)`
  - Windows: xterm.js の `registerOscHandler(9)` / `registerOscHandler(777)`
- ペインのフォーカス状態を CSI I（FocusIn）/ CSI O（FocusOut）として PTY へ転送する
  （claude は「フォーカス中は通知を抑制」するため、これが無いと通知が出ない）
- 通知クリックで該当ペインへフォーカスを復帰する
  （macOS: `UNUserNotificationCenter` の `didReceive` / Windows: `local_notifier` の onClick）
- ADR-0057 実装（HTTP 受信口・トークン・フックインストーラ・設定画面のフック節）は
  OSC 版の安定確認まで並走させる。撤去は本 change のスコープ外（後続 change で行う）
- **BREAKING なし**（既存のフック通知は当面そのまま動く）

## Capabilities

### New Capabilities

- `task-notification`: ターミナル内 CLI ツールからの in-band 通知（OSC 9/777）を
  OS 通知へ中継し、クリックで該当ペインへフォーカスを戻す。ベンダー中立
  （Claude Code 専用だった `claude-task-notification`〔2026-05-25 アーカイブ〕を置き換える）

### Modified Capabilities

（なし — `openspec/specs/` に昇格済みの既存 spec は存在しない）

## Impact

- **Dart**: `pty_terminal_runner.dart`（環境変数注入の変更）、ターミナルビュー周辺
  （フォーカス転送・通知イベントの受け口）、`task_notification_*`（並走のため温存）
- **macOS ネイティブ**: `TerminalPlatformView.swift`（`notify` デリゲート実装・
  `registerOscHandler(9)`・フォーカスレポーティング）、`MainFlutterWindow.swift`
  （通知デリゲート `didReceive` 追加・クリック → ペインフォーカスの MethodChannel）
- **Windows**: `assets/js/xterm/terminal.html`（OSC ハンドラ登録）、
  通知サービス（`notification_service_windows.dart` の onClick 対応）
- **依存関係**: 追加なし（SwiftTerm / xterm.js の既存 API のみ使用）
- **参照**: ADR-0066（決定）、ADR-0057（Supersede 対象・並走）、ADR-0055（フォーカス復元）、
  Issue #85、`docs/notes/2026-06-11-ai-era-concept-review.md`（スパイク結果）
