import 'package:flutter/material.dart';
import 'package:roola/app/theme.dart';

/// `flutter_highlight` 用のシンタックスハイライトテーマを [PolarisTokens]
/// から組み立てる（ADR-0046 / Decision 6）。
///
/// `flutter_highlight` の `HighlightView(theme: ...)` は `Map<String, TextStyle>`
/// を受け取り、`highlight.js` の CSS クラス名（`hljs-keyword` 等）をキーに
/// テキストスタイルを引く。本関数は Polaris のトークンだけで全色を構成し、
/// `Color(0x...)` の直書きを避ける（ADR-0038 D1）。
///
/// 各クラスの色付けは Roola の暖色ゴールド 1 アクセント方針に合わせ:
/// - キーワード / 型 / 制御フロー: アクセント（暖色ゴールド or アイスブルー）
/// - 文字列: signalNew 系（緑）— 安定して読みやすい
/// - 数値 / リテラル: signalModified 系（スチールブルー）
/// - コメント: textFaint（最弱トーン）
/// - シンボル / 演算子 / 区切り: textDim
/// - エラー / 削除: signalConflict（赤）
///
/// 行全体（`root`）の地は描かない（呼び出し側のコンテナが Polaris の地色を
/// 塗る）。
Map<String, TextStyle> polarisHighlightTheme(PolarisTokens tokens) {
  // `HighlightView` は `theme['root']?.backgroundColor ?? 白` を全体の地色に
  // 使う。Polaris では計器ディスプレイ（well）の上に置くため、地色は
  // `tokens.well` を明示する（指定しないと白が出る）。
  final base = TextStyle(color: tokens.text, backgroundColor: tokens.well);
  final keyword = TextStyle(
    color: tokens.accent,
    fontWeight: FontWeight.w600,
  );
  final string = TextStyle(color: tokens.signalNew);
  final number = TextStyle(color: tokens.signalModified);
  final comment = TextStyle(
    color: tokens.textFaint,
    fontStyle: FontStyle.italic,
  );
  final type = TextStyle(color: tokens.accent);
  final symbol = TextStyle(color: tokens.textDim);
  final attr = TextStyle(color: tokens.signalModified);
  final error = TextStyle(color: tokens.signalConflict);

  return <String, TextStyle>{
    // 行全体のフォールバック。地はここでは塗らない（呼び出し側のコンテナ責務）。
    'root': base,

    // コメント全般。
    'comment': comment,
    'quote': comment,

    // 言語キーワード / 制御フロー / 文法上の予約語。
    'keyword': keyword,
    'selector-tag': keyword,
    'literal': keyword,
    'section': keyword,
    'link': keyword,

    // 関数 / メソッド / クラス / 型名。
    'function': type,
    'title': type,
    'class': type,
    'type': type,
    'name': type,

    // 文字列リテラル / 正規表現 / メタ文字列。
    'string': string,
    'regexp': string,
    'addition': string,

    // 数値 / リテラル / ビルトイン値。
    'number': number,
    'symbol': number,
    'bullet': number,
    'subst': number,
    'meta': number,
    'meta-keyword': keyword,
    'meta-string': string,

    // 属性 / プロパティ名（CSS / JSON / YAML キー / HTML 属性）。
    'attr': attr,
    'attribute': attr,
    'variable': attr,
    'template-variable': attr,
    'tag': symbol,

    // 演算子 / 区切り / 記号。
    'operator': symbol,
    'punctuation': symbol,

    // 強調系（Markdown）。
    'strong': base.copyWith(fontWeight: FontWeight.w700),
    'emphasis': base.copyWith(fontStyle: FontStyle.italic),

    // 削除 / コンフリクト（diff など）。
    'deletion': error,

    // ビルトイン / 標準ライブラリ参照。
    'built_in': keyword,
    'builtin-name': keyword,
  };
}
