import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/router.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_layout_mode.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/app_bar_divider.dart';
import 'package:roola/ui/common/macos_window_app_bar.dart';
import 'package:roola/ui/explorer/explorer_sidebar.dart';
import 'package:roola/ui/notepad/notepad_panel.dart';
import 'package:roola/ui/workspace/pane_widget.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:roola/ui/workspace/workspace_split.dart';

/// Roola のメイン画面（`/explorer` ルートの中身）。
///
/// ウィンドウ AppBar + サイドバー + 3 ペインタブ式ワークスペース（ADR-0026）。
/// 戻る / 進むはエクスプローラタブのペインヘッダへ移設したため、ここの
/// AppBar には置かない。
///
/// ノートパッド（ADR-0036）の開閉はワークスペース内に閉じた一時的な
/// UI 状態のため、Provider ではなく Hook のローカル状態で持つ。
class WorkspacePage extends HookWidget {
  const WorkspacePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notepadOpen = useState(false);

    return Scaffold(
      appBar: MacosWindowAppBar(
        bottom: const AppBarDivider(),
        actions: [
          IconButton(
            icon: const Icon(Icons.sticky_note_2_outlined),
            tooltip: l10n.notepadButtonTooltip,
            isSelected: notepadOpen.value,
            onPressed: () => notepadOpen.value = !notepadOpen.value,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.settingsButtonTooltip,
            onPressed: () => const SettingsRoute().push<void>(context),
          ),
        ],
      ),
      body: Row(
        children: [
          const ExplorerSidebar(),
          Expanded(
            child: Stack(
              children: [
                const _WorkspaceArea(),
                if (notepadOpen.value)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: NotepadPanel(
                      onClose: () => notepadOpen.value = false,
                    ),
                  ),
              ],
            ),
          ),
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
