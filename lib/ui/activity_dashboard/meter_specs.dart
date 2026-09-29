import 'dart:math' as math;

import 'package:roola/ui/activity_dashboard/activity_dashboard_state.dart';
import 'package:roola/ui/activity_dashboard/activity_format.dart';
import 'package:roola/ui/activity_dashboard/meter_physics.dart';

/// 目盛りの種類。
///
/// - `percent`: 0–100 %
/// - `log`: I/O の対数目盛り（1 KB/s〜1 GB/s）
/// - `load`: ロードアベレージ（論理コア数が満点）
enum MeterScale { percent, log, load }

/// メーター 1 本ぶん（LEVEL のチャンネル / TACHO の 1 メーター）。
class MeterChannel {
  const MeterChannel({
    required this.key,
    required this.name,
    required this.short,
    required this.parts,
  });

  /// [MeterAnimator] のチャンネル ID。
  final String key;

  /// LEVEL のチャンネル名（`RX` 等）。
  final String name;

  /// LEVEL の数値欄（`42%` / `1.2M`）。
  final String short;

  /// TACHO の数値欄（数値, 単位）。
  final (String, String) parts;
}

/// LEVEL の 1 グループ（CPU / MEMORY / NETWORK / DISK / LOAD）。
class MeterGroup {
  const MeterGroup({
    required this.title,
    required this.note,
    required this.scale,
    required this.channels,
  });

  final String title;
  final String note;
  final MeterScale scale;
  final List<MeterChannel> channels;
}

/// TACHO の円形メーター 1 つぶん。
class DialSpec {
  const DialSpec({
    required this.channel,
    required this.label,
    required this.sub,
    required this.majors,
    required this.minorsPerMajor,
    required this.redFrom,
    this.size = DialSize.small,
  });

  final MeterChannel channel;
  final String label;
  final String sub;

  /// 大目盛りの数字（等間隔に配置）。
  final List<String> majors;

  /// 大目盛り 1 区間あたりの小目盛り数。
  final int minorsPerMajor;

  /// レッドゾーンの開始位置（0–1）。
  final double redFrom;

  final DialSize size;
}

/// 円形メーターの大きさ。`big` は CPU / メモリ、`core` はコア別。
enum DialSize { big, small, core }

/// ロードアベレージの満点（論理コア数。不明なら 8）。
int loadFullScale(ActivityDashboardState s) =>
    s.coreCount > 0 ? s.coreCount : 8;

/// CPU・メモリの目盛り（タコメータ風の 0–10、×10 %）。
const List<String> tachoMajors = [
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', //
];

const List<String> _logMajors = [
  '1K',
  '10K',
  '100K',
  '1M',
  '10M',
  '100M',
  '1G',
];

/// 各チャンネルの目標値（0–1）。[MeterAnimator.setTargets] に渡す。
Map<String, double> meterTargets(ActivityDashboardState s) {
  final full = loadFullScale(s);
  final load = s.loadAverage;
  return {
    'cpu': s.cpu ?? 0,
    for (var i = 0; i < s.cores.length; i++) 'core$i': s.cores[i],
    'mem': s.memory,
    if (s.swap != null) 'swap': s.swap!,
    if (s.diskReadRate != null) 'diskR': logScale(s.diskReadRate!),
    if (s.diskWriteRate != null) 'diskW': logScale(s.diskWriteRate!),
    if (s.netRxRate != null) 'netRx': logScale(s.netRxRate!),
    if (s.netTxRate != null) 'netTx': logScale(s.netTxRate!),
    if (load != null) ...{
      'load1': math.min(1, load[0] / full),
      'load5': math.min(1, load[1] / full),
      'load15': math.min(1, load[2] / full),
    },
  };
}

MeterChannel cpuChannel(ActivityDashboardState s) {
  final cpu = s.cpu ?? 0;
  return MeterChannel(
    key: 'cpu',
    name: 'ALL',
    short: formatPercent(cpu),
    parts: ('${(cpu * 100).round()}', '%'),
  );
}

List<MeterChannel> coreChannels(ActivityDashboardState s) => [
  for (var i = 0; i < s.cores.length; i++)
    MeterChannel(
      key: 'core$i',
      name: 'C${i + 1}',
      short: formatPercent(s.cores[i]),
      parts: ('${(s.cores[i] * 100).round()}', '%'),
    ),
];

MeterChannel memoryChannel(ActivityDashboardState s) => MeterChannel(
  key: 'mem',
  name: 'USED',
  short: formatPercent(s.memory),
  parts: (formatGigabytes(s.memoryUsedBytes), 'GB'),
);

MeterChannel? swapChannel(ActivityDashboardState s) {
  final swap = s.swap;
  if (swap == null) {
    return null;
  }
  return MeterChannel(
    key: 'swap',
    name: 'SWAP',
    short: formatPercent(swap),
    parts: (formatGigabytes(s.swapUsedBytes ?? 0), 'GB'),
  );
}

MeterChannel _rateChannel(String key, String name, double rate) => MeterChannel(
  key: key,
  name: name,
  short: formatRateShort(rate),
  parts: formatRateParts(rate),
);

List<MeterChannel> netChannels(ActivityDashboardState s) => [
  if (s.netRxRate != null) _rateChannel('netRx', 'RX', s.netRxRate!),
  if (s.netTxRate != null) _rateChannel('netTx', 'TX', s.netTxRate!),
];

List<MeterChannel> diskChannels(ActivityDashboardState s) => [
  if (s.diskReadRate != null) _rateChannel('diskR', 'READ', s.diskReadRate!),
  if (s.diskWriteRate != null) _rateChannel('diskW', 'WRITE', s.diskWriteRate!),
];

List<MeterChannel> loadChannels(ActivityDashboardState s) {
  final load = s.loadAverage;
  if (load == null) {
    return const [];
  }
  const names = ['1m', '5m', '15m'];
  const keys = ['load1', 'load5', 'load15'];
  return [
    for (var i = 0; i < 3; i++)
      MeterChannel(
        key: keys[i],
        name: names[i],
        short: load[i].toStringAsFixed(2),
        parts: (load[i].toStringAsFixed(2), ''),
      ),
  ];
}

/// LEVEL のグループ一覧。取得できない項目のグループは含めない。
List<MeterGroup> levelGroups(
  ActivityDashboardState s, {
  required bool allCores,
}) {
  final showCores = allCores && s.hasPerCore;
  final swap = swapChannel(s);
  final net = netChannels(s);
  final disk = diskChannels(s);
  final load = loadChannels(s);
  return [
    MeterGroup(
      title: 'CPU',
      note: showCores ? '${s.cores.length} cores' : 'total',
      scale: MeterScale.percent,
      channels: showCores ? coreChannels(s) : [cpuChannel(s)],
    ),
    MeterGroup(
      title: 'MEMORY',
      note: '${formatGigabytes(s.memoryTotalBytes)} GB',
      scale: MeterScale.percent,
      channels: [memoryChannel(s), ?swap],
    ),
    if (net.isNotEmpty)
      MeterGroup(
        title: 'NETWORK',
        note: 'B/s',
        scale: MeterScale.log,
        channels: net,
      ),
    if (disk.isNotEmpty)
      MeterGroup(
        title: 'DISK',
        note: 'B/s',
        scale: MeterScale.log,
        channels: disk,
      ),
    if (load.isNotEmpty)
      MeterGroup(
        title: 'LOAD',
        note: 'max ${loadFullScale(s)}',
        scale: MeterScale.load,
        channels: load,
      ),
  ];
}

/// TACHO の大メーター（CPU / メモリ）。
List<DialSpec> mainDials(ActivityDashboardState s) => [
  DialSpec(
    channel: cpuChannel(s),
    label: 'CPU',
    sub: '×10 %',
    majors: tachoMajors,
    minorsPerMajor: 5,
    redFrom: 0.85,
    size: DialSize.big,
  ),
  DialSpec(
    channel: memoryChannel(s),
    label: 'MEMORY',
    sub: '×10 %',
    majors: tachoMajors,
    minorsPerMajor: 5,
    redFrom: 0.85,
    size: DialSize.big,
  ),
];

/// TACHO の小メーター（I/O・ロードアベレージ）。取得できない項目は含めない。
List<DialSpec> subDials(ActivityDashboardState s) {
  DialSpec io(MeterChannel c, String label) => DialSpec(
    channel: c,
    label: label,
    sub: 'B/s',
    majors: _logMajors,
    minorsPerMajor: 5,
    redFrom: 0.84,
  );
  final net = netChannels(s);
  final disk = diskChannels(s);
  final load = loadChannels(s);
  final full = loadFullScale(s);
  return [
    for (final c in net) io(c, c.key == 'netRx' ? 'NET RX' : 'NET TX'),
    for (final c in disk) io(c, c.key == 'diskR' ? 'DISK R' : 'DISK W'),
    if (load.isNotEmpty)
      DialSpec(
        channel: load.first,
        label: 'LOAD',
        sub: '1 min',
        majors: [for (var i = 0; i <= 5; i++) '${(full * i / 5).round()}'],
        minorsPerMajor: 5,
        redFrom: 0.8,
      ),
  ];
}

/// TACHO のコア別メーター。
List<DialSpec> coreDials(ActivityDashboardState s) => [
  for (final c in coreChannels(s))
    DialSpec(
      channel: c,
      label: c.name,
      sub: '%',
      majors: const ['0', '50', '100'],
      minorsPerMajor: 5,
      redFrom: 0.85,
      size: DialSize.core,
    ),
];
