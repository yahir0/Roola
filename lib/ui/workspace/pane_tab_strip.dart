import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
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

  static const double height = 36;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final activeIndex = slot.safeActiveIndex;
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
        color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
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
    final colors = Theme.of(context).colorScheme;
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
              child: Container(width: 3, color: colors.primary),
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
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: isActive
          ? colors.surface
          : colors.surfaceContainerHighest.withValues(alpha: 0.2),
      child: InkWell(
        onTap: dragging ? null : () => notifier.activateTab(tab.id),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 180),
          padding: const EdgeInsets.only(left: 12, right: 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? colors.primary : Colors.transparent,
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
                size: 14,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _label(tab),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                icon: const Icon(Icons.close, size: 14),
                tooltip: 'タブを閉じる',
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
    PopupMenuItem<_TabMenuAction> item(
      _TabMenuAction action,
      IconData icon,
      String label,
    ) => PopupMenuItem(
      value: action,
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        dense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );

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
          item(_TabMenuAction.moveTopLeft, Icons.north_west, '左上ペインへ移動'),
        if (slotId != PaneSlotId.topRight)
          item(_TabMenuAction.moveTopRight, Icons.north_east, '右上ペインへ移動'),
        if (slotId != PaneSlotId.bottom)
          item(_TabMenuAction.moveBottom, Icons.south, '下ペインへ移動'),
        const PopupMenuDivider(),
        item(_TabMenuAction.close, Icons.close, 'タブを閉じる'),
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
    final colors = Theme.of(context).colorScheme;
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
                  width: 3,
                  height: PaneTabStrip.height - 8,
                  color: colors.primary,
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
      icon: const Icon(Icons.add, size: 18),
      tooltip: 'タブを追加',
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
