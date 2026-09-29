import 'package:roola/data/activity_metrics/system_snapshot.dart';

const int _wrap32 = 1 << 32;

/// 累積カウンタ 2 点の差分。
///
/// - 通常は `cur - prev`。
/// - 32bit で一周したカウンタ（macOS の CPU tick / ネットワーク IF）は、前回値が
///   32bit に収まり、かつ半周以上戻っていれば一周とみなして 2^32 を足す。
/// - それ以外の減少（ディスクの取り外し・IF のリセット等）は 0 とする。
int counterDelta(int prev, int cur) {
  if (cur >= prev) {
    return cur - prev;
  }
  if (prev < _wrap32 && prev - cur > _wrap32 ~/ 2) {
    return cur + _wrap32 - prev;
  }
  return 0;
}

/// 1 コアぶんの累積 tick `[user, system, idle, nice]` 2 点から使用率（0–1）。
double coreUsage(List<int> prev, List<int> cur) {
  final user = counterDelta(prev[0], cur[0]);
  final system = counterDelta(prev[1], cur[1]);
  final idle = counterDelta(prev[2], cur[2]);
  final nice = counterDelta(prev[3], cur[3]);
  final busy = user + system + nice;
  final total = busy + idle;
  return total <= 0 ? 0 : (busy / total).clamp(0.0, 1.0);
}

/// CPU 使用率（全体と各コア、0–1）。
typedef CpuUsage = ({double total, List<double> cores});

/// 2 つのスナップショットから CPU 使用率を算出する。コア数が変わった・tick が
/// 取れないときは null。
CpuUsage? cpuUsageBetween(SystemSnapshot prev, SystemSnapshot cur) {
  final a = prev.cpuTicks;
  final b = cur.cpuTicks;
  if (a == null || b == null || a.length != b.length || a.isEmpty) {
    return null;
  }
  final cores = <double>[];
  final sum = [0, 0, 0, 0];
  for (var i = 0; i < a.length; i++) {
    cores.add(coreUsage(a[i], b[i]));
    for (var s = 0; s < 4; s++) {
      sum[s] += counterDelta(a[i][s], b[i][s]);
    }
  }
  final busy = sum[0] + sum[1] + sum[3];
  final total = busy + sum[2];
  return (
    total: total <= 0 ? 0.0 : (busy / total).clamp(0.0, 1.0),
    cores: cores,
  );
}

/// 累積バイト 2 点から毎秒バイト数。どちらかが null・経過時間が 0 以下なら null。
double? bytesPerSecond(int? prev, int? cur, Duration elapsed) {
  if (prev == null || cur == null || elapsed <= Duration.zero) {
    return null;
  }
  return counterDelta(prev, cur) / (elapsed.inMicroseconds / 1e6);
}

/// ネットワークの受信 / 送信レート（B/s）。
typedef NetRates = ({double rx, double tx});

/// IF ごとに差分を取ってから合計する（macOS のカウンタは IF ごとに 32bit で
/// 一周するため、合計値の差分では一周を検出できない / design D8）。前回に無い
/// IF は 0 とする。IF が 1 つも無いときは null。
NetRates? netRatesBetween(
  SystemSnapshot prev,
  SystemSnapshot cur,
  Duration elapsed,
) {
  if (cur.netInterfaces.isEmpty || elapsed <= Duration.zero) {
    return null;
  }
  final before = {for (final n in prev.netInterfaces) n.name: n};
  var rx = 0;
  var tx = 0;
  for (final n in cur.netInterfaces) {
    final p = before[n.name];
    if (p == null) {
      continue;
    }
    rx += counterDelta(p.rxBytes, n.rxBytes);
    tx += counterDelta(p.txBytes, n.txBytes);
  }
  final seconds = elapsed.inMicroseconds / 1e6;
  return (rx: rx / seconds, tx: tx / seconds);
}
