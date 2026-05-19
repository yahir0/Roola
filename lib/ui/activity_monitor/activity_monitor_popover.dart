import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/activity_metrics/process_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics_repository.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/activity_monitor/activity_monitor_view_model.dart';

/// アクティビティモニタのクリックで開く、上位プロセス一覧パネル
/// （ADR-0039 D6）。
///
/// Polaris の面（`bg` 地・1px `line` ボーダー・角丸 `radius`）。CPU /
/// メモリのどちらから開いたか（[sortKey]）でタイトルと並び順が変わる。
class ActivityMonitorPopover extends ConsumerWidget {
  const ActivityMonitorPopover({required this.sortKey, super.key});

  /// 並び替えキー。クリックされたモニタに対応する。
  final ProcessSortKey sortKey;

  /// パネル幅（4px グリッド）。プロセス名と 2 つの数値列が収まる幅。
  static const double _width = 248;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PolarisTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final processes = ref.watch(activityTopProcessesProvider(sortKey));

    final title = switch (sortKey) {
      ProcessSortKey.cpu => l10n.activityMonitorCpuPopoverTitle,
      ProcessSortKey.memory => l10n.activityMonitorMemoryPopoverTitle,
    };

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
            _Header(title: title),
            Divider(height: 1, thickness: 1, color: tokens.line),
            const _ColumnLabels(),
            processes.when(
              data: (list) => list.isEmpty
                  ? _EmptyMessage(message: l10n.activityMonitorEmpty)
                  : Column(
                      children: [
                        for (final p in list) _ProcessRow(process: p),
                      ],
                    ),
              // 取得中は空の枠を出す（スピナーは出さない / ADR-0038 D7）。
              loading: () => const SizedBox(height: PolarisTokens.space6),
              error: (_, _) =>
                  _EmptyMessage(message: l10n.activityMonitorEmpty),
            ),
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
      child: Text(
        title,
        style: tokens.label.copyWith(color: tokens.textFaint),
      ),
    );
  }
}

/// 数値列の見出し（CPU / メモリ）。
class _ColumnLabels extends StatelessWidget {
  const _ColumnLabels();

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final style = tokens.label.copyWith(color: tokens.textFaint);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PolarisTokens.space3,
        PolarisTokens.space1,
        PolarisTokens.space3,
        0,
      ),
      child: Row(
        children: [
          const Spacer(),
          SizedBox(
            width: _ProcessRow.cpuColumnWidth,
            child: Text(
              l10n.activityMonitorColumnCpu,
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
          SizedBox(
            width: _ProcessRow.memoryColumnWidth,
            child: Text(
              l10n.activityMonitorColumnMemory,
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

/// プロセス 1 行（名前・CPU%・メモリ MB）。
class _ProcessRow extends StatelessWidget {
  const _ProcessRow({required this.process});

  final ProcessMetrics process;

  /// CPU 列の幅。
  static const double cpuColumnWidth = 52;

  /// メモリ列の幅。
  static const double memoryColumnWidth = 64;

  /// 行高（4px グリッド）。
  static const double _rowHeight = 24;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    final mono = tokens.mono.copyWith(color: tokens.textDim);
    final memoryMb = (process.memoryBytes / 1024 / 1024).round();
    return SizedBox(
      height: _rowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PolarisTokens.space3),
        child: Row(
          children: [
            Expanded(
              child: Text(
                process.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tokens.meta.copyWith(color: tokens.text),
              ),
            ),
            SizedBox(
              width: cpuColumnWidth,
              child: Text(
                '${process.cpuPercent.toStringAsFixed(1)}%',
                textAlign: TextAlign.right,
                style: mono,
              ),
            ),
            SizedBox(
              width: memoryColumnWidth,
              child: Text(
                '$memoryMb MB',
                textAlign: TextAlign.right,
                style: mono,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// プロセス情報が無い / 取得失敗時のプレースホルダ。
class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PolarisTokens.space3,
        vertical: PolarisTokens.space3,
      ),
      child: Text(
        message,
        style: tokens.meta.copyWith(color: tokens.textFaint),
      ),
    );
  }
}
