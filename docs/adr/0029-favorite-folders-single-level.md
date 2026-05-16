# ADR-0029: エクスプローラのお気に入りをフォルダで 1 階層グループ化する

- **Status**: Accepted
- **Date**: 2026-05-16

## Context

サイドバーの「お気に入り」セクションは、ユーザーが登録したディレクトリをフラットリストで並べる。
ランチャーは ADR-0019 で 1 階層のフォルダグルーピングを導入済みで、お気に入りも登録数が増えると
同様に把握しづらくなる。お気に入りもランチャーと同じくフォルダでまとめたいという要望が入った。

## Decision

**お気に入りを 1 階層のフォルダでグルーピングできるようにする。ランチャーフォルダ（ADR-0019）と
同じデータ構造・UI パターンを踏襲する。**

- `ExplorerFavoriteFolder { id, name, createdAt }` を新規追加。フォルダの中にフォルダは作らない
- `ExplorerFavorite` に `folderId: String?` フィールドを追加。null は未分類
- 永続化は `ExplorerSettings` に `favoriteFolders` フィールドを追加（`repo_explorer_settings.json` 内）
- サイドバーは inline expand/collapse 形式。caret + フォルダアイコン + 名前
- `_FavoritesHeader` の右クリックで「新しいフォルダ」、`_FavoriteFolderTile` の右クリックで
  「リネーム / 削除」を表示
- お気に入りタイルは `LongPressDraggable`、フォルダタイルと「未分類」mini-header が `DragTarget` で
  受領。`folderId` を切り替えて移動する

## Why

### ランチャーフォルダ（ADR-0019）の設計をそのまま踏襲した理由

お気に入りもランチャーも「サイドバーに並ぶフラットリスト」という UI 上の性質が同じで、ADR-0019 で
1 階層フォルダの設計判断（ネスト深さ・データ構造・サイドバー UI・DnD + 右クリック操作）は検討済み。
同じ判断をお気に入りに再適用するだけで、新たな設計上のトレードオフは発生しない。UI/操作感を
ランチャーと揃えることで学習コストも下がる。

### 永続化先を別ファイルにせず `ExplorerSettings` に同居させた理由

ランチャーフォルダは `LauncherFolderRepository` という別 repository を持つが、お気に入りはもともと
`ExplorerSettings`（`repo_explorer_settings.json` の単一ファイル）に `favorites` として同居している。
お気に入りフォルダだけ別ファイル・別 repository に切り出すと一貫性が崩れるため、`favoriteFolders` を
同じ `ExplorerSettings` に追加する。フォルダ削除 → 配下お気に入りの folderId クリアも 1 つの
`ExplorerSettings` を書き換えるだけで atomic に完結する（ADR-0019 の「選択肢 A」と同じ理由）。

### lazy migration

`favoriteFolders` キーが無い古い JSON は空配列、`favorites` 各要素の `folderId` キーが無ければ null
（未分類）として読み込む。書き戻しは新スキーマ固定。ADR-0019 / ADR-0016 と同じ on-read migration。

### expanded 状態は永続化しない

ランチャーフォルダ（ADR-0019）と同じく、展開状態はセッション内で `useState<Set<String>>` に持ち、
永続化しない。デフォルトは全フォルダ展開。

## Trade-offs

- **多階層の拡張は破壊変更**: ADR-0019 と同じ。1 階層で要件が満たせている間は問題ない。
- **expanded 状態の永続化なし**: ウィンドウを閉じると展開状態がリセットされる。
- **空フォルダの存在**: フォルダだけ作ってお気に入りを入れない状態を許容する。サイドバーでは
  expand しても何も出ないだけ。
- **管理画面は持たない**: ランチャーは独立した管理画面（ADR-0018）を持つが、お気に入りはサイドバー
  上の右クリック / DnD で完結し、専用の管理画面は設けない。お気に入りの操作（追加 / リネーム /
  削除 / フォルダ移動）はすべてサイドバーから行える。
- **並べ替え未対応**: 同一グループ内のお気に入りの順序入れ替えは未対応。ランチャーと同じく、
  必要になったら別 ADR で扱う。

## References

- ADR-0019（ランチャーをフォルダで 1 階層グループ化する）— 本 ADR が踏襲した設計
- ADR-0014（Explorer をメイン UI に格上げ）
- ADR-0026（3 画面タブ式ワークスペース）— サイドバーはウィンドウ共通
