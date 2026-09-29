import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/activity_metrics/system_snapshot.dart';
import 'package:roola/ui/activity_dashboard/activity_rates.dart';

SystemSnapshot _snap({
  List<List<int>>? ticks,
  List<NetInterfaceCounters> nets = const [],
}) => SystemSnapshot(
  cpuTicks: ticks,
  memoryUsedBytes: 0,
  memoryTotalBytes: 0,
  netInterfaces: nets,
);

void main() {
  group('counterDelta', () {
    test('増加はそのまま差分', () {
      expect(counterDelta(100, 250), 150);
    });

    test('32bit で一周したカウンタは 2^32 を足して補正する', () {
      const max = 1 << 32;
      expect(counterDelta(max - 1000, 500), 1500);
    });

    test('一周ではない減少（ディスク取り外し等）は 0', () {
      expect(counterDelta(5000, 4000), 0);
      expect(counterDelta(10000000000000, 20), 0);
    });
  });

  group('cpuUsageBetween', () {
    test('全体とコア別の使用率を tick 差分から出す', () {
      final prev = _snap(
        ticks: [
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
      );
      final cur = _snap(
        ticks: [
          [30, 20, 50, 0],
          [5, 5, 90, 0],
        ],
      );

      final usage = cpuUsageBetween(prev, cur)!;

      expect(usage.cores[0], closeTo(0.5, 1e-9));
      expect(usage.cores[1], closeTo(0.1, 1e-9));
      expect(usage.total, closeTo(0.3, 1e-9));
    });

    test('コア数が変わった・tick が無いときは null', () {
      expect(cpuUsageBetween(_snap(), _snap()), isNull);
      expect(
        cpuUsageBetween(
          _snap(
            ticks: [
              [0, 0, 0, 0],
            ],
          ),
          _snap(
            ticks: [
              [0, 0, 0, 0],
              [0, 0, 0, 0],
            ],
          ),
        ),
        isNull,
      );
    });
  });

  group('netRatesBetween', () {
    test('IF ごとに差分を取って合計し、一周した IF も正しく数える', () {
      const max = 1 << 32;
      final prev = _snap(
        nets: const [
          NetInterfaceCounters(name: 'en0', rxBytes: max - 100, txBytes: 0),
          NetInterfaceCounters(name: 'en1', rxBytes: 1000, txBytes: 500),
        ],
      );
      final cur = _snap(
        nets: const [
          NetInterfaceCounters(name: 'en0', rxBytes: 900, txBytes: 1000),
          NetInterfaceCounters(name: 'en1', rxBytes: 2000, txBytes: 500),
        ],
      );

      final rates = netRatesBetween(prev, cur, const Duration(seconds: 2))!;

      expect(rates.rx, (1000 + 1000) / 2);
      expect(rates.tx, 1000 / 2);
    });

    test('前回に無かった IF は数えない', () {
      final rates = netRatesBetween(
        _snap(),
        _snap(
          nets: const [
            NetInterfaceCounters(name: 'en5', rxBytes: 999999, txBytes: 1),
          ],
        ),
        const Duration(seconds: 1),
      )!;

      expect(rates.rx, 0);
      expect(rates.tx, 0);
    });
  });

  test('bytesPerSecond は経過時間で割る', () {
    expect(bytesPerSecond(1000, 3000, const Duration(milliseconds: 250)), 8000);
    expect(bytesPerSecond(null, 3000, const Duration(seconds: 1)), isNull);
    expect(bytesPerSecond(1, 3, Duration.zero), isNull);
  });
}
