## MODIFIED Requirements

### Requirement: ターミナル UI のレンダリング

システムは、`skill-runner` が保有する `xterm.Terminal` インスタンスを `TerminalView` で描画する SHALL。**View 側で Terminal インスタンスを生成しない**ことで、View ウィジェットの離脱・再構築から独立したスクロールバック保持を実現する。

#### Scenario: 実行画面の初期描画

- **WHEN** ユーザーが実行画面を開く
- **THEN** システムは `RunViewModel` を経由して `SkillRunner.terminal` を取得し、`TerminalView` の引数として渡して描画する

#### Scenario: 既存セッションの再来訪

- **WHEN** ユーザーが一度ホームへ戻ったあと、同じセッションの実行画面を再度開く
- **THEN** `SkillRunner` が保持する `Terminal` インスタンスは破棄されておらず、過去の出力履歴がそのまま `TerminalView` に表示される

#### Scenario: セッション破棄

- **WHEN** ユーザーが「閉じる」を押してセッションを破棄する
- **THEN** 当該 `SkillRunner` の `Terminal` インスタンスが解放され、出力履歴も消失する

## REMOVED Requirements

### Requirement: View 側での Terminal 生成と PTY 配線

**Reason**: Terminal インスタンス生成・PTY との双方向配線（output → terminal.write / terminal.onOutput → PTY.write / terminal.onResize → PTY.resize）を View 側の `useEffect` で行う構造を廃止する。これにより View 離脱で Terminal が破棄されてしまう問題、および subscribe タイミングと PTY 生成タイミングのレースに起因するバグ（既知の output stream 空 Stream バグ）の再発リスクを除去する。

**Migration**: `RunPage._useWiredTerminal` を削除し、`SkillRunner.terminal` を直接 `TerminalView` に渡す形に置き換える。Stream `output` の公開は `SkillRunner` の interface に残し、テストや将来の拡張に備える。
