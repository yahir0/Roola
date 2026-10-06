import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:roola_activity/ui/activity_dashboard/activity_dashboard_view.dart';

/// アクティビティタブの body（ADR-0067）。
///
/// 計器盤そのものは共通パッケージの [ActivityDashboardView]（ADR-0069）。ここでは
/// ワークスペースとの連携だけを持つ。ペインの非アクティブタブも `IndexedStack`
/// で mount されたまま残るため、自タブが所属ペインのアクティブタブである間だけ
/// 計器盤をアクティブにしてポーリングさせる（design D4）。
class ActivityTabBody extends ConsumerWidget {
  const ActivityTabBody({required this.tabId, super.key});

  final String tabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = ref.watch(
      workspaceProvider.select((layout) => _isActiveTab(layout, tabId)),
    );
    return ActivityDashboardView(isActive: isActive);
  }

  static bool _isActiveTab(WorkspaceLayout layout, String tabId) {
    for (final slotId in PaneSlotId.values) {
      final slot = layout.slot(slotId);
      if (slot.tabs.isEmpty) {
        continue;
      }
      if (slot.tabs.any((t) => t.id == tabId)) {
        return slot.tabs[slot.safeActiveIndex].id == tabId;
      }
    }
    return false;
  }
}
