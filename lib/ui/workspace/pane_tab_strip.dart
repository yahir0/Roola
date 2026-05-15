import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';

/// ペイン上端のタブストリップ。
///
/// タブ chip を横に並べ、末尾に「+」（エクスプローラ / ターミナル追加）を
/// 置く。各タブ chip はドラッグ可能で、タブ間 / 両端のギャップが
/// `DragTarget` になっており、ドロップで `workspaceProvider.moveTab` を
/// 呼ぶ（ストリップ内並べ替え・ペイン間移動 / ADR-0026）。
class PaneTabStrip extends ConsumerWidget {
  const PaneTabStrip({required this.slotId, required this.slot, super.key});

  final PaneSlotId slotId;
  final PaneSlot slot;

  static const double height = 36;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final activeIndex = slot.safeActiveIndex;
    final strip = <Widget>[];
    for (var i = 0; i < slot.tabs.length; i++) {
      strip.add(_TabGap(slotId: slotId, gapIndex: i));
      strip.add(
        _TabChip(slotId: slotId, tab: slot.tabs[i], isActive: i == activeIndex),
      );
    }
    strip.add(_TabGap(slotId: slotId, gapIndex: slot.tabs.length));

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
              child: Row(children: strip),
            ),
          ),
          _AddTabButton(slotId: slotId),
        ],
      ),
    );
  }
}

/// タブ間 / 両端のドロップ受け口。タブをドラッグ中はインジケータを表示する。
class _TabGap extends ConsumerWidget {
  const _TabGap({required this.slotId, required this.gapIndex});

  final PaneSlotId slotId;
  final int gapIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        ref
            .read(workspaceProvider.notifier)
            .moveTab(details.data, slotId, gapIndex);
      },
      builder: (context, candidate, rejected) {
        final hover = candidate.isNotEmpty;
        return Container(
          width: hover ? 24 : 6,
          height: PaneTabStrip.height,
          alignment: Alignment.center,
          child: Container(
            width: hover ? 3 : 0,
            height: PaneTabStrip.height - 10,
            decoration: BoxDecoration(
              color: hover ? colors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      },
    );
  }
}

/// タブ 1 件分の chip。クリックでアクティブ化、× で閉じる。`Draggable` で
/// ストリップ内 / ペイン間へドラッグできる。
class _TabChip extends ConsumerWidget {
  const _TabChip({
    required this.slotId,
    required this.tab,
    required this.isActive,
  });

  final PaneSlotId slotId;
  final WorkspaceTab tab;
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(workspaceProvider.notifier);
    final chip = _chip(context, notifier);
    return Draggable<String>(
      data: tab.id,
      feedback: Material(
        elevation: 4,
        color: Colors.transparent,
        child: _chip(context, notifier, dragging: true),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: chip),
      child: chip,
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
                tab is ExplorerTab ? Icons.folder_outlined : Icons.terminal,
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

  static String _label(WorkspaceTab tab) => switch (tab) {
    ExplorerTab(:final currentPath) => _basename(currentPath),
    TerminalTab(:final args) => args.displayName,
  };

  static String _basename(String path) {
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    return segments.isEmpty ? path : segments.last;
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
