## Why

現状はホーム画面でアイコンをクリックすると即座に実行画面へ遷移し、ホームへ戻るとセッション（PTY プロセス・端末スクロールバック）が破棄される。長時間動く Skill を 1 つでも実行すると他のアイコンに切り替えられず、終わったセッションの出力を後から見返すこともできない。Skill ランチャーとしての日常運用に致命的に不向き。

## What Changes

- 実行中・終了済みのセッションを「明示的に閉じる」までアプリ内で保持し、複数 Skill の並行実行をサポートする。
- 実行画面のアクションを 3 種に分離する。
  - **ホームへ戻る**: セッション維持のままホームへ pop
  - **キャンセル**: PTY を SIGTERM。出力履歴とセッションは残り、再実行可能
  - **閉じる**: PTY 終了 + セッション破棄 + ホームへ
- ホーム画面に「実行中のセッション」chip 列を追加し、各 chip タップで該当セッションへ復帰可能にする。
- 各エントリアイコンに「セッション保持中」を示す小バッジを表示する。
- 端末出力のスクロールバックがセッションに紐づいて保持され、再来訪時に過去出力をそのまま閲覧できる。
- 1 entry につき同時 1 セッションを上限とする（同一 entry 並行は対象外）。総セッション数の上限は設けない。
- アプリ終了（ウィンドウ close）時、`session-registry` に 1 件以上のセッションが残っていれば確認ダイアログを表示する。確定時のみ全 PTY を SIGTERM して終了する（誤クリックによる作業ロストを防ぐ）。

## Capabilities

### New Capabilities

- `session-registry`: アプリ全体で生きているスキル実行セッションを登録・状態追跡・破棄するレジストリ。`launcher-home` と `skill-runner` の橋渡しとして「現在生きているセッション一覧と各状態」を購読可能な形で提供する。

### Modified Capabilities

- `skill-runner`: 実行画面を離脱しても PTY と状態が保持されるよう、ライフサイクルを実行画面 widget の生存ではなく `session-registry` に委ねる。Terminal インスタンス自体を SkillRunner 側で保有することでスクロールバックを保持する。
- `launcher-home`: 実行中のセッション chip 列と、各エントリアイコンへのセッション状態バッジを追加する。同一エントリ再クリック時は既存セッションの実行画面へ復帰する。
- `embedded-terminal`: View（`RunPage`）側で Terminal を生成するのを止め、`skill-runner` が保持する Terminal を `TerminalView` に渡すだけの構造にする。

## Impact

- **`RunViewModel`**: `@Riverpod(keepAlive: true)` 化。`ref.onDispose` で行っている cancel ロジックは「明示破棄」時のみ起動するよう責務移譲。
- **`PtySkillRunner`**: `xterm.Terminal` インスタンスをコンストラクション時に確保し、PTY 出力をそこに書き込む。`output` Stream は内部購読用に維持（テスト・将来の拡張のため）。
- **新規 `ActiveSessionsNotifier`**: `Map<String, SkillRunState>` を state として持つ Riverpod Notifier。`RunViewModel` の build / state listen / 明示破棄から呼ばれる。
- **UI**: ホームに `_ActiveSessionsStrip`、エントリタイル右上に小バッジ Widget を追加。`RunPage` のアクションボタンを 3 種に整理。
- **アプリ終了フロー**: `window_manager` の `preventClose` を有効化し、終了試行時に `ActiveSessions` を参照する `WindowListener` を常駐させる。1 件以上残っていれば確認ダイアログ → 確定時に全 PTY を SIGTERM → `windowManager.destroy()`。
- **テスト**: `ActiveSessions` のユニットテスト、`RunViewModel` の明示破棄経路テスト、`HomePage` の chip 列とバッジの Widget テスト追加。既存テストは挙動変更（ホーム戻りで cancel しない）に追従。
- **後方互換**: ローカル永続データ（launcher_entries.json / appearance_settings.json）には変更なし。マイグレーション不要。
- **非 goal**: 同一エントリ並行、別ウィンドウ / タブビュー、セッション上限、永続化されたセッション履歴（アプリ再起動跨ぎ）は本 change のスコープ外。
