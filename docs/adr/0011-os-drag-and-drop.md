# ADR-0011: エクスプローラのドラッグ＆ドロップを `super_drag_and_drop` で OS 連携にする

- **Status**: Accepted
- **Date**: 2026-05-13

## Context

エクスプローラ画面のドラッグ＆ドロップは Flutter 標準の `Draggable` / `DragTarget` で実装されており、データの受け渡しは `Draggable<String>(data: path)` 形式の単純な型でアプリ内に閉じている。これは Flutter 公式ガイドに沿った最も自然な実装だが、ウィジェットツリー外（OS 上の他アプリや Finder）とは一切やり取りできない制約を持つ。

ユーザーから以下のユースケースが繰り返し求められた:

1. エクスプローラのノードを **Finder にドラッグして移動 / コピー**
2. ノードを **ターミナルにドラッグしてパスをペースト**
3. ノードを **Slack / Mail 等の他アプリにドラッグして添付**
4. **Finder からエクスプローラへドラッグしてファイルを取り込む**

いずれも標準の `Draggable` では実現不可能。OS のドラッグセッション（macOS だと `NSPasteboardItem` / Promise Files / `NSItemProvider`）に乗る必要がある。

Flutter desktop の DnD 周辺は plugin の選択肢が複数あるが、`super_clipboard` を採用済みの本プロジェクトでは `super_native_extensions` が既に登録されており、同じファミリーの `super_drag_and_drop` が最短距離で導入できる状況だった。

## Decision

エクスプローラ画面の DnD 実装を、**Flutter 標準 `Draggable` / `DragTarget` から `super_drag_and_drop` 系（`DragItemWidget` + `DraggableWidget` / `DropRegion`）に置換する**。drag item には `Formats.fileUri(Uri.file(path))` を載せ、Finder / 他アプリ / 他アプリからの drop と双方向に互換する。

drop ハンドラは内部・外部いずれの発生元でも `Formats.fileUri` を受け、**Finder と同等の操作判定**で `ExplorerFileOps.moveInto` / `copyInto` に振り分ける:

- 同一ボリューム & 修飾キー無し: move
- 異ボリューム: copy（rename が失敗するため自動でフォールバック）
- ⌥ (option): copy（強制）
- ⌘ (command): move（強制、ただし異ボリュームは copy にフォールバック）

カーソルバッジは `onDropOver` から返す `DropOperation.move` / `copy` / `none` を OS が描画する。判定ロジックは `lib/ui/explorer/explorer_node_tile.dart` の top-level helpers (`decideDropOperation` / `performFileDrop` / `moveOrCopyInto`) に集約し、サイドバーも同 helpers を import して利用する。

## Why

### 代替案 1: `desktop_drop` + Flutter 標準 `Draggable` の併用

却下。

- `desktop_drop` は OS → アプリの drop は受けられるが、アプリ → OS の drag を発行できない（外向きが未サポート）
- ユースケース 1 / 2 / 3 が満たせず、要件の半分しかカバーできない
- 内部 DnD（Flutter 標準）と外部 DnD（desktop_drop）が別レイヤーで動くため、drop 先によって挙動が変わって混乱を生む

### 代替案 2: macOS native でカスタム実装

却下。

- `NSItemProvider` / `NSDraggingSource` を直接扱う method channel を組めば実現可能だが、実装・テスト・メンテのコストが大きい
- Linux / Windows desktop 展開時に同等の実装を二度書く必要が出る
- Flutter エコシステムに既にメンテされている `super_drag_and_drop` がある以上、自前実装の正当化が難しい

### 採用理由

- `super_clipboard` で **`super_native_extensions` が既登録**。追加 Pod / native ビルドが事実上ゼロコスト
- アプリ ↔ OS の **双方向** をワンセットで提供（drag source / drop target いずれも）
- 標準フォーマット（`Formats.fileUri`）が Finder / ターミナル / 他アプリで広く認識される
- API が `Draggable` / `DragTarget` に概念対応（`DraggableWidget` / `DropRegion`）しており、移行が局所修正で済む
- 同作者の超有名 plugin ファミリー（`super_clipboard` / `super_drag_and_drop` / `super_native_extensions`）でメンテナンス活発

## Trade-offs

### `_DragFeedback` チップの廃止

これまでドラッグ中はカスタムの小チップ（アイコン + ノード名）を `Draggable.feedback` で描画していた。`DraggableWidget` は OS 標準のドラッグプレビュー（ノードのサムネを OS 側がレンダリング）に切り替わるため、見た目が変わる。Finder と一貫性を取る方向のトレードオフとして許容する。

### Widget テストでの mocking 困難性

`super_drag_and_drop` は native channel 経由で動作し、`flutter_test` 上では呼び出しが no-op になる。drag/drop の widget 単体テストは追加せず、`ExplorerFileOps.moveInto` のユニットテストでロジック側のカバレッジを担保。受け入れは macOS 実機での手動検証で行う。

### 異ボリュームの強制 move 未対応

Finder の ⌘+drag は異ボリューム間でも「copy + 元削除」で擬似 move を実現するが、本実装ではフォールバックで copy 止まりにする。実装するには:

1. `copyInto` 成功確認
2. 元 path を `trashServiceProvider` でゴミ箱送り（あるいは即削除）
3. いずれかが失敗した場合の rollback / 重複コピー検出

の 3 段階トランザクションが必要で、考慮ポイントが多い。実装複雑度に対する価値は低いと判断し、必要になった時点で別 ADR / change で扱う。

### 外部 drag のカーソル表示が一瞬ずれる

外部 drag では `onDropOver` 同期文脈で source ファイルパスを取れない（`reader.getValue` は async）。そのため修飾キー無し外部 drag では `onDropOver` がいったん `move` を返し、`onPerformDrop` で source path を読んだ時点で「異ボリュームだから copy」と判明する。実際の操作は正しく copy になるが、ドラッグ中のカーソルバッジが「移動」のまま見える瞬間がある。実害は軽微なので許容。

### native プラグインの初回ビルド時間

`super_native_extensions` は Rust / CMake を含む。今回は既に依存ツリーに入っているため新規ビルドは不要だが、CI で新しい OS イメージを引いた直後など、cache miss 時にネイティブビルドが数分かかる可能性は残る。

## References

- https://pub.dev/packages/super_drag_and_drop
- https://pub.dev/packages/super_native_extensions
- OpenSpec change `os-drag-and-drop`（本 ADR の提案フェーズ）
- ADR-0005: 外部 Skill / プラグインに依存しない自己完結方針（プラグイン採用判断の上位指針）
