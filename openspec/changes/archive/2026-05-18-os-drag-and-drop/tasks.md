## 1. 設計判断の記録

- [ ] 1.1 `docs/adr/0011-os-drag-and-drop.md` を追加（super_drag_and_drop 採用、標準 Draggable 廃止の理由、代替案）
- [ ] 1.2 `docs/adr/README.md` に ADR-0011 をリンク追加
- [ ] 1.3 `CLAUDE.md` の ADR リストに ADR-0011 を追記

## 2. 依存追加

- [ ] 2.1 `pubspec.yaml` の `dependencies` に `super_drag_and_drop: ^0.9.0`
- [ ] 2.2 `flutter pub get`
- [ ] 2.3 `GeneratedPluginRegistrant.swift` の差分確認（super_native_extensions は既登録のため変化なし想定）

## 3. explorer_node_tile.dart の書き換え

- [ ] 3.1 `_DirectoryTile`: `Draggable<String>` を `DragItemWidget + DraggableWidget` に置換
- [ ] 3.2 `_DirectoryTile`: `DragTarget<String>` を `DropRegion(formats: [Formats.fileUri])` に置換
- [ ] 3.3 `_FileTile`: `Draggable<String>` を `DragItemWidget + DraggableWidget` に置換（ファイルは drop target を持たないので DropRegion なし）
- [ ] 3.4 `ExplorerParentDropTile`: `DragTarget<String>` を `DropRegion` に置換
- [ ] 3.5 `_DragFeedback` クラスを削除（OS 描画プレビューに統一）
- [ ] 3.6 top-level helpers を追加:
  - `decideDropOperation(session, target, {disallowSameParent})`: modifier (⌥ / ⌘) + ボリューム判定 + self-loop ガードを統合
  - `performFileDrop(context, ref, event, target)`: `fileUri` を読み、`acceptedOperation` から `prefersCopy` を決めて `moveOrCopyInto` を呼ぶ
  - `moveOrCopyInto(context, ref, source, target, {required prefersCopy})`: `prefersCopy` or 異ボリュームなら `copyInto`、それ以外は `moveInto`
  - `_volumeKey(path)`: `/Volumes/<name>` 単位のボリュームキー
- [ ] 3.7 `Formats.fileUri.decode` が返す URI → ファイルパス変換は `uri.toFilePath()`

## 4. explorer_sidebar.dart の書き換え

- [ ] 4.1 `_FavoriteTile` の `DragTarget<String>` を `DropRegion` に置換
- [ ] 4.2 `decideDropOperation` / `performFileDrop` を import して `_FavoriteTile` 内で利用（ロジックは node_tile.dart に集約）

## 5. 動作検証

- [ ] 5.1 `flutter analyze` が緑
- [ ] 5.2 `flutter test` が緑（既存テスト 64+ に影響無し想定）
- [ ] 5.3 macOS 実機での手動検証
  - エクスプローラ内 → エクスプローラ内（同一ボリューム）: drag → 移動。カーソル「移動」
  - エクスプローラ内 → エクスプローラ内（異ボリューム）: drag → コピー。カーソル「コピー」
  - エクスプローラ内 → エクスプローラ内（⌥ + 同一ボリューム）: drag → コピー。カーソル「コピー」
  - エクスプローラ内 → エクスプローラ内（⌘ + 異ボリューム）: drag → コピー（強制 move 未対応のフォールバック）
  - エクスプローラ内 → サイドバーお気に入り / 「上の階層へ」: ボリューム判定が同じ挙動で効く
  - エクスプローラ内 → Finder: drag → コピー / 移動できる（Finder 側のセマンティクスに従う）
  - エクスプローラ内 → ターミナル (iTerm / 標準): drag → パスがペーストされる
  - エクスプローラ内 → 他アプリ（Slack / Mail 等）: drag → 添付できる
  - Finder → エクスプローラ（同一ボリューム）: drag → 移動
  - Finder → エクスプローラ（異ボリューム）: drag → コピー（自動フォールバック）
  - Finder → エクスプローラ（⌥）: drag → コピー
  - 自身 / 子孫への drop: カーソル「禁止」、無視される

## 6. アーカイブ

- [ ] 6.1 全タスク完了後、`openspec/changes/archive/<YYYY-MM-DD>-os-drag-and-drop/` に移動
