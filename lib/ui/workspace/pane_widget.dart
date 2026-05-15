import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/explorer/explorer_tab_body.dart';
import 'package:roola/ui/explorer/session_view.dart';
import 'package:roola/ui/workspace/current_tab_id_provider.dart';
import 'package:roola/ui/workspace/focused_tab_provider.dart';
import 'package:roola/ui/workspace/pane_tab_strip.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';

/// ペインスロット 1 つ分の widget。タブストリップ + アクティブタブ body。
///
/// 非アクティブタブも `IndexedStack` で mount 維持し、エクスプローラの
/// スクロール位置やターミナルの出力を保持する。各タブ body は
/// `ProviderScope` で `currentTabIdProvider` を override し、配下の widget に
/// tabId を配る（ADR-0027）。
class PaneWidget extends ConsumerWidget {
  const PaneWidget({required this.slotId, super.key});

  final PaneSlotId slotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slot = ref.watch(
      workspaceProvider.select((layout) => layout.slot(slotId)),
    );
    if (slot.tabs.isEmpty) {
      // 崩し再フローで空スロットは描画対象から外れるため、通常ここには
      // 来ない。来た場合のフォールバック。
      return const SizedBox.shrink();
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          PaneTabStrip(slotId: slotId, slot: slot),
          Expanded(
            child: IndexedStack(
              index: slot.safeActiveIndex,
              children: [
                for (final tab in slot.tabs)
                  _TabContent(key: ValueKey(tab.id), tab: tab),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// タブ 1 件分の body。`ProviderScope` で tabId を注入し、ポインタ押下で
/// フォーカス追跡を更新する（ADR-0026 design Decision 4）。
class _TabContent extends ConsumerWidget {
  const _TabContent({required this.tab, super.key});

  final WorkspaceTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [currentTabIdProvider.overrideWithValue(tab.id)],
      child: Listener(
        onPointerDown: (_) {
          final focus = ref.read(focusedTabProvider.notifier);
          switch (tab) {
            case ExplorerTab():
              focus.focusExplorer(tab.id);
            case TerminalTab():
              focus.focusTerminal(tab.id);
          }
        },
        child: switch (tab) {
          ExplorerTab() => const ExplorerTabBody(),
          TerminalTab(:final args) => SessionView(args),
        },
      ),
    );
  }
}
