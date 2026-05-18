import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/keybindings/chord_conflict.dart';
import 'package:roola/core/keybindings/chord_formatter.dart';
import 'package:roola/core/keybindings/key_chord_recorder.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/command_registry.dart';
import 'package:roola/data/keybindings/effective_keybindings.dart';
import 'package:roola/data/keybindings/key_chord.dart';

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

final keybindingRecordingProvider =
    NotifierProvider<KeybindingRecording, bool>(KeybindingRecording.new);

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
        ref
            .read(keybindingRecordingProvider.notifier)
            .setActive(active: true);
      });
      focusNode.requestFocus();
      return () {
        ref
            .read(keybindingRecordingProvider.notifier)
            .setActive(active: false);
      };
    }, const []);

    final effective = ref.watch(effectiveKeybindingsProvider);
    final chord = captured.value;

    String? error;
    if (chord != null) {
      if (!isAssignableChord(chord)) {
        error = '修飾キー（⌘ ⌥ ⌃ ⇧）を 1 つ以上含めてください。';
      } else {
        final conflict = conflictingCommand(
          effective: effective,
          target: target,
          candidate: chord,
        );
        if (conflict != null) {
          error =
              '「${CommandRegistry.metadataFor(conflict).label}」に'
              '割り当て済みです。';
        }
      }
    }
    final canConfirm = chord != null && error == null;
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text('${CommandRegistry.metadataFor(target).label} のショートカット'),
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
            const Text('割り当てたいキーを押してください。'),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  chord == null ? '（未入力）' : formatChord(chord),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: canConfirm
              ? () => Navigator.of(context).pop(chord)
              : null,
          child: const Text('決定'),
        ),
      ],
    );
  }
}
