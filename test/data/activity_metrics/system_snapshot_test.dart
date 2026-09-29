import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/activity_metrics/system_metrics_repository_macos.dart';
import 'package:roola/data/activity_metrics/system_snapshot.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SystemSnapshot.fromChannelMap', () {
    test('全キーを変換する', () {
      final snapshot = SystemSnapshot.fromChannelMap({
        'cpuTicks': [
          [10, 20, 70, 0],
          [5, 5, 90, 0],
        ],
        'memoryUsed': 8,
        'memoryTotal': 16,
        'swapUsed': 1,
        'swapTotal': 4,
        'diskReadBytes': 100,
        'diskWriteBytes': 200,
        'netInterfaces': [
          {'name': 'en0', 'rx': 300, 'tx': 400},
        ],
        'loadAverage': [1.5, 2.0, 2.5],
        'uptimeSeconds': 3600,
      });

      expect(snapshot.cpuTicks, [
        [10, 20, 70, 0],
        [5, 5, 90, 0],
      ]);
      expect(snapshot.coreCount, 2);
      expect(snapshot.memoryUsedBytes, 8);
      expect(snapshot.memoryTotalBytes, 16);
      expect(snapshot.swapUsedBytes, 1);
      expect(snapshot.swapTotalBytes, 4);
      expect(snapshot.diskReadBytes, 100);
      expect(snapshot.diskWriteBytes, 200);
      expect(snapshot.netInterfaces, const [
        NetInterfaceCounters(name: 'en0', rxBytes: 300, txBytes: 400),
      ]);
      expect(snapshot.loadAverage, [1.5, 2.0, 2.5]);
      expect(snapshot.uptimeSeconds, 3600);
    });

    test('欠けたキーは null / 空になる（Windows のロードアベレージなど）', () {
      final snapshot = SystemSnapshot.fromChannelMap({
        'memoryUsed': 8,
        'memoryTotal': 16,
      });

      expect(snapshot.cpuTicks, isNull);
      expect(snapshot.coreCount, 0);
      expect(snapshot.swapTotalBytes, isNull);
      expect(snapshot.diskReadBytes, isNull);
      expect(snapshot.netInterfaces, isEmpty);
      expect(snapshot.loadAverage, isNull);
      expect(snapshot.uptimeSeconds, isNull);
    });

    test('形の崩れた要素は読み飛ばす', () {
      final snapshot = SystemSnapshot.fromChannelMap({
        'cpuTicks': [
          [1, 2],
          'x',
        ],
        'memoryUsed': 'bad',
        'netInterfaces': [
          {'rx': 1},
          42,
        ],
        'loadAverage': [1.0],
      });

      expect(snapshot.cpuTicks, isNull);
      expect(snapshot.memoryUsedBytes, 0);
      expect(snapshot.netInterfaces, isEmpty);
      expect(snapshot.loadAverage, isNull);
    });
  });

  group('SystemMetricsRepositoryMacos.fetchSnapshot', () {
    const channel = MethodChannel('roola/system/metrics');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const repo = SystemMetricsRepositoryMacos();

    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test('getSystemSnapshot を呼んで変換する', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'getSystemSnapshot');
        return {'memoryUsed': 1, 'memoryTotal': 2};
      });

      final snapshot = await repo.fetchSnapshot();

      expect(snapshot?.memoryTotalBytes, 2);
    });

    test('ネイティブが例外を返したら null', () async {
      messenger.setMockMethodCallHandler(
        channel,
        (call) async => throw PlatformException(code: 'x'),
      );

      expect(await repo.fetchSnapshot(), isNull);
    });
  });
}
