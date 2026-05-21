## Why

Roola でテキスト系ファイル（`.txt` / `.dart` / `.md` / `.yaml` 等）の中身を
ちょっと確認したいとき、現状は右クリック → vim（または OS デフォルトアプリ）
でファイルを開くしかない。「1 行確認したい」「依存パッケージ名だけ見たい」
程度の用途には別アプリ起動が重く、操作コストに対するリターンが低い。

Roola は ADR-0014 / ADR-0016 で「エクスプローラ + 汎用ターミナルランチャー」
として定義されており、エディタを内包すると製品の核がぶれる。一方で、Finder の
Column View 右ペインや QuickLook のような **読み取り専用の軽量プレビュー** は、
エクスプローラ機能の自然な強化として収まる。「Roola = 見る・操作する」「vim
= 編集する」の役割分担を保ったまま、ファイルを見るコストを下げる。

設計判断は ADR-0046 に記録済み。

## What Changes

- Explorer タブの body を **左ペイン（既存ディレクトリ一覧）＋ 右ペイン
  （読み取り専用ファイルプレビュー）** の横分割にする。
- 主選択（[ExplorerSelection].primary）がファイルのとき、その内容をプレビュー
  ペインに **シンタックスハイライト付き** で表示する。
- ハイライトには **`flutter_highlight`** を採用する（編集 UI を含む
  `flutter_code_editor` は採用しない）。
- 表示はテキスト系ファイルのみ。バイナリ / 大きすぎファイル / 読み込みエラー
  にはそれぞれ専用の placeholder を出す。
- パネルは tab pane header の **トグルボタン** で表示 / 非表示を切替え可能。
  デフォルトは表示。表示状態と幅は **per-tab の in-memory 状態**（永続化なし）。
- パネルには **リフレッシュボタン** を置き、ファイルを手動で読み直せるように
  する（FSEvents 自動連携は今回見送り）。
- 言語判定は拡張子 → shebang → プレーンテキストの順。Polaris トークンから
  ハイライト用 `Map<String, TextStyle>` を組み立て、`PolarisTokens` 経由で
  色付けする（ハードコード色なし）。
- 既存の右クリック → vim 導線は **そのまま残す**（編集経路）。

## Capabilities

### New Capabilities

- `explorer-file-preview`: Explorer タブ内に常設する読み取り専用ファイル
  プレビューパネル。主選択ファイルを `flutter_highlight` でシンタックス
  ハイライト表示し、テキスト系のみサポート（バイナリ / 大きすぎファイルは
  placeholder）。表示トグル / リフレッシュを持つ。状態は per-tab in-memory。

### Modified Capabilities

<!-- 既存 spec の要件変更なし。Explorer タブ内の横分割は実装詳細であり、
     既存ディレクトリ一覧の要件は変更しない。 -->

## Impact

- **依存追加**: `pubspec.yaml` に `flutter_highlight` を追加。
- **UI**: 新規 `lib/ui/explorer/file_preview/` 配下に
  `file_preview_pane.dart` / `file_preview_view_model.dart` /
  `polaris_highlight_theme.dart` を追加。`explorer_tab_body.dart` の縦
  Column を `Row(listing | preview)` 構造に変更。pane header にトグル
  ボタンを追加。
- **data 層**: `lib/data/file_preview/` を新設し、ファイル読み込み /
  バイナリ判定 / サイズ制限を担う Repository を実装（interface は作らない
  方針 [ADR-0006] に沿う）。
- **状態管理**: ADR-0027 に倣い `filePreviewViewModelProvider.family(tabId)`
  を実装。`explorerSelectionProvider(tabId)` の主選択を watch する。
- **l10n**: ARB に「プレビュー」「プレビュー不可（バイナリ）」「ファイルが
  大きすぎます」「リフレッシュ」「先頭部分のみ表示」「ファイルを選択して
  プレビュー」等の文言キーを追加（ADR-0034）。
- **設計記録**: ADR-0046 を追加済み。

[ExplorerSelection]: ../../../lib/ui/explorer/explorer_item_selection.dart
[ADR-0006]: ../../../docs/adr/0006-mvvm-over-clean-architecture.md
