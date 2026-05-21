import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/activity_metrics/process_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics_repository.dart';
import 'package:roola/data/activity_metrics/system_metrics_snapshot.dart';
import 'package:roola/ui/activity_monitor/activity_monitor_view_model.dart';

/// ネイティブ呼び出しを伴わない fake。`fetchSystemMetrics` / `fetchProcesses`
/// の挙動はテストごとに差し替える。
class _FakeRepository extends SystemMetricsRepository {
  _FakeRepository({this.metricsSequence, this.processesBySort = const {}});

  /// `fetchSystemMetrics` 呼び出しごとに次の値を返すキュー。空になったら最後の
  /// 値を返し続ける。
  final List<SystemMetrics>? metricsSequence;
  final Map<ProcessSortKey, List<ProcessMetrics>> processesBySort;

  int _callCount = 0;

  @override
  Future<SystemMetrics> fetchSystemMetrics() async {
    final seq = metricsSequence;
    if (seq == null || seq.isEmpty) {
      return SystemMetrics.zero;
    }
    final idx = _callCount < seq.length ? _callCount : seq.length - 1;
    _callCount++;
    return seq[idx];
  }

  @override
  Future<List<ProcessMetrics>> fetchProcesses(ProcessSortKey sortKey) async =>
      processesBySort[sortKey] ?? const [];
}

class _ThrowingRepository extends SystemMetricsRepository {
  @override
  Future<SystemMetrics> fetchSystemMetrics() async =>
      throw Exception('native fail');

  @override
  Future<List<ProcessMetrics>> fetchProcesses(ProcessSortKey sortKey) async =>
      const [];
}

ProcessMetrics _proc(
  String name, {
  double cpu = 0,
  int memory = 0,
  int io = 0,
}) => ProcessMetrics(
  pid: name.hashCode,
  name: name,
  cpuPercent: cpu,
  memoryBytes: memory,
  ioBytesPerSec: io,
);

SystemMetrics _metrics({
  double cpu = 0,
  int memUsed = 0,
  int memTotal = 0,
  int diskRead = 0,
  int diskWritten = 0,
  int netIn = 0,
  int netOut = 0,
}) => SystemMetrics(
  cpuPercent: cpu,
  memoryUsedBytes: memUsed,
  memoryTotalBytes: memTotal,
  diskReadBytes: diskRead,
  diskWrittenBytes: diskWritten,
  networkInBytes: netIn,
  networkOutBytes: netOut,
);

void main() {
  test('build 後の初回ポーリングで state が最新値に更新される', () async {
    final container = ProviderContainer(
      overrides: [
        systemMetricsRepositoryProvider.overrideWithValue(
          _FakeRepository(
            metricsSequence: [_metrics(cpu: 50, memUsed: 2, memTotal: 4)],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    // build() の戻り値は zero、_poll は非同期に走る。
    expect(container.read(activityMonitorProvider), SystemMetricsSnapshot.zero);

    await Future<void>.delayed(Duration.zero);

    final snapshot = container.read(activityMonitorProvider);
    expect(snapshot.metrics.cpuPercent, 50);
    // 初回ポーリングは前回値が無いためレートは 0。
    expect(snapshot.diskBytesPerSec, 0);
    expect(snapshot.networkBytesPerSec, 0);
  });

  test('ポーリングが失敗しても state を保ちクラッシュしない', () async {
    final container = ProviderContainer(
      overrides: [
        systemMetricsRepositoryProvider.overrideWithValue(
          _ThrowingRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(activityMonitorProvider);
    await Future<void>.delayed(Duration.zero);

    // 取得失敗時は直近値（初期 zero）を維持する。
    expect(container.read(activityMonitorProvider), SystemMetricsSnapshot.zero);
  });

  test('ディスク / ネットワークの累積カウンタから差分レートが計算される', () async {
    // 1 回目: ベースライン。2 回目: 1 秒後に各カウンタが +bytes 増加。
    // ViewModel の polling は 1 秒インターバルだが、テストでは
    // ref.invalidate で 2 回目を即発火させる代わりに、_poll を直接呼ぶ
    // 経路がないため、シーケンシャルな 2 サンプルとして用意する。
    // 経過時間は実時刻 (Future.delayed) の差。短時間の延長を入れて
    // delta が計算可能になるようにする。
    final container = ProviderContainer(
      overrides: [
        systemMetricsRepositoryProvider.overrideWithValue(
          _FakeRepository(
            metricsSequence: [
              _metrics(diskRead: 1000, netIn: 2000),
              _metrics(diskRead: 11000, netIn: 7000),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(activityMonitorProvider);
    // 1 回目の poll の完了を待つ。
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final first = container.read(activityMonitorProvider);
    expect(first.diskBytesPerSec, 0);
    expect(first.networkBytesPerSec, 0);

    // 2 回目の poll を発火するために少し時間を進めて invalidate する。
    // ActivityMonitorViewModel.pollInterval は 1 秒なので、テストでは
    // タイマー発火を直接待つ代わりに provider を invalidate して再 build
    // する経路は state がリセットされるので、_poll を呼ぶための delay を
    // 入れる代替手段としてここでは初回 / 2 回目のシーケンスが回るのを
    // ポーリング 1 周期＋αで待つ。
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    final second = container.read(activityMonitorProvider);
    // ディスク 10000 / ネット 5000 を 1 秒ちょっとで進めた値。
    // 厳密値は時間ゆらぎが乗るので、概算で確認する（>0、おおむね倍率内）。
    expect(second.diskBytesPerSec, greaterThan(5000));
    expect(second.diskBytesPerSec, lessThan(20000));
    expect(second.networkBytesPerSec, greaterThan(2500));
    expect(second.networkBytesPerSec, lessThan(10000));
  });

  test('上位プロセスは CPU 降順 / メモリ降順で並ぶ', () async {
    final container = ProviderContainer(
      overrides: [
        systemMetricsRepositoryProvider.overrideWithValue(
          _FakeRepository(
            processesBySort: {
              ProcessSortKey.cpu: [
                _proc('a', cpu: 5, memory: 100),
                _proc('b', cpu: 50, memory: 10),
                _proc('c', cpu: 20, memory: 999),
              ],
              ProcessSortKey.memory: [
                _proc('a', cpu: 5, memory: 100),
                _proc('b', cpu: 50, memory: 10),
                _proc('c', cpu: 20, memory: 999),
              ],
            },
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

  test('上位プロセスは Disk / Network で ioBytesPerSec 降順に並ぶ', () async {
    final container = ProviderContainer(
      overrides: [
        systemMetricsRepositoryProvider.overrideWithValue(
          _FakeRepository(
            processesBySort: {
              ProcessSortKey.disk: [
                _proc('mds', io: 1024),
                _proc('chrome', io: 1024 * 1024),
                _proc('fseventsd', io: 512),
              ],
              ProcessSortKey.network: [
                _proc('chrome', io: 2048),
                _proc('slack', io: 4096),
              ],
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final byDisk = await container.read(
      activityTopProcessesProvider(ProcessSortKey.disk).future,
    );
    expect(byDisk.map((p) => p.name), ['chrome', 'mds', 'fseventsd']);

    final byNet = await container.read(
      activityTopProcessesProvider(ProcessSortKey.network).future,
    );
    expect(byNet.map((p) => p.name), ['slack', 'chrome']);
  });

  test('上位プロセスは activityTopProcessLimit 件に絞られる', () async {
    final many = List.generate(
      activityTopProcessLimit + 5,
      (i) => _proc('p$i', cpu: i.toDouble(), memory: i),
    );
    final container = ProviderContainer(
      overrides: [
        systemMetricsRepositoryProvider.overrideWithValue(
          _FakeRepository(processesBySort: {ProcessSortKey.cpu: many}),
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
