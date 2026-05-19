import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/activity_metrics/process_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics_repository.dart';

/// ポップオーバーに出す上位プロセスの件数。
const int activityTopProcessLimit = 8;

/// トップバーのアクティビティモニタが参照するシステムメトリクス（ADR-0039）。
///
/// 一定間隔でネイティブ層をポーリングし、最新値を state に反映する。
/// 取得に失敗しても state は直近の有効値を維持し、次回ポーリングで回復を
/// 試みる（モニタが一瞬ゼロへ落ちて見えるのを防ぐ）。`NotifierProvider` は
/// autoDispose ではないため、トップバーが存在する限り常駐してポーリングする。
class ActivityMonitorViewModel extends Notifier<SystemMetrics> {
  /// ポーリング間隔。負荷計の更新頻度として一般的な 1 秒（ADR-0039 D5）。
  static const Duration pollInterval = Duration(seconds: 1);

  Timer? _timer;
  late SystemMetricsRepository _repository;

  @override
  SystemMetrics build() {
    _repository = ref.read(systemMetricsRepositoryProvider);
    _timer = Timer.periodic(pollInterval, (_) => _poll());
    ref.onDispose(() => _timer?.cancel());
    unawaited(_poll());
    return SystemMetrics.zero;
  }

  Future<void> _poll() async {
    try {
      state = await _repository.fetchSystemMetrics();
    } on Object {
      // 取得失敗時は直近値を維持。次回ポーリングで回復を試みる。
    }
  }
}

/// システムメトリクスの Provider。CPU / メモリ両モニタが参照する。
final activityMonitorProvider =
    NotifierProvider<ActivityMonitorViewModel, SystemMetrics>(
      ActivityMonitorViewModel.new,
    );

/// どのアクティビティモニタのポップオーバーが開いているか。
enum ActivityPopover { none, cpu, memory }

/// アクティビティモニタのポップオーバー開閉状態（ADR-0039 D6）。
///
/// CPU とメモリのポップオーバーは排他で、同時に 1 つしか開かない。
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
/// [ProcessSortKey]（CPU / メモリ）に応じて降順ソートし、上位
/// [activityTopProcessLimit] 件に絞る。`autoDispose` のため、ポップオーバーが
/// 閉じてリスナーが居なくなると破棄され、再び開いたときに最新の一覧を
/// 取得し直す（spec「プロセス一覧は開いた時点で取得される」）。
final activityTopProcessesProvider = FutureProvider.autoDispose
    .family<List<ProcessMetrics>, ProcessSortKey>((ref, sortKey) async {
      final processes = await ref
          .read(systemMetricsRepositoryProvider)
          .fetchProcesses();
      final sorted = [...processes]..sort(
        (a, b) => switch (sortKey) {
          ProcessSortKey.cpu => b.cpuPercent.compareTo(a.cpuPercent),
          ProcessSortKey.memory => b.memoryBytes.compareTo(a.memoryBytes),
        },
      );
      return sorted.take(activityTopProcessLimit).toList();
    });
