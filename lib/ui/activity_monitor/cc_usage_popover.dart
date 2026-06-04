import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/activity_monitor/cc_usage_format.dart';
import 'package:roola/ui/activity_monitor/cc_usage_view_model.dart';

/// 使用量メーターのクリックで開く、当日の Claude Code 使用量内訳パネル
/// （ADR-0060）。
///
/// トークン種別別（入力 / 出力 / キャッシュ読取 / キャッシュ書込）の合計と、
/// 総トークン・推定コストを並べる。アクティビティモニタの上位プロセスパネル
/// （ADR-0039）と同じ Polaris の面（`bg` 地・1px `line` ボーダー・角丸）。
/// レートリミット残量は表示しない（取得手段が無いため／ADR-0060）。
class CcUsagePopover extends ConsumerWidget {
  const CcUsagePopover({super.key});

  /// パネル幅（4px グリッド）。ラベルと数値列が収まる幅。
  static const double _width = 248;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PolarisTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final usage = ref.watch(ccUsageProvider);

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: _width,
        decoration: BoxDecoration(
          color: tokens.bg,
          borderRadius: BorderRadius.circular(tokens.radius),
          border: Border.all(color: tokens.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(title: l10n.ccUsagePopoverTitle),
            Divider(height: 1, thickness: 1, color: tokens.line),
            _Row(
              label: l10n.ccUsageRowInput,
              value: CcUsageFormat.groupedTokens(usage.inputTokens),
            ),
            _Row(
              label: l10n.ccUsageRowOutput,
              value: CcUsageFormat.groupedTokens(usage.outputTokens),
            ),
            _Row(
              label: l10n.ccUsageRowCacheRead,
              value: CcUsageFormat.groupedTokens(usage.cacheReadTokens),
            ),
            _Row(
              label: l10n.ccUsageRowCacheWrite,
              value: CcUsageFormat.groupedTokens(usage.cacheCreationTokens),
            ),
            Divider(height: 1, thickness: 1, color: tokens.line),
            _Row(
              label: l10n.ccUsageRowTotal,
              value: CcUsageFormat.groupedTokens(usage.totalTokens),
              emphasize: true,
            ),
            _Row(
              label: l10n.ccUsageRowCost,
              value: CcUsageFormat.cost(usage.estimatedCostUsd),
              emphasize: true,
            ),
            _EstimateNote(text: l10n.ccUsageEstimateNote),
          ],
        ),
      ),
    );
  }
}

/// パネル見出し。
class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PolarisTokens.space3,
        vertical: PolarisTokens.space2,
      ),
      child: Text(title, style: tokens.label.copyWith(color: tokens.textFaint)),
    );
  }
}

/// ラベル＋数値の 1 行。[emphasize] は合計・コスト行を強調する。
class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  /// 行高（4px グリッド）。
  static const double _rowHeight = 24;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    final labelColor = emphasize ? tokens.text : tokens.textDim;
    final valueColor = emphasize ? tokens.accent : tokens.textDim;
    return SizedBox(
      height: _rowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PolarisTokens.space3),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tokens.meta.copyWith(color: labelColor),
              ),
            ),
            Text(value, style: tokens.mono.copyWith(color: valueColor)),
          ],
        ),
      ),
    );
  }
}

/// 「コストは推定」である旨の注記（ADR-0060 / レートリミット非表示）。
class _EstimateNote extends StatelessWidget {
  const _EstimateNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PolarisTokens.space3,
        PolarisTokens.space2,
        PolarisTokens.space3,
        PolarisTokens.space3,
      ),
      child: Text(text, style: tokens.meta.copyWith(color: tokens.textFaint)),
    );
  }
}
