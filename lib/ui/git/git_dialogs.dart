import 'package:flutter/material.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_dialog.dart';

/// 破壊的な Git 操作（複数 discard・ブランチ削除・stash drop・force push）の
/// 前に出す確認ダイアログ（ADR-0030 / tasks 6.7）。
///
/// ユーザーが実行を承認すると `true`、取り消すと `false` を返す。実体は
/// Polaris の [showPolarisConfirm]（計器パネル調シェル）。
Future<bool> gitConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = '実行',
  bool destructive = true,
}) {
  return showPolarisConfirm(
    context,
    title: title,
    message: message,
    confirmLabel: confirmLabel,
    cancelLabel: AppLocalizations.of(context).buttonCancel,
    destructive: destructive,
  );
}

/// 1 行テキストを入力させるダイアログ。ブランチ名・stash メッセージなどに使う。
///
/// 入力が確定すれば文字列、取り消されれば `null` を返す。
Future<String?> gitPrompt(
  BuildContext context, {
  required String title,
  required String label,
  String confirmLabel = 'OK',
  String initialValue = '',
  bool allowEmpty = false,
}) {
  return showPolarisPrompt(
    context,
    title: title,
    confirmLabel: confirmLabel,
    cancelLabel: AppLocalizations.of(context).buttonCancel,
    initialValue: initialValue,
    labelText: label,
    allowEmpty: allowEmpty,
  );
}
