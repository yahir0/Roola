## ADDED Requirements

### Requirement: Flutter Desktop（macOS）プロジェクトの初期化

システムは、リポジトリ直下に Flutter Desktop（macOS）対応のプロジェクトをセットアップし、`flutter run -d macos` でビルド・起動できる状態にする SHALL。

#### Scenario: 初期ビルドが成功する

- **WHEN** クリーン環境で `flutter pub get` 後に `flutter run -d macos --dart-define-from-file=dart_defines/prod.json` を実行する
- **THEN** macOS アプリウィンドウが起動し、ホーム画面が表示される

### Requirement: 単一環境の dart-define 設定

システムは、`dart_defines/prod.json` を 1 ファイル用意し、`--dart-define-from-file` で読み込む構成を備える SHALL。Flavor 分離（dev / stg）は行わない。

#### Scenario: prod 設定で起動する

- **WHEN** ユーザーが `flutter run -d macos --dart-define-from-file=dart_defines/prod.json` を実行する
- **THEN** `dart_defines/prod.json` のキー値がアプリへ反映される

#### Scenario: VSCode から起動する

- **WHEN** ユーザーが VSCode の Run and Debug から「Launch (prod)」コンフィグを選択する
- **THEN** `--dart-define-from-file=dart_defines/prod.json` 付きで `flutter run` が実行される

### Requirement: macOS Entitlements の調整

システムは、子プロセス起動（PTY 経由を含む）とユーザー指定ディレクトリへのアクセスのため、Debug / Release の Entitlements を調整する SHALL。

#### Scenario: PTY 経由で子プロセスを起動できる

- **WHEN** Debug ビルドで `flutter_pty` 経由で `claude` プロセスを起動する
- **THEN** Entitlements 設定により起動がブロックされず、PTY 上で子プロセスが立ち上がる

### Requirement: 透過ウィンドウの初期設定

システムは、macOS Runner 側で `MainFlutterWindow` を透過対応に設定し、Flutter 側からウィンドウ背景色を制御可能にする SHALL。

#### Scenario: 透過設定が反映される

- **WHEN** Flutter 側で `appearance-settings` が「透過」モードである
- **THEN** Mac のウィンドウ背景は透過で描画される
