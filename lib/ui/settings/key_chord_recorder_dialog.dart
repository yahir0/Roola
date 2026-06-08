import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/core/keybindings/chord_conflict.dart';
import 'package:roola/core/keybindings/chord_formatter.dart';
import 'package:roola/core/keybindings/key_chord_recorder.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/effective_keybindings.dart';
import 'package:roola/data/keybindings/key_chord.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/command_l10n.dart';
import 'package:roola/ui/common/polaris_dialog.dart';

/// キーレコーダ表示中フラグ（ADR-0033）。
///
/// macOS のネイティブメニューバーの key equivalent は、ファーストレスポンダ
/// に関係なく発火する。レコーダでキーを入力するとき、既存ショートカットと
/// 一致するキーはメニュー側に横取りされて Flutter まで届かない。これが true
/// の間、`AppMenuBar` は全項目の `shortcut` を外し、レコーダがキーを
/// 受け取れるようにする。
class KeybindingRecording extends Notifier<bool> {
  @override
  bool build() => false;

  void setActive({required bool active}) => state = active;
}

final keybindingRecordingProvider = NotifierProvider<KeybindingRecording, bool>(
  KeybindingRecording.new,
);

/// [target] コマンドへ割り当てるキーコンビをユーザーに入力させる。
/// 確定されたら [KeyChord] を、キャンセルされたら null を返す。
Future<KeyChord?> showKeyChordRecorder(
  BuildContext context, {
  required CommandId target,
}) {
  return showDialog<KeyChord>(
    context: context,
    builder: (_) => _KeyChordRecorderDialog(target: target),
  );
}

class _KeyChordRecorderDialog extends HookConsumerWidget {
  const _KeyChordRecorderDialog({required this.target});

  final CommandId target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final captured = useState<KeyChord?>(null);
    final focusNode = useFocusNode();

    // 表示中はメニューバーの key equivalent を無効化する。
    useEffect(() {
      Future.microtask(() {
        ref.read(keybindingRecordingProvider.notifier).setActive(active: true);
      });
      focusNode.requestFocus();
      return () {
        ref.read(keybindingRecordingProvider.notifier).setActive(active: false);
      };
    }, const []);

    final effective = ref.watch(effectiveKeybindingsProvider);
    final chord = captured.value;
    final l10n = AppLocalizations.of(context);

    String? error;
    if (chord != null) {
      if (!isAssignableChord(chord)) {
        error = Platform.isWindows
            ? l10n.keyChordErrorMissingModifierWindows
            : l10n.keyChordErrorMissingModifier;
      } else if (isReservedChord(chord)) {
        error = Platform.isWindows
            ? l10n.keyChordErrorReservedWindows
            : l10n.keyChordErrorReserved;
      } else {
        final conflict = conflictingCommand(
          effective: effective,
          target: target,
          candidate: chord,
        );
        if (conflict != null) {
          error = l10n.keyChordErrorAlreadyAssigned(
            l10n.commandLabel(conflict),
          );
        }
      }
    }
    final canConfirm = chord != null && error == null;
    final colors = Theme.of(context).colorScheme;
    final tokens = PolarisTokens.of(context);

    return PolarisDialog(
      title: l10n.keyChordRecorderTitle(l10n.commandLabel(target)),
      width: 400,
      content: Focus(
        focusNode: focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          final recorded = recordChord(event);
          if (recorded != null) {
            captured.value = recorded;
          }
          // 修飾キー単独も含めすべて飲み込み、ダイアログの既定キー操作
          // （Enter で確定 / Esc で閉じる）を抑止する。
          return KeyEventResult.handled;
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.keyChordRecorderInstructions),
            const SizedBox(height: PolarisTokens.space4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: PolarisTokens.space4,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(tokens.radius),
              ),
              child: Center(
                child: Text(
                  chord == null
                      ? l10n.keyChordPlaceholderUnselected
                      : formatChord(chord),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: PolarisTokens.space3),
              Text(
                error,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(
          onPressed: canConfirm ? () => Navigator.of(context).pop(chord) : null,
          child: Text(l10n.buttonConfirm),
        ),
      ],
    );
  }
}
