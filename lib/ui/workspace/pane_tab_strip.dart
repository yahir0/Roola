import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/core/keybindings/chord_formatter.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/command_registry.dart';
import 'package:roola/data/keybindings/effective_keybindings.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/command_l10n.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';

/// ペイン上端のタブストリップ。
///
/// タブ chip を横に並べ、末尾に「+」（エクスプローラ / ターミナル追加）を
/// 置く。タブ chip 全体がドラッグ可能かつドロップ受け口になっており、
/// ドロップで `workspaceProvider.moveTab` を呼ぶ（ストリップ内並べ替え・
/// ペイン間移動 / ADR-0026）。右クリックで移動先ペインを選ぶメニューも出す。
class PaneTabStrip extends ConsumerWidget {
  const PaneTabStrip({required this.slotId, required this.slot, super.key});

  final PaneSlotId slotId;
  final PaneSlot slot;

  /// タブストリップの高さ（px）。タブ（アイコン 16 ＋ ラベル 14）が枠に
  /// 詰まって見えないよう上下にゆとりを取り、4px グリッド上の 40px とする
  /// （ADR-0038 D6）。
  static const double height = 40;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PolarisTokens.of(context);
    final activeIndex = slot.safeActiveIndex;
    // タブストリップは筐体側のクローム＝bg トーン＋下端 1px ヘアライン継ぎ目。
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tokens.line)),
        color: tokens.bg,
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < slot.tabs.length; i++)
                    _TabChip(
                      slotId: slotId,
                      tab: slot.tabs[i],
                      index: i,
                      isActive: i == activeIndex,
                    ),
                  _EndDropZone(slotId: slotId, tabCount: slot.tabs.length),
                ],
              ),
            ),
          ),
          _AddTabButton(slotId: slotId),
        ],
      ),
    );
  }
}

/// タブメニュー / DnD で扱う移動操作。
enum _TabMenuAction { moveTopLeft, moveTopRight, moveBottom, close }

/// タブ 1 件分の chip。
///
/// - クリック: アクティブ化
/// - × ボタン: 閉じる
/// - ドラッグ: 別位置 / 別ペインへ移動（chip 全体がドロップ受け口）
/// - 右クリック: 移動先ペインを選ぶメニュー
class _TabChip extends ConsumerWidget {
  const _TabChip({
    required this.slotId,
    required this.tab,
    required this.index,
    required this.isActive,
  });

  final PaneSlotId slotId;
  final WorkspaceTab tab;
  final int index;
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(workspaceProvider.notifier);
    final tokens = PolarisTokens.of(context);
    return DragTarget<String>(
      // 自分自身の上へのドロップは受けない（no-op）。
      onWillAcceptWithDetails: (details) => details.data != tab.id,
      // chip i の上へのドロップは「chip i の前へ挿入」とみなす。
      onAcceptWithDetails: (details) =>
          notifier.moveTab(details.data, slotId, index),
      builder: (context, candidate, rejected) {
        final chip = Draggable<String>(
          data: tab.id,
          feedback: Material(
            elevation: 4,
            color: Colors.transparent,
            child: _chip(context, notifier, dragging: true),
          ),
          childWhenDragging: Opacity(
            opacity: 0.4,
            child: _chip(context, notifier),
          ),
          child: GestureDetector(
            onSecondaryTapDown: (details) =>
                _showMenu(context, ref, details.globalPosition),
            child: _chip(context, notifier),
          ),
        );
        if (candidate.isEmpty) {
          return chip;
        }
        // ドロップ位置インジケータ（chip 左端の縦バー）。
        return Stack(
          children: [
            chip,
            Positioned(
              left: 0,
              top: 4,
              bottom: 4,
              child: Container(width: 2, color: tokens.accent),
            ),
          ],
        );
      },
    );
  }

  Widget _chip(
    BuildContext context,
    Workspace notifier, {
    bool dragging = false,
  }) {
    final tokens = PolarisTokens.of(context);
    // アクティブタブのみ surface に持ち上げ、2px アクセント下線で点灯（D12）。
    return Material(
      color: isActive ? tokens.surface : Colors.transparent,
      child: InkWell(
        onTap: dragging ? null : () => notifier.activateTab(tab.id),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 180),
          padding: const EdgeInsets.only(left: 12, right: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? tokens.accent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                switch (tab) {
                  ExplorerTab() => Icons.folder_outlined,
                  TerminalTab() => Icons.terminal,
                  GitTab() => Icons.account_tree_outlined,
                },
                size: PolarisIconSize.small,
                color: isActive ? tokens.accent : tokens.textFaint,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _label(tab),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tokens.body.copyWith(
                    color: isActive ? tokens.accent : tokens.textDim,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.close, size: PolarisIconSize.small),
                tooltip: AppLocalizations.of(context).paneTabCloseTooltip,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                onPressed: dragging ? null : () => notifier.closeTab(tab.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 右クリックメニュー。現在のペイン以外への移動と「閉じる」を出す。
  Future<void> _showMenu(
    BuildContext context,
    WidgetRef ref,
    Offset position,
  ) async {
    final effective = ref.read(effectiveKeybindingsProvider);
    PopupMenuItem<_TabMenuAction> item(
      _TabMenuAction action,
      CommandId command,
    ) {
      final metadata = CommandRegistry.metadataFor(command);
      return PopupMenuItem(
        value: action,
        child: ListTile(
          leading: Icon(metadata.icon),
          title: Text(AppLocalizations.of(context).commandLabel(command)),
          trailing: Text(
            formatChord(effective[command]!),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      );
    }

    final selected = await showMenu<_TabMenuAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        if (slotId != PaneSlotId.topLeft)
          item(_TabMenuAction.moveTopLeft, CommandId.moveTabTopLeft),
        if (slotId != PaneSlotId.topRight)
          item(_TabMenuAction.moveTopRight, CommandId.moveTabTopRight),
        if (slotId != PaneSlotId.bottom)
          item(_TabMenuAction.moveBottom, CommandId.moveTabBottom),
        const PopupMenuDivider(),
        item(_TabMenuAction.close, CommandId.closeTab),
      ],
    );
    if (selected == null) {
      return;
    }
    final notifier = ref.read(workspaceProvider.notifier);
    final layout = ref.read(workspaceProvider);
    void moveTo(PaneSlotId target) {
      // 移動先ペインの末尾に追加する。空ペインへ移動するとそのペインが
      // 再生成され、崩れていた画面が再び開く（ADR-0026）。
      notifier.moveTab(tab.id, target, layout.slot(target).tabs.length);
    }

    switch (selected) {
      case _TabMenuAction.moveTopLeft:
        moveTo(PaneSlotId.topLeft);
      case _TabMenuAction.moveTopRight:
        moveTo(PaneSlotId.topRight);
      case _TabMenuAction.moveBottom:
        moveTo(PaneSlotId.bottom);
      case _TabMenuAction.close:
        notifier.closeTab(tab.id);
    }
  }

  static String _label(WorkspaceTab tab) => switch (tab) {
    ExplorerTab(:final currentPath) => _basename(currentPath),
    TerminalTab(:final args) => args.displayName,
    GitTab(:final repoRoot) => 'Git: ${_basename(repoRoot)}',
  };

  static String _basename(String path) {
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    return segments.isEmpty ? path : segments.last;
  }
}

/// タブ列末尾のドロップ受け口。ここにドロップするとタブはペイン末尾へ移る。
class _EndDropZone extends ConsumerWidget {
  const _EndDropZone({required this.slotId, required this.tabCount});

  final PaneSlotId slotId;
  final int tabCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PolarisTokens.of(context);
    return DragTarget<String>(
      onAcceptWithDetails: (details) => ref
          .read(workspaceProvider.notifier)
          .moveTab(details.data, slotId, tabCount),
      builder: (context, candidate, rejected) {
        return Container(
          width: 48,
          height: PaneTabStrip.height,
          alignment: Alignment.centerLeft,
          child: candidate.isEmpty
              ? null
              : Container(
                  width: 2,
                  height: PaneTabStrip.height - 8,
                  color: tokens.accent,
                ),
        );
      },
    );
  }
}

/// タブストリップ末尾の「+」。エクスプローラ / ターミナルを選んで追加する。
class _AddTabButton extends ConsumerWidget {
  const _AddTabButton({required this.slotId});

  final PaneSlotId slotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_AddTabKind>(
      icon: const Icon(Icons.add, size: PolarisIconSize.standard),
      tooltip: AppLocalizations.of(context).paneTabAddTooltip,
      iconSize: 18,
      padding: EdgeInsets.zero,
      onSelected: (kind) {
        final notifier = ref.read(workspaceProvider.notifier);
        switch (kind) {
          case _AddTabKind.explorer:
            notifier.addExplorerTab(slotId);
          case _AddTabKind.terminal:
            notifier.addTerminalTab(slotId);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _AddTabKind.explorer,
          child: ListTile(
            leading: Icon(Icons.folder_outlined),
            title: Text('エクスプローラ'),
            dense: true,
          ),
        ),
        PopupMenuItem(
          value: _AddTabKind.terminal,
          child: ListTile(
            leading: Icon(Icons.terminal),
            title: Text('ターミナル'),
            dense: true,
          ),
        ),
      ],
    );
  }
}

enum _AddTabKind { explorer, terminal }
