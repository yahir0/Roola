import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/git/git_commit.dart';
import 'package:roola/data/git/git_graph_row.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/git/git_changes_section.dart';
import 'package:roola/ui/git/git_diff_view.dart';
import 'package:roola/ui/git/git_graph_painter.dart';
import 'package:roola/ui/git/git_view_model.dart';
import 'package:roola/ui/git/git_view_state.dart';

/// 履歴行 1 行の高さ。
const double _rowHeight = 30;

/// グラフ 1 レーンの幅。
const double _laneWidth = 14;

/// グラフ列に表示するレーン数の上限（描画幅の暴走を防ぐ）。
const int _maxLanesShown = 12;

/// Git ビューの「History」セクション本体。
///
/// コミットグラフ（`CustomPaint`）の一覧と、選択コミットの詳細（変更ファイル
/// 一覧）を表示する（ADR-0030）。
class GitHistorySection extends ConsumerWidget {
  const GitHistorySection({
    required this.tabId,
    required this.state,
    super.key,
  });

  final String tabId;
  final GitViewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.graph.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context).gitNoCommits));
    }
    final notifier = ref.read(gitViewModelProvider(tabId).notifier);
    var maxLanes = 1;
    for (final row in state.graph) {
      if (row.laneCount > maxLanes) {
        maxLanes = row.laneCount;
      }
    }
    final graphWidth =
        (maxLanes.clamp(1, _maxLanesShown)) * _laneWidth + _laneWidth;

    return Column(
      children: [
        // 履歴リストと詳細パネルはセクションの高さを flex で分け合う。
        // 詳細を固定高にするとセクションが縮んだとき収まらず溢れる。
        Expanded(
          flex: 3,
          child: ListView.builder(
            itemCount: state.graph.length + (state.hasMoreHistory ? 1 : 0),
            itemExtent: _rowHeight,
            itemBuilder: (context, index) {
              if (index >= state.graph.length) {
                return _LoadMoreRow(
                  busy: state.runningOperation == GitOperation.loadMore,
                  onPressed: notifier.loadMoreHistory,
                );
              }
              final row = state.graph[index];
              return _CommitRow(
                tabId: tabId,
                row: row,
                graphWidth: graphWidth,
                selected: row.commit.sha == state.selectedSha,
              );
            },
          ),
        ),
        if (state.selectedSha != null)
          Expanded(
            flex: 2,
            child: _CommitDetail(tabId: tabId, state: state),
          ),
      ],
    );
  }
}

class _LoadMoreRow extends StatelessWidget {
  const _LoadMoreRow({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : TextButton(
              onPressed: onPressed,
              child: Text(AppLocalizations.of(context).gitLoadMoreButton),
            ),
    );
  }
}

class _CommitRow extends ConsumerWidget {
  const _CommitRow({
    required this.tabId,
    required this.row,
    required this.graphWidth,
    required this.selected,
  });

  final String tabId;
  final GitGraphRow row;
  final double graphWidth;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gitViewModelProvider(tabId).notifier);
    final tokens = PolarisTokens.of(context);
    final commit = row.commit;

    return InkWell(
      onTap: () {
        if (selected) {
          notifier.clearSelection();
        } else {
          notifier.selectCommit(commit.sha);
        }
      },
      child: Container(
        color: selected ? tokens.surfaceHi : null,
        padding: const EdgeInsets.only(right: PolarisTokens.space2),
        child: Row(
          children: [
            SizedBox(
              width: graphWidth,
              height: _rowHeight,
              child: CustomPaint(
                painter: GitGraphPainter(
                  row: row,
                  laneWidth: _laneWidth,
                  dotRadius: 5,
                  lineWidth: 2,
                  laneColors: GitGraphPainter.paletteFor(tokens),
                  dotInnerColor: tokens.well,
                ),
              ),
            ),
            // ref ラベル・subject・作者は flex で必ず行内に収める。
            // 固定幅は日付と SHA のみ（いずれも幅が一定）。
            Expanded(
              child: Row(
                children: [
                  for (final refLabel in commit.refs.take(3))
                    Flexible(child: _RefChip(label: refLabel)),
                  Expanded(
                    flex: 5,
                    child: Text(
                      commit.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: PolarisTokens.space2),
                  Flexible(
                    flex: 2,
                    child: Text(
                      commit.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: tokens.textDim),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: PolarisTokens.space3),
            Text(
              _formatDate(commit.date),
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: tokens.textDim),
            ),
            const SizedBox(width: PolarisTokens.space3),
            Text(
              commit.shortSha,
              style: const TextStyle(fontFamily: 'SarasaTermJ', fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _RefChip extends StatelessWidget {
  const _RefChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    final isHead = label.startsWith('HEAD');
    final isTag = label.startsWith('tag:');
    final text = isTag ? label.substring(4).trim() : label;
    // 1 アクセント色のまま 3 種を塗り/枠/無彩で描き分ける（ADR-0038 D4）。
    // HEAD = アクセント塗り、タグ = アクセント枠のみ、ブランチ = surfaceHi。
    final bg = isHead
        ? tokens.accent
        : isTag
        ? Colors.transparent
        : tokens.surfaceHi;
    final fg = isHead
        ? tokens.onAccent
        : isTag
        ? tokens.accent
        : tokens.text;
    return Container(
      margin: const EdgeInsets.only(right: PolarisTokens.space1),
      padding: const EdgeInsets.symmetric(
        horizontal: PolarisTokens.space2,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: isTag ? Border.all(color: tokens.accent) : null,
        borderRadius: BorderRadius.circular(tokens.radius),
      ),
      // アイコンをインライン（WidgetSpan）にして Flex を持たせない。
      // こうすると親 Flexible が幅を極端に絞っても、Row のように
      // オーバーフローせず単に省略表示される。
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(right: PolarisTokens.space1),
                child: Icon(
                  isTag ? Icons.sell_outlined : Icons.commit,
                  size: 11,
                  color: fg,
                ),
              ),
            ),
            TextSpan(text: text),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 10, color: fg),
      ),
    );
  }
}

/// 選択コミットの詳細（メタ情報＋変更ファイル一覧）。
class _CommitDetail extends ConsumerWidget {
  const _CommitDetail({required this.tabId, required this.state});

  final String tabId;
  final GitViewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gitViewModelProvider(tabId).notifier);
    final colors = Theme.of(context).colorScheme;
    final sha = state.selectedSha!;
    final commit = _findCommit(sha);

    return Container(
      // 高さは親の Expanded から受ける（固定高にしない。上のコメント参照）。
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PolarisTokens.space3,
              PolarisTokens.space2,
              PolarisTokens.space1,
              PolarisTokens.space1,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commit?.subject ?? sha,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (commit != null)
                        Text(
                          '${commit.shortSha} · ${commit.authorName} · '
                          '${_formatDate(commit.date)}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: PolarisIconSize.standard),
                  tooltip: AppLocalizations.of(context).gitCloseDetailsTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: notifier.clearSelection,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.selectedCommitFiles.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context).gitLoadingChangedFiles,
                      style: const TextStyle(fontSize: 13),
                    ),
                  )
                : ListView(
                    children: [
                      for (final file in state.selectedCommitFiles)
                        InkWell(
                          onTap: () => showGitDiffDialog(
                            context,
                            title: file.displayPath,
                            load: () => notifier.commitFileDiff(sha, file.path),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: PolarisTokens.space3,
                              vertical: PolarisTokens.space1,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  child: Text(
                                    gitChangeLetter(file.type),
                                    style: TextStyle(
                                      color: gitChangeColor(
                                        PolarisTokens.of(context),
                                        file.type,
                                      ),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    file.displayPath,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  GitCommit? _findCommit(String sha) {
    for (final row in state.graph) {
      if (row.commit.sha == sha) {
        return row.commit;
      }
    }
    return null;
  }
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${local.year}/${two(local.month)}/${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}
