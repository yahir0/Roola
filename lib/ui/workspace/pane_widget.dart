import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/explorer/explorer_tab_body.dart';
import 'package:roola/ui/explorer/session_view.dart';
import 'package:roola/ui/git/git_tab.dart';
import 'package:roola/ui/workspace/current_tab_id_provider.dart';
import 'package:roola/ui/workspace/focused_tab_provider.dart';
import 'package:roola/ui/workspace/pane_tab_strip.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';

/// タブ body（[_TabContent]）の Element を tabId 単位で保持する GlobalKey。
///
/// タブをペイン間で DnD 移動したり、崩し再フロー（`resolveWorkspaceLayout`）で
/// ペインの widget ツリーが組み変わると、`ValueKey`（LocalKey）では Element が
/// 別 `IndexedStack` を跨げず作り直される。すると `SessionView` 配下の
/// `AppKitView` も再生成され、SwiftTerm ネイティブビューが破棄されてターミナル
/// の表示内容が消える。tabId 単位の GlobalKey を使うと Flutter が Element ごと
/// reparent するため、移動・再フローを跨いでもネイティブビュー（表示内容）が
/// 保持される。
///
/// タブを閉じても当該 tabId のキーは残るが、1 タブにつき軽量オブジェクト
/// 1 つで実害は無いため除去はしない。
final Map<String, GlobalKey> _tabContentKeys = {};

GlobalKey _tabContentKey(String tabId) =>
    _tabContentKeys.putIfAbsent(tabId, GlobalKey.new);

/// ペインスロット 1 つ分の widget。タブストリップ + アクティブタブ body。
///
/// 非アクティブタブも `IndexedStack` で mount 維持し、エクスプローラの
/// スクロール位置やターミナルの出力を保持する。ペイン間移動・崩し再フローを
/// 跨いだ保持は [_tabContentKey] の GlobalKey が担う。各タブ body は
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
                  _TabContent(key: _tabContentKey(tab.id), tab: tab),
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
            case GitTab():
              focus.focusGit(tab.id);
          }
        },
        child: switch (tab) {
          ExplorerTab() => const ExplorerTabBody(),
          TerminalTab(:final args) => SessionView(args),
          GitTab() => const GitTabBody(),
        },
      ),
    );
  }
}
