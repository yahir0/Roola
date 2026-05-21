import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/activity_metrics/system_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('roola/system/metrics');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const repo = SystemMetricsRepository();

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('fetchSystemMetrics はネイティブの map を SystemMetrics へ変換する', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'getSystemMetrics');
      return {
        'cpu': 42.5,
        'memoryUsed': 1000,
        'memoryTotal': 4000,
        'diskReadBytes': 5000,
        'diskWrittenBytes': 6000,
        'networkInBytes': 7000,
        'networkOutBytes': 8000,
      };
    });

    final metrics = await repo.fetchSystemMetrics();

    expect(metrics.cpuPercent, 42.5);
    expect(metrics.memoryUsedBytes, 1000);
    expect(metrics.memoryTotalBytes, 4000);
    expect(metrics.memoryPercent, 25);
    expect(metrics.diskReadBytes, 5000);
    expect(metrics.diskWrittenBytes, 6000);
    expect(metrics.networkInBytes, 7000);
    expect(metrics.networkOutBytes, 8000);
  });

  test('fetchSystemMetrics は欠損フィールドを 0 として補完する', () async {
    // 旧バージョンのネイティブが新フィールドを返さないケースを想定。
    messenger.setMockMethodCallHandler(channel, (call) async {
      return {'cpu': 10.0, 'memoryUsed': 100, 'memoryTotal': 200};
    });

    final metrics = await repo.fetchSystemMetrics();

    expect(metrics.diskReadBytes, 0);
    expect(metrics.diskWrittenBytes, 0);
    expect(metrics.networkInBytes, 0);
    expect(metrics.networkOutBytes, 0);
  });

  test('fetchSystemMetrics はネイティブが null のとき zero を返す', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => null);

    expect(await repo.fetchSystemMetrics(), SystemMetrics.zero);
  });

  test(
    'fetchProcesses(cpu) はネイティブに sortKey=cpu を渡し ProcessMetrics へ変換する',
    () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'getTopProcesses');
        final args = call.arguments as Map<Object?, Object?>;
        expect(args['sortKey'], 'cpu');
        return [
          {'pid': 1, 'name': 'Roola', 'cpu': 12.0, 'memoryBytes': 200},
          {'pid': 2, 'name': 'kernel_task', 'cpu': 3.0, 'memoryBytes': 50},
        ];
      });

      final processes = await repo.fetchProcesses(ProcessSortKey.cpu);

      expect(processes, hasLength(2));
      expect(processes.first.pid, 1);
      expect(processes.first.name, 'Roola');
      expect(processes.first.cpuPercent, 12.0);
      expect(processes.first.memoryBytes, 200);
      expect(processes.first.ioBytesPerSec, 0);
    },
  );

  test('fetchProcesses(disk) は sortKey=disk を渡し ioBytesPerSec を読む', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      final args = call.arguments as Map<Object?, Object?>;
      expect(args['sortKey'], 'disk');
      return [
        {'pid': 10, 'name': 'fseventsd', 'ioBytesPerSec': 1024 * 1024},
        {'pid': 11, 'name': 'mds', 'ioBytesPerSec': 512},
      ];
    });

    final processes = await repo.fetchProcesses(ProcessSortKey.disk);

    expect(processes, hasLength(2));
    expect(processes.first.name, 'fseventsd');
    expect(processes.first.ioBytesPerSec, 1024 * 1024);
    expect(processes.first.cpuPercent, 0);
    expect(processes.first.memoryBytes, 0);
  });

  test('fetchProcesses(network) は sortKey=network を渡す', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      final args = call.arguments as Map<Object?, Object?>;
      expect(args['sortKey'], 'network');
      return [
        {'pid': 100, 'name': 'Chrome', 'ioBytesPerSec': 2048},
      ];
    });

    final processes = await repo.fetchProcesses(ProcessSortKey.network);

    expect(processes, hasLength(1));
    expect(processes.first.name, 'Chrome');
    expect(processes.first.ioBytesPerSec, 2048);
  });

  test('fetchProcesses はネイティブが null のとき空リストを返す', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => null);

    expect(await repo.fetchProcesses(ProcessSortKey.cpu), isEmpty);
  });
}
