import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/skill_session/adhoc_run_args.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/ui/git/git_changes_section.dart';
import 'package:roola/ui/git/git_history_section.dart';
import 'package:roola/ui/git/git_toolbar.dart';
import 'package:roola/ui/git/git_view_model.dart';
import 'package:roola/ui/git/git_view_state.dart';
import 'package:roola/ui/workspace/current_tab_id_provider.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// 狭幅レイアウトで切り替える表示セクション。
enum _Section { changes, history }

/// Git ビュータブ 1 つ分の body（ADR-0030）。
///
/// `currentTabIdProvider` から自タブ id を取得し、per-tab の
/// `gitViewModelProvider(tabId)` を購読する（ADR-0027）。ツールバー・
/// 通知バー・Changes / History セクションを縦に積む。
class GitTabBody extends ConsumerWidget {
  const GitTabBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabId = ref.watch(currentTabIdProvider);
    final async = ref.watch(gitViewModelProvider(tabId));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _GitErrorView(tabId: tabId, error: error),
      data: (state) => state.gitMissing
          ? const _GitMissingView()
          : _GitWorkspace(tabId: tabId, state: state),
    );
  }
}

class _GitErrorView extends ConsumerWidget {
  const _GitErrorView({required this.tabId, required this.error});

  final String tabId;
  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 40),
          const SizedBox(height: 8),
          Text('Git 情報の取得に失敗しました\n$error', textAlign: TextAlign.center),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('再試行'),
            onPressed: () => ref.invalidate(gitViewModelProvider(tabId)),
          ),
        ],
      ),
    );
  }
}

class _GitMissingView extends StatelessWidget {
  const _GitMissingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.terminal, size: 40),
            const SizedBox(height: 8),
            Text(
              'git コマンドが見つかりません',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            const Text(
              'Git ビューを使うには git をインストールし、'
              'PATH を通してください。',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _GitWorkspace extends HookWidget {
  const _GitWorkspace({required this.tabId, required this.state});

  final String tabId;
  final GitViewState state;

  /// この幅未満では Changes / History をセグメント切替にする。
  static const double _narrowThreshold = 420;

  @override
  Widget build(BuildContext context) {
    final changesCollapsed = useState(false);
    final historyCollapsed = useState(false);
    final narrowSection = useState(_Section.changes);
    final changedCount =
        (state.status?.staged.length ?? 0) +
        (state.status?.unstaged.length ?? 0);

    return Column(
      children: [
        GitToolbar(tabId: tabId, state: state),
        if (state.notice != null)
          _GitNoticeBar(tabId: tabId, notice: state.notice!),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < _narrowThreshold) {
                return _NarrowBody(
                  tabId: tabId,
                  state: state,
                  section: narrowSection,
                  changedCount: changedCount,
                );
              }
              return _WideBody(
                tabId: tabId,
                state: state,
                changesCollapsed: changesCollapsed,
                historyCollapsed: historyCollapsed,
                changedCount: changedCount,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WideBody extends StatelessWidget {
  const _WideBody({
    required this.tabId,
    required this.state,
    required this.changesCollapsed,
    required this.historyCollapsed,
    required this.changedCount,
  });

  final String tabId;
  final GitViewState state;
  final ValueNotifier<bool> changesCollapsed;
  final ValueNotifier<bool> historyCollapsed;
  final int changedCount;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      _SectionHeader(
        title: 'Changes',
        count: changedCount,
        collapsed: changesCollapsed.value,
        onToggle: () => changesCollapsed.value = !changesCollapsed.value,
      ),
    ];
    if (!changesCollapsed.value) {
      children.add(
        Expanded(
          // Changes セクションを既定で広めに取り、ファイル一覧が
          // コミット欄に潰されないようにする。
          flex: historyCollapsed.value ? 1 : 3,
          child: GitChangesSection(tabId: tabId, state: state),
        ),
      );
    }
    children.add(const Divider(height: 1));
    children.add(
      _SectionHeader(
        title: 'History',
        count: state.graph.length,
        collapsed: historyCollapsed.value,
        onToggle: () => historyCollapsed.value = !historyCollapsed.value,
      ),
    );
    if (!historyCollapsed.value) {
      children.add(
        Expanded(
          flex: changesCollapsed.value ? 1 : 2,
          child: GitHistorySection(tabId: tabId, state: state),
        ),
      );
    }
    if (changesCollapsed.value && historyCollapsed.value) {
      children.add(const Expanded(child: SizedBox.shrink()));
    }
    return Column(children: children);
  }
}

class _NarrowBody extends StatelessWidget {
  const _NarrowBody({
    required this.tabId,
    required this.state,
    required this.section,
    required this.changedCount,
  });

  final String tabId;
  final GitViewState state;
  final ValueNotifier<_Section> section;
  final int changedCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: SegmentedButton<_Section>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: _Section.changes,
                label: Text('Changes ($changedCount)'),
              ),
              ButtonSegment(
                value: _Section.history,
                label: Text('History (${state.graph.length})'),
              ),
            ],
            selected: {section.value},
            onSelectionChanged: (s) => section.value = s.first,
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: switch (section.value) {
            _Section.changes => GitChangesSection(tabId: tabId, state: state),
            _Section.history => GitHistorySection(tabId: tabId, state: state),
          },
        ),
      ],
    );
  }
}

/// 折りたたみ可能なセクションの見出しバー。
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.collapsed,
    required this.onToggle,
  });

  final String title;
  final int count;
  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onToggle,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        child: Row(
          children: [
            Icon(collapsed ? Icons.chevron_right : Icons.expand_more, size: 18),
            const SizedBox(width: 2),
            Text(
              '$title  $count',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// 同期失敗などの通知バー。`offerTerminal` のときターミナル誘導を出す。
class _GitNoticeBar extends ConsumerWidget {
  const _GitNoticeBar({required this.tabId, required this.notice});

  final String tabId;
  final GitNotice notice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isError = notice.kind == GitNoticeKind.error;
    final bg = isError ? colors.errorContainer : colors.surfaceContainerHighest;
    final fg = isError ? colors.onErrorContainer : colors.onSurface;

    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.info_outline,
            size: 15,
            color: fg,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              notice.message,
              style: TextStyle(color: fg, fontSize: 12),
            ),
          ),
          if (notice.offerTerminal)
            TextButton(
              onPressed: () => _openTerminal(ref),
              child: const Text('ターミナルで開く'),
            ),
          IconButton(
            icon: Icon(Icons.close, size: 15, color: fg),
            tooltip: '閉じる',
            visualDensity: VisualDensity.compact,
            onPressed: () =>
                ref.read(gitViewModelProvider(tabId).notifier).dismissNotice(),
          ),
        ],
      ),
    );
  }

  /// リポジトリルートを作業ディレクトリにしたターミナルタブを開く
  /// （ADR-0030 / design D7）。
  void _openTerminal(WidgetRef ref) {
    final state = ref.read(gitViewModelProvider(tabId)).value;
    final repoRoot = state?.repoRoot;
    if (repoRoot == null || repoRoot.isEmpty) {
      return;
    }
    final name = repoRoot.split('/').where((s) => s.isNotEmpty).toList();
    ref
        .read(workspaceProvider.notifier)
        .addTerminalTab(
          PaneSlotId.bottom,
          args: AdhocRunArgs(
            adhocId: 'adhoc-${_uuid.v4()}',
            workingDirectory: repoRoot,
            displayName: '${name.isEmpty ? repoRoot : name.last} (git)',
            action: const LauncherAction.openHere(),
          ),
        );
  }
}
