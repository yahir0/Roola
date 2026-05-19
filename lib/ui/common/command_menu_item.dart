import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/core/keybindings/chord_formatter.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/command_registry.dart';
import 'package:roola/data/keybindings/effective_keybindings.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/command_l10n.dart';

/// コンテキストメニュー項目の共通ビルダー（ADR-0033 / ADR-0038）。
///
/// `CommandId` から「リーディングアイコン + ラベル + 右端のショートカット
/// 表示」の行を作る。右クリックメニューとメニューバーが同じ
/// `CommandRegistry` / `effectiveKeybindingsProvider` を参照することで、
/// 表示が一貫する。
///
/// Polaris（ADR-0038）に合わせ、Material `ListTile` の既定（48px の最小高・
/// 24px の標準アイコン）は使わず、4px グリッドの低い行に収める。

/// コンテキストメニュー 1 行の高さ（4px グリッド / ADR-0038 D6）。
/// エクスプローラの comfortable 行と揃えた 28px。
const double polarisMenuItemHeight = 28;

/// 右クリックメニューの区切り線エントリの高さ。1px の線＋上下 4px の余白。
const double polarisMenuDividerHeight = 9;

/// アイコン・ラベル（・ショートカット）を [polarisMenuItemHeight] の行に
/// 収めた、Polaris のコンテキストメニュー 1 行。`PopupMenuItem.child` に渡す。
/// [icon] を省略するとラベルのみの行になる。
Widget polarisMenuRow(
  BuildContext context, {
  required String label,
  IconData? icon,
  String? shortcut,
}) {
  final tokens = PolarisTokens.of(context);
  return SizedBox(
    height: polarisMenuItemHeight,
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: PolarisIconSize.small, color: tokens.textDim),
          const SizedBox(width: PolarisTokens.space3),
        ],
        Expanded(
          child: Text(
            label,
            style: tokens.body.copyWith(color: tokens.text),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (shortcut != null) ...[
          const SizedBox(width: PolarisTokens.space5),
          Text(shortcut, style: tokens.mono.copyWith(color: tokens.textFaint)),
        ],
      ],
    ),
  );
}

/// ラベル（+ アイコン + ショートカット）を持つ Polaris の `PopupMenuItem`。
/// [value] はメニューの戻り値型に合わせて呼び出し側が指定する。
PopupMenuItem<T> polarisPopupMenuItem<T>(
  BuildContext context, {
  required T value,
  required String label,
  IconData? icon,
  String? shortcut,
  bool enabled = true,
}) {
  return PopupMenuItem<T>(
    value: value,
    enabled: enabled,
    height: polarisMenuItemHeight,
    padding: const EdgeInsets.symmetric(horizontal: PolarisTokens.space3),
    child: polarisMenuRow(
      context,
      label: label,
      icon: icon,
      shortcut: shortcut,
    ),
  );
}

/// コマンドに対応する Polaris の `PopupMenuItem`。アイコン・ラベル・
/// ショートカットを `CommandRegistry` から解決する。
PopupMenuItem<T> commandPopupMenuItem<T>(
  BuildContext context,
  WidgetRef ref, {
  required CommandId command,
  required T value,
}) {
  final metadata = CommandRegistry.metadataFor(command);
  final chord = ref.read(effectiveKeybindingsProvider)[command]!;
  return polarisPopupMenuItem<T>(
    context,
    value: value,
    icon: metadata.icon,
    label: AppLocalizations.of(context).commandLabel(command),
    shortcut: formatChord(chord),
  );
}
