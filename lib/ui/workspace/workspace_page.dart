import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/router.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_layout_mode.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/app_bar_divider.dart';
import 'package:roola/ui/common/macos_window_app_bar.dart';
import 'package:roola/ui/explorer/explorer_sidebar.dart';
import 'package:roola/ui/workspace/pane_widget.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:roola/ui/workspace/workspace_split.dart';

/// Roola のメイン画面（`/explorer` ルートの中身）。
///
/// ウィンドウ AppBar + サイドバー + 3 ペインタブ式ワークスペース（ADR-0026）。
/// 戻る / 進むはエクスプローラタブのペインヘッダへ移設したため、ここの
/// AppBar には置かない。
class WorkspacePage extends StatelessWidget {
  const WorkspacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MacosWindowAppBar(
        bottom: const AppBarDivider(),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: AppLocalizations.of(context).settingsButtonTooltip,
            onPressed: () => const SettingsRoute().push<void>(context),
          ),
        ],
      ),
      body: const Row(
        children: [
          ExplorerSidebar(),
          Expanded(child: _WorkspaceArea()),
        ],
      ),
    );
  }
}

/// 崩し再フロー結果に応じて 3 / 2 / 単一ペインを描画する領域。
class _WorkspaceArea extends ConsumerWidget {
  const _WorkspaceArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(workspaceProvider);
    final notifier = ref.read(workspaceProvider.notifier);
    final resolved = resolveWorkspaceLayout(layout);

    Widget pane(PaneSlotId slotId) =>
        PaneWidget(key: ValueKey(slotId), slotId: slotId);

    switch (resolved.mode) {
      case WorkspaceLayoutMode.single:
        return pane(resolved.visibleSlots.first);
      case WorkspaceLayoutMode.twoHorizontal:
        return WorkspaceSplit(
          axis: Axis.horizontal,
          ratio: layout.leftRatio,
          onRatioChanged: notifier.setLeftRatio,
          first: pane(resolved.visibleSlots[0]),
          second: pane(resolved.visibleSlots[1]),
        );
      case WorkspaceLayoutMode.twoVertical:
        return WorkspaceSplit(
          axis: Axis.vertical,
          ratio: layout.topRatio,
          onRatioChanged: notifier.setTopRatio,
          first: pane(resolved.visibleSlots[0]),
          second: pane(resolved.visibleSlots[1]),
        );
      case WorkspaceLayoutMode.three:
        return WorkspaceSplit(
          axis: Axis.vertical,
          ratio: layout.topRatio,
          onRatioChanged: notifier.setTopRatio,
          first: WorkspaceSplit(
            axis: Axis.horizontal,
            ratio: layout.leftRatio,
            onRatioChanged: notifier.setLeftRatio,
            first: pane(PaneSlotId.topLeft),
            second: pane(PaneSlotId.topRight),
          ),
          second: pane(PaneSlotId.bottom),
        );
    }
  }
}
