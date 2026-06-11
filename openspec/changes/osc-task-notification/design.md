# Design: osc-task-notification

## Context

現行のタスク通知（ADR-0057）は out-of-band 経路（Stop フック → HTTP POST →
トークン + タブ照合）で動く。ADR-0066 で in-band の OSC 方式への移行を決定済み。
スパイク（2026-06-11、`docs/notes/2026-06-11-ai-era-concept-review.md`）で確認済みの事実:

- claude 2.1.173 は `preferredNotifChannel` 未設定（auto）+ `TERM_PROGRAM=iTerm.app` で
  `ESC ] 9 ; <message> BEL` を出力する（実機キャプチャ済み）
- claude はフォーカストラッキング（CSI ?1004h を有効化し CSI I / CSI O を受信）で
  「フォーカス中は通知を抑制」する。FocusOut を受けていない場合は通知しない
- SwiftTerm: OSC 777（`notify;title;body`）はネイティブ解釈で
  `TerminalDelegate.notify(source:title:body:)` を呼ぶ。`registerOscHandler(code:handler:)`
  は公開 API で、登録ハンドラは組み込み switch より優先される
- xterm.js（Windows 同梱バンドル）: `registerOscHandler(ident, cb)` が公開 API

現行実装の関連箇所:

- PTY 起動と環境変数注入: `lib/data/terminal_runner/pty_terminal_runner.dart`
- macOS ターミナルビュー: `macos/Runner/TerminalPlatformView.swift`
  （`RoolaTerminalView: NSView, TerminalViewDelegate`、`bell()` は空実装）
- macOS 通知: `MainFlutterWindow.swift` の `UNUserNotificationCenter`（`roola/notification`
  MethodChannel。デリゲートは `willPresent` のみで `didReceive` 未実装）
- フォーカス管理: `focusedTabId` / `window_activation_provider.dart`（ADR-0055）
- Windows ターミナル: `assets/js/xterm/terminal.html` + xterm.js（ADR-0058 D1）
- Windows 通知: `notification_service_windows.dart`（`local_notifier`）

## Goals / Non-Goals

**Goals:**

- Roola 内で起動した CLI ツール（claude を含む任意のツール）の OSC 9/777 通知を
  ユーザー設定ゼロで OS 通知に中継する
- フォーカス中のペインからの通知は抑制する（claude 側の抑制を正しく機能させる +
  受信側でも同等のポリシーを適用する）
- 通知クリックで該当ペインにフォーカスを戻す（両 OS）
- ADR-0057 実装と並走できる（同時に有効でも通知が二重にならないこと）

**Non-Goals:**

- ADR-0057 実装の撤去（OSC 版の安定確認後、後続 change で行う）
- OSC 133 による実行中／入力待ちの状態検知（将来の別 ADR / change）
- アプリ外で起動されたセッションの観測（ADR-0066 Decision 6 のスコープ原則）
- kitty プロトコル（OSC 99）の構造化パース（OSC 9/777 で十分。必要になれば追加）

## Decisions

### D1: `TERM_PROGRAM=iTerm.app` を全 PTY に注入する

`pty_terminal_runner.dart` の環境変数構築で `TERM_PROGRAM=iTerm.app` /
`TERM_PROGRAM_VERSION=3.5.0` を設定する。スパイクで実機検証済みの唯一の組み合わせ。

- 代替案: ghostty チャネル（OSC 777・SwiftTerm ネイティブと一致）→ emit されるシーケンスの
  実機確認が未実施のため見送り。受信側は 777 にも対応するので将来の切替は受信側変更なしで可能
- 代替案: ユーザーに `preferredNotifChannel=iterm2` を案内 → 設定ゼロの方針に反する
- 既存の環境変数（`ROOLA_TAB_ID` 等）の注入と同じ場所で行い、特定 action 種別に
  限定しない（claude 以外のツールも OSC を吐けるため全 PTY で有効にする）

### D2: 通知イベントはネイティブ → Dart へ MethodChannel で上げ、発射は Dart 層で判断する

OSC を解釈したネイティブビュー（SwiftTerm / xterm.js→WebView）は「通知要求イベント
（title / body / ペイン識別子）」を Dart に上げるだけにし、OS 通知を出すか否かの判断
（フォーカス状態・並走時の重複抑止・将来の通知センター化）は Dart 層に集約する。

- 理由: 通知ポリシーが 1 箇所になり、両 OS で対称になる。既存の `roola/notification`
  チャネルと通知リポジトリ層をそのまま再利用できる
- 代替案: ネイティブで直接 `UNUserNotificationCenter` を叩く → ポリシーが OS ごとに
  分散し、ADR-0057 並走時の重複制御が難しくなるため不採用

### D3: フォーカス転送はネイティブビューのファーストレスポンダ変化で行う

macOS は `RoolaTerminalView` の `becomeFirstResponder` / `resignFirstResponder` で
CSI I / CSI O を PTY へ書く（アプリレベルのウィンドウアクティブ化は ADR-0055 の
既存機構がフォーカスペインを復元するので、ビューのレスポンダ変化に一本化できる）。
Windows は xterm.js の `textarea` focus/blur（または Flutter 側フォーカスノード変化の
WebView 通知）で同じ CSI を書く。

- 注意: CSI ?1004h（フォーカスレポーティング有効化）をアプリが受けたときだけ送るのが
  プロトコル上正しい。SwiftTerm / xterm.js のフォーカスレポーティング対応状況を実装時に
  確認し、組み込み対応があればそれを使う（自前送信はフォールバック）

### D4: 通知クリック → ペインフォーカスは通知自体に sessionId を載せて解決する

（実装時に簡素化: 当初案の「通知 ID → tabId マップ」は持たない。マップと
タブクローズ時の掃除が丸ごと不要になる。）通知発射時に sessionId
（ad-hoc セッション id）を通知へ直接載せ、クリック時にワークスペースから
タブを解決する:

- macOS: `userInfo["sessionId"]` に載せ、`UNUserNotificationCenterDelegate.didReceive`
  が `roola/notification` チャネルの逆方向 `notificationClicked` で Dart へ送る
- Windows: `LocalNotification.onClick` クロージャに sessionId を束縛する
- Dart: `notification_click_provider.dart`（App から常駐 watch）が sessionId から
  `TerminalTab` を探して `activateTab`、ADR-0055 の復帰経路を
  `WindowActivation.bump()` で再利用。タブが見つからなければ no-op

### D5: 並走期間中、両経路は互いに抑止せず独立して発射する（安定確認後にフック経路を撤去）

（実装後に 2 度改訂。当初の「OSC 受信実績のあるセッションのフック通知を破棄」
する重複抑止は、別イベントの混同だったため撤廃。次に「フック経路を即時完了
通知のオプションとして存続」する案を採ったが、Ghostty 等の既存ターミナルも
同じ意味論で運用されていることを確認し、**撤去方針に戻した**。）

実機確認で判明した両経路のイベントの違い:

- フック（Stop）= **タスク完了の瞬間**に発火
- OSC（claude ネイティブ）= 許可待ち（即時）と**入力待ち 60 秒アイドル**
  （`messageIdleNotifThresholdMs` 既定 60000）のみ。「完了の瞬間」の通知は
  claude ネイティブには存在しない — これは Ghostty / iTerm2 等でも同じ

決定:

- 完了通知の意味論は「完了から約 60 秒後のアイドル通知」を正とする
  （既存ターミナルのネイティブ通知と同一・claude の標準設定
  `messageIdleNotifThresholdMs` で各自調整可能）
- 並走期間中は両経路を抑止し合わせない（別イベントのため。時間も 60 秒離れる）
- フック経路（ADR-0057 実装一式）は OSC 版の安定確認後、後続 change で撤去する

## Risks / Trade-offs

- [エスケープシーケンス注入: OSC 9 を含むファイルの `cat` で偽通知が出る]
  → ADR-0066 で許容済み（iTerm2 等と同じ前提）。通知文字列を権限付与等の入力として
  扱わない。通知のレート制限（同一ペイン連続通知の抑制）を入れて嫌がらせ耐性を上げる
- [`TERM_PROGRAM` 偽装により CLI が iTerm2 固有機能を有効化する]
  → SwiftTerm は OSC 1337 を解釈でき、未知シーケンスは無視されるため実害は限定的。
  問題が出たツールが見つかれば ADR-0066 Trade-offs に追記して個別判断
- [claude の通知挙動（フォーカス抑制・チャネル判別）は非公開実装で、将来変わりうる]
  → 受信側は OSC 9/777 という標準への対応であり claude 依存ではない。送信側が変わって
  も受信面は無傷。`preferredNotifChannel` が公開設定である限り経路は維持される
- [SwiftTerm のフォーカスレポーティング対応が不完全な可能性]
  → D3 のフォールバック（自前で CSI I/O 送信）で吸収。実装タスクに検証を含める
- [Windows 実機での送信側（claude → OSC 9）が未検証]
  → 受信側 API は確認済み。Windows 実装タスクの先頭で実機キャプチャを行い、
  NG なら Windows のみフック並走を継続して切り分ける

## Migration Plan

1. 本 change 実装後も ADR-0057 経路は温存（設定画面のフック節も残す）
2. OSC 版で数リリース安定運用（クラッシュ・通知漏れの報告がないこと）
3. 後続 change で ADR-0057 実装を撤去（`task_notification_server.dart` /
   `hook_installer.dart` / トークン注入 / 設定画面フック節 / 関連テスト）。
   設定画面には「フックを登録済みのユーザーは削除してよい」旨の案内を一時表示

ロールバック: OSC 受信ハンドラの登録を外せば現行挙動に完全に戻る（環境変数注入は
無害なので残してよい）。

## Open Questions

- SwiftTerm / xterm.js のフォーカスレポーティング（mode 1004）の組み込み対応状況
  （実装タスク内で確認。無ければ D3 フォールバック）
- 通知タイトルの既定値: OSC 9 は body のみのため、タイトルにはタブ名（実行中の
  action 名）を使う想定。タブ名が無い場合の表記は実装時に決める
