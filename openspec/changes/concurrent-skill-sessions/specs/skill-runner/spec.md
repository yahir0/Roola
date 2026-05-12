## MODIFIED Requirements

### Requirement: プロセスのライフサイクル管理

システムは、PTY 上の子プロセスの開始・終了・キャンセルを観測可能な状態として公開し、ユーザーがキャンセルできるようにする SHALL。**実行画面ウィジェットの離脱はライフサイクルに直接影響せず、セッションは `session-registry` への登録が解除されるまで保持される。**

#### Scenario: プロセスが正常終了する

- **WHEN** PTY 上のプロセスが終了コードを返して終了する
- **THEN** システムは状態を「完了（終了コード N）」に遷移させ、ターミナル UI に終了コードを表示する。**セッションは引き続き `session-registry` に保持され、出力スクロールバックも残る**

#### Scenario: ユーザーがキャンセルする

- **WHEN** ユーザーが実行画面のキャンセルボタンを押す
- **THEN** システムは PTY 経由で SIGTERM を送り、状態を「キャンセル済み」に遷移させる。**セッションは `session-registry` に残り、出力履歴も保持される**

#### Scenario: 実行画面を離脱する（ホームへ戻る）

- **WHEN** ユーザーが実行画面の「ホームへ戻る」ボタンを押す、または `Navigator.pop` 相当の遷移が発生する
- **THEN** システムは PTY を **終了させず**、状態とスクロールバックを保持したまま実行画面ウィジェットのみを破棄する

#### Scenario: 明示的に閉じる

- **WHEN** ユーザーが実行画面の「閉じる」ボタンを押す
- **THEN** システムは PTY を SIGTERM で終了させ、`session-registry` から当該エントリを除去し、`RunViewModel` を解放してリソースを開放する

## ADDED Requirements

### Requirement: ターミナルインスタンスの保有

システムは、`xterm.Terminal` のインスタンスを `SkillRunner` 実装側で保有し、PTY 出力・入力・リサイズの双方向配線を `SkillRunner` 内に閉じ込める SHALL。

#### Scenario: 出力配線

- **WHEN** PTY が新しい出力を発する
- **THEN** `SkillRunner` は保有する `Terminal` インスタンスへ即座に書き込む

#### Scenario: 入力配線

- **WHEN** `Terminal` の `onOutput` が呼ばれる（ユーザーのキー入力）
- **THEN** `SkillRunner` は当該バイト列をそのまま PTY に書き込む

#### Scenario: リサイズ配線

- **WHEN** `Terminal` の `onResize` が呼ばれる（端末サイズ変更）
- **THEN** `SkillRunner` は PTY に対し対応するサイズ変更を伝える

### Requirement: スクロールバックの保持

システムは、セッションが `session-registry` に登録されている間、当該 `Terminal` インスタンスとそのスクロールバックを破棄しない SHALL。

#### Scenario: 実行画面に再来訪する

- **WHEN** ユーザーがホームへ戻ったあと、同じセッションの実行画面を再度開く
- **THEN** ターミナルには離脱前までの出力履歴が表示されている

#### Scenario: セッションを閉じる

- **WHEN** ユーザーが「閉じる」ボタンを押してセッションを破棄する
- **THEN** システムは `Terminal` インスタンスを破棄し、保有していた出力履歴を解放する
