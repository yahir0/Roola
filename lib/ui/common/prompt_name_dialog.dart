import 'package:flutter/material.dart';

/// 名前入力ダイアログ。空文字 / キャンセル時は null を返す。
///
/// エクスプローラの「リネーム」「新規フォルダ」「新規ファイル」やお気に入り
/// 表示名入力など、1 行テキストを受け取りたい場面で共通利用する。
Future<String?> promptName(
  BuildContext context, {
  required String title,
  String initialValue = '',
  String? hintText,
  String confirmLabel = 'OK',
}) async {
  final controller = TextEditingController(text: initialValue);
  // 拡張子前までを選択状態にして、編集の主目的（ファイル名）にすぐ
  // 入れるようにする。ディレクトリの場合は全選択。
  final dotIndex = initialValue.lastIndexOf('.');
  controller.selection = TextSelection(
    baseOffset: 0,
    extentOffset: dotIndex > 0 && dotIndex < initialValue.length
        ? dotIndex
        : initialValue.length,
  );
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: hintText),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
