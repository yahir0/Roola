## Why

Roola は開発者向けの汎用ターミナルランチャーだが、現状キーボードショートカットは「パスのコピー（修飾キーなし `C` 2 連打、ADR-0021）」の 1 つしかない。エクスプローラのファイル操作・タブ操作・ナビゲーション・Git 操作はすべてマウス（クリック / 右クリックメニュー）専用で、開発者向けツールとしてキーボード操作性が不足している。

ユーザーは次を求めている:

1. アプリの全アクションにショートカットキーを割り当てる
2. 設定画面からショートカットを確認・編集できる
3. 右クリック（コンテキスト）メニュー各項目の右側に、割り当てショートカットをカッコ付きで表示する
4. ショートカットをユーザーが任意に変更できる

確定済みの方針: `C` `C` 連打（ADR-0021）は廃止し、標準的な「修飾キー + キー」1 コンビへ統一してカスタマイズ可能にする。macOS ネイティブメニューバー（`PlatformMenuBar`）も追加する。キー重複時は設定画面で警告し保存をブロックする。

設計判断は ADR-0033 に記録した。本 change はその実装計画である。

## What Changes

- **コマンドレジストリの新設**: アプリの全アクションを安定 ID（`CommandId` enum）で一元管理し、カテゴリ・日本語ラベル・アイコン・既定キーコンビを静的メタデータ（`CommandRegistry`）として定義する
- **キーバインドの永続化**: ユーザーのカスタム割り当てを `<appSupport>/keybindings.json` に保存する。`appearance` フィーチャーと同じ DTO ⇄ モデル分離 + Repository + `AsyncNotifier` パターン
- **ネイティブメニューバーの追加**: `PlatformMenuBar` をアプリ最上位に追加する。ショートカット機構は `PlatformMenuBar` に一本化し、Flutter の `Shortcuts`/`Actions` は使わない。ADR-0031 によりターミナル（SwiftTerm ネイティブビュー）フォーカス時に Flutter の `Shortcuts` はキーを受け取れないが、メニューバーの key equivalent はファーストレスポンダに関係なく発火するため
- **コマンドディスパッチ機構**: `CommandDispatcher` が `CommandId` を受け取り、フォーカス中タブ / 選択アイテムを provider から解決して実処理へ委譲する
- **コンテキストメニューの統合**: 既存の右クリックメニュー（`showMenu` 群）を `CommandId` ベースの共通ビルダーに置き換え、各項目の右端にショートカットラベルを表示する
- **ショートカット設定画面の新設**: `KeybindingsPage` を追加し、全コマンドをカテゴリ別に一覧・編集できるようにする。キー入力をキャプチャするレコーダダイアログと、重複検出 → 警告 → 保存ブロックを備える
- **`C` `C` 連打の廃止**: `explorer_tab_body.dart` の `Focus.onKeyEvent` による `C` `C` 検出を削除し、`copyPath` コマンドを統一システムへ移行する

## Capabilities

### Added Capabilities

- `keyboard-shortcuts`: アプリの全アクションに対するカスタマイズ可能なキーボードショートカット機構。コマンドレジストリ・キーバインド永続化・ネイティブメニューバー・コマンドディスパッチ・設定画面で構成する

## Impact

- **新規コード（`lib/data/keybindings/`）**: `KeyChord` モデル + DTO、`CommandId` / `CommandCategory` / `CommandMetadata` / `CommandRegistry`、`Keybindings` モデル + DTO、Repository（interface + impl）、`KeybindingsNotifier`、`effectiveKeybindingsProvider`
- **新規コード（`lib/core/keybindings/`）**: 衝突検出・キーコンビ整形・キー入力キャプチャの純粋ユーティリティ
- **新規コード（`lib/app/`）**: `CommandDispatcher`、`AppMenuBar`（`PlatformMenuBar`）
- **新規コード（`lib/ui/`）**: `command_menu_item.dart`（コンテキストメニュー共通ビルダー）、`KeybindingsPage` + キーレコーダダイアログ
- **既存コード変更**:
  - `lib/app/app.dart`（`AppMenuBar` を最上位に差し込む）
  - `lib/app/router.dart`（`KeybindingsRoute` 追加、`router.g.dart` 再生成）
  - `lib/core/storage/app_paths.dart`（`keybindingsFile` getter 追加）
  - `lib/ui/settings/settings_page.dart`（`_ShortcutsSection` を編集画面への導線に変更）
  - `lib/ui/explorer/explorer_tab_body.dart`（`C` `C` 検出の削除）
  - `lib/ui/explorer/explorer_node_tile.dart`（実処理の関数抽出、コンテキストメニューの `CommandId` 化）
  - `lib/ui/workspace/pane_tab_strip.dart` ほかコンテキストメニュー（`commandPopupMenuItem` 化）
- **依存変更**: なし（`PlatformMenuBar` は Flutter 標準）
- **テスト**: 純粋関数（衝突検出 / 整形 / キーキャプチャ / マージ / DTO round-trip）、Repository（実 I/O）、`KeybindingsNotifier`（モック）、`CommandDispatcher`（provider override）、`KeybindingsPage`（Widget）
- **ドキュメント**: ADR-0033 を作成。ADR-0021 の `C` `C` 部分を supersede（ADR-0021 の Status を更新）。`docs/architecture.md` のディレクトリ構成を更新
