## 1. 設計判断の記録

- [x] 1.1 `docs/adr/0008-keep-alive-skill-sessions.md` を追加する（セッションを実行画面 widget 生存から `session-registry` の登録に紐づけ直す判断・Terminal を data 層に置く判断の背景）
- [x] 1.2 `docs/adr/README.md` に ADR-0008 をリンク追加
- [x] 1.3 `CLAUDE.md` の ADR リストに ADR-0008 を追記

## 2. session-registry (新規)

- [x] 2.1 `lib/data/skill_session/active_sessions.dart` を作成し、`@Riverpod(keepAlive: true)` 注釈の `ActiveSessions` Notifier を実装する（state は `Map<String, SkillRunState>`、`register` / `updateState` / `unregister` / `cancelAll` を公開。cancel ハンドルは内部 `_cancelHandlers` で保持）
- [x] 2.2 `dart run build_runner build` を実行し generator 出力を commit する
- [x] 2.3 `test/data/skill_session/active_sessions_test.dart` を追加し、register / updateState / unregister / cancelAll の挙動と購読更新を検証する（9 テスト）

## 3. skill-runner: Terminal 保有とライフサイクル変更

- [x] 3.1 `lib/data/skill_runner/skill_runner.dart` (interface) に `Terminal get terminal` ゲッターと `Future<void> dispose()` を追加する
- [x] 3.2 `lib/data/skill_runner/pty_skill_runner.dart` を改修する
  - コンストラクション時に `Terminal` インスタンスを生成（xterm デフォルトのスクロールバック）
  - `terminal.onOutput` / `terminal.onResize` をコンストラクタで配線（PTY 未起動時は破棄）
  - `start()` 内で PTY 出力を `terminal.write(utf8.decode(...))` と `_outputController.add(...)` の双方へ流す
  - `cancel()` は PTY kill + state を cancelled に遷移。Terminal と controllers は保持
  - `dispose()` を新設し、Terminal の listener 解除と controllers の close をまとめて行う
- [x] 3.3 既存テスト `test/data/skill_runner/pty_skill_runner_test.dart` を新しい挙動に追従させる（`cancel` 後も Terminal が参照可能、`dispose` で onOutput / onResize が外れる）

## 4. RunViewModel の keepAlive 化と責務再配置

- [x] 4.1 `lib/ui/run/run_view_model.dart` を `@Riverpod(keepAlive: true)` に変更
- [x] 4.2 build 後の microtask で `ActiveSessions.register(entryId, runner.currentState, cancel: runner.cancel)` を呼ぶ（Riverpod 3.x で build 中の他 provider 変更は禁止）
- [x] 4.3 `runner.state.listen` で state を更新する際に `ActiveSessions.updateState(entryId, next)` も呼ぶ
- [x] 4.4 `ref.onDispose` で `runner.dispose()` を呼ぶ（明示破棄経路: View 側で invalidate されたら発火）
- [x] 4.5 公開メソッドを整理する
  - `cancelRun()`: PTY kill のみ（出力履歴とセッションは残す）
  - `restart()`: 既存通り（`ref.invalidateSelf()`）
  - 「閉じる」操作は keepAlive provider を自身から invalidate できないため View 側で `unregister + container.invalidate` の 2 行で書く（コメントで明示）
- [x] 4.6 `dart run build_runner build` で generator 出力を更新する
- [x] 4.7 `test/ui/run/run_view_model_test.dart` を新規追加し、register / updateState / 閉じるフロー / cancelRun の挙動をテストする（4 テスト）

## 5. RunPage の UI 変更

- [x] 5.1 `lib/ui/run/run_page.dart` から `_useWiredTerminal` Hook を削除し、`pageState.runner.terminal` を直接 `TerminalView` に渡す形にする
- [x] 5.2 `_ActionButtons` のボタン構成を以下に変更する
  - 常時: 「ホームへ戻る」🏠（cancel せず pop / go('/')）
  - running 中: 「キャンセル」⏹
  - 終了状態（completed / failed / cancelled）: 「再実行」🔄 と 「閉じる」✕
- [x] 5.3 「ホームへ戻る」ボタンから `await viewModel.cancelRun()` を取り除く
- [x] 5.4 「閉じる」ボタンで `unregister + ref.invalidate + context.go('/')` を呼ぶ
- [x] 5.5 既存 widget test なし、動作確認は実機で行う想定

## 6. HomePage の拡張

- [x] 6.1 `lib/ui/home/active_sessions_strip.dart` を新規追加し、`activeSessionsProvider` を購読して chip 列を描画する（empty 時は `SizedBox.shrink()`）
- [x] 6.2 chip タップで `RunRoute(entryId: ...).go(context)`
- [x] 6.3 `lib/ui/home/home_page.dart` の `body` を `Column` にして上部に `ActiveSessionsStrip` を配置
- [x] 6.4 `_LauncherTile` の `_Icon` を `Stack` で包み、セッションあり時に右上に `_SessionBadge` を重ねる（`sessionStateIcon()` を strip と共有）
- [x] 6.5 各エントリアイコンタップは現状通り `RunRoute().go`。`runViewModelProvider(id)` が keepAlive のため同一 id なら既存セッションに復帰する（動作確認は実機で）
- [x] 6.6 `test/ui/home/active_sessions_strip_test.dart` を追加（空時非表示・複数 chip 描画・タップ遷移、3 テスト）
- [x] 6.7 既存 `test/widget_test.dart` は変更なし（空状態の挙動は破壊していない）

## 7. アプリ終了フロー

- [x] 7.1 `ActiveSessions.cancelAll()` は Section 2.1 で先行実装済み（内部 `_cancelHandlers` を `Future.wait` で一括 invoke）
- [x] 7.2 `main.dart` の起動時に `windowManager.setPreventClose(true)` を呼ぶ
- [x] 7.3 `lib/app/window_close_guard.dart` を新規追加する
  - `HookConsumerWidget` として `MaterialApp.router` の builder 配下に常駐
  - `WindowListener` を `useEffect` で attach / detach
  - `onWindowClose` で `activeSessionsProvider` を読み、空 → `windowManager.destroy()`、非空 → 確認ダイアログ表示
  - ダイアログで Yes → `ActiveSessions.cancelAll()` → `windowManager.destroy()`、No → 何もしない
  - 確認ダイアログ表示は `showSessionCloseConfirmation()` として独立関数化（テスタブル化のため）
- [x] 7.4 `lib/app/app.dart` の Widget ツリー（`MaterialApp.router.builder`）に `WindowCloseGuard` を組み込む
- [x] 7.5 `test/app/window_close_guard_test.dart` を追加し、確認ダイアログのタイトル / セッション件数表示 / 「終了する」「キャンセル」の戻り値を検証する（2 テスト。`windowManager` 自体は plugin 呼び出しで test 環境では動かないため、ダイアログ関数を分離してそこをテスト）

## 8. 動作検証と仕上げ

- [x] 8.1 `make check`（format / analyze / test）を実行し緑にする（44 テスト green）
- [ ] 8.2 macOS 実機で以下のシナリオを通す
  - skill A を起動 → ホームへ戻る → ホームに chip と badge が出る
  - skill B を起動（並行） → A / B 両方の chip が出る
  - chip A タップ → A の出力履歴が残っている
  - A をキャンセル → chip 状態が cancelled に変化、出力は残る
  - A の「閉じる」 → chip と badge が消える
  - 再度 skill A を起動できる
  - 実行中セッションあり状態で × / Cmd+Q → 確認ダイアログ → キャンセルで継続 / 終了で全 PTY が落ちて終了
  - 全セッション閉じた状態で × → 確認なしで終了
- [x] 8.3 README にホーム上部の chip 列・「キャンセル」と「閉じる」の使い分け・終了時確認ダイアログの説明を追記
- [x] 8.4 README の「想定される症状」表に「Mac スリープから復帰すると、進行中だった Skill が API ストリーミング切断で `failed` 状態になることがある」を 1 行追記

## 9. アーカイブ

- [ ] 9.1 全タスク完了後、本 change をアーカイブ済みとして `openspec/changes/archive/<date>-concurrent-skill-sessions/` に移す（または OpenSpec の archive コマンドに従う）
