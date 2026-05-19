import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/activity_metrics/process_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics.dart';

/// プロセス一覧の並び替えキー。クリックされたモニタに対応する。
enum ProcessSortKey { cpu, memory }

/// macOS のシステムメトリクスをネイティブ層から取得する（ADR-0039）。
///
/// `roola/system/metrics` の `MethodChannel` をラップするだけの薄い具象
/// クラス。差し替え可能性のある箇所ではないため interface は設けない
/// （CLAUDE.md）。テストでは Riverpod の provider override でサブクラスへ
/// 差し替える。
class SystemMetricsRepository {
  const SystemMetricsRepository();

  static const MethodChannel _channel = MethodChannel('roola/system/metrics');

  /// システム全体の CPU / メモリを取得する。
  /// 取得できなかった場合は [SystemMetrics.zero] を返す。
  Future<SystemMetrics> fetchSystemMetrics() async {
    final raw = await _channel.invokeMapMethod<String, Object?>(
      'getSystemMetrics',
    );
    if (raw == null) {
      return SystemMetrics.zero;
    }
    return SystemMetrics(
      cpuPercent: (raw['cpu'] as num?)?.toDouble() ?? 0,
      memoryUsedBytes: (raw['memoryUsed'] as num?)?.toInt() ?? 0,
      memoryTotalBytes: (raw['memoryTotal'] as num?)?.toInt() ?? 0,
    );
  }

  /// プロセスの生リストを取得する。並び替え・件数制限は呼び出し側で行う。
  Future<List<ProcessMetrics>> fetchProcesses() async {
    final raw = await _channel.invokeListMethod<Object?>('getTopProcesses');
    if (raw == null) {
      return const <ProcessMetrics>[];
    }
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
  }
}

/// [SystemMetricsRepository] の DI。テストでは override してネイティブ
/// 呼び出しを伴わない fake に差し替える。
final systemMetricsRepositoryProvider = Provider<SystemMetricsRepository>(
  (ref) => const SystemMetricsRepository(),
);
