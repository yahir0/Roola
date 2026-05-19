import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/activity_metrics/system_metrics_repository.dart';
import 'package:roola/ui/activity_monitor/activity_monitor_popover.dart';
import 'package:roola/ui/activity_monitor/activity_monitor_view_model.dart';

/// アクティビティモニタのポップオーバーを描くレイヤー（ADR-0039 D6）。
///
/// トップバーの [ActivityMonitorBar] とは別に、ワークスペース body の
/// `Stack` 直下へ置く。ノートパッド（ADR-0036）と同じ構成。body 側に置く
/// ことで、外側クリックを受ける透明バリアがトップバーを覆わず、ポップ
/// オーバーを開いたまま別モニタへ切り替えられる。
///
/// 開閉状態は [activityPopoverProvider] が持ち、[ActivityMonitorBar] の
/// クリックと連動する。
class ActivityMonitorPopoverLayer extends ConsumerWidget {
  const ActivityMonitorPopoverLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(activityPopoverProvider);
    if (open == ActivityPopover.none) {
      return const SizedBox.shrink();
    }
    final sortKey = open == ActivityPopover.cpu
        ? ProcessSortKey.cpu
        : ProcessSortKey.memory;
    final notifier = ref.read(activityPopoverProvider.notifier);

    return Stack(
      children: [
        // 外側クリックで閉じる透明バリア。body のみを覆い、トップバーの
        // モニタは覆わないため、開いたまま別モニタへ切り替えられる。
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: notifier.close,
          ),
        ),
        // モニタ直下（body 右上）にパネルを出す。
        Positioned(
          top: PolarisTokens.space1,
          right: PolarisTokens.space2,
          // パネル内クリックはバリアへ透過させない。
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: ActivityMonitorPopover(sortKey: sortKey),
          ),
        ),
      ],
    );
  }
}
