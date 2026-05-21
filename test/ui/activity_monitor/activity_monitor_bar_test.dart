import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/activity_metrics/process_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics_repository.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/activity_monitor/activity_monitor_bar.dart';
import 'package:roola/ui/activity_monitor/activity_monitor_popover_layer.dart';

/// ネイティブ呼び出しを伴わない fake。固定のメトリクスとプロセス一覧を返す。
class _FakeRepository extends SystemMetricsRepository {
  const _FakeRepository();

  @override
  Future<SystemMetrics> fetchSystemMetrics() async => const SystemMetrics(
    cpuPercent: 30,
    memoryUsedBytes: 2,
    memoryTotalBytes: 4,
    diskReadBytes: 0,
    diskWrittenBytes: 0,
    networkInBytes: 0,
    networkOutBytes: 0,
  );

  @override
  Future<List<ProcessMetrics>> fetchProcesses(ProcessSortKey sortKey) async {
    switch (sortKey) {
      case ProcessSortKey.cpu:
      case ProcessSortKey.memory:
        return const [
          ProcessMetrics(
            pid: 1,
            name: 'Roola',
            cpuPercent: 12,
            memoryBytes: 200,
          ),
          ProcessMetrics(
            pid: 2,
            name: 'kernel_task',
            cpuPercent: 3,
            memoryBytes: 50,
          ),
        ];
      case ProcessSortKey.disk:
        return const [
          ProcessMetrics(
            pid: 10,
            name: 'fseventsd',
            ioBytesPerSec: 1024 * 1024,
          ),
        ];
      case ProcessSortKey.network:
        return const [
          ProcessMetrics(pid: 100, name: 'Chrome', ioBytesPerSec: 2048),
        ];
    }
  }
}

Widget _app() => ProviderScope(
  overrides: [
    systemMetricsRepositoryProvider.overrideWithValue(const _FakeRepository()),
  ],
  child: const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: Locale('en'),
    // 実機ではバーはトップバー、ポップオーバーは body 側に置かれる。
    // テストでは同じ Stack に重ね、バーをポップオーバーレイヤーより上に
    // 置いて「トップバーがバリアに覆われない」配置を再現する。
    home: Scaffold(
      body: Stack(
        children: [
          ActivityMonitorPopoverLayer(),
          Align(alignment: Alignment.topRight, child: ActivityMonitorBar()),
        ],
      ),
    ),
  ),
);

/// 0ms アニメーション・非同期 provider の解決ぶんだけ確定的に進める。
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 10));
  }
}

void main() {
  testWidgets('CPU / メモリ / ディスク / ネットワークの 4 モニタが表示される', (tester) async {
    await tester.pumpWidget(_app());
    await _settle(tester);

    expect(find.byIcon(Icons.speed), findsOneWidget);
    expect(find.byIcon(Icons.memory), findsOneWidget);
    expect(find.byIcon(Icons.storage), findsOneWidget);
    expect(find.byIcon(Icons.swap_vert), findsOneWidget);
    expect(find.text('Top processes — CPU'), findsNothing);
  });

  testWidgets('CPU クリックで上位プロセスのポップオーバーが開く', (tester) async {
    await tester.pumpWidget(_app());
    await _settle(tester);

    await tester.tap(find.byIcon(Icons.speed));
    await _settle(tester);

    expect(find.text('Top processes — CPU'), findsOneWidget);
    expect(find.text('Roola'), findsOneWidget);
    expect(find.text('kernel_task'), findsOneWidget);
  });

  testWidgets('ディスククリックでディスクポップオーバーが開く', (tester) async {
    await tester.pumpWidget(_app());
    await _settle(tester);

    await tester.tap(find.byIcon(Icons.storage));
    await _settle(tester);

    expect(find.text('Top processes — Disk I/O'), findsOneWidget);
    expect(find.text('fseventsd'), findsOneWidget);
  });

  testWidgets('ネットワーククリックでネットワークポップオーバーが開く', (tester) async {
    await tester.pumpWidget(_app());
    await _settle(tester);

    await tester.tap(find.byIcon(Icons.swap_vert));
    await _settle(tester);

    expect(find.text('Top processes — Network I/O'), findsOneWidget);
    expect(find.text('Chrome'), findsOneWidget);
  });

  testWidgets('同じモニタの再クリックでポップオーバーが閉じる', (tester) async {
    await tester.pumpWidget(_app());
    await _settle(tester);

    await tester.tap(find.byIcon(Icons.speed));
    await _settle(tester);
    expect(find.text('Top processes — CPU'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.speed));
    await _settle(tester);
    expect(find.text('Top processes — CPU'), findsNothing);
  });

  testWidgets('4 種のポップオーバーは排他で切り替わる', (tester) async {
    await tester.pumpWidget(_app());
    await _settle(tester);

    await tester.tap(find.byIcon(Icons.speed));
    await _settle(tester);
    expect(find.text('Top processes — CPU'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.memory));
    await _settle(tester);
    expect(find.text('Top processes — CPU'), findsNothing);
    expect(find.text('Top processes — Memory'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.storage));
    await _settle(tester);
    expect(find.text('Top processes — Memory'), findsNothing);
    expect(find.text('Top processes — Disk I/O'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.swap_vert));
    await _settle(tester);
    expect(find.text('Top processes — Disk I/O'), findsNothing);
    expect(find.text('Top processes — Network I/O'), findsOneWidget);
  });

  testWidgets('ポップオーバーの外側クリックで閉じる', (tester) async {
    await tester.pumpWidget(_app());
    await _settle(tester);

    await tester.tap(find.byIcon(Icons.speed));
    await _settle(tester);
    expect(find.text('Top processes — CPU'), findsOneWidget);

    // モニタからもパネルからも外れた空き領域をクリックする。
    await tester.tapAt(const Offset(100, 400));
    await _settle(tester);
    expect(find.text('Top processes — CPU'), findsNothing);
  });
}
