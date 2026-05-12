## ADDED Requirements

### Requirement: 実行中セッションの登録と購読

システムは、アプリ全体で生きている Skill 実行セッションを一元的にレジストリへ登録し、その一覧と各セッションの実行状態を購読可能な単一のソースとして公開する SHALL。

#### Scenario: 新しいセッションの開始

- **WHEN** ユーザーが未起動のエントリのアイコンをクリックし、`RunViewModel` が初期化される
- **THEN** システムは `ActiveSessions` レジストリに `entryId` を `SkillRunIdle` 相当の初期状態で登録する

#### Scenario: 状態変化の伝播

- **WHEN** あるセッションの `SkillRunState` が starting / running / completed / failed / cancelled の何れかに遷移する
- **THEN** システムは同じ `entryId` でレジストリ上の状態を最新値に更新する

#### Scenario: ホーム画面からの購読

- **WHEN** ホーム画面が `ActiveSessions` を購読している
- **THEN** 登録・更新・除去のいずれが発生してもホーム画面は状態変化を受信して再描画される

### Requirement: セッションの明示破棄

システムは、ユーザーの「閉じる」操作によりセッションを破棄するとき、PTY を終了し、レジストリから除去し、紐づく `RunViewModel` インスタンスを解放する SHALL。

#### Scenario: 終了状態のセッションを閉じる

- **WHEN** completed / failed / cancelled 状態のセッションでユーザーが「閉じる」ボタンを押す
- **THEN** システムはレジストリから当該 `entryId` を除去し、`RunViewModel` を invalidate して関連リソースを解放する

#### Scenario: 実行中のセッションを閉じる

- **WHEN** running 状態のセッションでユーザーが「閉じる」ボタンを押す
- **THEN** システムは PTY に SIGTERM を送り、当該 `entryId` をレジストリから除去し、`RunViewModel` を invalidate する

### Requirement: アプリ終了時の確認とセッション破棄

システムは、ユーザーがアプリウィンドウを閉じる操作（× ボタン / Cmd+Q / NSApplication terminate）を行ったとき、`session-registry` の状態に応じて挙動を分岐する SHALL。

#### Scenario: セッションが残っていない状態で閉じる

- **WHEN** ユーザーがウィンドウ close を試み、`ActiveSessions` が空である
- **THEN** システムは確認なしでアプリを終了する

#### Scenario: セッションが 1 件以上残った状態で閉じる

- **WHEN** ユーザーがウィンドウ close を試み、`ActiveSessions` に 1 件以上のセッションが登録されている
- **THEN** システムは即時の終了を抑止し、「N 件のセッションが残っています。終了するとすべて破棄されます」という確認ダイアログを表示する

#### Scenario: 確認ダイアログで「終了する」を選ぶ

- **WHEN** 確認ダイアログでユーザーが「終了する」を選ぶ
- **THEN** システムは全 PTY に SIGTERM を送り、レジストリを空にして、ウィンドウを実際に閉じる

#### Scenario: 確認ダイアログで「キャンセル」を選ぶ

- **WHEN** 確認ダイアログでユーザーが「キャンセル」を選ぶ
- **THEN** システムは終了処理を中断し、アプリを継続実行する

### Requirement: 同一エントリ並行セッションの抑止

システムは、同じ `entryId` に対して同時に複数のセッションを保持しない SHALL。

#### Scenario: 既存セッションを持つアイコンをクリックする

- **WHEN** すでにセッションが存在するエントリのアイコンが再度クリックされる
- **THEN** システムは新しいセッションを開始せず、既存セッションの実行画面へ遷移する
