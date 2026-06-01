import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/activity_metrics/process_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics_repository_macos.dart';
import 'package:roola/data/activity_metrics/system_metrics_repository_windows.dart';

/// プロセス一覧の並び替えキー。クリックされたモニタに対応する。
enum ProcessSortKey { cpu, memory }

/// システムメトリクス取得の抽象インタフェース（ADR-0039）。
abstract interface class SystemMetricsRepository {
  Future<SystemMetrics> fetchSystemMetrics();
  Future<List<ProcessMetrics>> fetchProcesses();
}

final systemMetricsRepositoryProvider = Provider<SystemMetricsRepository>(
  (ref) {
    if (Platform.isMacOS) return const SystemMetricsRepositoryMacos();
    if (Platform.isWindows) return const SystemMetricsRepositoryWindows();
    throw UnsupportedError(
      'Unsupported platform: ${Platform.operatingSystem}',
    );
  },
);
