## Goals

- 複数 Skill を並行実行できる
- セッションは終了後（exit / 失敗 / キャンセル）も明示破棄まで残る
- 既存セッションへ復帰したとき、過去のターミナル出力が保持されている
- 既存の MVVM レイヤー構成（`ui/` / `data/` / `core/`）と Repository pattern 採用基準を逸脱しない

## Non-goals

- 同一 entry の並行セッション（1 entry = 1 session）
- セッションのアプリ再起動跨ぎ永続化
- マルチウィンドウ / タブビュー化
- セッション上限とリソース保護（PTY プロセスは OS 側に委ねる）

## Architecture

### セッションのライフサイクル

セッションのライフタイムを「実行画面 widget の生存」から **「`session-registry` に登録されている間」** へ移す。

```
[ユーザがアイコンクリック]
  → 既存セッションあり: /run/:id へ go（RunViewModel.build は走らない）
  → 既存セッションなし: /run/:id へ go → RunViewModel.build → セッション開始

[RunViewModel.build]
  → PtySkillRunner 生成 → session-registry.register(entryId)
  → state listen で session-registry.update(entryId, runState)
  → Future.microtask(runner.start)

[ホームへ戻る]
  → Navigator.pop のみ。RunViewModel は keepAlive なので生存
  → 次回 /run/:id で同じインスタンスに戻る

[キャンセル]
  → runner.cancel() で PTY kill、SkillRunState.cancelled 遷移
  → session-registry には残る。RunViewModel は生存

[閉じる]
  → runner.cancel() → session-registry.unregister(entryId)
  → ref.invalidate(runViewModelProvider(entryId))
  → onDispose で残務（出力 controller close 等）
  → Navigator.pop でホームへ
```

### Provider 構成

| Provider | 種別 | 生存 | 役割 |
|---|---|---|---|
| `runViewModelProvider(entryId)` | `Notifier.family` | keepAlive | 各セッションの ViewModel |
| `activeSessionsProvider` | `Notifier` | keepAlive（デフォルト Provider） | `Map<entryId, SkillRunState>` を保持 |

### `ActiveSessions` (新規 `data/skill_session/active_sessions.dart`)

```dart
class ActiveSessions extends Notifier<Map<String, SkillRunState>> {
  @override
  Map<String, SkillRunState> build() => const {};

  void register(String entryId, SkillRunState initialState) { ... }
  void updateState(String entryId, SkillRunState next)       { ... }
  void unregister(String entryId)                            { ... }
}
```

Riverpod の family は「現在生きているキー一覧」を直接取得する公式 API を提供しない。明示的なレジストリを持つことで、Home 画面側がリアクティブに購読できる単一の真実の源とする。

### `PtySkillRunner` の Terminal 保有

スクロールバック保持のため、`xterm.Terminal` インスタンスを `PtySkillRunner` がコンストラクション時に確保し、PTY 出力を直接書き込む。

```dart
class PtySkillRunner implements SkillRunner {
  final Terminal terminal = Terminal();
  // _pty.output.listen → terminal.write(utf8.decode(...)) と _outputController.add(...)
}
```

- View は `runner.terminal` を `TerminalView` に渡すだけ
- `terminal.onOutput` / `terminal.onResize` の配線も SkillRunner 側で行う（PTY との双方向接続を SkillRunner に閉じ込める）
- これにより `RunPage` から `useEffect` での Stream 配線が消える

依存方向: `data/skill_runner/` が `xterm` パッケージに依存することになる。MVVM 上 data 層がプレゼンテーション系パッケージを参照するのは原則避けたいが、`xterm.Terminal` 自体はターミナルバッファ + 制御シーケンス解析の純粋ロジックであり、Widget には依存しない（`TerminalView` のみが Widget）。よって data 層からの import を許容する。ADR-0008 に記録する。

### `RunViewModel` の責務

```dart
@Riverpod(keepAlive: true)
class RunViewModel extends _$RunViewModel {
  @override
  RunPageState build(String entryId) {
    final runner = PtySkillRunner(...);
    ref.read(activeSessionsProvider.notifier).register(entryId, runner.currentState);

    final sub = runner.state.listen((next) {
      state = state.copyWith(runState: next);
      ref.read(activeSessionsProvider.notifier).updateState(entryId, next);
    });

    ref.onDispose(() async {
      await sub.cancel();
      await runner.cancel();
      // unregister は close() 経由で先に呼ばれている前提だが、念のためここでも
      ref.read(activeSessionsProvider.notifier).unregister(entryId);
    });

    Future.microtask(runner.start);
    return RunPageState(entry: entry, runState: runner.currentState, runner: runner);
  }

  Future<void> cancelRun() => state.runner.cancel();      // PTY kill のみ
  void close() {                                          // 明示破棄
    ref.read(activeSessionsProvider.notifier).unregister(entryId);
    ref.invalidate(runViewModelProvider(entryId));         // → onDispose 発火
  }
  void restart() {                                         // 再実行
    state.runner.cancel();
    ref.invalidate(runViewModelProvider(entryId));         // 同 id で再 build
  }
}
```

### `RunPage` のボタン分離

| ボタン | アイコン | 振る舞い |
|---|---|---|
| ホームへ戻る | `Icons.home` | `context.go('/')` のみ |
| キャンセル | `Icons.stop` | `cancelRun()`（PTY kill、状態 cancelled、出力残存） |
| 再実行 | `Icons.refresh` | `restart()`（同 id で新規起動） |
| 閉じる | `Icons.close` | `close()` → ホームへ |

「キャンセル」と「閉じる」は state によって出し分け（running 中は「キャンセル」のみ、終了状態時に「閉じる」を出す）。

### アプリ終了時のフロー

セッションが累積する設計のため、ユーザーが誤ってウィンドウを閉じたときに作業がロストするリスクが大きい。`window_manager` の `preventClose` を有効化し、`WindowListener.onWindowClose` で `ActiveSessions` を参照して挙動を分岐させる。

```
[ユーザがウィンドウを閉じる操作 (× ボタン / Cmd+Q / NSApplication terminate)]
  → window_manager が onWindowClose を発火（実際の close は preventClose で抑止）
  → ActiveSessions.state を読む
    - 空: windowManager.destroy() でそのまま終了
    - 1 件以上: 確認ダイアログ
       「N 件のセッションが残っています。終了するとすべて破棄されます。よろしいですか？」
       - Yes:
          - 全 entryId に対し runner.cancel() で PTY を SIGTERM
          - windowManager.destroy()
       - No / キャンセル: 何もしない（アプリ継続）
```

実装ポイント:

- `main.dart` の起動時に `windowManager.setPreventClose(true)` を 1 度呼ぶ
- 常駐 `WindowListener` を保持する Widget を `app/` 配下に追加（例: `app/window_lifecycle.dart` 内の `WindowCloseGuard`）
  - `ProviderScope` 配下に置き、`ref` から `activeSessionsProvider` を読めるようにする
  - `HookConsumerWidget` + `useEffect` で listener を attach / detach
- ダイアログは Material の `AlertDialog`。`navigatorKey` を介して context を確保

`ActiveSessions` には全 PTY を一括 cancel するヘルパー（例: `Future<void> cancelAll()` がレジストリ側にあると簡潔）を追加するか、`WindowCloseGuard` 側で `Map<String, _>` を iterate して各 `RunViewModel.cancelRun()` を呼ぶ。前者のほうがレジストリの責務として収まりがよい。

### `HomePage` の拡張

- 上部にコンパクトな chip 列 `_ActiveSessionsStrip` を追加。`activeSessionsProvider` を watch
  - chip ラベル: `entry.displayName`
  - chip avatar: 状態アイコン（running 緑・completed 灰・failed 赤・cancelled 灰）
  - chip タップ: `context.go('/run/${entryId}')`
- アイコングリッドの各タイル右上に `_SessionStateBadge`（半透明オーバーレイ）
  - そのエントリ id でセッションがある時のみ表示
  - 状態アイコン 1 つ

## Trade-offs

### keepAlive の永続化

`@Riverpod(keepAlive: true)` は手動 invalidate まで生存する。本変更では明示「閉じる」で invalidate を呼ぶ運用なので問題ないが、ユーザーが何時間もアプリを開いたまま大量にセッションを残すとメモリ上に Terminal バッファが積まれる。

緩和策:
- `xterm.Terminal` のスクロールバックは既定で 1000 行（実装デフォルト）。1 セッション数 MB 程度
- 上限を設けないことは確定方針。OS のメモリ管理に委ねる
- 将来「N 件超で警告」を入れたくなったら `ActiveSessions` の length を見るだけで実装可能

### Terminal を data 層に置く違和感

`xterm.Terminal` は Widget ではなく純粋ロジック層なので技術的には data 層配置でも依存方向は守られる。とはいえ ViewModel から data 層へのアクセスは Repository 越し、というプロジェクト原則からは少し外れる。

代替案: Terminal を ViewModel が持つ。だが `ViewModel = Riverpod Notifier` で `keepAlive` でも、Terminal インスタンスの生存は Notifier の生存と一致するため挙動上の違いはない。

選定理由:
- SkillRunner が PTY との双方向配線（terminal.onOutput → PTY.write / PTY.output → terminal.write / terminal.onResize → PTY.resize）を一括で管理できるため、責務がきれいに閉じる
- View は `runner.terminal` を表示するだけになり、`useEffect` での配線が消えて 1 か所のバグ（前回 fix した output stream 問題）の再発リスクが下がる
- ADR-0008 でこの設計判断を時系列記録する

### family の「現在のキー一覧」問題

Riverpod の family は内部的に生きているインスタンスを持つが、外から「現在生きているキー」を購読する公式 API はない。`activeSessionsProvider` という外部レジストリを置くことで:

- Home 画面が状態変化に反応してリビルドできる（chip 列・バッジ）
- `RunViewModel` 側で register/unregister を 1 箇所に集約できる

外部レジストリと family の生死を整合させる責務は `RunViewModel.build` と `close` に閉じる。

## Migration

- ローカル永続化（launcher_entries.json / appearance_settings.json）には変更なし
- アプリ起動時にセッションは存在しない（永続化しない方針）
- 既存ユーザーの体験変化: ホームへ戻ってもプロセスが残るようになる。これは仕様変更だが、現在の動作（戻ると消える）がそもそも不便だったので望ましい方向の変更
