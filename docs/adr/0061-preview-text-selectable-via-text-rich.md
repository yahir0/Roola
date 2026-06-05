# ADR-0061: プレビューのテキストを Text.rich で描画し選択・コピー可能にする

- **Status**: Accepted
- **Date**: 2026-06-05

## Context

ファイルプレビューパネル（ADR-0046）は当初から「**`SelectableText` ベースで
選択 / コピーのみ可**」を要件として掲げていた（ADR-0046 Decision / D）。読み取り
専用ビューでも、md やコードの一部を選んでコピーできることはプレビューの実用上
ほぼ必須だからである。

ところが実装はシンタックスハイライトのために `flutter_highlight` の
`HighlightView` を使い、その出力を `SelectionArea` で包む形になっていた
（`lib/ui/explorer/file_preview/file_preview_pane.dart`）。これは一見正しく
見えるが、**テキストを選択できない**（カーソル（I ビーム）が出ず、ドラッグ選択も
⌘C コピーもできない）状態だった。

原因は `HighlightView` の内部実装にある。`HighlightView.build` は素の
[`RichText`] を直接生成する:

```dart
// flutter_highlight 0.7.0
return Container(
  ...,
  child: RichText(text: TextSpan(style: _textStyle, children: _convert(...))),
);
```

Flutter の `SelectionArea`（`SelectableRegion`）は、子孫テキストが
`SelectionContainer`/`SelectionRegistrar` に**自分を選択可能ノードとして登録**して
初めて選択対象になる。`Text` / `Text.rich` ウィジェットは `build` 内で
`SelectionContainer.maybeOf(context)` を読んでこの登録を行うが、**生の
`RichText` はこの配線を持たない**。したがって `SelectionArea` で包んでも
`HighlightView` 内の `RichText` は選択レジストラに載らず、選択できなかった。

## Decision

### D1. ハイライト結果を `Text.rich` で描画する

`HighlightView` の利用をやめ、構文解析の結果（`TextSpan` ツリー）を
**`Text.rich` で描画**する。`Text.rich` は `SelectionArea` 配下で自動的に選択可能
ノードとして登録されるため、ドラッグ選択・⌘C コピー・カーソル表示が機能する。

`_TextBody` は引き続き `SelectionArea` で本文を包み、その内側を
`Text.rich(TextSpan(style: baseStyle, children: spans))` にする。横スクロール
（長い行の非折返し）と縦スクロールの二重 `SingleChildScrollView` は従来どおり。

### D2. 依存を `flutter_highlight` から `highlight` へ差し替える

`flutter_highlight` は `HighlightView`（ウィジェット）を提供する薄いラッパで、
その実体である構文解析は依存先の **`highlight`** パッケージが担う
（`highlight.parse(source, language: ...)` が `TextSpan` 化前のノード木を返す）。

`HighlightView` を使わなくなったため `flutter_highlight` は不要になり、
pubspec の直接依存を `highlight: ^0.7.0` に置き換える。ノード木 → `TextSpan` の
変換は `HighlightView._convert` と同じ走査を `file_preview_pane.dart` の
`_highlightSpans` に持つ（Polaris テーマ `Map<String, TextStyle>` でスタイルを
引くのは従来と同じ）。言語未判定（プレーンテキスト）は空文字を渡し、
`highlight.parse` が未登録言語を `plaintext` にフォールバックして素通しで描画する
挙動も `HighlightView` と同一。

## Why

- ADR-0046 が掲げていた「選択 / コピー可」という**当初の要件を、実装として
  ようやく満たす**修正である。新しい方針を足すのではなく、ドキュメント上の意図と
  実装の乖離を埋める。
- `flutter_highlight` の `HighlightView` は「色付けして表示する」だけのウィジェット
  で、選択可否は制御できない（生 `RichText` がハードコードされている）。選択を
  得るには描画ウィジェットを自前で持つしかなく、その素材（パース結果）は同梱の
  `highlight` パッケージがそのまま提供する。ラッパを 1 枚剥がして `Text.rich` に
  載せ替えるのが最小で確実。
- `SelectableText.rich` を単独で使う案もあったが、現行の「横スクロールで長い行を
  折り返さない」レイアウト（幅 unbounded の水平 `SingleChildScrollView`）と相性が
  悪い。`SelectionArea` + `Text.rich` なら既存レイアウトをそのまま活かせる。

## Trade-offs

- **ハイライト変換ロジックを自前で保守する**: `HighlightView._convert` 相当の
  ノード走査（約 25 行）を `_highlightSpans` として持つ。`highlight` のノード構造は
  安定しており、変換は単純なので保守コストは低い。
- **`flutter_highlight` のバージョン追従から外れる**: 代わりに `highlight` を直接
  追従する。`flutter_highlight` は `highlight` の薄ラッパなので実質的な追従対象は
  変わらない。
- **md は引き続きフルレンダリングしない**: 本 ADR は「選択可能にする」ことだけが
  目的で、md を見出し / 太字付きでレンダリングするものではない（ADR-0046 の「天井を
  低く」方針は維持）。構文の色分け（markdown ハイライト）のまま選択可能になる。

## References

- ADR-0046: Explorer に読み取り専用ファイルプレビューパネルを追加する（本 ADR は
  その「選択 / コピー可」要件を実装で満たす。ライブラリ採用を `flutter_highlight`
  → `highlight` に変更）
- ADR-0050: プレビューに画像 / PDF を追加し既定非表示にする（テキスト描画部分は本 ADR で変更）
- ADR-0038: Polaris デザインシステム（ハイライトテーマは Polaris トークンから構成）
- `lib/ui/explorer/file_preview/file_preview_pane.dart`（`_TextBody` / `_highlightSpans`）
- `test/ui/explorer/file_preview/file_preview_pane_test.dart`（SelectionArea 配下の Text.rich 回帰ガード）
- [`SelectionArea` / `SelectableRegion`](https://api.flutter.dev/flutter/material/SelectionArea-class.html)
- [`highlight` on pub.dev](https://pub.dev/packages/highlight)
