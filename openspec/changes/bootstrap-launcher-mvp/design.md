## Context

Mac 上で Claude Code の Skill を実行するには、ターミナル起動 → `cd` → `claude` → Skill 名入力という 3〜4 ステップが毎回発生する。本 change は、設定済みのリポジトリ + Skill の組み合わせを「アイコン」として登録し、ワンクリックで実行まで到達する Mac 向けデスクトップアプリの初期 MVP を構築する。

技術スタックは Flutter 公式 [App architecture guide](https://docs.flutter.dev/app-architecture) の MVVM パターンに、状態管理 Riverpod / Hooks、モデル Freezed、ルーティング go_router を組み合わせる。Mac 固有のウィンドウ装飾・PTY 制御・ターミナル描画のみアプリ固有で追加する。Skill 実行は **最初から PTY ベース** とし、`flutter_pty` で `claude` CLI を擬似端末上で起動して入出力をバイト列ストリームで橋渡しする。後から差し替える方針は取らない。

想定ユーザーは Claude Code Skills を日常的に活用する開発者で、CLI ベースのツール操作に習熟していることを前提とする（PTY 統合ターミナルでの対話入力が UI の中核となるため）。本ツールは「daily use の摩擦を下げる」ことが目的のため、UX の素直さ（最短経路でアイコン → 実行 → 操作）を最優先する。

## Goals / Non-Goals

**Goals:**

- Flutter Desktop（macOS）の新規プロジェクトとして、Flutter 公式 MVVM 構成（`ui/` / `data/` / `core/` + 起動系 `app/`）・Riverpod DI・Freezed モデル・go_router ナビゲーションの骨組みを動く形で組む。
- 設定画面でリポジトリパス・Skill 名・アイコン・表示名を登録し、永続化する。
- ホーム画面の登録アイコンクリックで対応リポジトリ内で `claude` を起動し、Skill を実行できる。
- 実行中の stdout/stderr をアプリ内ターミナルビューに表示し、stdin への入力（承認 y/n や行入力）が可能。
- アプリ背景は透過がデフォルトで、設定で単色・画像に切り替えられる。
- VSCode から `flutter run --dart-define-from-file=dart_defines/prod.json` で起動できる構成を `.vscode/launch.json` 付きで整備する。

**Non-Goals:**

- 簡易エクスプローラ機能（ディレクトリツリー表示・Skill 自動検知・右クリック → Claude 起動）。
- Git リポジトリのクローンウィザード。
- Spotlight 風の展開アニメーション・ホットキーでの呼び出し。
- 複数 Skill のチェイン実行 / 並列実行。
- Windows / Linux サポート。Mac のみ動作確認する。
- 配布（コード署名・公証・dmg 化）。本 change ではローカル `flutter run` で動けば良い。
- CI パイプライン（format / analyze / test の自動化）。本 change には含めない。
- 環境分離（dev / stg / prod の Flavor 構成）。本アプリは将来も URL 切り替え等を行わない方針で、単一環境（prod）のみ用意する。

## Decisions

### 1. Flutter Desktop（macOS）を採用する

代替案として Electron / SwiftUI / Tauri を検討した。**Flutter Desktop を採用** する理由:
- Flutter エコシステム標準のライブラリ群（Riverpod / Freezed / go_router 等）と公開ドキュメントをそのまま参照でき、規約整備コストが低い。
- Riverpod / Freezed / Dio / go_router 等の既存ライブラリ群がそのまま使える。
- Mac 限定のため、Skia レンダリングの違いやネイティブ統合の制限も許容範囲。

### 2. Skill 実行は最初から PTY ベース（`flutter_pty`）

`dart:io Process.start` での実装も検討したが、**最初から PTY ベースで実装する** ことを決定した。

理由:
- 現状ユーザーが使用している Claude Skills 群は、承認プロンプト（y/n）・矢印キーでの選択 UI・ANSI 制御による画面更新など、**TTY を前提とした対話** を多用する。`Process.start` ではこれらをまともに扱えない。
- 後から `Process.start` → PTY に差し替える計画は、状態管理境界の再設計やテスト書き直しを伴い、コストが大きい。MVP 段階で PTY ベースに揃えるほうが結果的に安く済む。

採用パッケージ: **`flutter_pty`**（Mac / Linux / Windows をサポート、`xterm.dart` の公式作者と同系統メンテで親和性が高い）。`PseudoTerminal.start(executable, arguments, workingDirectory, environment)` で `claude` を起動し、`pty.output` ストリームを購読、`pty.write(bytes)` でキー入力を流す。

代替案として検討:
- `dart:io Process.start`: 上記のとおり TTY 要件で却下。
- `process` パッケージ: `Process.start` のラッパーであり TTY 問題は解決しない。

### 2-α. PTY 抽象化境界

`SkillRunner` インターフェースは PTY 前提の API として定義する（バイト列入出力 + リサイズ + 状態）。`flutter_pty` から別 PTY 実装へ将来差し替える場合も、`data/skill_runner/` 配下の `PtySkillRunner` を取り替えるだけで `ui/` 層・`app/` 層は無修正で済む。

### 3. ターミナル表示は `xterm` パッケージのフルターミナル UI

**`xterm` パッケージ** を採用する。Terminal オブジェクトに PTY 出力バイト列をそのまま流し込み、`Terminal.onOutput` でキー入力（矢印・Ctrl/Alt 修飾・ペースト含む）を取得して PTY の `write` に橋渡しする。ウィンドウサイズの変化に応じて `Terminal.resize(cols, rows)` と `pty.resize(rows, cols)` を同期する。

`SelectableText` ベースで自前 ANSI パーサを書く案は、TTY 対応コストを考えると割に合わないので却下。

### 4. 永続化は JSON ファイル on `path_provider`

代替: `shared_preferences` / Hive / Drift / sqlite。**JSON ファイル（`path_provider` の `getApplicationSupportDirectory` 配下）** を選ぶ理由:
- データ量が少ない（ランチャーエントリ数十件 + 設定）。
- スキーマ進化はあり得るが、Freezed + JsonSerializable で十分対応可能。
- ユーザーが手で開いて編集・バックアップしやすい。

ファイル構成:
- `<appSupport>/launcher_entries.json` — ランチャーエントリ一覧。
- `<appSupport>/appearance.json` — 背景・透過などの外観設定。
- `<appSupport>/icons/<entry-id>.png` — ユーザーアイコン画像（コピー保存）。

### 5. 透過ウィンドウは `window_manager` + macOS 側の調整

`window_manager` パッケージで `setBackgroundColor(Colors.transparent)` を呼び、macOS の `MainFlutterWindow.swift` で `isOpaque = false` / `backgroundColor = .clear` を設定する。Vibrancy（背景ブラー）は MVP では入れない。

### 6. ルーティングは go_router + go_router_builder

画面遷移は型安全な `GoRouteData`（go_router_builder）で定義する。MVP の画面は以下:
- `/` — ホーム（ランチャーアイコン一覧）
- `/run/:entryId` — 実行画面（ターミナルビュー）
- `/settings` — 設定（エントリ一覧 + 外観設定）
- `/settings/entries/new` `/settings/entries/:id` — エントリ編集

### 7. dart-define（単一環境）

本アプリは将来的にも API URL の切り替え等を行う予定がないため、**Flavor 分離はせず prod 単一構成** とする。`dart_defines/prod.json` のみを用意し、`--dart-define-from-file=dart_defines/prod.json` で読み込む。VSCode `launch.json` も prod 用 1 コンフィグのみ。dart-define ファイルを敢えて 1 ファイル用意するのは、後でクラッシュレポート用フラグ等を足したくなった際の差し込みスロットとしての意味のみ。

### 8. macOS Entitlements

子プロセス起動とユーザー指定ディレクトリへのアクセスのために、以下の対応を取る:
- `macos/Runner/DebugProfile.entitlements` / `Release.entitlements` から **App Sandbox を無効化**（`com.apple.security.app-sandbox = false`）。
- 加えて `com.apple.security.cs.allow-jit` `allow-unsigned-executable-memory` を Debug / Release で許可。
- 将来的に配布する場合は user-selected file entitlement + security-scoped bookmark へ移行する旨を design に明記し、本 change のスコープ外とする。

### 9. レイヤー構成（Flutter 公式 MVVM）

本プロジェクトは Flutter 公式 App architecture guide の MVVM パターンを採用する。詳細とレイヤーごとの責務・依存方向は `docs/architecture.md` を参照（本 change の archive 時に `openspec/specs/` へ反映される）。背景は `docs/adr/0006-mvvm-over-clean-architecture.md` を参照。

要約のディレクトリ構成:

```
lib/
  app/        # 起動・DI・ルーティング・テーマ
  ui/         # View + ViewModel（フィーチャー単位）
    home/
    settings/
    run/
    common/
  data/       # モデル + Repository（フィーチャー単位）
    launcher_entry/
    appearance/
    skill_runner/
  core/       # 横断ユーティリティ・例外
```

ハイブリッド要素として、以下のみ Repository pattern の interface + impl 二段構えを残す（差し替え可能性のため）:

- `SkillRunner` interface → `PtySkillRunner` 実装
- `LauncherEntryRepository` interface → ローカル JSON 実装
- `AppearanceSettingsRepository` interface → ローカル JSON 実装

DTO ⇄ モデル分離は永続化フィーチャー（`launcher_entry` / `appearance`）のみ実施。`skill_runner` は表示・状態のみで永続化を持たないため分離しない。Use Case 層は作らず、ロジックは ViewModel に集約する。

## Risks / Trade-offs

- **claude CLI 不在**: ユーザーの PATH に `claude` が無い場合、PTY 起動が失敗する → 起動時に `claude --version` をヘルスチェックし、不在なら設定画面でエラー表示。Mitigation: アプリ起動時のヘルスチェック Provider を用意。
- **`flutter_pty` の macOS 動作**: PTY ライブラリは OS ごとの挙動差があり、ANSI 制御の取りこぼしやサイズ変更時の文字化けが起こる可能性がある → MVP では `xterm` のデフォルト設定で動作確認し、不具合は `data/skill_runner/` 配下で吸収する。Mitigation: `PtySkillRunner` を薄く保ち、将来差し替えやすい境界に保つ。
- **macOS Sandbox 無効化**: 配布時にセキュリティ評価が厳しくなる → MVP はローカル開発限定とし、Sandbox 無効化を許容。Mitigation: 配布フェーズで別 change を立てる。
- **透過ウィンドウのちらつき / 描画不整合**: Flutter の透過は macOS で時々背景に残像が出る → MVP では透過を「許容範囲の見た目」で受け入れる。Mitigation: 設定で「不透明」に切り替え可能にして逃げ道を用意。
- **アイコン画像の大量保存によるディスク肥大**: ユーザーが大きな PNG を登録するとサイズが膨らむ → 登録時に 512px へリサイズして保存。Mitigation: `image` パッケージで縮小処理。
- **PTY 出力レンダリング負荷**: ターミナル全画面更新を頻繁に行う Skill では描画コストが上がる → `xterm` のスクロールバック上限を妥当な値（例: 1,000 行）に設定。Mitigation: パフォーマンス検証は MVP の受け入れ条件には含めず、Open Question として残す。

## Migration Plan

新規プロジェクトのため、マイグレーション対象は無い。ロールバックは「change archive を取り消す」だけで完結する。

## Open Questions

- `xterm` のスクロールバック上限はデフォルトでよいか、設定可能にするか。
- ランチャーエントリの並び順はユーザー定義（ドラッグ&ドロップ）か登録順か。MVP では登録順固定、並び替えは後続。
- 同じリポジトリで Skill だけ違うエントリを複数登録するケースの UX（コピー登録機能）は後続 change で扱う。
- PTY のサイズ初期値（cols / rows）は固定値で始めるか、ウィンドウサイズから動的計算するか。MVP は固定（80x24）で始め、ウィンドウリサイズで追従させる方針だが、`xterm` のレイアウトメトリクスから自動算出するほうがユーザー体験が良い可能性がある。
