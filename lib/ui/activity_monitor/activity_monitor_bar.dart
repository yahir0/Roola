import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/activity_monitor/activity_monitor_popover_layer.dart';
import 'package:roola/ui/activity_monitor/activity_monitor_view_model.dart';

/// トップバーに常駐するアクティビティモニタ（ADR-0039）。
///
/// CPU とメモリを「アイコン＋ミニレベルバー」で並べ、システム全体の負荷を
/// バーの占有で示す。各モニタをクリックすると上位プロセス一覧の
/// ポップオーバー（[ActivityMonitorPopoverLayer]）が開く。メモパッド・設定
/// アイコンの左に置く。
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
      ],
    );
  }
}

/// CPU またはメモリ 1 項目ぶんのモニタ。クリックでポップオーバーを開閉する。
class _ActivityGaugeButton extends HookConsumerWidget {
  const _ActivityGaugeButton({required this.kind});

  /// この項目が CPU か メモリか（`none` は渡さない）。
  final ActivityPopover kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hovering = useState(false);
    final metrics = ref.watch(activityMonitorProvider);
    final isOpen = ref.watch(activityPopoverProvider) == kind;

    final isCpu = kind == ActivityPopover.cpu;
    final percent = isCpu ? metrics.cpuPercent : metrics.memoryPercent;
    final ratio = (percent / 100).clamp(0.0, 1.0).toDouble();
    final l10n = AppLocalizations.of(context);
    final value = percent.toStringAsFixed(0);
    final tooltip = isCpu
        ? l10n.activityMonitorCpuTooltip(value)
        : l10n.activityMonitorMemoryTooltip(value);

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
            message: tooltip,
            child: _ActivityGauge(
              icon: isCpu ? Icons.speed : Icons.memory,
              ratio: ratio,
              percent: percent,
              active: isOpen || hovering.value,
            ),
          ),
        ),
      ),
    );
  }
}

/// モニタ 1 項目の見た目 — アイコン＋ミニレベルバー＋現在値（%）。
class _ActivityGauge extends StatelessWidget {
  const _ActivityGauge({
    required this.icon,
    required this.ratio,
    required this.percent,
    required this.active,
  });

  final IconData icon;

  /// 0–1 に正規化した占有率。
  final double ratio;

  /// 占有率（0–100）。バーの横に数値表示する。
  final double percent;

  /// ホバー中 / ポップオーバー展開中。
  final bool active;

  /// モニタの高さ（4px グリッド）。トップバー 40px の中に収める。
  static const double _height = 32;

  /// 数値表示の固定幅。"100%" まで桁揺れしないよう右寄せで確保する。
  static const double _readoutWidth = 32;

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
              '${percent.round()}%',
              textAlign: TextAlign.right,
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
