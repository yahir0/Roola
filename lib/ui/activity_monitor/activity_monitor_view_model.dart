import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/activity_metrics/process_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics_repository.dart';
import 'package:roola/data/activity_metrics/system_metrics_snapshot.dart';

/// ポップオーバーに出す上位プロセスの件数。
const int activityTopProcessLimit = 8;

/// トップバーのアクティビティモニタが参照するシステムメトリクス（ADR-0039 /
/// ADR-0048）。
///
/// 一定間隔でネイティブ層をポーリングし、最新値を state に反映する。
/// ディスク / ネットワークはネイティブから累積カウンタが来るので、前回 snapshot
/// との差分から per-second レートを計算して [SystemMetricsSnapshot] に乗せる
/// （ADR-0048 D4）。取得に失敗しても state は直近の有効値を維持し、次回
/// ポーリングで回復を試みる（モニタが一瞬ゼロへ落ちて見えるのを防ぐ）。
/// `NotifierProvider` は autoDispose ではないため、トップバーが存在する限り
/// 常駐してポーリングする。
class ActivityMonitorViewModel extends Notifier<SystemMetricsSnapshot> {
  /// ポーリング間隔。負荷計の更新頻度として一般的な 1 秒（ADR-0039 D5）。
  static const Duration pollInterval = Duration(seconds: 1);

  Timer? _timer;
  late SystemMetricsRepository _repository;
  // 前回ポーリングの結果（rate 計算用）。初回ポーリング後にセットされる。
  SystemMetrics? _previousMetrics;
  DateTime? _previousAt;

  @override
  SystemMetricsSnapshot build() {
    _repository = ref.read(systemMetricsRepositoryProvider);
    _timer = Timer.periodic(pollInterval, (_) => _poll());
    ref.onDispose(() => _timer?.cancel());
    unawaited(_poll());
    return SystemMetricsSnapshot.zero;
  }

  Future<void> _poll() async {
    final SystemMetrics metrics;
    try {
      metrics = await _repository.fetchSystemMetrics();
    } on Object {
      // 取得失敗時は直近値を維持。次回ポーリングで回復を試みる。
      return;
    }
    final now = DateTime.now();
    state = _composeSnapshot(metrics, now);
    _previousMetrics = metrics;
    _previousAt = now;
  }

  /// 新しい [metrics] と前回値から差分レート（B/s）を計算して snapshot を組む。
  ///
  /// 累積カウンタが減少しているケース（OS の wrap-around や fetch 順序の影響）
  /// は 0 として扱う。前回値が無い初回ポーリングはレート 0 を返す（CPU と
  /// 同じ挙動 — 差分方式の宿命）。
  SystemMetricsSnapshot _composeSnapshot(SystemMetrics metrics, DateTime now) {
    final prev = _previousMetrics;
    final prevAt = _previousAt;
    if (prev == null || prevAt == null) {
      return SystemMetricsSnapshot(
        metrics: metrics,
        diskBytesPerSec: 0,
        networkBytesPerSec: 0,
      );
    }
    final elapsedSec = now.difference(prevAt).inMicroseconds / 1e6;
    if (elapsedSec <= 0) {
      return SystemMetricsSnapshot(
        metrics: metrics,
        diskBytesPerSec: 0,
        networkBytesPerSec: 0,
      );
    }
    int safeDelta(int current, int previous) =>
        current >= previous ? current - previous : 0;
    final diskDelta =
        safeDelta(metrics.diskReadBytes, prev.diskReadBytes) +
        safeDelta(metrics.diskWrittenBytes, prev.diskWrittenBytes);
    final netDelta =
        safeDelta(metrics.networkInBytes, prev.networkInBytes) +
        safeDelta(metrics.networkOutBytes, prev.networkOutBytes);
    return SystemMetricsSnapshot(
      metrics: metrics,
      diskBytesPerSec: diskDelta / elapsedSec,
      networkBytesPerSec: netDelta / elapsedSec,
    );
  }
}

/// システムメトリクスの Provider。CPU / メモリ / ディスク / ネットワークの
/// 全モニタが参照する。
final activityMonitorProvider =
    NotifierProvider<ActivityMonitorViewModel, SystemMetricsSnapshot>(
      ActivityMonitorViewModel.new,
    );

/// どのアクティビティモニタのポップオーバーが開いているか。
enum ActivityPopover { none, cpu, memory, disk, network }

/// アクティビティモニタのポップオーバー開閉状態（ADR-0039 D6）。
///
/// 4 種類のポップオーバーは排他で、同時に 1 つしか開かない。
class ActivityPopoverController extends Notifier<ActivityPopover> {
  @override
  ActivityPopover build() => ActivityPopover.none;

  /// [target] のポップオーバーを開閉する。開いているものを再指定すると
  /// 閉じ、別のものを指定すると切り替える（前のものは閉じる）。
  void toggle(ActivityPopover target) {
    state = state == target ? ActivityPopover.none : target;
  }

  /// 開いているポップオーバーを閉じる（外側クリック等）。
  void close() => state = ActivityPopover.none;
}

/// ポップオーバー開閉状態の Provider。
final activityPopoverProvider =
    NotifierProvider<ActivityPopoverController, ActivityPopover>(
      ActivityPopoverController.new,
    );

/// ポップオーバーに出す上位プロセス一覧。
///
/// [ProcessSortKey] に応じてネイティブ経路を切り替え、降順ソートして上位
/// [activityTopProcessLimit] 件に絞る。`autoDispose` のため、ポップオーバーが
/// 閉じてリスナーが居なくなると破棄され、再び開いたときに最新の一覧を
/// 取得し直す（spec「プロセス一覧は開いた時点で取得される」）。
/// disk / network はネイティブ側で 1 秒サンプリングするため、最初のフレームは
/// loading 状態のまま 1 秒程度待たされる。
final activityTopProcessesProvider = FutureProvider.autoDispose
    .family<List<ProcessMetrics>, ProcessSortKey>((ref, sortKey) async {
      final processes = await ref
          .read(systemMetricsRepositoryProvider)
          .fetchProcesses(sortKey);
      final sorted = [...processes]
        ..sort(
          (a, b) => switch (sortKey) {
            ProcessSortKey.cpu => b.cpuPercent.compareTo(a.cpuPercent),
            ProcessSortKey.memory => b.memoryBytes.compareTo(a.memoryBytes),
            ProcessSortKey.disk || ProcessSortKey.network =>
              b.ioBytesPerSec.compareTo(a.ioBytesPerSec),
          },
        );
      return sorted.take(activityTopProcessLimit).toList();
    });
