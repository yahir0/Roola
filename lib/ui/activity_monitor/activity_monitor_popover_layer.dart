import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/activity_metrics/system_metrics_repository.dart';
import 'package:roola/ui/activity_monitor/activity_monitor_popover.dart';
import 'package:roola/ui/activity_monitor/activity_monitor_view_model.dart';

/// アクティビティモニタのポップオーバーを描くレイヤー（ADR-0039 D6）。
///
/// トップバーの [ActivityMonitorBar] とは別に、ワークスペース body の
/// `Stack` 直下へ置く。ノートパッド（ADR-0036）と同じ構成。
///
/// 開閉状態は [activityPopoverProvider] が持ち、[ActivityMonitorBar] の
/// クリックと連動する。
///
/// 外側クリックでの自動クローズは [TapRegion] で実装する。バリアを敷く
/// 方式だとパネル領域がアクティビティモニタバー側を覆えず（覆うと開いた
/// まま別モニタに切り替えられない）、body 内に置いたバリアは body 全面
/// 限定になる。TapRegion なら groupId に含めたウィジェット内側を「内」と
/// 判定し、それ以外（モニタバー以外のトップバー / Sidebar / AppBar 等）で
/// クリックが起きると閉じる。
class ActivityMonitorPopoverLayer extends ConsumerWidget {
  const ActivityMonitorPopoverLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(activityPopoverProvider);
    if (open == ActivityPopover.none) {
      return const SizedBox.shrink();
    }
    final sortKey = switch (open) {
      ActivityPopover.cpu => ProcessSortKey.cpu,
      ActivityPopover.memory => ProcessSortKey.memory,
      ActivityPopover.disk => ProcessSortKey.disk,
      ActivityPopover.network => ProcessSortKey.network,
      // 上の `none` ガードで除外済み。フォールバックで cpu を返す。
      ActivityPopover.none => ProcessSortKey.cpu,
    };
    final notifier = ref.read(activityPopoverProvider.notifier);

    // 子が Positioned 1 つだけだと Stack 自身が 0×0 に縮むため、`fit` で
    // 親いっぱいに広げる。Positioned 配置の基準を body 領域に揃える。
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: PolarisTokens.space1,
          right: PolarisTokens.space2,
          // モニタバー側のゲージは [activityPopoverGroupId] の TapRegion
          // に含まれており、ゲージをクリックしても onTapOutside は発火し
          // ない（ゲージ自身の toggle が走る）。
          child: TapRegion(
            groupId: activityPopoverGroupId,
            onTapOutside: (_) => notifier.close(),
            child: ActivityMonitorPopover(sortKey: sortKey),
          ),
        ),
      ],
    );
  }
}

/// アクティビティモニタのポップオーバーとモニタバーを束ねる [TapRegion]
/// の groupId。ポップオーバー本体とゲージボタンを同じグループに入れて、
/// 「グループ外クリックで閉じる」を実装する（ADR-0039 D6）。
const String activityPopoverGroupId = 'activity-monitor-popover';
