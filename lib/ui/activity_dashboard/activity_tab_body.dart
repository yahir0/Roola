import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/activity_meter_palette.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/activity_dashboard/activity_dashboard_settings.dart';
import 'package:roola/data/activity_dashboard/activity_dashboard_settings_repository_impl.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/ui/activity_dashboard/activity_dashboard_state.dart';
import 'package:roola/ui/activity_dashboard/activity_dashboard_view_model.dart';
import 'package:roola/ui/activity_dashboard/activity_format.dart';
import 'package:roola/ui/activity_dashboard/dial_meter.dart';
import 'package:roola/ui/activity_dashboard/level_meter.dart';
import 'package:roola/ui/activity_dashboard/meter_animator.dart';
import 'package:roola/ui/activity_dashboard/meter_specs.dart';
import 'package:roola/ui/activity_dashboard/meter_text.dart';
import 'package:roola/ui/activity_dashboard/race_cluster.dart';
import 'package:roola/ui/common/polaris_display_panel.dart';
import 'package:roola/ui/common/polaris_toggle.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';

/// アクティビティタブの body（ADR-0067）。
///
/// ツールバー（Polaris）と、メーターを描くディスプレイパネルからなる。メーター
/// 描画領域だけは Polaris の規定を適用しない（ADR-0068）。
///
/// ペインの非アクティブタブも `IndexedStack` で mount されたまま残るため、自タブが
/// 所属ペインのアクティブタブである間だけ ViewModel を watch してポーリングさせる
/// （design D4）。
class ActivityTabBody extends ConsumerWidget {
  const ActivityTabBody({required this.tabId, super.key});

  final String tabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = ref.watch(
      workspaceProvider.select((layout) => _isActiveTab(layout, tabId)),
    );
    final settings =
        ref.watch(activityDashboardSettingsProvider).value ??
        ActivityDashboardSettings.defaults();
    final tokens = PolarisTokens.of(context);
    return ColoredBox(
      color: tokens.bg,
      child: Column(
        children: [
          _Toolbar(settings: settings, isActive: isActive),
          Expanded(
            child: PolarisDisplayPanel(
              child: ColoredBox(
                color: ActivityMeterPalette.of(context).stage,
                child: isActive
                    ? _LiveMeters(settings: settings)
                    : const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
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

/// 表示モード・TACHO スタイル・全コア表示の切替（Polaris のトグル）。
class _Toolbar extends ConsumerWidget {
  const _Toolbar({required this.settings, required this.isActive});

  final ActivityDashboardSettings settings;

  /// 非アクティブの間は ViewModel を watch しない（watch するとポーリングが
  /// 続いてしまう）。
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(activityDashboardSettingsProvider.notifier);
    final hasPerCore =
        !isActive ||
        ref.watch(
          activityDashboardViewModelProvider.select((s) => s.hasPerCore),
        );
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: PolarisTokens.space2),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            PolarisToggle<ActivityDisplayMode>(
              segments: const [
                PolarisToggleSegment(
                  value: ActivityDisplayMode.level,
                  label: 'LEVEL',
                ),
                PolarisToggleSegment(
                  value: ActivityDisplayMode.tacho,
                  label: 'TACHO',
                ),
              ],
              selected: settings.mode,
              onChanged: notifier.setMode,
            ),
            if (settings.mode == ActivityDisplayMode.tacho) ...[
              const SizedBox(width: PolarisTokens.space3),
              PolarisToggle<TachoStyle>(
                segments: const [
                  PolarisToggleSegment(
                    value: TachoStyle.classic,
                    label: 'CLASSIC',
                  ),
                  PolarisToggleSegment(
                    value: TachoStyle.digital,
                    label: 'DIGITAL',
                  ),
                  PolarisToggleSegment(value: TachoStyle.race, label: 'RACE'),
                ],
                selected: settings.tachoStyle,
                onChanged: notifier.setTachoStyle,
              ),
            ],
            const SizedBox(width: PolarisTokens.space3),
            PolarisToggle<bool>(
              segments: const [
                PolarisToggleSegment(value: false, label: 'CPU 全体'),
                PolarisToggleSegment(value: true, label: '全コア'),
              ],
              selected: settings.showAllCores && hasPerCore,
              // コア別の値が取れない環境では操作できない（spec）。
              onChanged: hasPerCore
                  ? (v) => notifier.setShowAllCores(value: v)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// ViewModel を watch してメーターを描く部分。アクティブな間だけ mount される。
class _LiveMeters extends HookConsumerWidget {
  const _LiveMeters({required this.settings});

  final ActivityDashboardSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activityDashboardViewModelProvider);
    final animator = useMemoized(MeterAnimator.new);
    final textCache = useMemoized(MeterTextCache.new);
    useEffect(
      () => () {
        animator.dispose();
        textCache.dispose();
      },
      const [],
    );

    // Ticker で毎フレーム dt を計算し、アニメータを進める（design D5）。
    final vsync = useSingleTickerProvider();
    useEffect(() {
      var last = Duration.zero;
      final ticker = vsync.createTicker((elapsed) {
        final dt = (elapsed - last).inMicroseconds / 1e6;
        last = elapsed;
        animator.tick(dt);
      });
      ticker.start();
      return ticker.dispose;
    }, [vsync]);

    animator
      ..reduceMotion = MediaQuery.of(context).disableAnimations
      ..setTargets(meterTargets(state));

    // TACHO に切り替えた直後・スタイル変更直後はオープニング演出。
    final isTacho = settings.mode == ActivityDisplayMode.tacho;
    useEffect(() {
      if (isTacho) {
        animator.startSweep();
      }
      return null;
    }, [isTacho, settings.tachoStyle]);

    final allCores = settings.showAllCores && state.hasPerCore;
    if (!isTacho) {
      animator.continuous = false;
      return LevelBoard(
        groups: levelGroups(state, allCores: allCores),
        animator: animator,
        textCache: textCache,
      );
    }
    if (settings.tachoStyle == TachoStyle.race) {
      // シフトライトの全灯点滅は時間で変わるため、その間は毎フレーム描く。
      animator.continuous = (state.cpu ?? 0) > 0.95;
      return RaceBoard(
        readouts: _raceReadouts(state),
        coreCount: allCores ? state.cores.length : 0,
        animator: animator,
        textCache: textCache,
      );
    }
    animator.continuous = false;
    return DialBoard(
      style: settings.tachoStyle,
      main: mainDials(state),
      sub: subDials(state),
      cores: allCores ? coreDials(state) : const [],
      animator: animator,
      textCache: textCache,
    );
  }

  static RaceReadouts _raceReadouts(ActivityDashboardState s) {
    final now = DateTime.now();
    final hour12 = (now.hour + 11) % 12 + 1;
    final swap = s.swap;
    return RaceReadouts(
      cpuNumber: '${((s.cpu ?? 0) * 100).round()}',
      memoryText: '${formatGigabytes(s.memoryUsedBytes)} GB',
      swapText: swap == null ? null : formatPercent(swap),
      loadText: s.loadAverage?.first.toStringAsFixed(2),
      rxText: s.netRxRate == null ? null : formatRateShort(s.netRxRate!),
      txText: s.netTxRate == null ? null : formatRateShort(s.netTxRate!),
      readText: s.diskReadRate == null
          ? null
          : formatRateShort(s.diskReadRate!),
      writeText: s.diskWriteRate == null
          ? null
          : formatRateShort(s.diskWriteRate!),
      uptimeText: s.uptimeSeconds == null
          ? null
          : formatUptime(s.uptimeSeconds!),
      clock: '$hour12:${now.minute.toString().padLeft(2, '0')}',
      meridiem: now.hour < 12 ? 'AM' : 'PM',
    );
  }
}
