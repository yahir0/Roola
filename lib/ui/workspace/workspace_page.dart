import 'dart:io';

import 'package:flutter/material.dart';
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
import 'package:roola/ui/common/windows_top_menu_bar.dart';
import 'package:roola/ui/common/windows_window_controls.dart';
import 'package:roola/ui/explorer/explorer_sidebar.dart';
import 'package:roola/ui/workspace/pane_widget.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:roola/ui/workspace/workspace_split.dart';

/// Roola のメイン画面（`/explorer` ルートの中身）。
///
/// ウィンドウ AppBar + サイドバー + タブ式ワークスペース（ADR-0026 / ADR-0068。
/// 既定 3 ペイン・ユーザー操作で最大 4 ペイン）。
/// 戻る / 進むはエクスプローラタブのペインヘッダへ移設したため、ここの
/// AppBar には置かない。
///
/// ノートパッド（ADR-0036）の開閉はワークスペース内に閉じた一時的な
/// UI 状態のため、Provider ではなく Hook のローカル状態で持つ。
class WorkspacePage extends ConsumerWidget {
  const WorkspacePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: MacosWindowAppBar(
        bottom: const AppBarDivider(),
        // macOS: ネイティブメニューバーにアプリ名が常時出ており、ウィンドウ内へ
        //   自社名/ロゴを再掲しないのが macOS の作法のためタイトルは持たない
        //   （ADR-0064 / ADR-0038 D9 を一部 Supersede）。空いた領域は
        //   `DragToMoveArea` のドラッグ移動領域として活きる。
        // Windows: ロゴ + インラインメニューバー（ADR-0058）。
        titleSpacing: 4,
        title: Platform.isWindows ? const WindowsTopMenuBar() : null,
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
              onPressed: () => ref
                  .read(workspaceProvider.notifier)
                  .addNotepadTab(PaneSlotId.bottomLeft),
            ),
          ),
          ExcludeFocus(
            child: IconButton(
              icon: const Icon(Icons.settings),
              tooltip: l10n.settingsButtonTooltip,
              onPressed: () => const SettingsRoute().push<void>(context),
            ),
          ),
          // Windows 専用: 最小化 / 最大化 / 閉じるボタン（ADR-0058）。
          if (Platform.isWindows) ...[
            const SizedBox(width: PolarisTokens.space1),
            const WindowsWindowControls(),
          ],
        ],
      ),
      body: const Row(
        children: [
          ExplorerSidebar(),
          Expanded(
            child: Stack(
              children: [
                _WorkspaceArea(),
                // アクティビティモニタのポップオーバー（ADR-0039）。閉じて
                // いる間は SizedBox.shrink。
                ActivityMonitorPopoverLayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 崩し再フロー結果に応じて 4 / 3 / 2 / 単一ペインを描画する領域。
///
/// 上段 row・下段 row を独立に組み立てる（ADR-0068）。row 内が 2 つなら左右
/// スプリッタ、1 つならそのまま全幅、両 row にコンテンツがあれば上下
/// スプリッタで束ねる。単一ペインになればスプリッタは 1 本も現れない。
class _WorkspaceArea extends ConsumerWidget {
  const _WorkspaceArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(workspaceProvider);
    final notifier = ref.read(workspaceProvider.notifier);
    final resolved = resolveWorkspaceLayout(layout);

    Widget pane(PaneSlotId slotId) =>
        PaneWidget(key: ValueKey(slotId), slotId: slotId);

    /// row 内のスロットを横に並べる。2 つなら左右スプリッタ、1 つならそのまま。
    Widget row(
      List<PaneSlotId> slots, {
      required double ratio,
      required ValueChanged<double> onRatioChanged,
    }) {
      if (slots.length == 1) {
        return pane(slots.first);
      }
      return WorkspaceSplit(
        axis: Axis.horizontal,
        ratio: ratio,
        onRatioChanged: onRatioChanged,
        first: pane(slots[0]),
        second: pane(slots[1]),
      );
    }

    final top = resolved.topSlots.isEmpty
        ? null
        : row(
            resolved.topSlots,
            ratio: layout.leftRatio,
            onRatioChanged: notifier.setLeftRatio,
          );
    final bottom = resolved.bottomSlots.isEmpty
        ? null
        : row(
            resolved.bottomSlots,
            ratio: layout.bottomLeftRatio,
            onRatioChanged: notifier.setBottomLeftRatio,
          );

    if (top == null) {
      return bottom!;
    }
    if (bottom == null) {
      return top;
    }
    return WorkspaceSplit(
      axis: Axis.vertical,
      ratio: layout.topRatio,
      onRatioChanged: notifier.setTopRatio,
      first: top,
      second: bottom,
    );
  }
}
