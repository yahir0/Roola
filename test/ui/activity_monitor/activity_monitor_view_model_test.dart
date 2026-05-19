import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/activity_metrics/process_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics_repository.dart';
import 'package:roola/ui/activity_monitor/activity_monitor_view_model.dart';

/// ネイティブ呼び出しを伴わない fake。`fetchSystemMetrics` の挙動は
/// テストごとに [onFetch] で差し替える。
class _FakeRepository extends SystemMetricsRepository {
  _FakeRepository({this.onFetch, this.processes = const []});

  final Future<SystemMetrics> Function()? onFetch;
  final List<ProcessMetrics> processes;

  @override
  Future<SystemMetrics> fetchSystemMetrics() =>
      onFetch?.call() ?? Future.value(SystemMetrics.zero);

  @override
  Future<List<ProcessMetrics>> fetchProcesses() async => processes;
}

ProcessMetrics _proc(String name, double cpu, int memory) => ProcessMetrics(
  pid: name.hashCode,
  name: name,
  cpuPercent: cpu,
  memoryBytes: memory,
);

void main() {
  test('build 後の初回ポーリングで state が最新値に更新される', () async {
    final container = ProviderContainer(
      overrides: [
        systemMetricsRepositoryProvider.overrideWithValue(
          _FakeRepository(
            onFetch: () async => const SystemMetrics(
              cpuPercent: 50,
              memoryUsedBytes: 2,
              memoryTotalBytes: 4,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    // build() の戻り値は zero、_poll は非同期に走る。
    expect(container.read(activityMonitorProvider), SystemMetrics.zero);

    await Future<void>.delayed(Duration.zero);

    expect(container.read(activityMonitorProvider).cpuPercent, 50);
  });

  test('ポーリングが失敗しても state を保ちクラッシュしない', () async {
    final container = ProviderContainer(
      overrides: [
        systemMetricsRepositoryProvider.overrideWithValue(
          _FakeRepository(onFetch: () async => throw Exception('native fail')),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(activityMonitorProvider);
    await Future<void>.delayed(Duration.zero);

    // 取得失敗時は直近値（初期 zero）を維持する。
    expect(container.read(activityMonitorProvider), SystemMetrics.zero);
  });

  test('上位プロセスは CPU 降順 / メモリ降順で並ぶ', () async {
    final container = ProviderContainer(
      overrides: [
        systemMetricsRepositoryProvider.overrideWithValue(
          _FakeRepository(
            processes: [
              _proc('a', 5, 100),
              _proc('b', 50, 10),
              _proc('c', 20, 999),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final byCpu = await container.read(
      activityTopProcessesProvider(ProcessSortKey.cpu).future,
    );
    expect(byCpu.map((p) => p.name), ['b', 'c', 'a']);

    final byMemory = await container.read(
      activityTopProcessesProvider(ProcessSortKey.memory).future,
    );
    expect(byMemory.map((p) => p.name), ['c', 'a', 'b']);
  });

  test('上位プロセスは activityTopProcessLimit 件に絞られる', () async {
    final many = List.generate(
      activityTopProcessLimit + 5,
      (i) => _proc('p$i', i.toDouble(), i),
    );
    final container = ProviderContainer(
      overrides: [
        systemMetricsRepositoryProvider.overrideWithValue(
          _FakeRepository(processes: many),
        ),
      ],
    );
    addTearDown(container.dispose);

    final list = await container.read(
      activityTopProcessesProvider(ProcessSortKey.cpu).future,
    );
    expect(list, hasLength(activityTopProcessLimit));
  });
}
