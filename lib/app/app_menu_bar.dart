import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/about.dart';
import 'package:roola/app/command_dispatcher.dart';
import 'package:roola/app/router.dart';
import 'package:roola/core/keybindings/chord_formatter.dart';
import 'package:roola/core/system/update_checker.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/effective_keybindings.dart';
import 'package:roola/data/keybindings/key_chord.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/command_l10n.dart';
import 'package:roola/ui/settings/key_chord_recorder_dialog.dart';

/// ネイティブメニューバー（ADR-0033）。
///
/// macOS 専用の `PlatformProvidedMenuItem`（servicesSubmenu / hide 等）と
/// Sparkle「アップデートを確認」は `Platform.isMacOS` で分岐する（ADR-0058）。
class AppMenuBar extends ConsumerWidget {
  const AppMenuBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effective = ref.watch(effectiveKeybindingsProvider);
    final recording = ref.watch(keybindingRecordingProvider);
    final l10n = AppLocalizations.of(context);
    return PlatformMenuBar(
      menus: _menus(ref, l10n, effective, recording: recording),
      child: child,
    );
  }

  List<PlatformMenuItem> _menus(
    WidgetRef ref,
    AppLocalizations l10n,
    Map<CommandId, KeyChord> effective, {
    required bool recording,
  }) {
    PlatformMenuItem item(CommandId id) =>
        _commandItem(ref, l10n, effective, id, recording: recording);

    return [
      PlatformMenu(
        label: l10n.appMenuRoola,
        menus: [
          PlatformMenuItem(
            label: l10n.aboutMenuItem,
            onSelected: () {
              final context = rootNavigatorKey.currentContext;
              if (context != null) {
                showRoolaAboutDialog(context);
              }
            },
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: l10n.checkForUpdatesMenuItem,
                onSelected: () {
                  ref.read(updateCheckerProvider).checkForUpdates();
                },
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              item(CommandId.openSettings),
              item(CommandId.openKeybindings),
            ],
          ),
          if (Platform.isMacOS) ...[
            const PlatformMenuItemGroup(
              members: [
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.servicesSubmenu,
                ),
              ],
            ),
            const PlatformMenuItemGroup(
              members: [
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.hide,
                ),
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.hideOtherApplications,
                ),
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.showAllApplications,
                ),
              ],
            ),
            const PlatformMenuItemGroup(
              members: [
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.quit,
                ),
              ],
            ),
          ],
        ],
      ),
      PlatformMenu(
        label: l10n.appMenuFile,
        menus: [
          PlatformMenuItemGroup(
            members: [
              item(CommandId.newExplorerTab),
              item(CommandId.newTerminalTab),
            ],
          ),
          PlatformMenuItemGroup(
            members: [item(CommandId.newFolder), item(CommandId.newFile)],
          ),
          PlatformMenuItemGroup(
            members: [item(CommandId.openLauncherManagement)],
          ),
          PlatformMenuItemGroup(members: [item(CommandId.closeTab)]),
        ],
      ),
      PlatformMenu(
        label: l10n.appMenuEdit,
        menus: [
          PlatformMenuItemGroup(
            members: [
              item(CommandId.copyItem),
              item(CommandId.copyPath),
              item(CommandId.pasteItem),
            ],
          ),
          PlatformMenuItemGroup(
            members: [item(CommandId.renameItem), item(CommandId.moveToTrash)],
          ),
        ],
      ),
      PlatformMenu(
        label: l10n.appMenuView,
        menus: [
          PlatformMenuItemGroup(
            members: [
              item(CommandId.navigateBack),
              item(CommandId.navigateForward),
              item(CommandId.navigateUp),
            ],
          ),
          PlatformMenuItemGroup(
            members: [item(CommandId.nextTab), item(CommandId.previousTab)],
          ),
          PlatformMenuItemGroup(
            members: [
              item(CommandId.revealInFinder),
              item(CommandId.showProperties),
            ],
          ),
        ],
      ),
      PlatformMenu(
        label: l10n.appMenuTerminal,
        menus: [
          item(CommandId.openTerminalHere),
          item(CommandId.openClaudeHere),
        ],
      ),
      PlatformMenu(
        label: l10n.appMenuGit,
        menus: [
          PlatformMenuItemGroup(members: [item(CommandId.gitRefresh)]),
          PlatformMenuItemGroup(
            members: [
              item(CommandId.gitFetch),
              item(CommandId.gitPull),
              item(CommandId.gitPush),
            ],
          ),
        ],
      ),
      PlatformMenu(
        label: l10n.appMenuPane,
        menus: [
          item(CommandId.moveTabTopLeft),
          item(CommandId.moveTabTopRight),
          item(CommandId.moveTabBottom),
        ],
      ),
    ];
  }

  PlatformMenuItem _commandItem(
    WidgetRef ref,
    AppLocalizations l10n,
    Map<CommandId, KeyChord> effective,
    CommandId id, {
    required bool recording,
  }) {
    return PlatformMenuItem(
      label: l10n.commandLabel(id),
      shortcut: recording ? null : toSingleActivator(effective[id]!),
      onSelected: () => dispatchCommand(id, ref),
    );
  }
}
