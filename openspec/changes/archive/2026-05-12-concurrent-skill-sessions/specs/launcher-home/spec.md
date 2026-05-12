## MODIFIED Requirements

### Requirement: アイコンクリックで実行画面へ遷移

システムは、ホーム画面のアイコンがクリックされたとき、対応するエントリの実行画面へ遷移する SHALL。**既にそのエントリのセッションが `session-registry` に存在する場合は、新しいセッションを開始せず既存セッションの画面に遷移する。**

#### Scenario: セッションが存在しない場合

- **WHEN** ユーザーがホーム画面のアイコンをクリックし、`session-registry` に当該 `entryId` のセッションが存在しない
- **THEN** システムは `/run/<entryId>` へ遷移し、新しいセッションが `RunViewModel.build` を通じて開始される

#### Scenario: セッションが既に存在する場合

- **WHEN** ユーザーがホーム画面のアイコンをクリックし、`session-registry` に当該 `entryId` のセッションが既に存在する
- **THEN** システムは `/run/<entryId>` へ遷移し、既存セッションの状態（PTY・ターミナル出力履歴）がそのまま表示される

## ADDED Requirements

### Requirement: 実行中セッションの一覧表示

システムは、ホーム画面上部に `session-registry` 上の全セッションをコンパクトな chip 列として描画する SHALL。

#### Scenario: セッションが 1 件以上ある

- **WHEN** `session-registry` に 1 件以上のセッションが登録されている
- **THEN** ホーム画面上部にエントリ表示名を持つ chip が並び、各 chip には実行状態を示すアイコン（running / completed / failed / cancelled）が付与される

#### Scenario: セッションが 0 件

- **WHEN** `session-registry` が空である
- **THEN** ホーム画面の chip 列は描画されない（縦方向のスペースを占有しない）

#### Scenario: chip タップで該当セッションへ遷移

- **WHEN** ユーザーが chip をタップする
- **THEN** システムは対応する `/run/<entryId>` へ遷移し、当該セッションの画面を表示する

### Requirement: エントリアイコンへのセッション状態バッジ

システムは、ホーム画面のエントリアイコン右上に、そのエントリに対するセッションが `session-registry` に存在する場合のみ、状態を示す小バッジを描画する SHALL。

#### Scenario: 実行中エントリのアイコン

- **WHEN** 当該 `entryId` のセッションが running 状態でレジストリに存在する
- **THEN** アイコン右上に running を示す小バッジ（緑のドット等）が重ねて描画される

#### Scenario: 終了済みエントリのアイコン

- **WHEN** 当該 `entryId` のセッションが completed / failed / cancelled のいずれかで残っている
- **THEN** アイコン右上に対応する状態の小バッジ（灰 / 赤 等）が描画される

#### Scenario: セッションが無いエントリ

- **WHEN** 当該 `entryId` のセッションがレジストリに存在しない
- **THEN** アイコンにバッジは描画されない
