# Tasks: osc-task-notification

## 1. PTY 環境変数注入（送信側の有効化）

- [ ] 1.1 `pty_terminal_runner.dart` の環境変数構築に `TERM_PROGRAM=iTerm.app` /
      `TERM_PROGRAM_VERSION=3.5.0` を追加する（全 PTY 対象・既存の注入箇所に追記）
- [ ] 1.2 注入のユニットテストを追加する（環境マップに両キーが含まれること）

## 2. macOS 受信側（SwiftTerm）

- [ ] 2.1 SwiftTerm のフォーカスレポーティング（mode 1004）の組み込み対応状況を確認し、
      design.md D3 の方式（組み込み or 自前 CSI I/O 送信）を確定する
- [ ] 2.2 `TerminalPlatformView.swift` の `RoolaTerminalView` に
      `notify(source:title:body:)` デリゲートを実装する（OSC 777 受信）
- [ ] 2.3 `registerOscHandler(9)` で OSC 9（body のみ）を受信し、notify と同じ経路に流す
- [ ] 2.4 通知要求（title / body / viewId）を MethodChannel で Dart へ送る
      （既存のターミナルチャネルにイベントを追加）
- [ ] 2.5 ファーストレスポンダ変化（`becomeFirstResponder` / `resignFirstResponder`）で
      CSI I / CSI O を PTY へ書き込む（2.1 の確定方式に従う）

## 3. Windows 受信側（xterm.js）

- [ ] 3.1 Windows 実機で claude の OSC 9 出力をキャプチャ確認する
      （NG の場合: design.md Risks の切り分けに従い Windows のみフック並走を継続）
- [ ] 3.2 `terminal.html` に `registerOscHandler(9)` / `registerOscHandler(777)` を追加し、
      通知要求を Flutter（WebView ブリッジ）へ送る
- [ ] 3.3 xterm.js のフォーカスイベントで CSI I / CSI O を PTY へ書き込む

## 4. Dart 通知判断層

- [ ] 4.1 通知要求イベント（title / body / tabId）の受信口を data 層に追加する
      （ネイティブイベント → モデル変換。Freezed モデル + リポジトリ）
- [ ] 4.2 通知ポリシーを実装する: フォーカス中ペインからの要求は破棄・
      同一ペインのレート制限・タイトル既定値（タブ名）の補完
- [ ] 4.3 ADR-0057 経路との重複抑止を実装する（OSC 受信実績のあるペインは
      HTTP 経路の通知を破棄。design.md D5）
- [ ] 4.4 既存のネイティブ通知発射（`roola/notification` / `local_notifier`）へ接続する
- [ ] 4.5 通知ポリシーのユニットテストを追加する（フォーカス破棄・レート制限・重複抑止）

## 5. 通知クリック → ペインフォーカス復帰

- [ ] 5.1 通知 ID ⇄ tabId のマップを通知発射時に登録する（タブクローズ時の掃除を含む）
- [ ] 5.2 macOS: `MainFlutterWindow.swift` に `UNUserNotificationCenterDelegate.didReceive`
      を追加し、クリックイベントを Dart へ送る
- [ ] 5.3 Windows: `notification_service_windows.dart` の `local_notifier` に
      onClick ハンドラを追加し、同じ Dart 経路に乗せる
- [ ] 5.4 クリック受信でウィンドウ前面化 + 該当タブへフォーカス
      （ADR-0055 のフォーカス復元機構を再利用。タブ消滅時は何もしない）

## 6. 検証・仕上げ

- [ ] 6.1 spec の全シナリオを実機で確認する（macOS / Windows、`printf` での OSC 9/777・
      claude 許可待ち通知・クリック復帰・cat 洪水のレート制限・フック併用の重複なし）
- [ ] 6.2 `flutter analyze` / `flutter test` / フォーマッタを通す
- [ ] 6.3 docs/notes の検討ノートに実装完了を追記し、Issue #85 をクローズできる状態にする
