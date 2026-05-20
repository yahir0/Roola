import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/router.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_layout_mode.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/activity_monitor/activity_monitor_bar.dart';
import 'package:roola/ui/activity_monitor/activity_monitor_popover_layer.dart';
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
        // 信号灯領域の直後にワードマークを詰め、トップバー中央の空白を埋めて
        // 右端のアクションと釣り合わせる（ADR-0038 D8/D9）。
        titleSpacing: 4,
        title: const _AppWordmark(),
        actions: [
          // アクティビティモニタはメモパッド・設定アイコンの左に置く
          // （ADR-0039）。
          const ActivityMonitorBar(),
          const SizedBox(width: PolarisTokens.space2),
          // クリック後やパネル閉じ時に IconButton が keyboard focus を握り、
          // 灰色のフォーカス枠が残って「勝手に選択されている」ように見える
          // のを防ぐ。これらのアクションはマウス操作 + ショートカット
          // （ADR-0033）で叩く前提なので、Tab 遷移の対象から外す。
          ExcludeFocus(
            child: IconButton(
              icon: const Icon(Icons.sticky_note_2_outlined),
              tooltip: l10n.notepadButtonTooltip,
              isSelected: notepadOpen.value,
              onPressed: () => notepadOpen.value = !notepadOpen.value,
            ),
          ),
          ExcludeFocus(
            child: IconButton(
              icon: const Icon(Icons.settings),
              tooltip: l10n.settingsButtonTooltip,
              onPressed: () => const SettingsRoute().push<void>(context),
            ),
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
                // アクティビティモニタのポップオーバー（ADR-0039）。閉じて
                // いる間は SizedBox.shrink。
                const ActivityMonitorPopoverLayer(),
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

/// トップバー左端に置くロゴワードマーク（ADR-0038 D9）。信号灯領域の直後に
/// 置き、トップバー中央の空白を埋めて右端のアクションと釣り合わせる。
class _AppWordmark extends StatelessWidget {
  const _AppWordmark();

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return Text('ROOLA', style: tokens.wordmark.copyWith(color: tokens.text));
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
