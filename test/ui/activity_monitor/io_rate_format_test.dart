import 'package:flutter_test/flutter_test.dart';
import 'package:roola/ui/activity_monitor/io_rate_format.dart';

void main() {
  group('formatBytesPerSec', () {
    test('< 1 KB/s は B/s、整数表記', () {
      expect(IoRateFormat.formatBytesPerSec(0), '0 B/s');
      expect(IoRateFormat.formatBytesPerSec(512), '512 B/s');
      expect(IoRateFormat.formatBytesPerSec(1023), '1023 B/s');
    });

    test('< 10 KB/s は小数 1 桁、>= 10 KB/s は整数', () {
      expect(IoRateFormat.formatBytesPerSec(1024 * 1.2), '1.2 KB/s');
      expect(IoRateFormat.formatBytesPerSec(1024 * 12), '12 KB/s');
    });

    test('< 10 MB/s は小数 1 桁、>= 10 MB/s は整数', () {
      expect(IoRateFormat.formatBytesPerSec(1024 * 1024 * 1.5), '1.5 MB/s');
      expect(IoRateFormat.formatBytesPerSec(1024 * 1024 * 100), '100 MB/s');
    });

    test('GB/s レンジ', () {
      expect(
        IoRateFormat.formatBytesPerSec(1024 * 1024 * 1024 * 1.2),
        '1.2 GB/s',
      );
    });

    test('負値 / NaN は 0 B/s', () {
      expect(IoRateFormat.formatBytesPerSec(-1), '0 B/s');
      expect(IoRateFormat.formatBytesPerSec(double.nan), '0 B/s');
    });
  });

  group('logScaleBytesPerSec', () {
    test('1 KB/s 以下は 0、1 GB/s 以上は 1 にクランプ', () {
      expect(IoRateFormat.logScaleBytesPerSec(0), 0);
      expect(IoRateFormat.logScaleBytesPerSec(1024), 0);
      expect(IoRateFormat.logScaleBytesPerSec(1024 * 1024 * 1024 * 2), 1);
    });

    test('1 KB → 1 GB の中央（1 MB/s）はおよそ 0.5 に近い', () {
      // log10(1MB/1KB) / log10(1GB/1KB) = 3/6 = 0.5
      final r = IoRateFormat.logScaleBytesPerSec(1024 * 1024);
      expect(r, closeTo(0.5, 0.01));
    });

    test('中間値は単調増加', () {
      final a = IoRateFormat.logScaleBytesPerSec(10 * 1024);
      final b = IoRateFormat.logScaleBytesPerSec(100 * 1024);
      final c = IoRateFormat.logScaleBytesPerSec(1024 * 1024);
      expect(a, lessThan(b));
      expect(b, lessThan(c));
    });
  });
}
