import 'package:flutter/services.dart';
import 'package:roola/data/activity_metrics/process_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics_repository.dart';

/// Windows 実装: `roola/system/metrics` MethodChannel 経由で C++ ハンドラを呼ぶ。
///
/// C++ 側は GlobalMemoryStatusEx（メモリ）と GetSystemTimes（CPU）、
/// CreateToolhelp32Snapshot（プロセス一覧）を使う（Task 4.8）。
class SystemMetricsRepositoryWindows implements SystemMetricsRepository {
  const SystemMetricsRepositoryWindows();

  static const MethodChannel _channel = MethodChannel('roola/system/metrics');

  @override
  Future<SystemMetrics> fetchSystemMetrics() async {
    try {
      final raw = await _channel.invokeMapMethod<String, Object?>(
        'getSystemMetrics',
      );
      if (raw == null) return SystemMetrics.zero;
      return SystemMetrics(
        cpuPercent: (raw['cpu'] as num?)?.toDouble() ?? 0,
        memoryUsedBytes: (raw['memoryUsed'] as num?)?.toInt() ?? 0,
        memoryTotalBytes: (raw['memoryTotal'] as num?)?.toInt() ?? 0,
      );
    } on PlatformException {
      return SystemMetrics.zero;
    }
  }

  @override
  Future<List<ProcessMetrics>> fetchProcesses() async {
    try {
      final raw = await _channel.invokeListMethod<Object?>('getTopProcesses');
      if (raw == null) return const <ProcessMetrics>[];
      return raw
          .whereType<Map<Object?, Object?>>()
          .map(
            (e) => ProcessMetrics(
              pid: (e['pid'] as num?)?.toInt() ?? 0,
              name: (e['name'] as String?) ?? '',
              cpuPercent: (e['cpu'] as num?)?.toDouble() ?? 0,
              memoryBytes: (e['memoryBytes'] as num?)?.toInt() ?? 0,
            ),
          )
          .toList();
    } on PlatformException {
      return const <ProcessMetrics>[];
    }
  }
}
