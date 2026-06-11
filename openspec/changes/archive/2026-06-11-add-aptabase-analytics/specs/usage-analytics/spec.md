# Spec: usage-analytics

## ADDED Requirements

### Requirement: 匿名利用統計の送信

アプリは、利用規約に同意済みかつアナリティクス送信が有効な場合に限り、匿名利用統計イベントを Aptabase ホステッドへ送信しなければならない（SHALL）。送信イベントにはユニークユーザー識別子・デバイス指紋・個人情報・ファイルパス・コマンド文字列等の自由文字列を含めてはならない（MUST NOT）。

#### Scenario: 起動イベントの送信

- **WHEN** 規約同意済みかつアナリティクス有効の状態でアプリが起動する
- **THEN** `app_launched` イベントが 1 回送信される（OS・アプリバージョン・ロケールは SDK の自動付与に委ねる）

#### Scenario: ランチャー実行イベントの送信

- **WHEN** 規約同意済みかつアナリティクス有効の状態でランチャーエントリを実行する
- **THEN** `launcher_executed` イベントが実行種別（shell / command / claudeSkill）の props 付きで送信される
- **THEN** 実行対象のパス・コマンド内容・エントリ名は送信されない

#### Scenario: 同意前は送信しない

- **WHEN** 利用規約に未同意の状態でアプリが動作している
- **THEN** Aptabase SDK は初期化されず、いかなるイベントも送信されない

### Requirement: アナリティクスのオプトアウト

ユーザーは設定画面からアナリティクス送信を無効化できなければならない（SHALL）。無効化は即時かつ永続的に適用され、再度有効化するまで一切のイベントを送信してはならない（MUST NOT）。

#### Scenario: 設定画面でオプトアウトする

- **WHEN** 設定画面の「使用状況の統計を送信する」トグルを OFF にする
- **THEN** 以後のイベント送信が停止し、設定が永続化される
- **THEN** アプリを再起動しても OFF が維持され、`app_launched` も送信されない

#### Scenario: 再度オプトインする

- **WHEN** トグルを OFF から ON に戻す
- **THEN** 以後のイベント送信が再開される

### Requirement: App Key 未設定時の無効化

ビルド時に Aptabase App Key（dart-define `APTABASE_APP_KEY`）が未設定または空の場合、アナリティクス機能全体が no-op にならなければならない（SHALL）。

#### Scenario: 開発ビルドでの無効化

- **WHEN** App Key を渡さずにアプリをビルド・起動する
- **THEN** Aptabase SDK は初期化されず、イベント送信 API の呼び出しはエラーなく無視される
