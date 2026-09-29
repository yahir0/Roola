import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/activity_dashboard/activity_dashboard_settings.dart';
import 'package:roola/data/activity_dashboard/activity_dashboard_settings_repository.dart';
import 'package:roola/data/activity_dashboard/activity_dashboard_settings_repository_impl.dart';
import 'package:roola/data/activity_metrics/process_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics_repository.dart';
import 'package:roola/data/activity_metrics/system_snapshot.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/activity_dashboard/activity_tab_body.dart';
import 'package:roola/ui/activity_dashboard/dial_meter.dart';
import 'package:roola/ui/activity_dashboard/level_meter.dart';
import 'package:roola/ui/activity_dashboard/race_cluster.dart';
import 'package:roola/ui/workspace/workspace_seed.dart';

class _FakeMetrics implements SystemMetricsRepository {
  _FakeMetrics({this.full = true});

  /// false なら I/O・ロードアベレージ・コア別 tick を返さない環境を模す。
  final bool full;
  int calls = 0;

  @override
  Future<SystemMetrics> fetchSystemMetrics() async => SystemMetrics.zero;

  @override
  Future<List<ProcessMetrics>> fetchProcesses() async => const [];

  @override
  Future<SystemSnapshot?> fetchSnapshot() async {
    final step = ++calls;
    if (!full) {
      return const SystemSnapshot(memoryUsedBytes: 4, memoryTotalBytes: 16);
    }
    return SystemSnapshot(
      cpuTicks: [
        [step * 30, 0, step * 70, 0],
        [step * 10, 0, step * 90, 0],
      ],
      memoryUsedBytes: 4,
      memoryTotalBytes: 16,
      swapUsedBytes: 1,
      swapTotalBytes: 4,
      diskReadBytes: step * 1000000,
      diskWriteBytes: step * 1000,
      netInterfaces: [
        NetInterfaceCounters(name: 'en0', rxBytes: step * 50000, txBytes: 0),
      ],
      loadAverage: const [1, 2, 3],
      uptimeSeconds: 3600,
    );
  }
}

class _MemorySettings implements ActivityDashboardSettingsRepository {
  ActivityDashboardSettings saved = ActivityDashboardSettings.defaults();

  @override
  Future<ActivityDashboardSettings> load() async => saved;

  @override
  Future<void> save(ActivityDashboardSettings settings) async =>
      saved = settings;
}

Finder _painters<T>() =>
    find.byWidgetPredicate((w) => w is CustomPaint && w.painter is T);

Future<void> _pump(
  WidgetTester tester, {
  required _FakeMetrics metrics,
  _MemorySettings? settings,
  bool active = true,
}) async {
  tester.view.physicalSize = const Size(1600, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final layout = WorkspaceLayout(
    topLeft: PaneSlot(
      tabs: [
        const WorkspaceTab.activity(id: 'act'),
        const WorkspaceTab.explorer(id: 'exp', currentPath: '/'),
      ],
      activeIndex: active ? 0 : 1,
    ),
    topRight: PaneSlot.empty,
    bottom: PaneSlot.empty,
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        workspaceInitialLayoutProvider.overrideWithValue(layout),
        systemMetricsRepositoryProvider.overrideWithValue(metrics),
        activityDashboardSettingsRepositoryProvider.overrideWithValue(
          settings ?? _MemorySettings(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.polaris(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ja'),
        home: const Scaffold(body: ActivityTabBody(tabId: 'act')),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 600));
}

/// ポーリングのタイマーと Ticker を片付ける。
Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('既定は LEVEL で、全項目のグループが並ぶ', (tester) async {
    await _pump(tester, metrics: _FakeMetrics());

    // CPU / MEMORY / NETWORK / DISK / LOAD
    expect(_painters<LevelGroupPainter>(), findsNWidgets(5));
    await _dispose(tester);
  });

  testWidgets('TACHO の各スタイルに切り替えると対応する描画になり、設定が保存される', (tester) async {
    final settings = _MemorySettings();
    await _pump(tester, metrics: _FakeMetrics(), settings: settings);

    await tester.tap(find.text('TACHO'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_painters<DialPainter>(), findsWidgets);
    expect(_painters<LevelGroupPainter>(), findsNothing);

    await tester.tap(find.text('RACE'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_painters<RaceClusterPainter>(), findsOneWidget);
    expect(_painters<ShiftLightsPainter>(), findsOneWidget);
    expect(settings.saved.mode, ActivityDisplayMode.tacho);
    expect(settings.saved.tachoStyle, TachoStyle.race);
    await _dispose(tester);
  });

  testWidgets('全コア表示で LEVEL の CPU がコア数ぶんのチャンネルになる', (tester) async {
    final settings = _MemorySettings()
      ..saved = const ActivityDashboardSettings(showAllCores: true);
    await _pump(tester, metrics: _FakeMetrics(), settings: settings);

    final cpuGroup = tester
        .widgetList<CustomPaint>(_painters<LevelGroupPainter>())
        .map((w) => w.painter! as LevelGroupPainter)
        .firstWhere((p) => p.group.title == 'CPU');
    expect(cpuGroup.group.channels.map((c) => c.name), ['C1', 'C2']);
    await _dispose(tester);
  });

  testWidgets('取得できない項目のメーターは出ず、全コア表示は操作できない', (tester) async {
    final settings = _MemorySettings();
    await _pump(tester, metrics: _FakeMetrics(full: false), settings: settings);

    // CPU / MEMORY のみ。
    expect(_painters<LevelGroupPainter>(), findsNWidgets(2));
    await tester.tap(find.text('全コア'));
    await tester.pump();
    expect(settings.saved.showAllCores, isFalse);
    await _dispose(tester);
  });

  testWidgets('所属ペインで非アクティブならポーリングしない', (tester) async {
    final metrics = _FakeMetrics();
    await _pump(tester, metrics: metrics, active: false);

    expect(metrics.calls, 0);
    expect(_painters<LevelGroupPainter>(), findsNothing);
    await _dispose(tester);
  });
}
