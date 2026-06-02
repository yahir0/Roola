## ADDED Requirements

### Requirement: Inno Setup スクリプトが存在する
`windows/installer/roola.iss` が存在し、`flutter build windows --release` の成果物ディレクトリ（`build/windows/x64/runner/Release/`）を入力として `RoolaSetup-<version>.exe` を生成する。

#### Scenario: インストーラ生成成功
- **WHEN** `make installer-windows` を実行し、ビルド成果物ディレクトリが存在する
- **THEN** `build/RoolaSetup-<version>.exe` が生成される

#### Scenario: 成果物ディレクトリが存在しない場合
- **WHEN** `flutter build windows` を実行せずに `make installer-windows` を実行する
- **THEN** エラーメッセージが表示され、インストーラは生成されない

### Requirement: per-user インストール（管理者権限不要）
インストーラは `PrivilegesRequired=lowest` で動作し、インストール先はデフォルトで `{localappdata}\Roola` とする。

#### Scenario: 標準ユーザアカウントでインストール
- **WHEN** 管理者権限のない Windows ユーザがインストーラをダブルクリックして実行する
- **THEN** UAC プロンプトが表示されずにインストールが完了し、`%LocalAppData%\Roola\roola.exe` が存在する

### Requirement: バージョン番号の自動取得
インストーラのバージョン番号は `pubspec.yaml` の `version: X.Y.Z+N` から semver 部分（`+N` を除く `X.Y.Z`）を使用する。

#### Scenario: `make installer-windows` でバージョンが反映される
- **WHEN** `pubspec.yaml` の `version: 1.2.3+10` の状態で `make installer-windows` を実行する
- **THEN** 生成されるファイル名が `RoolaSetup-1.2.3.exe` となる

### Requirement: スタートメニューとデスクトップショートカット
インストール時にスタートメニュー（`{userprograms}\Roola`）にショートカットを作成する。デスクトップショートカットはオプション（インストーラのチェックボックスで選択可能）とする。

#### Scenario: インストール完了後のスタートメニュー
- **WHEN** インストールが正常に完了する
- **THEN** スタートメニューの「Roola」フォルダに `Roola.lnk` が存在する

### Requirement: アンインストーラの提供とユーザデータ選択削除
Inno Setup が自動生成する `unins000.exe` により、「設定 → アプリ → アプリと機能」から Roola をアンインストールできる。アンインストール完了後、Inno Setup の `[Code]` Pascal スクリプトでメッセージボックスを表示し、ユーザデータ（`%AppData%\tech.yahiro.Roola`）を削除するか保持するかをユーザが選択できる。

#### Scenario: アンインストール後にデータ削除を選択した場合
- **WHEN** 「アプリと機能」から Roola をアンインストールし、データ削除の確認ダイアログで「はい」を選択する
- **THEN** `%LocalAppData%\Roola\` ディレクトリが削除され、スタートメニューショートカットが削除される
- **THEN** `%AppData%\tech.yahiro.Roola\` も完全に削除される

#### Scenario: アンインストール後にデータを保持した場合
- **WHEN** 「アプリと機能」から Roola をアンインストールし、データ削除の確認ダイアログで「いいえ」を選択する
- **THEN** `%LocalAppData%\Roola\` ディレクトリが削除され、スタートメニューショートカットが削除される
- **THEN** `%AppData%\tech.yahiro.Roola\` は残存する（ユーザデータ保護）
