import 'package:freezed_annotation/freezed_annotation.dart';

part 'system_snapshot.freezed.dart';

/// アクティビティタブ（ADR-0067）が 250ms ごとに取得する累積値スナップショット。
///
/// ネイティブ層は状態を持たず、ある瞬間の累積カウンタだけを返す（design D3）。
/// 使用率・レートは 2 つのスナップショットの差分から ViewModel 側で算出する。
/// OS から取得できない項目は null（例: Windows の [loadAverage]）。
/// 表示専用・非永続のため DTO 分離はしない。
@freezed
abstract class SystemSnapshot with _$SystemSnapshot {
  const factory SystemSnapshot({
    /// コアごとの累積 tick `[user, system, idle, nice]`。取得不可なら null。
    List<List<int>>? cpuTicks,

    /// 使用中メモリ（bytes）。
    required int memoryUsedBytes,

    /// 物理メモリ総容量（bytes）。
    required int memoryTotalBytes,

    /// スワップ（ページファイル）使用量 / 容量（bytes）。
    int? swapUsedBytes,
    int? swapTotalBytes,

    /// ディスク読み込み / 書き込みの累積バイト。
    int? diskReadBytes,
    int? diskWriteBytes,

    /// 物理ネットワーク IF ごとの累積バイト。
    @Default(<NetInterfaceCounters>[]) List<NetInterfaceCounters> netInterfaces,

    /// ロードアベレージ `[1 分, 5 分, 15 分]`。macOS のみ。
    List<double>? loadAverage,

    /// 起動からの経過秒数。
    int? uptimeSeconds,
  }) = _SystemSnapshot;

  const SystemSnapshot._();

  /// `roola/system/metrics` の `getSystemSnapshot` が返す Map から生成する。
  /// 欠けているキー・型の合わない値は null（または空）として扱う。
  factory SystemSnapshot.fromChannelMap(Map<Object?, Object?> raw) {
    int? asInt(Object? v) => v is num ? v.toInt() : null;

    final ticks = raw['cpuTicks'];
    final cores = ticks is List
        ? [
            for (final core in ticks)
              if (core is List && core.length >= 4)
                [for (final t in core.take(4)) asInt(t) ?? 0],
          ]
        : null;

    final nets = raw['netInterfaces'];
    final load = raw['loadAverage'];
    return SystemSnapshot(
      cpuTicks: cores == null || cores.isEmpty ? null : cores,
      memoryUsedBytes: asInt(raw['memoryUsed']) ?? 0,
      memoryTotalBytes: asInt(raw['memoryTotal']) ?? 0,
      swapUsedBytes: asInt(raw['swapUsed']),
      swapTotalBytes: asInt(raw['swapTotal']),
      diskReadBytes: asInt(raw['diskReadBytes']),
      diskWriteBytes: asInt(raw['diskWriteBytes']),
      netInterfaces: nets is List
          ? [
              for (final n in nets)
                if (n is Map && n['name'] is String)
                  NetInterfaceCounters(
                    name: n['name']! as String,
                    rxBytes: asInt(n['rx']) ?? 0,
                    txBytes: asInt(n['tx']) ?? 0,
                  ),
            ]
          : const [],
      loadAverage: load is List && load.length >= 3
          ? [for (final v in load.take(3)) v is num ? v.toDouble() : 0]
          : null,
      uptimeSeconds: asInt(raw['uptimeSeconds']),
    );
  }

  /// 論理コア数。コア別 tick が取れないときは 0。
  int get coreCount => cpuTicks?.length ?? 0;
}

/// ネットワーク IF 1 つぶんの累積バイト。
///
/// macOS は一般プロセスにこのカウンタを 32bit で一周させて渡すため、差分は
/// IF ごとに 2^32 剰余で取る（design D8）。
@freezed
abstract class NetInterfaceCounters with _$NetInterfaceCounters {
  const factory NetInterfaceCounters({
    required String name,
    required int rxBytes,
    required int txBytes,
  }) = _NetInterfaceCounters;
}
