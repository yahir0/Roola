## 1. 準備・ドキュメント

- [x] 1.1 ADR-0033「コマンドレジストリとネイティブメニューバーによる統一ショートカット機構」を `docs/adr/` に作成
- [x] 1.2 ADR-0021 の Status を更新し、`C` `C` 部分が ADR-0033 に supersede されたことを明記
- [x] 1.3 `docs/adr/README.md` と `CLAUDE.md` の ADR 一覧に ADR-0033 を追記
- [x] 1.4 `docs/architecture.md` のディレクトリ構成に `data/keybindings/` / `core/keybindings/` を追記

## 2. data 層: KeyChord / コマンドレジストリ

- [x] 2.1 `data/keybindings/key_chord.dart` に `KeyChord`（修飾キー bool 群 + `triggerKeyId`）を Freezed で定義。`SingleActivator` 変換・表示ラベル整形は core 側に委譲
- [x] 2.2 `data/keybindings/command_id.dart` に `enum CommandId`（全コマンド）を定義
- [x] 2.3 `data/keybindings/command_category.dart` に `enum CommandCategory` を定義
- [x] 2.4 `data/keybindings/command_metadata.dart` に `CommandMetadata` を定義
- [x] 2.5 `data/keybindings/command_registry.dart` に `CommandId → CommandMetadata` の静的 Map と参照 API（`metadataFor` / `all` / `byCategory`）を定義
- [x] 2.6 `data/keybindings/keybindings.dart` に `Keybindings`（`Map<CommandId, KeyChord>` 上書き）を Freezed で定義
- [x] 2.7 `build_runner` を実行し Freezed 生成物を出力

## 3. core 層: 純粋ユーティリティ

- [x] 3.1 `core/keybindings/chord_formatter.dart` に `KeyChord` → 表示文字列、`KeyChord` → `SingleActivator`（`MenuSerializableShortcut`）変換を実装
- [x] 3.2 `core/keybindings/chord_conflict.dart` に衝突検出の純粋関数（`findConflicts` / `conflictingCommand`）を実装
- [x] 3.3 `core/keybindings/key_chord_recorder.dart` に生 `KeyEvent` → `KeyChord` 組み立てと修飾必須バリデーションを実装

## 4. data 層: 永続化

- [x] 4.1 `core/storage/app_paths.dart` に `keybindingsFile` getter を追加
- [x] 4.2 `data/keybindings/key_chord_dto.dart` / `keybindings_dto.dart` を json_serializable で定義（`CommandId` は `name` 文字列、未知キー読み飛ばし）
- [x] 4.3 `data/keybindings/keybindings_repository.dart`（interface）/ `keybindings_repository_impl.dart`（`<appSupport>/keybindings.json` 実装 + `keybindingsRepositoryProvider` + `KeybindingsNotifier`（`setChord` / `resetToDefault` / `resetAll`）+ `keybindingsProvider`）を実装。全コマンドは常に実効キーコンビを持つため未割り当て（unbind）は設けない
- [x] 4.4 `data/keybindings/effective_keybindings.dart` に既定 + 上書きをマージする `effectiveKeybindingsProvider` を実装
- [x] 4.5 `build_runner` を実行し json_serializable 生成物を出力

## 5. ディスパッチ機構

- [x] 5.1 `explorer_node_tile.dart` の `_handleDirectoryAction` / `showFileContextMenu` の各実処理を、`BuildContext` + `WidgetRef` + 対象パスを取るトップレベル関数へ抽出（挙動不変）
- [x] 5.2 `app/command_dispatcher.dart` に `CommandDispatcher` を実装。`CommandId` ごとにフォーカス解決 → 実処理委譲

## 6. ネイティブメニューバー

- [x] 6.1 `app/app_menu_bar.dart` に `PlatformMenuBar` を組む `AppMenuBar` を実装（`effectiveKeybindingsProvider` を watch）
- [x] 6.2 `app/app.dart` の `MaterialApp.router` builder 最上位に `AppMenuBar` を差し込む

## 7. コンテキストメニュー統合

- [x] 7.1 `ui/common/command_menu_item.dart` に `CommandId` から「アイコン + ラベル + trailing ショートカット」の `PopupMenuItem` を返す共通ビルダーを実装
- [x] 7.2 `explorer_node_tile.dart` の `showExplorerContextMenu` / `showFileContextMenu` を `commandPopupMenuItem` ベースに置換
- [x] 7.3 `pane_tab_strip.dart` のタブ右クリックメニューを `commandPopupMenuItem` ベースに置換
- [x] 7.4 `explorer_sidebar.dart` / `launcher_management_page.dart` の右クリックメニューのうち割り当て対象項目を `commandPopupMenuItem` 化

## 8. ショートカット設定画面

- [x] 8.1 `ui/settings/key_chord_recorder_dialog.dart` にキー入力キャプチャ + 衝突警告 + 保存ブロックのダイアログを実装
- [x] 8.2 `ui/settings/keybindings_page.dart` に `KeybindingsPage`（カテゴリ別一覧 + 編集 + デフォルトに戻す）を実装
- [x] 8.3 `app/router.dart` に `KeybindingsRoute` を追加し `build_runner` で `router.g.dart` を再生成
- [x] 8.4 `ui/settings/settings_page.dart` の `_ShortcutsSection` を `KeybindingsRoute` への導線に変更（マウス操作の説明行は残す）

## 9. C C 廃止

- [x] 9.1 `explorer_tab_body.dart` の `C` `C` 検出（`handleC` / `lastCAt` / `_ccGap` / `Focus.onKeyEvent`）を削除

## 10. テスト

- [x] 10.1 純粋関数ユニットテスト: `chord_formatter` / `chord_conflict` / `key_chord_recorder` / `effective_keybindings` のマージ
- [x] 10.2 DTO round-trip テスト: `KeyChordDto` / `KeybindingsDto`（未知 `CommandId` 読み飛ばし含む）
- [x] 10.3 Repository テスト: 一時ディレクトリで `keybindings.json` の load/save、空 / 壊れ JSON でデフォルト返却
- [x] 10.4 `KeybindingsNotifier` テスト: モック Repository で `setChord` / `resetToDefault` / `resetAll`
- [x] 10.5 `CommandDispatcher` テスト: ワークスペースを override しタブ操作系コマンドの委譲を検証
- [x] 10.6 `KeybindingsPage` Widget テスト: カテゴリ別の全コマンド行と既定ショートカットの表示。衝突時の保存ブロックは `chord_conflict` のユニットテストと実機確認でカバー

## 11. 検証

- [x] 11.1 `dart run build_runner build` が通る
- [x] 11.2 `fvm flutter analyze` がクリーン
- [x] 11.3 `fvm flutter test` が通る（既存の `git_tab_test` 3 件は本 change 以前からの環境依存失敗で対象外）
- [ ] 11.4 `fvm flutter run -d macos` で実機確認（メニューバー表示・ショートカット発火・ターミナルフォーカス時の発火・コンテキストメニュー表示・設定画面の編集と衝突警告・C C 無効化）
