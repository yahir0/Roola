import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/command_dispatcher.dart';
import 'package:roola/core/keybindings/chord_formatter.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/command_registry.dart';
import 'package:roola/data/keybindings/effective_keybindings.dart';
import 'package:roola/data/keybindings/key_chord.dart';
import 'package:roola/ui/settings/key_chord_recorder_dialog.dart';

/// macOS ネイティブメニューバー（ADR-0033）。
///
/// ショートカットの発火はこのメニューバーの key equivalent に一本化する。
/// ターミナル（SwiftTerm のネイティブビュー）にフォーカスがあっても、
/// ネイティブメニューの key equivalent はファーストレスポンダに関係なく
/// 発火するため（ADR-0031）。
///
/// `effectiveKeybindingsProvider` を watch し、ユーザーがキーを変更すると
/// メニュー項目のショートカット表示が即再構築される。
class AppMenuBar extends ConsumerWidget {
  const AppMenuBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effective = ref.watch(effectiveKeybindingsProvider);
    // レコーダ表示中はメニューの key equivalent を外し、入力キーが
    // レコーダまで届くようにする（ADR-0033）。
    final recording = ref.watch(keybindingRecordingProvider);
    return PlatformMenuBar(
      menus: _menus(ref, effective, recording: recording),
      child: child,
    );
  }

  List<PlatformMenuItem> _menus(
    WidgetRef ref,
    Map<CommandId, KeyChord> effective, {
    required bool recording,
  }) {
    PlatformMenuItem item(CommandId id) =>
        _commandItem(ref, effective, id, recording: recording);

    return [
      // macOS の先頭メニュー（アプリメニュー）。
      PlatformMenu(
        label: 'Roola',
        menus: [
          const PlatformProvidedMenuItem(
            type: PlatformProvidedMenuItemType.about,
          ),
          PlatformMenuItemGroup(
            members: [
              item(CommandId.openSettings),
              item(CommandId.openKeybindings),
            ],
          ),
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
      ),
      PlatformMenu(
        label: 'ファイル',
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
        label: '編集',
        menus: [
          PlatformMenuItemGroup(
            members: [
              item(CommandId.copyItem),
              item(CommandId.copyPath),
              item(CommandId.pasteItem),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              item(CommandId.renameItem),
              item(CommandId.moveToTrash),
            ],
          ),
        ],
      ),
      PlatformMenu(
        label: '表示',
        menus: [
          PlatformMenuItemGroup(
            members: [
              item(CommandId.navigateBack),
              item(CommandId.navigateForward),
              item(CommandId.navigateUp),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              item(CommandId.nextTab),
              item(CommandId.previousTab),
            ],
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
        label: 'ターミナル',
        menus: [
          item(CommandId.openTerminalHere),
          item(CommandId.openClaudeHere),
        ],
      ),
      PlatformMenu(
        label: 'Git',
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
        label: 'ペイン',
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
    Map<CommandId, KeyChord> effective,
    CommandId id, {
    required bool recording,
  }) {
    return PlatformMenuItem(
      label: CommandRegistry.metadataFor(id).label,
      shortcut: recording ? null : toSingleActivator(effective[id]!),
      onSelected: () => dispatchCommand(id, ref),
    );
  }
}
