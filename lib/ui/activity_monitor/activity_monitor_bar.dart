import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/activity_metrics/system_metrics_snapshot.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/activity_monitor/activity_monitor_popover_layer.dart';
import 'package:roola/ui/activity_monitor/activity_monitor_view_model.dart';
import 'package:roola/ui/activity_monitor/io_rate_format.dart';

/// トップバーに常駐するアクティビティモニタ（ADR-0039 / ADR-0048）。
///
/// CPU・メモリ・ディスク I/O・ネットワーク I/O の 4 項目を「アイコン＋ミニ
/// レベルバー」で並べ、システム全体の負荷をバーの占有で示す。各モニタを
/// クリックすると上位プロセス一覧のポップオーバー
/// （[ActivityMonitorPopoverLayer]）が開く。メモパッド・設定アイコンの左に
/// 置く。
///
/// ポップオーバー本体はトップバーではなくワークスペース body 側の
/// [ActivityMonitorPopoverLayer] が描く。開閉状態は [activityPopoverProvider]
/// 経由で共有する。
class ActivityMonitorBar extends StatelessWidget {
  const ActivityMonitorBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActivityGaugeButton(kind: ActivityPopover.cpu),
        SizedBox(width: PolarisTokens.space1),
        _ActivityGaugeButton(kind: ActivityPopover.memory),
        SizedBox(width: PolarisTokens.space1),
        _ActivityGaugeButton(kind: ActivityPopover.disk),
        SizedBox(width: PolarisTokens.space1),
        _ActivityGaugeButton(kind: ActivityPopover.network),
      ],
    );
  }
}

/// ゲージ 1 項目ぶんのモニタ。クリックでポップオーバーを開閉する。
class _ActivityGaugeButton extends HookConsumerWidget {
  const _ActivityGaugeButton({required this.kind});

  /// この項目が CPU / メモリ / ディスク / ネットワークのどれか
  /// （`none` は渡さない）。
  final ActivityPopover kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hovering = useState(false);
    final snapshot = ref.watch(activityMonitorProvider);
    final isOpen = ref.watch(activityPopoverProvider) == kind;
    final l10n = AppLocalizations.of(context);
    final spec = _gaugeSpecOf(kind, snapshot, l10n);

    // ゲージ自身もポップオーバーの TapRegion グループに含める。グループ
    // 内クリックは onTapOutside を発火させないため、ポップオーバーが開いて
    // いる状態でゲージをクリックすると「外側で閉じる」と「toggle で開閉」
    // が二重発火しない（外側 close が先行すると、その後の toggle が再オー
    // プンしてしまう）。
    return TapRegion(
      groupId: activityPopoverGroupId,
      child: MouseRegion(
        onEnter: (_) => hovering.value = true,
        onExit: (_) => hovering.value = false,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => ref.read(activityPopoverProvider.notifier).toggle(kind),
          child: Tooltip(
            message: spec.tooltip,
            child: _ActivityGauge(
              icon: spec.icon,
              ratio: spec.ratio,
              readout: spec.readout,
              active: isOpen || hovering.value,
            ),
          ),
        ),
      ),
    );
  }
}

/// ゲージ 1 つに渡す描画情報。各モニタ種別ごとに値を組み立てる。
class _GaugeSpec {
  const _GaugeSpec({
    required this.icon,
    required this.ratio,
    required this.readout,
    required this.tooltip,
  });

  final IconData icon;

  /// 0–1 に正規化した占有率。
  final double ratio;

  /// 数値の文字列（CPU/Memory は `42%`、Disk/Network は `12 MB/s`）。
  final String readout;

  final String tooltip;
}

_GaugeSpec _gaugeSpecOf(
  ActivityPopover kind,
  SystemMetricsSnapshot snapshot,
  AppLocalizations l10n,
) {
  switch (kind) {
    case ActivityPopover.cpu:
      final percent = snapshot.metrics.cpuPercent;
      final value = percent.toStringAsFixed(0);
      return _GaugeSpec(
        icon: Icons.speed,
        ratio: (percent / 100).clamp(0.0, 1.0).toDouble(),
        readout: '$value%',
        tooltip: l10n.activityMonitorCpuTooltip(value),
      );
    case ActivityPopover.memory:
      final percent = snapshot.metrics.memoryPercent;
      final value = percent.toStringAsFixed(0);
      return _GaugeSpec(
        icon: Icons.memory,
        ratio: (percent / 100).clamp(0.0, 1.0).toDouble(),
        readout: '$value%',
        tooltip: l10n.activityMonitorMemoryTooltip(value),
      );
    case ActivityPopover.disk:
      final rate = snapshot.diskBytesPerSec;
      final readable = IoRateFormat.formatBytesPerSec(rate);
      return _GaugeSpec(
        icon: Icons.storage,
        ratio: IoRateFormat.logScaleBytesPerSec(rate),
        readout: readable,
        tooltip: l10n.activityMonitorDiskTooltip(readable),
      );
    case ActivityPopover.network:
      final rate = snapshot.networkBytesPerSec;
      final readable = IoRateFormat.formatBytesPerSec(rate);
      return _GaugeSpec(
        icon: Icons.swap_vert,
        ratio: IoRateFormat.logScaleBytesPerSec(rate),
        readout: readable,
        tooltip: l10n.activityMonitorNetworkTooltip(readable),
      );
    case ActivityPopover.none:
      // 呼び出し側がガードする。フォールバックとして空表示。
      return const _GaugeSpec(
        icon: Icons.help_outline,
        ratio: 0,
        readout: '',
        tooltip: '',
      );
  }
}

/// モニタ 1 項目の見た目 — アイコン＋ミニレベルバー＋現在値。
class _ActivityGauge extends StatelessWidget {
  const _ActivityGauge({
    required this.icon,
    required this.ratio,
    required this.readout,
    required this.active,
  });

  final IconData icon;

  /// 0–1 に正規化した占有率。
  final double ratio;

  /// 現在値の文字列。`%` 単位（CPU / メモリ）または `B/s` / `KB/s` /
  /// `MB/s` / `GB/s`（ディスク / ネットワーク）。
  final String readout;

  /// ホバー中 / ポップオーバー展開中。
  final bool active;

  /// モニタの高さ（4px グリッド）。トップバー 40px の中に収める。
  static const double _height = 32;

  /// 数値表示の固定幅。`999 MB/s` までを 1 列で収めるため、CPU/Memory の
  /// `100%` よりも広い 60px を確保する（4px グリッド）。
  static const double _readoutWidth = 60;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    final tint = active ? tokens.accent : tokens.textDim;
    return Container(
      height: _height,
      padding: const EdgeInsets.symmetric(horizontal: PolarisTokens.space2),
      decoration: BoxDecoration(
        color: active ? tokens.surface : null,
        borderRadius: BorderRadius.circular(tokens.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: PolarisIconSize.small, color: tint),
          const SizedBox(width: PolarisTokens.space2),
          _LevelBar(ratio: ratio),
          const SizedBox(width: PolarisTokens.space1),
          SizedBox(
            width: _readoutWidth,
            child: Text(
              readout,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // height:1 の等幅スタイルは行ボックス内でグリフが上寄りに
              // 配置され、バー・アイコンと中心がずれて見える。leading を
              // 上下均等に分配して縦中央に揃える。
              style: tokens.mono.copyWith(
                color: tint,
                leadingDistribution: TextLeadingDistribution.even,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 占有率を示す水平レベルバー（Polaris のゲージ表現）。
///
/// 線形 / 対数の区別はバー自身は持たない。呼び出し側があらかじめ 0–1 の
/// 占有率（CPU/Memory は `value/100`、Disk/Network は対数マッピング後）に
/// 変換して渡す。
class _LevelBar extends StatelessWidget {
  const _LevelBar({required this.ratio});

  /// 0–1 に正規化した占有率。
  final double ratio;

  static const double _width = 32;
  static const double _height = 8;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return Container(
      width: _width,
      height: _height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tokens.well,
        borderRadius: BorderRadius.circular(tokens.radius),
        border: Border.all(color: tokens.line),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: ratio.clamp(0.0, 1.0),
        child: ColoredBox(color: tokens.accent),
      ),
    );
  }
}
