## Why

Claude Code の Skills を起動するには、毎回ターミナルを開き、対象リポジトリへ `cd` し、`claude` コマンドを叩いてからスキル名を入力するという定型操作が必要で、日常的に繰り返すには手間が大きい。Mac 上で「アイコンをクリックするだけで対象ディレクトリで Skill 実行まで到達」できる軽量ランチャーがあれば、Skill の利用頻度を大きく引き上げられる。

## What Changes

- Flutter Desktop（macOS）プロジェクトを新規セットアップし、Mac 向けランチャーアプリの初期骨組みを構築する。
- 「ランチャー設定（リポジトリ + Skill + アイコン）」を登録・編集・削除する設定画面を提供する。
- ホーム画面にアイコン一覧を表示し、クリックすると登録済みリポジトリのディレクトリで Claude Code を起動し、指定 Skill を実行する。
- 実行は **最初から PTY（擬似端末）ベースのフルターミナル** とし、現状の Skills が要求する対話的入力（承認 y/n・プロンプト応答・矢印キー操作・ANSI 制御）をそのまま扱えるようにする。後から差し替える前提を取らない。
- アプリの背景はデフォルトで透過、ユーザーが背景色・背景画像を変更できる設定を提供する。
- VSCode から `flutter run --dart-define-from-file=dart_defines/prod.json` で起動できるよう、単一環境（prod）の dart-define 設定とサンプル launch.json を整備する。**Flavor 分離は将来も行わない方針** のため、dev / stg は用意しない。
- **本 change は MVP スコープ**。簡易エクスプローラ・Skill 自動検知・Git クローンウィザード・Spotlight 風展開アニメーション・CI パイプライン整備は含めず、後続 change に分離する。

## Capabilities

### New Capabilities

- `launcher-config`: ランチャーに登録するエントリ（ID / 表示名 / リポジトリパス / 実行する Skill 名 / アイコン）の永続化・一覧取得・追加・更新・削除を担う。
- `launcher-home`: アプリ起動時のホーム画面。登録済みアイコンを一覧表示し、クリックで Skill 実行フローを起動する。
- `skill-runner`: 指定ディレクトリで `claude` プロセスを **PTY 上で** 起動し、Skill を実行する。PTY の入出力（バイト列）と状態をストリームで公開する。
- `embedded-terminal`: skill-runner の PTY 入出力を xterm.dart ベースのアプリ内フルターミナル UI に接続する。キー入力・矢印キー・ANSI 制御・リサイズに対応する。
- `appearance-settings`: アプリの背景（透過 / 単色 / 画像）とウィンドウ装飾の設定を永続化・反映する。
- `app-bootstrap`: Flutter Desktop（macOS）プロジェクトの初期化、単一環境用 dart-define、VSCode launch.json、必要な entitlements / Info.plist を整備する。

### Modified Capabilities

（既存 spec は無いため、本 change では変更しない）

## Impact

- **新規プロジェクト構築**: `pubspec.yaml`、`macos/`、`lib/` ディレクトリ一式が新規作成される。
- **依存パッケージ**: Riverpod、Hooks、go_router、Freezed、Dio、`flutter_pty`（PTY 制御）、`xterm`（ターミナル描画）、`window_manager`（透過ウィンドウ）、`path_provider` + JSON 永続化、`file_picker`、`image` などを導入。
- **macOS Entitlements**: 子プロセス起動・PTY 利用・任意ディレクトリへの読み書き許可が必要（App Sandbox を明示的に無効化）。
- **OS 前提**: ユーザー環境に `claude` CLI と `git` が PATH 上に存在することを前提とする。検出と分かりやすいエラー表示は本 change のスコープに含める。
- **CI**: 本 change では CI パイプラインを追加しない（後続 change で整備）。
