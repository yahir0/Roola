// 計器の数値表示の整形（ADR-0067）。

/// B/s を短い表記（`1.2M` 等）に。LEVEL の数値欄向け。
String formatRateShort(double bytesPerSecond) {
  final b = bytesPerSecond;
  if (b >= 1e9) {
    return '${(b / 1e9).toStringAsFixed(2)}G';
  }
  if (b >= 1e6) {
    return '${(b / 1e6).toStringAsFixed(1)}M';
  }
  if (b >= 1e3) {
    return '${(b / 1e3).toStringAsFixed(0)}K';
  }
  return b.toStringAsFixed(0);
}

/// B/s を数値と単位に分ける（`('1.2', 'MB/s')`）。TACHO の数値欄向け。
(String, String) formatRateParts(double bytesPerSecond) {
  final b = bytesPerSecond;
  if (b >= 1e9) {
    return ((b / 1e9).toStringAsFixed(2), 'GB/s');
  }
  if (b >= 1e6) {
    return ((b / 1e6).toStringAsFixed(1), 'MB/s');
  }
  if (b >= 1e3) {
    return ((b / 1e3).toStringAsFixed(0), 'KB/s');
  }
  return (b.toStringAsFixed(0), 'B/s');
}

/// 0–1 の比率を整数 % に。
String formatPercent(double fraction) => '${(fraction * 100).round()}%';

/// bytes を GB（小数 1 桁）に。
String formatGigabytes(int bytes) => (bytes / (1 << 30)).toStringAsFixed(1);

/// 起動からの経過秒数を `3d 04:12` 形式に。
String formatUptime(int seconds) {
  final d = seconds ~/ 86400;
  final h = (seconds % 86400) ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final hm = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  return d > 0 ? '${d}d $hm' : hm;
}
