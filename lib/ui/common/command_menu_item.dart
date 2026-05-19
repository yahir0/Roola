import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/keybindings/chord_formatter.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/command_registry.dart';
import 'package:roola/data/keybindings/effective_keybindings.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/command_l10n.dart';

/// コンテキストメニュー項目の共通ビルダー（ADR-0033）。
///
/// `CommandId` から「リーディングアイコン + ラベル + 右端のショートカット
/// 表示」の `ListTile` を作る。右クリックメニューとメニューバーが同じ
/// `CommandRegistry` / `effectiveKeybindingsProvider` を参照することで、
/// 表示が一貫する。

/// コマンドのメニュー項目の中身（アイコン + ラベル + ショートカット）。
ListTile commandMenuTile(
  BuildContext context,
  WidgetRef ref,
  CommandId command,
) {
  final metadata = CommandRegistry.metadataFor(command);
  final chord = ref.read(effectiveKeybindingsProvider)[command]!;
  final hintColor = Theme.of(context).hintColor;
  return ListTile(
    leading: Icon(metadata.icon),
    title: Text(AppLocalizations.of(context).commandLabel(command)),
    trailing: Text(
      formatChord(chord),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: hintColor),
    ),
  );
}

/// コマンドに対応する `PopupMenuItem`。[value] はメニューの戻り値型に
/// 合わせて呼び出し側が指定する。
PopupMenuItem<T> commandPopupMenuItem<T>(
  BuildContext context,
  WidgetRef ref, {
  required CommandId command,
  required T value,
}) {
  return PopupMenuItem<T>(
    value: value,
    child: commandMenuTile(context, ref, command),
  );
}
