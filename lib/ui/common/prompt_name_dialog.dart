import 'package:flutter/material.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_dialog.dart';

/// 名前入力ダイアログ。空文字 / キャンセル時は null を返す。
///
/// エクスプローラの「リネーム」「新規フォルダ」「新規ファイル」やお気に入り
/// 表示名入力など、1 行テキストを受け取りたい場面で共通利用する。
/// 実体は Polaris の [showPolarisPrompt]（計器パネル調シェル）。
Future<String?> promptName(
  BuildContext context, {
  required String title,
  String initialValue = '',
  String? hintText,
  String confirmLabel = 'OK',
}) {
  return showPolarisPrompt(
    context,
    title: title,
    confirmLabel: confirmLabel,
    cancelLabel: AppLocalizations.of(context).buttonCancel,
    initialValue: initialValue,
    hintText: hintText,
  );
}
