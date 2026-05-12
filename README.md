# Claude Skills Launcher

Mac 向けの Claude Code Skills ランチャーアプリ（Flutter Desktop / macOS）。
登録したリポジトリと Skill の組み合わせをアイコンとして並べ、ワンクリックで対象ディレクトリで Skill 実行まで到達することを目的にしています。

## 主な機能

- **アイコングリッド**: ホーム画面に登録済みエントリをアイコンで並べ、クリックで実行画面へ
- **アプリ内 PTY ターミナル**: `xterm` ベースのフルターミナルを内蔵。承認プロンプト・矢印キー操作・ANSI 制御に対応
- **設定画面**: エントリ追加・編集・削除、アイコン画像登録、リポジトリパスのディレクトリ選択
- **外観カスタマイズ**: 透過 / 単色 / 画像背景の切り替え
- **ヘルスチェック**: `claude` CLI の存在確認と設定画面でのバナー表示

## 前提条件

- macOS（Apple Silicon / Intel どちらも）
- [`claude`](https://docs.claude.com/claude-code) CLI が PATH に通っていること
- `git` が PATH に通っていること
- Flutter SDK（バージョンは `.fvmrc` 参照 / [FVM](https://fvm.app/) 推奨）

## セットアップと起動

```bash
# 依存パッケージのインストール
flutter pub get

# コード生成（Freezed / Riverpod / go_router_builder）
dart run build_runner build

# 起動
flutter run -d macos --dart-define-from-file=dart_defines/prod.json
```

VSCode から起動する場合は `.vscode/launch.json` の「Launch (prod)」コンフィグを使ってください。

## 既知の制約

- macOS 専用です（Windows / Linux サポートは現時点では行っていません）
- App Sandbox は **無効化** されています（PTY 起動と任意ディレクトリへのアクセスのため）。配布フェーズで再評価が必要です
- `riverpod_lint` / `custom_lint` は riverpod 3.x との依存解決の都合で現在保留中（詳細は `docs/adr/0007-riverpod-lint-deferral.md` を参照）

## 開発者向け情報

設計判断は `docs/adr/` を参照してください。アーキテクチャの詳細は `docs/architecture.md`、コーディング規約は `docs/coding-standards.md` にあります。

仕様駆動開発として [OpenSpec](https://github.com/lukasvalle/openspec) を採用しています。新しい change は `openspec new change <name>` で起こせます。

## ライセンス

未定（公開時に設定）。
