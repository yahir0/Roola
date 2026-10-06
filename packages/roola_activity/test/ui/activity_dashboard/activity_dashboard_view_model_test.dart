import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola_activity/data/activity_metrics/process_metrics.dart';
import 'package:roola_activity/data/activity_metrics/system_metrics.dart';
import 'package:roola_activity/data/activity_metrics/system_metrics_repository.dart';
import 'package:roola_activity/data/activity_metrics/system_snapshot.dart';
import 'package:roola_activity/ui/activity_dashboard/activity_dashboard_view_model.dart';

class _FakeRepository implements SystemMetricsRepository {
  _FakeRepository(this.onSnapshot);

  final Future<SystemSnapshot?> Function(int call) onSnapshot;
  int calls = 0;

  @override
  Future<SystemMetrics> fetchSystemMetrics() async => SystemMetrics.zero;

  @override
  Future<List<ProcessMetrics>> fetchProcesses() async => const [];

  @override
  Future<SystemSnapshot?> fetchSnapshot() => onSnapshot(calls++);
}

SystemSnapshot _snapshot(int step) => SystemSnapshot(
  cpuTicks: [
    [step * 25, 0, step * 75, 0],
  ],
  memoryUsedBytes: 4,
  memoryTotalBytes: 16,
  diskReadBytes: step * 1000,
  diskWriteBytes: 0,
  netInterfaces: [
    NetInterfaceCounters(name: 'en0', rxBytes: step * 500, txBytes: 0),
  ],
  loadAverage: const [1, 2, 3],
);

ProviderContainer _container(SystemMetricsRepository repo) {
  final container = ProviderContainer(
    overrides: [systemMetricsRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  // autoDispose のため listen して生かしておく（タブが watch している状態）。
  container.listen(activityDashboardViewModelProvider, (_, _) {});
  return container;
}

void main() {
  test('初回サンプルではメモリだけ出て CPU は差分が取れるまで null', () async {
    final container = _container(
      _FakeRepository((call) async => _snapshot(call)),
    );

    await Future<void>.delayed(Duration.zero);
    final state = container.read(activityDashboardViewModelProvider);

    expect(state.cpu, isNull);
    expect(state.memory, 0.25);
    expect(state.coreCount, 1);
    expect(state.loadAverage, [1, 2, 3]);
  });

  test('2 回目以降のポーリングで CPU とレートが算出される', () async {
    final container = _container(
      _FakeRepository((call) async => _snapshot(call)),
    );

    await Future<void>.delayed(const Duration(milliseconds: 320));
    final state = container.read(activityDashboardViewModelProvider);

    expect(state.cpu, closeTo(0.25, 1e-9));
    expect(state.cores, hasLength(1));
    expect(state.diskReadRate, greaterThan(0));
    expect(state.netRxRate, greaterThan(0));
  });

  test('取得に失敗しても直近の値を保つ', () async {
    final container = _container(
      _FakeRepository((call) async {
        if (call == 0) {
          return _snapshot(1);
        }
        throw Exception('native fail');
      }),
    );

    await Future<void>.delayed(const Duration(milliseconds: 320));
    final state = container.read(activityDashboardViewModelProvider);

    expect(state.memory, 0.25);
  });

  test('取得できない項目は null のまま（Windows のロードアベレージ等）', () async {
    final container = _container(
      _FakeRepository(
        (call) async =>
            const SystemSnapshot(memoryUsedBytes: 1, memoryTotalBytes: 2),
      ),
    );

    await Future<void>.delayed(Duration.zero);
    final state = container.read(activityDashboardViewModelProvider);

    expect(state.loadAverage, isNull);
    expect(state.diskReadRate, isNull);
    expect(state.netRxRate, isNull);
    expect(state.hasPerCore, isFalse);
  });
}
