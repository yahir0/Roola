## ADDED Requirements

### Requirement: Windows プロジェクトが生成・ビルドできる
Roola の Flutter プロジェクトは `flutter build windows` を実行すると Windows 向け実行ファイルを生成できる SHALL。`windows/` ディレクトリが存在し、FVM で指定した Flutter SDK バージョンでビルドが成功する SHALL。

#### Scenario: Windows ビルドが成功する
- **WHEN** `fvm flutter build windows --dart-define-from-file dart_defines/prod.json` を実行する
- **THEN** `build/windows/x64/runner/Release/roola.exe` が生成されエラーが発生しない

#### Scenario: Debug ビルドが起動する
- **WHEN** `fvm flutter run -d windows` を実行する
- **THEN** アプリが起動し Explorer タブが表示される

### Requirement: Windows アプリのメタデータが正しく設定される
アプリ名は `Roola`、会社名は `tech.yahiro` で `windows/runner/Runner.rc` に設定される SHALL。

#### Scenario: アプリ名がタスクバーに表示される
- **WHEN** Windows でアプリを起動する
- **THEN** タスクバーに「Roola」と表示される

### Requirement: Windows アプリアイコンが設定される
`windows/runner/resources/app_icon.ico` にアプリアイコン（ICO 形式、256x256 以上を含む）が配置される SHALL。

#### Scenario: ICO ファイルが存在する
- **WHEN** `windows/runner/resources/app_icon.ico` を確認する
- **THEN** ファイルが存在し、ICO 形式として有効である

### Requirement: macOS ビルドが引き続き成功する
Windows プロジェクト追加後も `flutter build macos` が成功する SHALL。

#### Scenario: macOS ビルドが壊れない
- **WHEN** `fvm flutter build macos --dart-define-from-file dart_defines/prod.json` を実行する
- **THEN** ビルドが成功しエラーが発生しない
