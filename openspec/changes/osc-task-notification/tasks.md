# Tasks: osc-task-notification

## 1. PTY 環境変数注入（送信側の有効化）

- [x] 1.1 `pty_terminal_runner.dart` の環境変数構築に `TERM_PROGRAM=iTerm.app` /
      `TERM_PROGRAM_VERSION=3.5.0` を追加する（全 PTY 対象・既存の注入箇所に追記）
      → 実装は環境構築の集約点 `notification_environment.dart` で実施
- [x] 1.2 注入のユニットテストを追加する（環境マップに両キーが含まれること）

## 2. macOS 受信側（SwiftTerm）

- [x] 2.1 SwiftTerm のフォーカスレポーティング（mode 1004）の組み込み対応状況を確認し、
      design.md D3 の方式（組み込み or 自前 CSI I/O 送信）を確定する
      → **組み込みで完結**。`MacTerminalView` が first responder 変化で
      `setTerminalFocus` → mode 1004 有効時に CSI I/O を自動送出。自前実装は不要
- [x] 2.2 OSC 777 受信を実装する
      → 設計変更: `TerminalViewDelegate` に notify は転送されないため、
      デリゲートではなく `registerOscHandler(777)` の明示登録で受ける
- [x] 2.3 `registerOscHandler(9)` で OSC 9（body のみ）を受信し、同じ経路に流す
      （`9;4` ConEmu 進捗は通知でないため除外）
- [x] 2.4 通知要求（title / body）を既存の per-tab ctrl チャネル
      （`roola/terminal/<channelId>/ctrl`）の `notify` メソッドで Dart へ送る
- [x] 2.5 フォーカスの CSI I / CSI O 書き込み → 2.1 のとおり SwiftTerm 組み込みで
      充足（first responder の付け外しは ADR-0037 の既存ブリッジが駆動）。実機確認は 6.1

## 3. Windows 受信側（xterm.js）

- [ ] 3.1 Windows 実機で claude の OSC 9 出力をキャプチャ確認する
      （NG の場合: design.md Risks の切り分けに従い Windows のみフック並走を継続）
      ※ 本セッション（macOS）では実施不可。Windows 機での確認が必要
- [x] 3.2 OSC ハンドラを追加し通知要求を WebView ブリッジへ送る
      → 実行時 HTML は `terminal.html` ではなく `terminal_surface_windows.dart` の
      `_buildHtml`（terminal.html は未参照のプレビュー用・同期済み）。
      `notify` メッセージ型を追加し、`channelId` を Windows サーフェスへ受け渡し
- [x] 3.3 フォーカスの CSI I / CSI O → **xterm.js が mode 1004 を組み込みで処理**
      （`sendFocus` → focus/blur で自動送出）。自前実装不要。実機確認は 6.1

## 4. Dart 通知判断層

- [x] 4.1 通知要求イベントの受信口を data 層に追加する
      → `TerminalChannel.onNotify` + `OscNotificationController`。引数 2 つの
      イベントのため Freezed モデルは作らず素のパラメータ（表示専用・DTO 分離不要の規約どおり）
- [x] 4.2 通知ポリシーを実装する（`osc_notification_policy.dart`）: フォーカス中破棄・
      セッション単位レート制限（既定 2 秒・cat 洪水対策）・タイトル補完はコントローラ側
      - 設計メモ: OSC 経路は `TaskNotificationSettings.enabled`（ADR-0057 の opt-in トグル）を
        参照しない。設定ゼロ要件のため。通知許可が未決定なら初回発射時に要求する
- [x] 4.3 ~~ADR-0057 経路との重複抑止~~ → **撤回**（design.md D5 改訂・2026-06-11）。
      フック = 完了の瞬間 / OSC = 60 秒アイドルで別イベントのため抑止しない。
      フック経路は即時完了通知のオプションとして存続（`isOscActive` は削除）
- [x] 4.4 既存のネイティブ通知発射（`taskNotificationRepositoryProvider`）へ接続
- [x] 4.5 通知ポリシーのユニットテスト（7 ケース: フォーカス破棄・レート制限・
      セッション独立・OSC 実績・forgetSession）

## 5. 通知クリック → ペインフォーカス復帰

- [x] 5.1 ~~通知 ID ⇄ tabId のマップ~~ → 設計簡素化: マップは持たず、通知の
      `userInfo`（macOS）/ onClick クロージャ（Windows）に sessionId を直接載せる。
      クリック時にワークスペースからタブを解決するため、タブクローズ時の掃除も不要
- [x] 5.2 macOS: `didReceive` デリゲートを追加し、`notificationClicked` を
      `roola/notification` チャネルの逆方向で Dart へ送る
- [x] 5.3 Windows: `LocalNotification.onClick` で同じ
      `TaskNotificationRepository.onNotificationClick` 経路に乗せる
- [x] 5.4 クリック受信 → `notification_click_provider.dart`（App から常駐 watch）が
      sessionId からターミナルタブを解決して `activateTab` + ADR-0055 復帰経路を
      `WindowActivation.bump()` で再利用。タブ消滅時は no-op。
      フック経路（ADR-0057）の通知も sessionId を載せたためクリック復帰に相乗り

## 6. 検証・仕上げ

- [ ] 6.1 spec の全シナリオを実機（GUI）で確認する — **手動確認チェックリスト**:
      - [ ] macOS: ペインで `printf '\e]9;Hello\a'` → 通知（フォーカス中は出ない →
            別ペインに移ってから実行）
      - [ ] macOS: `printf '\e]777;notify;Build;Done\a'` → タイトル「Build」の通知
      - [ ] macOS: claude を起動し許可待ちにする（別ペインへフォーカスを移す）→
            「Claude needs your permission」通知（フック・設定なしで出ること）
      - [ ] 通知クリック → ウィンドウ前面化 + 該当ペインへフォーカス。
            タブを閉じてからクリック → 何も起きない
      - [ ] OSC 9 を 100 個含むファイルを `cat` → 通知は 1 件程度
      - [x] claude 完了 → 即時には出ず、約 60 秒後に「Claude is waiting for your
            input」が出る（2026-06-11 オーナー実機で確認・仕様として確定）
      - [ ] （並走確認・任意）フック登録 + 有効化済み環境で claude 完了 →
            完了の瞬間に「完了しました」、60 秒後に OSC 通知（互いに抑止しないこと。
            フック経路は安定確認後に後続 change で撤去予定）
      - [ ] Windows 実機で同セット（+ タスク 3.1 の送信側確認）
- [x] 6.2 `flutter analyze`（No issues）/ `flutter test`（361 件パス）/
      `dart format`（変更ファイル 0 差分）/ `flutter build macos --debug`（Swift コンパイル成功）
- [ ] 6.3 docs/notes の検討ノートに実装完了を追記し、Issue #85 をクローズできる状態にする
      （6.1 の手動確認が済んでから）
