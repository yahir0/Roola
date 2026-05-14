# ADR-0024: エクスプローラのタイル表示密度を切替え可能にする

- **Status**: Accepted
- **Date**: 2026-05-14

## Context

エクスプローラのファイル / フォルダタイルは長らく `EdgeInsets.symmetric(horizontal: 16, vertical: 12)` +
デフォルトアイコンサイズ + Skill subtitle 行 + Skill 件数チップという 3 要素レイアウトだった。これは
ADR-0014 で Explorer をメイン UI に格上げした際に「情報密度よりも視認性」を優先した結果。

一方サイドバー（お気に入り / ランチャー）のタイルは `EdgeInsets.symmetric(horizontal: 16, vertical: 6)` +
`Icon(size: 18)` の単行レイアウトで、縦幅が約半分。同じ画面に両者が並ぶと、エクスプローラ側の縦幅が
過大に見え「同じ密度で並べてほしい」という要望が出ていた。

また Claude Skill のサブタイトル表示は ADR-0022 / ADR-0023 を経て「画面上は無くても困らない」位置付け
になっており、必須情報ではない。

## Decision

`ExplorerListDensity { compact, comfortable }` の永続化設定を追加し、設定画面の SegmentedButton で
切替えられるようにする。新規ユーザーは **comfortable がデフォルト**（縦幅は広めだが Skill サブタイトル /
Chip を含めて情報量を確保）。

### compact

- padding: `EdgeInsets.symmetric(horizontal: 16, vertical: 6)`（サイドバーと一致）
- アイコンサイズ: 18（サイドバーと一致）
- アイコン⇄テキスト間隔: 12（従来は 16）
- 1 行表示。Skill subtitle 行と件数チップは省略
- ファイル名 / フォルダ名は単行 `TextOverflow.ellipsis`

### comfortable

- 従来レイアウト（`vertical: 12` + デフォルトサイズアイコン + Skill subtitle + Chip）

### 永続化

`ExplorerSettings.listDensity` フィールドを追加。`explorer_settings.json` に `listDensity` キーで
書き込む。`json_serializable` の既定動作で旧 JSON（キーなし）は DTO のデフォルト `comfortable` に倒れる
（既存ユーザーの見た目を変えない）。

### Skill 関連表示

`hasSkill` 判定（`.claude/skills/` 検知）自体は compact / comfortable いずれでも残る。compact では
- フォルダアイコン: 通常 `Icons.folder` → Skill 検知時 `Icons.folder_special`（色も primary に切替え）
- subtitle と Chip を省略

これにより「Skill 含みフォルダの識別性は失わない」状態を維持する。

## Why

サイドバーとエクスプローラ本体で縦幅が揃っていない不均衡を解消する最短経路。

- compact は情報量を捨てる代わりに「画面に映る件数」を 2 倍弱に増やせる
- Skill subtitle は ADR-0022 の Claude optional 化 / ADR-0023 のアイコン廃止と方向性が一致
- ただし Skill サブタイトルが欲しい層も居るため、削除ではなく **切替** で残す
- デフォルトを comfortable にしたのは、既存ユーザーが意識せずアップデートしたときに見た目が変わら
  ないことを優先したため。縦幅を詰めたい人は設定から compact に切替えればよい

設定の置き場所は「外観」セクションのすぐ下の独立セクションにした。表示密度は外観設定（色 / 画像）
と粒度が違う preference なので分けたほうが見つけやすい。

## 代替案

### 代替案 1: 常に compact にして comfortable を削除する

サイドバーと完全に揃え、設定を増やさない案。

- Skill 検知の subtitle / Chip 表示を完全削除することになる
- Skill subtitle に依存している既存ユーザーへの黙示的な後退になる
- 却下: 切替コストはトグル 1 つで済み、データモデルへの影響も最小。残す価値がある

### 代替案 2: タイルの高さを SegmentedButton ではなくスライダーで連続調整

`vertical` 値を直接スライダーで動かす。

- 自由度は上がるが「何 px が良いか」をユーザーに判断させる UI は粗い
- 代表的な 2 状態に絞ったほうが UI も実装もシンプル
- 却下: ユースケースは「サイドバー揃え or 従来」の二択で十分

### 代替案 3: タイル右クリックメニューに「表示密度…」サブメニューを追加

設定画面を経由しない高速トグル。

- 右クリックメニューが肥大化する。tile 操作（コピー / 削除 / 名前変更等）と密度切替は粒度が違う
- 設定画面に置けば 1 度だけ触れば済む preference として相応
- 却下: preference は設定画面側

## Trade-offs

- **サイドバーとエクスプローラ本体の縦幅は依然不揃い**: comfortable がデフォルトなので、初期状態
  ではサイドバーのタイルが詰まって見える非対称が残る。compact に切替えて初めて揃う
- **2 レイアウトを保守する必要がある**: tile widget 内で `isCompact` 分岐が常に生きる。将来 Skill
  表示自体が無くなる方向（ADR-0022 / ADR-0023 路線）に振れたら、comfortable 側を削る選択肢が出る

## References

- ADR-0014（Explorer をメイン UI に格上げ）
- ADR-0022（Claude Code 関連機能を optional 化）
- ADR-0023（カスタムアイコン機能を廃止）
