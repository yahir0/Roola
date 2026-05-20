import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/about.dart';
import 'package:roola/app/command_dispatcher.dart';
import 'package:roola/app/router.dart';
import 'package:roola/core/keybindings/chord_formatter.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/effective_keybindings.dart';
import 'package:roola/data/keybindings/key_chord.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/command_l10n.dart';
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
      // macOS の先頭メニュー（アプリメニュー）。
      PlatformMenu(
        label: l10n.appMenuRoola,
        menus: [
          // macOS 標準の About 項目は `PlatformProvidedMenuItem.about` で
          // 出せるが、それだと OS 既定のダイアログ（Info.plist のみ参照）が
          // 開く。OSS ライセンスの「ライセンスを表示」ボタン付き
          // [showAboutDialog] に差し替えるために、自前の `PlatformMenuItem`
          // にする（ADR-0040）。
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
              PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.hide),
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
              PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.quit),
            ],
          ),
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
