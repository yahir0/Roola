import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/activity_metrics/system_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics_repository_macos.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('roola/system/metrics');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const repo = SystemMetricsRepositoryMacos();

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('fetchSystemMetrics はネイティブの map を SystemMetrics へ変換する', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'getSystemMetrics');
      return {'cpu': 42.5, 'memoryUsed': 1000, 'memoryTotal': 4000};
    });

    final metrics = await repo.fetchSystemMetrics();

    expect(metrics.cpuPercent, 42.5);
    expect(metrics.memoryUsedBytes, 1000);
    expect(metrics.memoryTotalBytes, 4000);
    expect(metrics.memoryPercent, 25);
  });

  test('fetchSystemMetrics はネイティブが null のとき zero を返す', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => null);

    expect(await repo.fetchSystemMetrics(), SystemMetrics.zero);
  });

  test('fetchProcesses はネイティブの list を ProcessMetrics へ変換する', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'getTopProcesses');
      return [
        {'pid': 1, 'name': 'Roola', 'cpu': 12.0, 'memoryBytes': 200},
        {'pid': 2, 'name': 'kernel_task', 'cpu': 3.0, 'memoryBytes': 50},
      ];
    });

    final processes = await repo.fetchProcesses();

    expect(processes, hasLength(2));
    expect(processes.first.pid, 1);
    expect(processes.first.name, 'Roola');
    expect(processes.first.cpuPercent, 12.0);
    expect(processes.first.memoryBytes, 200);
  });

  test('fetchProcesses はネイティブが null のとき空リストを返す', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => null);

    expect(await repo.fetchProcesses(), isEmpty);
  });
}
