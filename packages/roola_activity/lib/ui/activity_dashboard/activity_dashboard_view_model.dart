import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:roola_activity/data/activity_metrics/system_metrics_repository.dart';
import 'package:roola_activity/data/activity_metrics/system_snapshot.dart';
import 'package:roola_activity/ui/activity_dashboard/activity_dashboard_state.dart';
import 'package:roola_activity/ui/activity_dashboard/activity_rates.dart';

part 'activity_dashboard_view_model.g.dart';

/// アクティビティタブのメトリクス（ADR-0067 / design D4）。
///
/// タブが表示中（所属ペインのアクティブタブ）の間だけ watch され、250ms ごとに
/// 累積値スナップショットを取得して前回との差分から使用率・レートを算出する。
/// autoDispose のため、タブが非表示になり watch が外れるとタイマーごと破棄
/// される。取得に失敗しても state は直近の値を保つ。
@riverpod
class ActivityDashboardViewModel extends _$ActivityDashboardViewModel {
  /// ポーリング間隔。トップバー（1 秒）より細かくし、描画側の補間と合わせて
  /// 針を実機らしく追従させる（design D4）。
  static const Duration pollInterval = Duration(milliseconds: 250);

  Timer? _timer;
  SystemSnapshot? _previous;
  DateTime? _previousAt;
  bool _polling = false;

  @override
  ActivityDashboardState build() {
    _timer = Timer.periodic(pollInterval, (_) => unawaited(_poll()));
    ref.onDispose(() => _timer?.cancel());
    unawaited(_poll());
    return const ActivityDashboardState();
  }

  Future<void> _poll() async {
    // 前回の取得が終わっていなければ重ねない（ネイティブが遅延した場合）。
    if (_polling) {
      return;
    }
    _polling = true;
    try {
      final snapshot = await ref
          .read(systemMetricsRepositoryProvider)
          .fetchSnapshot();
      if (snapshot == null || !ref.mounted) {
        return;
      }
      final now = DateTime.now();
      state = _next(
        state,
        _previous,
        snapshot,
        now.difference(_previousAt ?? now),
      );
      _previous = snapshot;
      _previousAt = now;
    } on Object {
      // 取得失敗時は直近値を維持し、次回ポーリングで回復を試みる。
    } finally {
      _polling = false;
    }
  }

  static ActivityDashboardState _next(
    ActivityDashboardState current,
    SystemSnapshot? prev,
    SystemSnapshot cur,
    Duration elapsed,
  ) {
    final cpu = prev == null ? null : cpuUsageBetween(prev, cur);
    final net = prev == null ? null : netRatesBetween(prev, cur, elapsed);
    final hasNet = cur.netInterfaces.isNotEmpty;
    return current.copyWith(
      cpu: cpu?.total ?? current.cpu,
      cores: cpu?.cores ?? current.cores,
      coreCount: cur.coreCount,
      memoryUsedBytes: cur.memoryUsedBytes,
      memoryTotalBytes: cur.memoryTotalBytes,
      swapUsedBytes: cur.swapUsedBytes,
      swapTotalBytes: cur.swapTotalBytes,
      diskReadRate: cur.diskReadBytes == null
          ? null
          : bytesPerSecond(prev?.diskReadBytes, cur.diskReadBytes, elapsed) ??
                current.diskReadRate ??
                0,
      diskWriteRate: cur.diskWriteBytes == null
          ? null
          : bytesPerSecond(prev?.diskWriteBytes, cur.diskWriteBytes, elapsed) ??
                current.diskWriteRate ??
                0,
      netRxRate: hasNet ? net?.rx ?? current.netRxRate ?? 0 : null,
      netTxRate: hasNet ? net?.tx ?? current.netTxRate ?? 0 : null,
      loadAverage: cur.loadAverage,
      uptimeSeconds: cur.uptimeSeconds,
    );
  }
}
