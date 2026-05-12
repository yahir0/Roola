## 1. プロジェクト初期化と環境セットアップ

- [x] 1.1 リポジトリ直下に `flutter create --platforms=macos --org io.github.yahir0 --project-name claude_skills_launcher .` で Flutter プロジェクトを生成する（bundle ID は `io.github.yahir0.claude_skills_launcher` になる）
- [x] 1.2 `.fvmrc` を追加し、本プロジェクトで採用する Flutter バージョンを固定する
- [x] 1.3 `pubspec.yaml` に依存パッケージを追加する（`flutter_hooks` / `hooks_riverpod` / `riverpod_annotation` / `freezed_annotation` / `json_annotation` / `go_router` / `go_router_builder` / `dio` / `path_provider` / `file_picker` / `image` / `xterm` / `flutter_pty` / `window_manager`）
- [x] 1.4 `pubspec.yaml` の dev_dependencies に `build_runner` / `freezed` / `json_serializable` / `riverpod_generator` / `go_router_builder` / `mocktail` / `flutter_lints` を追加する（`custom_lint` / `riverpod_lint` は現時点で riverpod 3.x との依存解決ができないため、エコシステム側が追従し次第別 change で追加）
- [x] 1.5 `analysis_options.yaml` を本プロジェクトのコーディング規約（`docs/coding-standards.md` で定義）に沿って整備する
- [x] 1.6 `dart_defines/prod.json` を作成し、最低限のキー（`APP_NAME` 等）を設定する（Flavor 分離はしない）
- [x] 1.7 `.vscode/launch.json` に prod 用 1 種の起動コンフィグを追加する
- [x] 1.8 `macos/Runner/DebugProfile.entitlements` / `Release.entitlements` から App Sandbox を無効化し、PTY 経由を含む子プロセス起動を許可するキーを追加する
- [x] 1.9 `macos/Runner/MainFlutterWindow.swift` を編集し、`isOpaque = false` / `backgroundColor = .clear` を設定する
- [x] 1.10 `.gitignore` に `dart_defines/*.local.json` 等のローカル設定を追加する

## 2. アーキテクチャ骨組み（MVVM 構成）

- [x] 2.1 `lib/app/main.dart` を作成し、`WidgetsFlutterBinding` 初期化 → `window_manager` 初期化 → `runApp` の順を実装する
- [x] 2.2 `lib/app/app.dart` を作成し、`ProviderScope` / `MaterialApp.router` の最小構成を組む
- [x] 2.3 `lib/app/router.dart` に go_router_builder ベースの `/` `/run/:entryId` `/settings` `/settings/entries/new` `/settings/entries/:id` を定義する
- [x] 2.4 `lib/app/theme.dart` に Material 3 ベースの ThemeData を作成する
- [x] 2.5 `lib/core/storage/app_paths.dart` に `path_provider` 経由でサポートディレクトリを取得するヘルパーを置く
- [x] 2.6 `lib/core/exceptions/app_exception.dart` に独自例外型（`AppException` Freezed Union）を定義する
- [x] 2.7 ディレクトリ骨格を作る:
  - `lib/ui/{home,settings,run,common}/` と `.gitkeep`
  - `lib/data/{launcher_entry,appearance,skill_runner}/` と `.gitkeep`
  - `lib/core/` 配下の必要サブディレクトリ

## 3. launcher_entry（data） + settings フィーチャー（ui）

### 3a. data 層

- [ ] 3.1 `lib/data/launcher_entry/launcher_entry.dart` に Freezed モデル `LauncherEntry` を定義する（id / displayName / repositoryPath / skillName / iconPath / createdAt）
- [ ] 3.2 `lib/data/launcher_entry/launcher_entry_dto.dart` に JsonSerializable な `LauncherEntryDto` を実装し、`LauncherEntry` ↔ DTO の変換ヘルパーを書く
- [ ] 3.3 `lib/data/launcher_entry/launcher_entry_repository.dart` に interface を定義する（`loadAll` / `add` / `update` / `delete`）
- [ ] 3.4 `lib/data/launcher_entry/launcher_entry_repository_impl.dart` に `<appSupport>/launcher_entries.json` 経由の実装を書く
- [ ] 3.5 Riverpod Provider `launcherEntryRepositoryProvider` を定義し、`LauncherEntryRepositoryImpl` を返す

### 3b. ui 層

- [ ] 3.6 `lib/ui/settings/settings_view_model.dart` に `SettingsViewModel`（AsyncNotifier）を実装する。`loadEntries` / `addEntry` / `updateEntry` / `deleteEntry` を公開
- [ ] 3.7 `lib/ui/settings/settings_page.dart` を実装する（エントリ一覧・追加ボタン・各エントリ行のタップで編集画面へ）
- [ ] 3.8 `lib/ui/settings/entry_edit_view_model.dart` に `EntryEditViewModel`（family で `entryId?` を受け取る）を実装する。バリデーション・保存ロジックを保持
- [ ] 3.9 `lib/ui/settings/entry_edit_page.dart` を実装する（表示名・リポジトリパス・Skill 名・アイコン選択フィールド + バリデーションエラー表示）
- [ ] 3.10 リポジトリパス入力欄に `file_picker` でディレクトリ選択ダイアログを呼び出す機能を実装する
- [ ] 3.11 アイコン選択で画像ファイルを選び、`image` パッケージで 512px に縮小して `<appSupport>/icons/<entryId>.png` に保存する処理を ViewModel に実装する
- [ ] 3.12 削除確認ダイアログ + 削除処理を実装する

## 4. home フィーチャー（ui）

- [ ] 4.1 `lib/ui/home/home_view_model.dart` に `HomeViewModel` を実装する（`launcherEntryRepositoryProvider` を購読し、エントリ一覧を AsyncValue で公開）
- [ ] 4.2 `lib/ui/home/home_page.dart` を作成し、ViewModel を購読してアイコングリッドを描画する
- [ ] 4.3 アイコン未登録時のプレースホルダー UI（設定画面導線付き）を実装する
- [ ] 4.4 アイコンタップで `/run/<entryId>` へ go_router 遷移する
- [ ] 4.5 ヘッダーに設定画面への遷移ボタンを設置する
- [ ] 4.6 デフォルトアイコン（assets 配下）を用意し、エントリの iconPath が空の場合のフォールバック表示にする

## 5. skill_runner（data） + run フィーチャー（ui）

### 5a. data 層（PTY ベース）

- [ ] 5.1 `lib/data/skill_runner/skill_run_state.dart` に Freezed Union を定義する（idle / starting / running / completed(exitCode) / failed(message) / cancelled）
- [ ] 5.2 `lib/data/skill_runner/skill_runner.dart` に interface を定義する（`start` / `inputSink` / `output` Stream / `state` Stream / `resize(cols, rows)` / `cancel`）
- [ ] 5.3 `lib/data/skill_runner/pty_skill_runner.dart` を実装し、`flutter_pty` の `PseudoTerminal.start` で `claude` プロセスを `workingDirectory` 指定で起動する
- [ ] 5.4 起動前に `Directory(repositoryPath).existsSync()` で存在チェックし、不在なら failed 状態へ遷移させる
- [ ] 5.5 PTY 起動失敗（`claude` 不在等）の例外をハンドリングし、「`claude` コマンドが見つかりません」のメッセージを failed 状態に乗せる
- [ ] 5.6 PTY の `exitCode` Future を購読し、completed 状態へ遷移させる
- [ ] 5.7 cancel メソッドで SIGTERM を送り、cancelled 状態へ遷移させる
- [ ] 5.8 resize メソッドで `pty.resize(rows, cols)` を呼び出すパススルー実装を入れる
- [ ] 5.9 Riverpod Provider（family modifier で entryId をパラメータ化）を定義し、`PtySkillRunner` を返す

### 5b. ui 層（フルターミナル）

- [ ] 5.10 `lib/ui/run/run_view_model.dart` に `RunViewModel`（family で `entryId` を受け取る）を実装する。`SkillRunner` の状態を View に橋渡しし、再実行・キャンセル・離脱処理を提供
- [ ] 5.11 `lib/ui/run/run_page.dart` を実装し、ヘッダーに表示名・実行状態・キャンセル/再実行/ホームへ戻るボタンを置く
- [ ] 5.12 `xterm` パッケージの `Terminal` インスタンスを保持する Hook（`useTerminal`）を作成する
- [ ] 5.13 本体に `TerminalView` を配置し、`SkillRunner` の出力ストリームを `terminal.write` に流し込む
- [ ] 5.14 `terminal.onOutput` のコールバックで `SkillRunner` の inputSink にバイト列を書き込む（矢印・Ctrl 修飾・ペースト含む）
- [ ] 5.15 `terminal.onResize` で `SkillRunner.resize(cols, rows)` を呼び、PTY サイズを追従させる
- [ ] 5.16 状態が completed/failed/cancelled になったときの UI 表示（終了コードバッジ・エラーメッセージ）を実装する
- [ ] 5.17 「再実行」ボタンで `ref.invalidate` を呼んで再起動する
- [ ] 5.18 「ホームへ戻る」ボタンで go_router pop し、画面破棄時に `SkillRunner.cancel()` を呼ぶ

## 6. appearance フィーチャー（data + ui）

### 6a. data 層

- [ ] 6.1 `lib/data/appearance/appearance_settings.dart` に Freezed モデルを定義する（mode: transparent/solid/image / solidColor / imagePath）
- [ ] 6.2 `lib/data/appearance/appearance_settings_dto.dart` に JsonSerializable な DTO を実装する
- [ ] 6.3 `lib/data/appearance/appearance_settings_repository.dart` に interface を定義する
- [ ] 6.4 `lib/data/appearance/appearance_settings_repository_impl.dart` に `<appSupport>/appearance.json` 経由の実装を書く

### 6b. ui 層

- [ ] 6.5 `lib/ui/settings/appearance_section_view_model.dart` に `AppearanceSectionViewModel` を実装する（モード切替・カラー設定・画像選択を扱う）
- [ ] 6.6 `lib/ui/settings/appearance_section.dart` を実装し、`SettingsPage` から組み込む
- [ ] 6.7 画像選択時に `<appSupport>/background.png` へコピー保存する処理を ViewModel に実装する
- [ ] 6.8 `lib/app/app.dart` で `AppearanceSectionViewModel` の状態を購読し、`Scaffold` の背景色・背景画像レイヤーへ即時反映する
- [ ] 6.9 `lib/app/main.dart` 内で `window_manager.setBackgroundColor(Colors.transparent)` を初期化時に呼ぶ

## 7. ヘルスチェックとエラー UX

- [ ] 7.1 アプリ起動時に `claude --version` を `Process.run` で実行し、結果を Provider で公開する
- [ ] 7.2 ヘルスチェック失敗時に設定画面上部に警告バナーを表示する
- [ ] 7.3 README.md に「`claude` CLI と `git` を PATH に通すこと」を明記する

## 8. テスト

- [ ] 8.1 `LauncherEntryRepositoryImpl` のユニットテストを書く（一時ディレクトリで JSON 読み書きを検証）
- [ ] 8.2 `SettingsViewModel` のユニットテストを書く（追加・更新・削除で状態が期待通り更新される。Repository を Mocktail でモック）
- [ ] 8.3 `EntryEditViewModel` のユニットテストを書く（バリデーション・新規登録 / 既存編集の分岐）
- [ ] 8.4 `PtySkillRunner` のユニットテストを書く（リポジトリ不在 → failed、正常終了 → completed、cancel → cancelled）。PTY 上で動く軽量コマンド（`bash -lc "exit 0"` 等）で代替する
- [ ] 8.5 `AppearanceSettingsRepositoryImpl` のユニットテストを書く
- [ ] 8.6 `HomePage` の Widget テストを書く（エントリ 0 件時のプレースホルダー / 複数件時のアイコン描画）
- [ ] 8.7 `EntryEditPage` の Widget テストを書く（バリデーションエラー表示）

## 9. ドキュメント

- [ ] 9.1 `README.md` にセットアップ手順・起動コマンド（`flutter run -d macos --dart-define-from-file=dart_defines/prod.json`）・既知の制約を記載する
- [ ] 9.2 `flutter run -d macos --dart-define-from-file=dart_defines/prod.json` で手動疎通確認し、受け入れチェック（アイコン登録 → クリック → PTY 上で Skill 実行 → 対話入力）を完走する

## 10. 仕上げ

- [ ] 10.1 `dart format` / `dart analyze` / `flutter test` をすべてグリーンにする
- [ ] 10.2 公開前チェック: `git grep` で個人情報・組織名・内部 URL が含まれていないことを確認する
- [ ] 10.3 change の archive 準備（成果物の最終確認）
