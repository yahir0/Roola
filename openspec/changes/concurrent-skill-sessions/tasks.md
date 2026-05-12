## 1. 設計判断の記録

- [ ] 1.1 `docs/adr/0008-keep-alive-skill-sessions.md` を追加する（セッションを実行画面 widget 生存から `session-registry` の登録に紐づけ直す判断・Terminal を data 層に置く判断の背景）
- [ ] 1.2 `docs/adr/README.md` に ADR-0008 をリンク追加
- [ ] 1.3 `CLAUDE.md` の ADR リストに ADR-0008 を追記

## 2. session-registry (新規)

- [ ] 2.1 `lib/data/skill_session/active_sessions.dart` を作成し、`@Riverpod(keepAlive: true)` 注釈の `ActiveSessions` Notifier を実装する（state は `Map<String, SkillRunState>`、`register` / `updateState` / `unregister` メソッドを公開）
- [ ] 2.2 `dart run build_runner build --delete-conflicting-outputs` を実行し generator 出力を commit する
- [ ] 2.3 `test/data/skill_session/active_sessions_test.dart` を追加し、register / updateState / unregister の挙動と購読更新を検証する

## 3. skill-runner: Terminal 保有とライフサイクル変更

- [ ] 3.1 `lib/data/skill_runner/skill_runner.dart` (interface) に `Terminal get terminal` ゲッターを追加する
- [ ] 3.2 `lib/data/skill_runner/pty_skill_runner.dart` を改修する
  - コンストラクション時に `Terminal` インスタンスを生成（カスタマイズ可能な MaxLines は xterm デフォルト維持）
  - `start()` 内で PTY 出力を `terminal.write(utf8.decode(...))` と既存 `_outputController.add(...)` の双方へ流す
  - `terminal.onOutput = (data) => _pty.write(utf8.encode(...))` を `start()` の中で配線
  - `terminal.onResize` を `_pty.resize` に配線
  - `cancel()` で PTY kill のみ行う。Terminal インスタンスはセッション破棄まで生存させ、`output` Stream も保持
  - 「明示破棄」を担う `dispose()`（仮称）を追加し、Terminal の参照解除・controllers の close をまとめて行う
- [ ] 3.3 既存テスト `test/data/skill_runner/pty_skill_runner_test.dart` を新しい挙動に追従させる（`cancel` 後も Terminal が参照可能、`dispose` で初めて Stream が完了する等）

## 4. RunViewModel の keepAlive 化と責務再配置

- [ ] 4.1 `lib/ui/run/run_view_model.dart` を `@Riverpod(keepAlive: true)` に変更
- [ ] 4.2 `build(entryId)` 内で `ActiveSessions.register(entryId, runner.currentState)` を呼ぶ
- [ ] 4.3 `runner.state.listen` で state を更新する際に `ActiveSessions.updateState(entryId, next)` も呼ぶ
- [ ] 4.4 既存 `ref.onDispose` の cancel ロジックを「明示破棄経路」専用に書き換える（PTY kill + `runner.dispose()` + `ActiveSessions.unregister`）
- [ ] 4.5 公開メソッドを整理する
  - `cancelRun()`: PTY kill のみ（出力履歴とセッションは残す）
  - `restart()`: 既存通り（cancel → invalidateSelf）
  - `close()`: ActiveSessions から除去して `ref.invalidate(runViewModelProvider(entryId))` を呼ぶ
- [ ] 4.6 `dart run build_runner build` で generator 出力を更新する
- [ ] 4.7 `test/ui/run/run_view_model_test.dart` を新規追加し、keepAlive 挙動 / register / unregister / cancel と close の分離をテストする

## 5. RunPage の UI 変更

- [ ] 5.1 `lib/ui/run/run_page.dart` から `_useWiredTerminal` Hook を削除し、`runner.terminal` を直接 `TerminalView` に渡す形にする
- [ ] 5.2 `_ActionButtons` のボタン構成を以下に変更する
  - 常時: 「ホームへ戻る」🏠（cancel せず pop のみ）
  - running 中: 「キャンセル」⏹
  - 終了状態（completed / failed / cancelled）: 「再実行」🔄 と 「閉じる」✕
- [ ] 5.3 「ホームへ戻る」ボタンから `await viewModel.cancelRun()` を取り除く
- [ ] 5.4 「閉じる」ボタンで `viewModel.close()` を呼んでから `context.go('/')` で戻す
- [ ] 5.5 既存 widget test があれば挙動変更に追従、必要なら新規追加

## 6. HomePage の拡張

- [ ] 6.1 `lib/ui/home/active_sessions_strip.dart` を新規追加し、`activeSessionsProvider` を購読してエントリ chip 列を描画する
- [ ] 6.2 chip タップで `context.go('/run/<entryId>')`、空のときは縦スペースを占有しない（empty fragment）
- [ ] 6.3 `lib/ui/home/home_page.dart` の `body` 先頭に `ActiveSessionsStrip` を配置する
- [ ] 6.4 `lib/ui/home/entry_tile.dart`（または `home_page.dart` 内 `_EntryTile` 相当）にセッション状態バッジを Stack でオーバーレイする
- [ ] 6.5 各エントリアイコンタップは現状通り `context.go('/run/<entryId>')`。`session-registry` 側で「同一 id なら既存セッションに復帰」が自動成立することを動作で確認する
- [ ] 6.6 `test/ui/home/active_sessions_strip_test.dart` を追加（空時非表示・1 件時に chip 描画・タップで遷移）
- [ ] 6.7 `test/widget_test.dart` に既存 home の挙動を破壊していない確認 / バッジが状態に応じて出る Widget テストを追加

## 7. アプリ終了フロー

- [ ] 7.1 `ActiveSessions` に `Future<void> cancelAll()` を追加し、保有する全 `RunViewModel` の PTY を SIGTERM するヘルパーを実装する
- [ ] 7.2 `main.dart` の起動時に `windowManager.setPreventClose(true)` を呼ぶ
- [ ] 7.3 `lib/app/window_close_guard.dart` を新規追加する
  - `HookConsumerWidget` として `ProviderScope` 配下に常駐
  - `WindowListener` を `useEffect` で attach / detach
  - `onWindowClose` で `activeSessionsProvider` を読み、空 → `windowManager.destroy()`、非空 → 確認ダイアログ表示
  - ダイアログで Yes → `ActiveSessions.cancelAll()` → `windowManager.destroy()`、No → 何もしない
- [ ] 7.4 `lib/app/app.dart` の Widget ツリーに `WindowCloseGuard` を組み込む
- [ ] 7.5 `test/app/window_close_guard_test.dart` を追加し、空時は確認なし・非空時はダイアログ表示・Yes 経路で cancelAll が呼ばれることを検証する（`windowManager` 自体は mock 化）

## 8. 動作検証と仕上げ

- [ ] 8.1 `make check`（format / analyze / test）を実行し緑にする
- [ ] 8.2 macOS 実機で以下のシナリオを通す
  - skill A を起動 → ホームへ戻る → ホームに chip と badge が出る
  - skill B を起動（並行） → A / B 両方の chip が出る
  - chip A タップ → A の出力履歴が残っている
  - A をキャンセル → chip 状態が cancelled に変化、出力は残る
  - A の「閉じる」 → chip と badge が消える
  - 再度 skill A を起動できる
  - 実行中セッションあり状態で × / Cmd+Q → 確認ダイアログ → キャンセルで継続 / 終了で全 PTY が落ちて終了
  - 全セッション閉じた状態で × → 確認なしで終了
- [ ] 8.3 README にホーム上部の chip 列・「キャンセル」と「閉じる」の使い分け・終了時確認ダイアログの説明を追記
- [ ] 8.4 README の「想定される症状」表に「Mac スリープから復帰すると、進行中だった Skill が API ストリーミング切断で `failed` 状態になることがある（OS スリープ中の TCP keepalive 喪失が原因。承認待ち / 完了済みセッションは影響なし）」を 1 行追記

## 9. アーカイブ

- [ ] 9.1 全タスク完了後、本 change をアーカイブ済みとして `openspec/changes/archive/<date>-concurrent-skill-sessions/` に移す（または OpenSpec の archive コマンドに従う）
