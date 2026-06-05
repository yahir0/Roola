import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:roola/app/theme.dart';

/// Polaris の計器パネル調ダイアログシェル（ADR-0038）。
///
/// Material の `AlertDialog` は大きな見出し・広い余白・右下アクションの構図が
/// 「Material のダイアログ」として強く読めてしまう。Polaris ではこれをやめ、
/// `[ヘッダ帯][1px 継ぎ目][本文][1px 継ぎ目][アクション帯]` の構成にして、
/// 計器パネルの一部のように見せる。枠（bg / R=2px / 1px ボーダー / elevation 0）
/// は `dialogTheme` から受け取る。
class PolarisDialog extends StatelessWidget {
  const PolarisDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions = const [],
    this.trailing,
    this.width = 360,
  });

  /// ヘッダ帯に出すタイトル。大見出しにせず控えめに置く。
  final String title;

  /// 本文。
  final Widget content;

  /// アクション帯のボタン群（右寄せ）。空ならアクション帯を描かない。
  final List<Widget> actions;

  /// ヘッダ帯の右端に置く widget（閉じるボタン等）。
  final Widget? trailing;

  /// ダイアログの幅。
  final double width;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return Dialog(
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ヘッダ帯。
            Padding(
              padding: EdgeInsets.fromLTRB(
                PolarisTokens.space4,
                PolarisTokens.space3,
                trailing != null ? PolarisTokens.space2 : PolarisTokens.space4,
                PolarisTokens.space3,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: tokens.body.copyWith(color: tokens.text),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
            Container(height: 1, color: tokens.line),
            // 本文。
            Padding(
              padding: const EdgeInsets.all(PolarisTokens.space4),
              child: content,
            ),
            if (actions.isNotEmpty) ...[
              Container(height: 1, color: tokens.line),
              Padding(
                padding: const EdgeInsets.all(PolarisTokens.space3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: PolarisTokens.space2),
                      actions[i],
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Polaris の確認ダイアログ。承認で `true`、取消／バリア外タップで `false`。
///
/// [destructive] が true のとき、実行ボタンをコンフリクト色（赤）にする。
Future<bool> showPolarisConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final tokens = PolarisTokens.of(context);
      return PolarisDialog(
        title: title,
        content: Text(
          message,
          style: tokens.body.copyWith(color: tokens.textDim),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: tokens.signalConflict,
                    foregroundColor: tokens.text,
                  )
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

/// Polaris の 1 行入力ダイアログ。確定で入力文字列（trim 済み）、取消で `null`。
///
/// [allowEmpty] が false のとき、空入力では確定ボタンを無効にする。
Future<String?> showPolarisPrompt(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  required String cancelLabel,
  String initialValue = '',
  String? hintText,
  String? labelText,
  bool allowEmpty = false,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _PromptDialog(
      title: title,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      initialValue: initialValue,
      hintText: hintText,
      labelText: labelText,
      allowEmpty: allowEmpty,
    ),
  );
}

/// Polaris の複数行入力ダイアログ。ログ / 文字起こしなど長文を貼り付けて
/// 渡す用途（ADR-0062）。確定で入力文字列（**trim しない**）、取消で `null`。
///
/// 1 行版（[showPolarisPrompt]）と違い、入力は **trim しない**。先頭 / 末尾の
/// 改行や空白も意味を持ちうる本文（プロンプト全文）をそのまま渡すため。
/// Enter は改行入力になるので、確定はボタンで行う（空入力も許可）。
Future<String?> showPolarisMultilinePrompt(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  required String cancelLabel,
  String? hintText,
  String initialValue = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _MultilinePromptDialog(
      title: title,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      hintText: hintText,
      initialValue: initialValue,
    ),
  );
}

class _MultilinePromptDialog extends HookWidget {
  const _MultilinePromptDialog({
    required this.title,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.hintText,
    required this.initialValue,
  });

  final String title;
  final String confirmLabel;
  final String cancelLabel;
  final String? hintText;
  final String initialValue;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: initialValue);
    // 確定時は trim せず生の本文を返す（長文プロンプトを改変しない）。
    void submit() => Navigator.of(context).pop(controller.text);

    return PolarisDialog(
      // 長文を見渡せるよう広めに取る。
      width: 560,
      title: title,
      content: SizedBox(
        height: 320,
        child: TextField(
          controller: controller,
          autofocus: true,
          // 高さいっぱいに広げ、長文はスクロールで扱う。文字数に上限は設けない。
          expands: true,
          maxLines: null,
          textAlignVertical: TextAlignVertical.top,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: hintText,
            alignLabelWithHint: true,
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelLabel),
        ),
        FilledButton(onPressed: submit, child: Text(confirmLabel)),
      ],
    );
  }
}

class _PromptDialog extends HookWidget {
  const _PromptDialog({
    required this.title,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.initialValue,
    required this.hintText,
    required this.labelText,
    required this.allowEmpty,
  });

  final String title;
  final String confirmLabel;
  final String cancelLabel;
  final String initialValue;
  final String? hintText;
  final String? labelText;
  final bool allowEmpty;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: initialValue);
    // 拡張子の手前までを選択し、ファイル名本体をすぐ編集できるようにする
    // （ディレクトリ名・拡張子なしは全選択）。
    useMemoized(() {
      final dot = initialValue.lastIndexOf('.');
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: dot > 0 && dot < initialValue.length
            ? dot
            : initialValue.length,
      );
      return null;
    });
    useListenable(controller);
    final canSubmit = allowEmpty || controller.text.trim().isNotEmpty;
    void submit() {
      if (canSubmit) {
        Navigator.of(context).pop(controller.text.trim());
      }
    }

    return PolarisDialog(
      title: title,
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          isDense: true,
        ),
        onSubmitted: (_) => submit(),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: canSubmit ? submit : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
