import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/about.dart';
import 'package:roola/app/command_dispatcher.dart';
import 'package:roola/app/router.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/core/keybindings/chord_formatter.dart';
import 'package:roola/core/system/update_checker.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/effective_keybindings.dart';
import 'package:roola/data/keybindings/key_chord.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/command_l10n.dart';
import 'package:roola/ui/settings/key_chord_recorder_dialog.dart';

/// Windows 専用のインラインメニューバー（ADR-0058）。
///
/// macOS の `PlatformMenuBar`（ネイティブメニューバー）に相当する Flutter 実装。
/// `TitleBarStyle.hidden` でネイティブメニューが非表示になるため、Flutter の
/// `MenuBar` ウィジェットで同等の構成を `AppBar.title` スロットに再現する。
/// 左端のロゴアイコンが「Roola」メニュー（About / アップデートを確認 / 設定）
/// を兼ね、以降にファイル / 編集 / 表示 / ターミナル / Git / ペインが並ぶ。
class WindowsTopMenuBar extends ConsumerWidget {
  const WindowsTopMenuBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effective = ref.watch(effectiveKeybindingsProvider);
    final recording = ref.watch(keybindingRecordingProvider);
    final l10n = AppLocalizations.of(context);
    final tokens = PolarisTokens.of(context);

    final barStyle = _barButtonStyle(tokens);
    final dropStyle = _dropdownMenuStyle(tokens);

    SubmenuButton sub(Widget label, List<Widget> items) => SubmenuButton(
          style: barStyle,
          menuStyle: dropStyle,
          menuChildren: items,
          child: SizedBox(
            height: 28,
            child: Align(
              widthFactor: 1.0,
              child: label,
            ),
          ),
        );

    MenuItemButton cmd(CommandId id) =>
        _cmdItem(ref, l10n, effective, id, tokens, recording: recording);

    // Polaris 区切り線（dividerTheme: space=1, thickness=1, color=tokens.line）
    const div = Divider();

    return Align(
      alignment: Alignment.centerLeft,
      child: MenuBar(
        style: const MenuStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          elevation: WidgetStatePropertyAll(0),
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
        ),
        children: [
          // ロゴアイコン → Roola メニュー（About / アップデートを確認 / 設定）
          sub(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Image.asset(
                'assets/branding/roola_icon.png',
                width: 28,
                height: 28,
              ),
            ),
            [
              _plainItem(l10n.aboutMenuItem, tokens, () {
                final ctx = rootNavigatorKey.currentContext;
                if (ctx != null) unawaited(showRoolaAboutDialog(ctx));
              }),
              div,
              _plainItem(
                l10n.checkForUpdatesMenuItem,
                tokens,
                () => ref.read(updateCheckerProvider).checkForUpdates(),
              ),
              div,
              cmd(CommandId.openSettings),
              cmd(CommandId.openKeybindings),
            ],
          ),
          sub(Text(l10n.appMenuFile), [
            cmd(CommandId.newExplorerTab),
            cmd(CommandId.newTerminalTab),
            div,
            cmd(CommandId.newFolder),
            cmd(CommandId.newFile),
            div,
            cmd(CommandId.openLauncherManagement),
            div,
            cmd(CommandId.closeTab),
          ]),
          sub(Text(l10n.appMenuEdit), [
            cmd(CommandId.copyItem),
            cmd(CommandId.copyPath),
            cmd(CommandId.pasteItem),
            div,
            cmd(CommandId.renameItem),
            cmd(CommandId.moveToTrash),
          ]),
          sub(Text(l10n.appMenuView), [
            cmd(CommandId.navigateBack),
            cmd(CommandId.navigateForward),
            cmd(CommandId.navigateUp),
            div,
            cmd(CommandId.nextTab),
            cmd(CommandId.previousTab),
            div,
            cmd(CommandId.revealInFinder),
            cmd(CommandId.showProperties),
          ]),
          sub(Text(l10n.appMenuTerminal), [
            cmd(CommandId.openTerminalHere),
            cmd(CommandId.openClaudeHere),
          ]),
          sub(Text(l10n.appMenuGit), [
            cmd(CommandId.gitRefresh),
            div,
            cmd(CommandId.gitFetch),
            cmd(CommandId.gitPull),
            cmd(CommandId.gitPush),
          ]),
          sub(Text(l10n.appMenuPane), [
            cmd(CommandId.moveTabTopLeft),
            cmd(CommandId.moveTabTopRight),
            cmd(CommandId.moveTabBottom),
          ]),
        ],
      ),
    );
  }
}

ButtonStyle _barButtonStyle(PolarisTokens tokens) => ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.hovered) || s.contains(WidgetState.focused)) {
          return tokens.surface;
        }
        return Colors.transparent;
      }),
      foregroundColor: WidgetStatePropertyAll(tokens.text),
      textStyle: WidgetStatePropertyAll(tokens.body),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: PolarisTokens.space2),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(0, 28)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      animationDuration: Duration.zero,
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius),
        ),
      ),
    );

MenuStyle _dropdownMenuStyle(PolarisTokens tokens) => MenuStyle(
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(tokens.surface),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      side: WidgetStatePropertyAll(BorderSide(color: tokens.line)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius),
        ),
      ),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 4)),
    );

ButtonStyle _menuItemStyle(PolarisTokens tokens) => ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.hovered)) return tokens.surfaceHi;
        return Colors.transparent;
      }),
      foregroundColor: WidgetStatePropertyAll(tokens.text),
      textStyle: WidgetStatePropertyAll(tokens.body),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: PolarisTokens.space3,
          vertical: 11,
        ),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(160, 0)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
      animationDuration: Duration.zero,
    );

MenuItemButton _plainItem(
  String label,
  PolarisTokens tokens,
  VoidCallback onPressed,
) =>
    MenuItemButton(
      style: _menuItemStyle(tokens),
      onPressed: onPressed,
      child: Text(label),
    );

MenuItemButton _cmdItem(
  WidgetRef ref,
  AppLocalizations l10n,
  Map<CommandId, KeyChord> effective,
  CommandId id,
  PolarisTokens tokens, {
  required bool recording,
}) {
  final chord = effective[id];
  return MenuItemButton(
    style: _menuItemStyle(tokens),
    shortcut: (!recording && chord != null) ? toSingleActivator(chord) : null,
    onPressed: () => dispatchCommand(id, ref),
    child: Text(l10n.commandLabel(id)),
  );
}
