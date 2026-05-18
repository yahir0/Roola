## 1. 準備・ドキュメント

- [x] 1.1 ADR-0036「ノートパッドをワークスペース外のフローティングパネルとして実装する」を `docs/adr/` に作成
- [x] 1.2 `docs/adr/README.md` と `CLAUDE.md` の ADR 一覧に ADR-0036 を追記
- [x] 1.3 `docs/architecture.md` のディレクトリ構成に `data/notepad/` / `ui/notepad/` を追記

## 2. data 層: 永続化

- [x] 2.1 `core/storage/app_paths.dart` に `notepadFile`（`<appSupport>/notepad.json`）を追加
- [x] 2.2 `data/notepad/notepad_repository.dart` に `NotepadRepository` interface を定義（`load` / `save`）
- [x] 2.3 `data/notepad/notepad_repository_impl.dart` で `notepad.json` 実装。本文は単一文字列のため DTO 分離はしない。`notepadRepositoryProvider` / `notepadInitialContentProvider` も定義
- [x] 2.4 `main.dart` で起動時に本文を同期読み込みし、`notepadInitialContentProvider` を `overrideWithValue` で注入

## 3. ui 層: ViewModel

- [x] 3.1 `ui/notepad/notepad_view_model.dart` に `NotepadViewModel`（`Notifier<String>`）を実装。本文の保持・debounce 永続化・破棄時 flush を担う

## 4. ui 層: パネル

- [x] 4.1 `ui/notepad/notepad_line_gutter.dart` に行番号ルーラ widget を実装。論理行ごとの高さを `TextPainter` で実測し折り返しに追従
- [x] 4.2 `ui/notepad/notepad_panel.dart` に `NotepadPanel`（ヘッダ + 行番号ルーラ + 本文 `TextField`）を実装
- [x] 4.3 `ui/workspace/workspace_page.dart` を `HookWidget` 化し、ヘッダにトグルアイコンを追加。`_WorkspaceArea` を `Stack` で包みパネルを右下に重ねる

## 5. 多言語化

- [x] 5.1 `l10n/app_ja.arb` / `app_en.arb` にノートパッド関連文言を追加し、`flutter gen-l10n` で再生成

## 6. テスト

- [x] 6.1 `test/data/notepad/notepad_repository_impl_test.dart`（load / save ラウンドトリップ・不正データ）
- [x] 6.2 `test/ui/notepad/notepad_view_model_test.dart`（初期値・更新・debounce 永続化・破棄時 flush）
- [x] 6.3 `test/ui/notepad/notepad_panel_test.dart`（本文入力・行番号表示・閉じる操作）

## 7. 仕上げ

- [x] 7.1 `dart format` / `dart analyze`（警告ゼロ）/ `flutter test`（全グリーン）を通す
