import 'package:flutter/material.dart';

/// 破壊的な Git 操作（複数 discard・ブランチ削除・stash drop・force push）の
/// 前に出す確認ダイアログ（ADR-0030 / tasks 6.7）。
///
/// ユーザーが実行を承認すると `true`、取り消すと `false` を返す。
Future<bool> gitConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = '実行',
  bool destructive = true,
}) async {
  final colors = Theme.of(context).colorScheme;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: colors.error)
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
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
}) async {
  final controller = TextEditingController(text: initialValue);
  final result = await showDialog<String>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final value = controller.text.trim();
          final canSubmit = allowEmpty || value.isNotEmpty;
          void submit() {
            if (canSubmit) {
              Navigator.of(context).pop(controller.text.trim());
            }
          }

          return AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(labelText: label),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => submit(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('キャンセル'),
              ),
              FilledButton(
                onPressed: canSubmit ? submit : null,
                child: Text(confirmLabel),
              ),
            ],
          );
        },
      );
    },
  );
  controller.dispose();
  return result;
}
