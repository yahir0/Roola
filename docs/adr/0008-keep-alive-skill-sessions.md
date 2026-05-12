# ADR-0008: スキル実行セッションを実行画面 widget から切り離して保持する

- **Status**: Accepted
- **Date**: 2026-05-12

## Context

MVP まで（`bootstrap-launcher-mvp` change で実装）の実行画面は、`RunViewModel` を `@riverpod`（auto-dispose）として実装し、実行画面ウィジェットが pop されるとセッション（PTY プロセス・状態 Stream・ターミナル出力）が破棄される設計だった。さらに「ホームへ戻る」ボタンは pop の前に明示的に `runner.cancel()` を呼び、ターミナルインスタンス自体は `RunPage._useWiredTerminal` 内の `useMemoized` で生成していたため、ウィジェット破棄に追従して `xterm.Terminal` も解放されていた。

実運用すると以下の不便が顕在化した:

- 長時間動く Skill を 1 つ起動するだけで、他のアイコンに切り替えられない
- ホームへ戻ると即 PTY が殺され、未完了の作業が失われる
- 終了した Skill の出力を後から見返せない（戻った時点で消失）
- 「複数 Skill 並行実行」はそもそも UI 上不可能

## Decision

スキル実行セッションのライフタイムを **実行画面ウィジェットの生存ではなく `session-registry`（`ActiveSessions` Notifier）への登録に紐づける**。

具体的には:

1. `RunViewModel` を `@Riverpod(keepAlive: true)` に変更し、family（entryId 単位）ごとに永続生存させる
2. 「ホームへ戻る」ボタンは `Navigator.pop` だけ行う（cancel しない）
3. 「キャンセル」ボタンは PTY kill のみ。セッションと出力履歴は残し、状態は `cancelled` に遷移
4. 「閉じる」ボタンを新設し、これだけが `session-registry` から除去 + `RunViewModel` を invalidate（明示破棄）
5. ホーム上部に `ActiveSessions` を購読する chip 列を置き、各エントリアイコンにはセッション状態バッジを重ねる
6. 同じエントリのアイコンを再クリックすると、`/run/:id` への遷移だけで既存セッションに戻る（`RunViewModel.build` は走らない）

加えて、ターミナル出力履歴を実行画面の再来訪後にも保持できるよう、**`xterm.Terminal` インスタンスを `PtySkillRunner` 側で保有**し、View（`RunPage`）は `runner.terminal` を `TerminalView` に渡すだけの構造にする。`terminal.onOutput` / `terminal.onResize` の配線も `PtySkillRunner` 内に閉じ込める。

## Why

### 代替案 1: 何もしない（auto-dispose のまま）

却下。ユーザー要件「複数 Skill を並行実行したい」「終了した出力を後から見たい」を満たせない。MVP 完了時点で既に「使い勝手が悪い」とフィードバックを受けている。

### 代替案 2: タブビュー化（複数セッションを 1 画面のタブとして並べる）

将来案として保留。タブ管理の状態（順序・選択中タブ・追加 / 閉じる操作）が増え、go_router との折り合いも検討が必要。並行実行とセッション保持という本質要件は keepAlive + chip 列で同程度に満たせるため、まず最小変更で済む方針を採る。

### 代替案 3: 別ウィンドウ化（`desktop_multi_window`）

将来案として保留。各セッションが独立した macOS ウィンドウになる点は最も「デスクトップらしい」体験だが、`desktop_multi_window` 導入・isolate 間 IPC・各ウィンドウへの独立した起動シーケンスなど実装量が大きく、ROI が見合わない。同等の体験は単一ウィンドウ + chip 列でほぼ実現できる。

### 代替案 4: Terminal は View 側で持ち続け、出力履歴は SkillRunner 側で別途バッファ

却下。出力履歴の二重管理（PTY からの生バイト列を SkillRunner で持ち、View 側の Terminal にも持つ）になり、ANSI 制御シーケンスの再解釈などで複雑度が増す。`xterm.Terminal` はそれ自体が制御シーケンス解析を内蔵した端末バッファ実装なので、Terminal インスタンスをセッションに紐づけて持つほうがシンプル。

### 採用理由

- 最小コードで「並行実行」「セッション保持」「出力履歴の再閲覧」の 3 要件を同時に満たす
- 状態を単一の `ActiveSessions` Notifier に集約することで、Home からの購読がリアクティブに、`RunViewModel` 側の責務も `register` / `unregister` の 2 点のみで明確
- Terminal を SkillRunner 側に持つことで、PTY との双方向配線が 1 箇所に閉じ、前回修正した「output stream 空 Stream バグ」のような View 側ライフサイクル起因のバグの再発リスクが下がる

## Trade-offs

### data 層が `xterm` パッケージに依存する

`xterm.Terminal` は Widget ではないが、`xterm` パッケージ自体は端末描画 Widget（`TerminalView`）も含むプレゼンテーション系の位置付け。data 層から `package:xterm/xterm.dart` を import するのは MVVM の依存方向ルールから見ると違和感がある。

緩和:

- import するのは `Terminal` クラス（制御シーケンス解析を持つ純粋ロジック層）のみ
- `TerminalView`（Widget）は引き続き `ui/run/` 側でのみ使用
- 本 ADR で明示的に「この import は許容する」旨を記録

### keepAlive によるメモリ累積

セッションを明示破棄するまで `xterm.Terminal` インスタンスとスクロールバックがメモリに残る。`xterm.Terminal` のスクロールバック既定は 1000 行程度（数 MB オーダー）で、現実的な利用ではユーザーが何時間も大量のセッションを残さない限り問題にならない。

緩和:

- 上限を機械的には設けない（ユーザーの自由を優先）
- 終了したセッションの「閉じる」ボタンを目立つ位置に置く
- 将来「N 件超で警告」を入れたくなったら `ActiveSessions.state.length` を見るだけで実装可能

### アプリ終了時のセッション喪失

セッションは Dart isolate 上のメモリにのみ存在するため、ユーザーがウィンドウを閉じると（× ボタン / Cmd+Q / NSApplication terminate）すべての PTY が落ち、ターミナル出力履歴も失われる。並行実行を常態化させる本変更ではこのリスクが現状より大きくなる。

緩和:

- `window_manager.setPreventClose(true)` を有効化し、`WindowListener.onWindowClose` で `ActiveSessions` を参照する常駐 Widget（`WindowCloseGuard`）を `ProviderScope` 配下に置く
- セッションが 0 件: 確認なしで `windowManager.destroy()`
- セッションが 1 件以上: 「N 件のセッションが残っています。終了するとすべて破棄されます」確認ダイアログを表示し、ユーザー確定時のみ `ActiveSessions.cancelAll()` → `windowManager.destroy()`
- セッションのアプリ再起動跨ぎ復元はしない（永続化対象外、design.md の Non-goals を参照）

### 同一 entryId 並行を許可しない

仕様として 1 entry につき 1 セッションに制限する。「同じ Skill をもう 1 つ立ち上げたい」場合は entry 複製で対応する想定。

緩和:

- `ActiveSessions` の API は `Map<String, _>` ベース。将来必要になったら `Map<SessionId, _>`（SessionId に entryId + index 等）へ拡張可能
- 現時点でこの制約による不便は想定されていない

## Re-evaluation Plan

以下のいずれかを契機に再評価する:

1. ユーザーから「タブビュー化したい」「別ウィンドウで開きたい」というフィードバックを複数回受けた場合
2. メモリ累積が現実的に問題化した場合（数十〜数百セッション保持の運用）
3. 同一 entry 並行セッションを必要とするユースケースが出てきた場合

## References

- `openspec/changes/concurrent-skill-sessions/`（本 ADR の提案フェーズ）
- ADR-0002: PTY ベースのターミナル統合（セッション = PTY プロセス + xterm Terminal という構造の前提）
- ADR-0003: Riverpod + Hooks による状態管理（`@Riverpod(keepAlive: true)` の根拠）
- ADR-0006: Flutter 公式 MVVM の採用（data 層からプレゼンテーション系 import に関する規律）
