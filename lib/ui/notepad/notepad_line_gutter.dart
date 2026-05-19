import 'package:flutter/material.dart';
import 'package:roola/app/theme.dart';

/// ノートパッド左端の行番号ルーラ（ADR-0036）。
///
/// 隣の `TextField` と本文・スクロールを共有し、論理行（`\n` 区切り）ごとに
/// 1 つの番号を表示する。行が折り返した場合でも番号がずれないよう、各論理行
/// の高さを [TextPainter] で実測してその先頭に番号を置く。
class NotepadLineGutter extends StatelessWidget {
  const NotepadLineGutter({
    required this.controller,
    required this.scrollController,
    required this.wrapWidth,
    required this.textStyle,
    required this.strutStyle,
    required this.lineHeight,
    required this.topPadding,
    required this.numberStyle,
    super.key,
  });

  /// 本文を共有する `TextField` のコントローラ。
  final TextEditingController controller;

  /// 本文の縦スクロール量を共有する `TextField` のスクロールコントローラ。
  final ScrollController scrollController;

  /// `TextField` が本文を折り返す幅。番号位置を本文と一致させるために、
  /// 呼び出し側で `RenderEditable` のキャレット余白ぶんを差し引いた値を渡す。
  final double wrapWidth;

  /// 本文と同一のテキストスタイル。折り返し計算に使う。
  final TextStyle textStyle;

  /// 本文と同一の strut。`forceStrutHeight` 前提で 1 表示行 = [lineHeight]。
  final StrutStyle strutStyle;

  /// 1 表示行の高さ（px）。
  final double lineHeight;

  /// 本文先頭の上方向パディング（`TextField` の contentPadding と一致）。
  final double topPadding;

  /// 行番号の文字スタイル。
  final TextStyle numberStyle;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, scrollController]),
      builder: (context, _) {
        final lines = controller.text.split('\n');
        final painter = TextPainter(
          textDirection: TextDirection.ltr,
          strutStyle: strutStyle,
        );
        final entries = <Widget>[];
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          // 空行でも 1 表示行ぶんの高さを得るためダミーのスペースを置く。
          painter.text = TextSpan(
            text: line.isEmpty ? ' ' : line,
            style: textStyle,
          );
          painter.layout(maxWidth: wrapWidth);
          entries.add(
            SizedBox(
              height: painter.height,
              child: Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  height: lineHeight,
                  child: Center(child: Text('${i + 1}', style: numberStyle)),
                ),
              ),
            ),
          );
        }
        painter.dispose();

        final offset = scrollController.hasClients
            ? scrollController.offset
            : 0.0;
        // 行数が表示領域より多いと番号の Column はビューポートより高くなる。
        // OverflowBox で縦の制約を外して内容ぶんの高さを取らせ、Transform で
        // 本文のスクロールに追従させ、ClipRect ではみ出しを切り取る。
        return ClipRect(
          child: Padding(
            padding: const EdgeInsets.only(right: PolarisTokens.space2),
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minHeight: 0,
              maxHeight: double.infinity,
              child: Transform.translate(
                offset: Offset(0, topPadding - offset),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: entries,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
