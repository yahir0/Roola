import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/activity_metrics/process_metrics.dart';
import 'package:roola/data/activity_metrics/system_metrics_repository.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/activity_monitor/activity_monitor_view_model.dart';
import 'package:roola/ui/activity_monitor/io_rate_format.dart';

/// アクティビティモニタのクリックで開く、上位プロセス一覧パネル
/// （ADR-0039 D6 / ADR-0048）。
///
/// Polaris の面（`bg` 地・1px `line` ボーダー・角丸 `radius`）。CPU /
/// メモリ / ディスク / ネットワークのどれから開いたか（[sortKey]）でタイトル
/// と表示列が変わる。CPU / メモリは CPU% + Memory MB の 2 列、ディスク /
/// ネットワークは I/O レート 1 列を表示する。
class ActivityMonitorPopover extends ConsumerWidget {
  const ActivityMonitorPopover({required this.sortKey, super.key});

  /// 並び替えキー。クリックされたモニタに対応する。
  final ProcessSortKey sortKey;

  /// パネル幅（4px グリッド）。プロセス名と数値列が収まる幅。
  static const double _width = 248;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PolarisTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final processes = ref.watch(activityTopProcessesProvider(sortKey));

    final title = switch (sortKey) {
      ProcessSortKey.cpu => l10n.activityMonitorCpuPopoverTitle,
      ProcessSortKey.memory => l10n.activityMonitorMemoryPopoverTitle,
      ProcessSortKey.disk => l10n.activityMonitorDiskPopoverTitle,
      ProcessSortKey.network => l10n.activityMonitorNetworkPopoverTitle,
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
            _ColumnLabels(sortKey: sortKey),
            processes.when(
              data: (list) => list.isEmpty
                  ? _EmptyMessage(message: l10n.activityMonitorEmpty)
                  : Column(
                      children: [
                        for (final p in list)
                          _ProcessRow(process: p, sortKey: sortKey),
                      ],
                    ),
              // 取得中は空の枠を出す（スピナーは出さない / ADR-0038 D7）。
              // disk / network は 1 秒サンプリングのため最大 1 秒待たされる。
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
      child: Text(title, style: tokens.label.copyWith(color: tokens.textFaint)),
    );
  }
}

/// 数値列の見出し。CPU/Memory は 2 列（CPU・メモリ）、Disk/Network は 1 列
/// （I/O）。
class _ColumnLabels extends StatelessWidget {
  const _ColumnLabels({required this.sortKey});

  final ProcessSortKey sortKey;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final style = tokens.label.copyWith(color: tokens.textFaint);
    final isIoMode =
        sortKey == ProcessSortKey.disk || sortKey == ProcessSortKey.network;
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
          if (isIoMode)
            SizedBox(
              width: _ProcessRow.ioColumnWidth,
              child: Text(
                l10n.activityMonitorColumnIo,
                textAlign: TextAlign.right,
                style: style,
              ),
            )
          else ...[
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
        ],
      ),
    );
  }
}

/// プロセス 1 行。CPU/Memory ソート時は CPU% + Memory MB、Disk/Network ソート
/// 時は I/O レート（人間可読単位）を表示する。
class _ProcessRow extends StatelessWidget {
  const _ProcessRow({required this.process, required this.sortKey});

  final ProcessMetrics process;
  final ProcessSortKey sortKey;

  /// CPU 列の幅。
  static const double cpuColumnWidth = 52;

  /// メモリ列の幅。
  static const double memoryColumnWidth = 64;

  /// I/O 列の幅（`999 MB/s` までを 1 列に収める）。
  static const double ioColumnWidth = 80;

  /// 行高（4px グリッド）。
  static const double _rowHeight = 24;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    final mono = tokens.mono.copyWith(color: tokens.textDim);
    final isIoMode =
        sortKey == ProcessSortKey.disk || sortKey == ProcessSortKey.network;
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
            if (isIoMode)
              SizedBox(
                width: ioColumnWidth,
                child: Text(
                  IoRateFormat.formatBytesPerSec(
                    process.ioBytesPerSec.toDouble(),
                  ),
                  textAlign: TextAlign.right,
                  style: mono,
                ),
              )
            else ...[
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
                  '${(process.memoryBytes / 1024 / 1024).round()} MB',
                  textAlign: TextAlign.right,
                  style: mono,
                ),
              ),
            ],
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
