## Why

エクスプローラ画面のドラッグ＆ドロップは現状 Flutter 標準の `Draggable` / `DragTarget` 実装で、アプリ内のタイル同士・タイルとお気に入りサイドバー間の移動だけサポートしている。

アプリ外（macOS Finder、デスクトップ、他アプリのファイルドロップ受け口）には到達しないため、以下の体験ができない:

- ターミナルへドラッグしてパスを貼る
- Finder / デスクトップへドラッグしてコピー / 移動
- Mail / Slack 等の他アプリにファイル添付

逆向きの「Finder → エクスプローラ」も Flutter 標準 DnD では受けられない（Flutter の `Draggable` は同一 widget tree 内のみ）。OS 連携のためには native bridge が必要。

## What Changes

- `super_drag_and_drop` パッケージを採用し、OS レベル DnD のブリッジを通す
- 既存の Flutter 標準 `Draggable` / `DragTarget` を、それぞれ `DragItemWidget + DraggableWidget` / `DropRegion` に置換
- DragItem には `Formats.fileUri(Uri.file(path))` を載せ、Finder / 他アプリでファイル参照として受け取れるようにする
- DropRegion は内部・外部いずれからの `Formats.fileUri` も Finder 等価のセマンティクスで処理する:
  - 同一ボリューム & 修飾キー無し: `ExplorerFileOps.moveInto`（rename）
  - 異ボリューム or ⌥ (option): `ExplorerFileOps.copyInto`（`cp -R`）
  - ⌘ (command) は強制 move（ただし異ボリュームは copy にフォールバック、強制 move の copy+delete は未対応）
- カーソルバッジは `onDropOver` で modifier + 内部 source のボリューム判定から `DropOperation.move` / `copy` / `none` を返して OS に反映させる
- 影響範囲は `lib/ui/explorer/explorer_node_tile.dart` と `lib/ui/explorer/explorer_sidebar.dart` の二ファイル

## Capabilities

### Modified Capabilities

- `repo-explorer`: ドラッグ＆ドロップ要件を OS 連携対応に拡張。drag source は OS 互換の `Formats.fileUri` を提供し、drop target は内部・外部の `Formats.fileUri` を受け付ける

## Impact

- **新規依存**: `super_drag_and_drop` ^0.9.0 を追加。下位依存の `super_native_extensions` は既に `super_clipboard` 経由で登録済み（`GeneratedPluginRegistrant.swift` 確認済み）のため、Pod / native の二重ビルドは発生しない
- **macOS entitlements**: app sandbox は既に false（子プロセス起動の都合）、追加 entitlements は不要
- **`ExplorerFileOps`**: 既存 `moveInto` / `copyInto` を組み合わせて使う。ボリューム判定（`_volumeKey` で `/Volumes/<name>` 単位）を `lib/ui/explorer/explorer_node_tile.dart` 側で行い、cross-volume の move は自動で copy にフォールバック
- **修飾キー判定**: `HardwareKeyboard.instance.isAltPressed` / `isMetaPressed` を `onDropOver` で参照。カーソルバッジに即反映
- **テスト**: 既存の widget テスト（`test/ui/explorer/explorer_page_test.dart`）は DnD を assert していないため非影響。drag/drop の単体 widget テストは super_drag_and_drop の native 依存を pump できないため後追いとし、まずは macOS 実機での動作確認で代える
- **非 goal**:
  - 外部 drop を「エントリ追加導線」として扱う UX（Finder からエクスプローラへドロップして launcher entry を一発登録する等）はこの change の範囲外
  - 異ボリュームに対する「強制 move」（Finder の ⌘+drag 相当の copy + 元削除）: 実装複雑度に対する価値が低いため未対応。⌘ + 異ボリュームは copy にフォールバック
  - ドラッグ中のカスタムプレビュー画像（`_DragFeedback` チップは Flutter 標準 `Draggable.feedback` 由来で、`DraggableWidget` のプレビューは OS 側が描画する）。チップ風 feedback は廃止する
