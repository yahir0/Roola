import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/keybindings/chord_formatter.dart';
import 'package:roola/data/keybindings/command_category.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/command_registry.dart';
import 'package:roola/data/keybindings/effective_keybindings.dart';
import 'package:roola/data/keybindings/keybindings_repository_impl.dart';
import 'package:roola/ui/common/macos_window_app_bar.dart';
import 'package:roola/ui/settings/key_chord_recorder_dialog.dart';

/// キーボードショートカットの一覧・編集画面（ADR-0033）。
///
/// 全コマンドをカテゴリ別に並べ、各行のタップでキーレコーダを開く。
/// 重複・修飾なしはレコーダ側で検出して保存をブロックする。
class KeybindingsPage extends ConsumerWidget {
  const KeybindingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const MacosWindowAppBar(title: Text('キーボードショートカット')),
      body: ListView(
        children: [
          const _Intro(),
          for (final category in CommandCategory.values) ...[
            _CategoryHeader(category: category),
            for (final metadata in CommandRegistry.byCategory(category))
              _KeybindingRow(commandId: metadata.id),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Intro extends ConsumerWidget {
  const _Intro();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '行をクリックしてショートカットを変更できます。'
              '修飾キー（⌘ ⌥ ⌃ ⇧）を 1 つ以上含める必要があり、'
              '他のコマンドと重複するキーは保存できません。',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () => _confirmResetAll(context, ref),
            child: const Text('すべてデフォルトに戻す'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmResetAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('すべてデフォルトに戻しますか？'),
        content: const Text('すべてのショートカットを既定のキーコンビに戻します。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('戻す'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(keybindingsProvider.notifier).resetAll();
    }
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category});

  final CommandCategory category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Text(
        category.label,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _KeybindingRow extends ConsumerWidget {
  const _KeybindingRow({required this.commandId});

  final CommandId commandId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadata = CommandRegistry.metadataFor(commandId);
    final chord = ref.watch(effectiveKeybindingsProvider)[commandId]!;
    final overridden =
        ref
            .watch(keybindingsProvider)
            .value
            ?.overrides
            .containsKey(commandId) ??
        false;

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(metadata.icon),
      title: Text(metadata.label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (overridden)
            IconButton(
              tooltip: 'デフォルトに戻す',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.settings_backup_restore, size: 18),
              onPressed: () => ref
                  .read(keybindingsProvider.notifier)
                  .resetToDefault(commandId),
            ),
          _ChordChip(text: formatChord(chord)),
        ],
      ),
      onTap: () => _edit(context, ref),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final result = await showKeyChordRecorder(context, target: commandId);
    if (result != null) {
      await ref.read(keybindingsProvider.notifier).setChord(commandId, result);
    }
  }
}

/// キーコンビを「キーキャップ風」に表示するチップ。
class _ChordChip extends StatelessWidget {
  const _ChordChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
          color: colors.onSurface,
        ),
      ),
    );
  }
}
