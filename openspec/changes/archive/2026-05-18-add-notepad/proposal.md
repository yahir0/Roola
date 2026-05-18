## Why

Roola を使う開発者は、作業中にコマンドの控え・一時的なパス・思いついた内容を書き留めたい場面がある。現状はアプリ外のメモアプリやエディタへ切り替える必要があり、ターミナルを見ながらのメモがアプリ内で完結しない。「ちょっとしたメモ書き」に割り切った軽量なノートパッドをワークスペース内に持つことで、この往復をなくす。

## What Changes

- ワークスペース右下（ターミナルの横）に重ねて表示する **ノートパッドのフローティングパネル** を追加する。3 ペインのレイアウト・スプリッタには影響しない独立した重ね表示で、固定サイズ。
- ヘッダ（`MacosWindowAppBar`）の設定アイコン左に **ノートパッドのトグルアイコン** を置く。クリックで開閉する。開閉状態はワークスペース内の一時的 UI 状態として `WorkspacePage` の Hook ローカル状態で持つ。
- パネルは **本文入力欄** と **左端の行番号ルーラ** のみを持つ。標準のテキスト編集ショートカット（コピー / ペースト / カット / 全選択 / 取り消し）は `TextField` 標準に委ねる（⌘C 等は ADR-0035 で予約済みのためコマンド機構と競合しない）。
- 本文は **`<appSupport>/notepad.json` に永続化** し、アプリ再起動後も復元する。`NotepadRepository` interface + `NotepadRepositoryImpl` を置き、本文は単一文字列のため DTO 分離はしない（`locale_settings` と同方針）。起動時に `main()` で同期読み込みし Provider に注入する。
- ワークスペースのタブ種別 union（`WorkspaceTab`）・`workspace.json` スキーマ・ペイン機構は **一切変更しない**。
- txt 等へのファイル書き出し、シンタックスハイライト、複数ノート、検索置換は範囲外。

## Capabilities

### New Capabilities

- `notepad`: ワークスペース右下のフローティングパネルとして、本文入力・行番号ルーラ・本文の永続化を提供する。data 層（`data/notepad/`）と UI / ViewModel（`ui/notepad/`）から成る。

## Impact

- **新規コード**: `data/notepad/`（`NotepadRepository` interface + `NotepadRepositoryImpl`）、`ui/notepad/`（`NotepadPanel` View、行番号ルーラ `NotepadLineGutter`、`NotepadViewModel` = `Notifier<String>`）
- **既存コード変更**: `core/storage/app_paths.dart`（`notepadFile` 追加）、`lib/main.dart`（起動時読み込み + override 注入）、`ui/workspace/workspace_page.dart`（ヘッダのトグルアイコン + パネルの重ね表示。`StatelessWidget` → `HookWidget`）、`l10n/app_ja.arb` / `app_en.arb`（文言追加）
- **永続化**: `<appSupport>/notepad.json` を新規追加。既存ファイルのスキーマ変更はなし
- **依存追加**: なし
- **ドキュメント**: ADR-0036「ノートパッドをワークスペース外のフローティングパネルとして実装する」を追加
