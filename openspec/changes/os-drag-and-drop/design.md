## Goals

- アプリ ↔ Finder / 他アプリの双方向ドラッグ＆ドロップを実現する
- 既存の `_DirectoryTile` / `_FileTile` / `ExplorerParentDropTile` / `_FavoriteTile` の四箇所を `super_drag_and_drop` API に置換するだけで済ませる。`ExplorerFileOps` 等の下位レイヤーには手を入れない
- 内部・外部いずれからの drop も同じ `moveInto` に集約し、分岐をシンプルに保つ

## Non-goals

- 外部 drop を「エントリ追加 / お気に入り追加」導線にする UX
- drag preview のカスタム widget（OS が描画するプレビューに乗せる）
- 複数選択 drag（現状 1 ノードずつ）

## Architecture

### `DragItem` の組み立て

各タイルの drag source は次の DragItem を提供する:

```dart
DragItemWidget(
  allowedOperations: () => [DropOperation.move, DropOperation.copy],
  dragItemProvider: (request) async {
    return DragItem(localData: node.path, suggestedName: node.name)
      ..add(Formats.fileUri(Uri.file(node.path)));
  },
  child: DraggableWidget(child: tileContent),
);
```

- `Formats.fileUri`: Finder / 他アプリが認識できる標準フォーマット。OS は drop 先で「移動 or コピー」のセマンティクスを drop 先側の挙動に合わせて解釈する
- `localData`: 内部 drop で「自身 / 祖先への drop を弾く」分岐に使う。外部 drop の場合は localData が無いので fileUri の URI から再判定する
- `allowedOperations`: macOS 標準の `[move, copy]` を許可。Finder 側は `option` 押下時に copy 指定可能

### `DropRegion` の組み立て

各 drop target は次の DropRegion を持つ。`decideDropOperation` と `performFileDrop` は `explorer_node_tile.dart` に top-level で定義し、サイドバーも import して使う:

```dart
DropRegion(
  formats: const [Formats.fileUri],
  hitTestBehavior: HitTestBehavior.opaque,
  onDropOver: (event) => decideDropOperation(event.session, targetPath),
  onPerformDrop: (event) => performFileDrop(context, ref, event, targetPath),
  child: ...,
);
```

`decideDropOperation` の判定順:

1. drop item が `Formats.fileUri` を提供しない → `none`
2. **内部 drag のみ**: source == target / source の子孫 / 同一親 no-op（`disallowSameParent` 指定時）→ `none`
3. `HardwareKeyboard.isAltPressed` → `copy`
4. `HardwareKeyboard.isMetaPressed` → `move`
5. 内部 drag で source ボリューム ≠ target ボリューム → `copy`
6. それ以外 → `move`

外部 drag は `localData` が無く source path が同期で取れないため、ステップ 5 をスキップする。実際の cross-volume 判定は `onPerformDrop` で行い、自動 copy にフォールバックする。

### `moveOrCopyInto` の振る舞い

実 I/O は `lib/ui/explorer/explorer_node_tile.dart` の top-level `moveOrCopyInto(context, ref, source, target, {required bool prefersCopy})` に集約する:

- `prefersCopy == true` → `ExplorerFileOps.copyInto`（`cp -R`）
- `prefersCopy == false` && 同一ボリューム → `ExplorerFileOps.moveInto`（`rename`）
- `prefersCopy == false` && 異ボリューム → 自動で `copyInto` にフォールバック
- 例外は SnackBar で「移動 / コピーに失敗しました: ...」と表示し、refresh しない

`prefersCopy` は `PerformDropEvent.acceptedOperation == DropOperation.copy` から決まる。

### ボリューム判定（`_volumeKey`）

```dart
String _volumeKey(String path) {
  if (path.startsWith('/Volumes/')) {
    final i = path.indexOf('/', '/Volumes/'.length);
    return i == -1 ? path : path.substring(0, i);
  }
  return '/';
}
```

`/Volumes/<name>` までを 1 ボリュームとして同値判定する。bind mount やネットワーク FS のレアケースは扱わない。

### `_DragFeedback` の扱い

Flutter 標準 `Draggable.feedback` で描画していたカスタムチップは廃止。OS が描画するドラッグプレビュー（ドラッグ中のサムネ）に置換される。アプリ内 DnD のときに見た目が少し変わるが、OS 標準体験との一貫性が優先。

## Trade-offs

### widget テストの欠落

`super_drag_and_drop` は native channel 経由で動作するため、`flutter_test` 上では mock しづらい。drag/drop の単体 widget テストは追加せず、macOS 実機検証で代替する。`ExplorerFileOps` 側のユニットテストは既に存在するため、ロジック側のカバレッジは維持される。

### 異ボリュームでの強制 move（未対応）

Finder の ⌘+drag は異ボリュームに対しても「copy + 元削除」で擬似 move を行うが、本 change では実装しない。代わりに ⌘ + 異ボリュームは自動的に copy にフォールバックする。実装する場合は `moveOrCopyInto` 内で「copyInto → 成功確認 → 元 path を `trashServiceProvider` でゴミ箱送り」の 3 段階トランザクションが必要で、途中失敗時の rollback / 重複コピー検出など考慮ポイントが多いため別 change で扱う。

### `super_native_extensions` の追加コスト

CMake / Rust ベースのプラグインを含むため初回ビルドが遅くなる懸念があったが、`super_clipboard` で既に取り込み済みなので追加コストはほぼゼロ。

## References

- https://pub.dev/packages/super_drag_and_drop
- https://pub.dev/packages/super_native_extensions
- ADR-0011 (本 change で追加)
