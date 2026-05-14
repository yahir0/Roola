# ADR-0023: カスタムアイコン機能を廃止する

- **Status**: Accepted
- **Date**: 2026-05-14

## Context

Roola の旧アイデンティティ「Claude Skills ランチャー」では、各エントリに画像を選んでアイコン化する
機能（96×96 のサムネイル表示、ピッカー、リサイズ保存）があり、Skills を視覚的に区別する用途で
活躍していた。ADR-0016 で汎用ターミナルランチャーへ転換し、ADR-0019 でフォルダグルーピングと
inline 表示が入った後では、サイドバー側の Launcher Tile は最初から `Icons.bolt` 固定で動作タイプ別に
意味付けされていた一方、Entry 編集画面と管理画面リストにだけカスタムアイコン UI が残っていた。

ユーザーフィードバック: 「アイコン設定は昔の名残。今は管理画面リストでしか視認できないし、要らない」。

## Decision

**カスタムアイコン関連の機能・データ・依存をすべて削除する。**

### 削除する範囲

- データモデル: `LauncherEntry.iconPath`、`LauncherEntryDto.iconPath`
- ファイルパス: `AppPaths.iconsDir`、`ensureDirectories` 内のディレクトリ作成
- 画像処理: `lib/core/image/icon_image_processor.dart` + 空になる `lib/core/image/` ディレクトリ
- 依存: `pubspec.yaml` の `image: ^4.8.0`（icon_image_processor のみが使っていた）
- UI: `EntryEditPage._IconSection`、`LauncherManagementPage._EntryIcon`
- ViewModel: `EntryEditState.iconPath` / `pendingIconSource`、`setPendingIcon` / `clearIcon`、
  `submit` 内のアイコン保存ロジック

### 管理画面リストの leading 置換

`_EntryIcon`（48×48 の画像 / placeholder）の代わりに、動作タイプ別の Material アイコン（40×40 角丸 2px
コンテナ + 1px ボーダー）を表示する `_ActionIcon`:

- `OpenHereAction` → `Icons.folder_open`
- `RunCommandAction` → `Icons.bolt`
- `ClaudeSkillAction` → `Icons.auto_awesome`

### 旧データ・旧 JSON の扱い

- `LauncherEntryDto.fromJson` は json_serializable の既定動作により、未知の `iconPath` キーを
  silently ignore する。旧 JSON は問題なく読み込め、書き戻しでキー自体が消える
- `Application Support/.../icons/` ディレクトリ配下のアイコン画像ファイルは orphan として残る。
  削除のためのマイグレーションコードは追加しない（ユーザーが手動で消すことに任せる）

## Why

カスタムアイコンの維持コストは:

- データモデルの 1 フィールド + DTO + JSON migration
- AppPaths のサブディレクトリと初期化
- 専用の画像処理依存（image: ^4.8.0、~MB クラスの transitive を含む）
- EntryEdit の UI セクション + ViewModel state + ピッカー連携
- 管理画面の Image.file ロード（File.existsSync の I/O）

…これだけ抱えていた割に、実際に表示されるのは管理画面リストの 48×48 サムネイルのみ。サイドバーは
最初から `Icons.bolt` 固定。Entry 編集画面の 96×96 プレビューは保存後に確認手段が乏しい。投資対効果が
合わず、消すほうがメンテナンス負荷も binary size も下がる。

動作タイプ別 Material アイコンは、ユーザーが「どんな起動か」を瞬時に見分けるのに十分な情報量を
提供する。「Skill だから装飾アイコン」「ローカルランチャーだから絵柄」などの個人カスタムは、
頻度の低い要望なので将来要望が出たら別 ADR で復活させる余地は残す。

## 代替案

### 代替案 1: UI だけ消してデータは残す

`iconPath` フィールドは残しつつ、表示と編集 UI だけ削除する案。

- フィールドは load/save で常にスルーされる「死んだスキーマ」になる
- 後で「やっぱり要る」と言われたときの復旧コストが小さい
- だが死んだスキーマが残るとコードを読む人が混乱する。後で復旧する確実な需要があるわけでもない
- 却下: 死んだフィールドより、必要になったら再導入する方が綺麗

### 代替案 2: アイコン UI を Settings に移して有効/無効切替できるようにする

カスタムアイコンを optional 機能として残し、Settings で on/off。

- 機能フラグの維持コストが追加で増える
- on でも off でもどちらかが死にコードになる
- 却下: シンプルに削除して、必要なら復活させる方針

### 代替案 3: PNG ファイルだけは消さずにマイグレーションスクリプトで掃除

旧 `iconsDir` 配下のファイルをアプリ起動時にクリーンアップ。

- 1 回きりのコードのために cleanup ロジックを足すのは保守負債
- 容量はせいぜい数 MB なので放置しても実害は小さい
- 却下: 手動で消したい人だけ消せばよい

## Trade-offs

- **旧 iconPath を持つ JSON エントリは silently 値を失う**: 警告も出さずに無視する。ユーザーが
  「アイコンが消えた」と気付くシナリオは管理画面でカスタムサムネが消えるだけ。代わりに動作タイプ
  アイコンが出るので「消えた」というより「変わった」感覚
- **orphan アイコンファイル**: `Application Support` 配下に残るが Roola からは参照されない。
  `make reset` (既存の prod / dev リセット) で消える
- **将来カスタムアイコンを再導入する場合**: スキーマ再追加 + 過去の archive ADR を参照しつつ
  別 ADR で復活させる。本 ADR は「最新時点での意思決定」として残す

## References

- ADR-0016（ランチャー汎用化 — Claude Skill 専用→3 タイプ）
- ADR-0019（フォルダグルーピング — サイドバーの inline 表示）
