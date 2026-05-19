import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/core/keybindings/chord_formatter.dart';
import 'package:roola/data/keybindings/command_category.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/command_registry.dart';
import 'package:roola/data/keybindings/effective_keybindings.dart';
import 'package:roola/data/keybindings/keybindings_repository_impl.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/command_l10n.dart';
import 'package:roola/ui/common/macos_window_app_bar.dart';
import 'package:roola/ui/common/polaris_dialog.dart';
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
      appBar: MacosWindowAppBar(
        title: Text(AppLocalizations.of(context).keybindingsPageTitle),
      ),
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
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              l10n.keybindingsIntro,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () => _confirmResetAll(context, ref),
            child: Text(l10n.keybindingsResetAllButton),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmResetAll(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showPolarisConfirm(
      context,
      title: l10n.keybindingsResetAllConfirmTitle,
      message: l10n.keybindingsResetAllConfirmMessage,
      confirmLabel: l10n.buttonReset,
      cancelLabel: l10n.buttonCancel,
    );
    if (confirmed) {
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
        AppLocalizations.of(context).commandCategoryLabel(category),
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
      title: Text(AppLocalizations.of(context).commandLabel(commandId)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (overridden)
            IconButton(
              tooltip: AppLocalizations.of(context).keybindingsResetOneTooltip,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.settings_backup_restore,
                size: PolarisIconSize.standard,
              ),
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
    final tokens = PolarisTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(tokens.radius),
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
