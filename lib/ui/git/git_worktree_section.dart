import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:roola/app/theme.dart';
import 'package:roola/core/health/claude_health_check.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_dialog.dart';
import 'package:roola/ui/git/git_dialogs.dart';
import 'package:roola/ui/git/git_view_model.dart';
import 'package:roola/ui/git/git_view_state.dart';
import 'package:roola/ui/git/worktree_create_dialog.dart';

/// Git ビューの worktree セクション（ADR-0067）。
///
/// 一覧（本体含む）・状態（dirty / ahead/behind / マージ済み / 孤児）の表示と、
/// 作成（「+」）・ここで開く・削除・マージ済み掃除・整理（prune）・修復
/// （repair）の導線を提供する。worktree 数は少数前提なので一覧は
/// shrink-wrap で描画し、本体の Changes / History の領域配分には干渉しない。
class GitWorktreeSection extends HookConsumerWidget {
  const GitWorktreeSection({super.key, required this.tabId, required this.state});

  final String tabId;
  final GitViewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = PolarisTokens.of(context);
    // 並列作業中（worktree が本体以外にもある）なら開いた状態で始める。
    final collapsed = useState(state.worktrees.length <= 1);
    final hasPrunable = state.worktrees.any((e) => e.worktree.isPrunable);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: PolarisTokens.space2),
          color: tokens.surface,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => collapsed.value = !collapsed.value,
                  child: Row(
                    children: [
                      Icon(
                        collapsed.value
                            ? Icons.chevron_right
                            : Icons.expand_more,
                        size: PolarisIconSize.standard,
                        color: tokens.textDim,
                      ),
                      const SizedBox(width: PolarisTokens.space1),
                      Text(
                        l10n.worktreeSectionTitle.toUpperCase(),
                        style: tokens.label.copyWith(color: tokens.textDim),
                      ),
                      const SizedBox(width: PolarisTokens.space2),
                      Text(
                        '${state.worktrees.length}',
                        style: tokens.mono.copyWith(color: tokens.textFaint),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add,
                  size: PolarisIconSize.standard,
                  color: tokens.textDim,
                ),
                tooltip: l10n.worktreeCreateTooltip,
                visualDensity: VisualDensity.compact,
                onPressed: state.isBusy
                    ? null
                    : () =>
                          runCreateWorktree(context, ref, repoRoot: state.repoRoot),
              ),
              PopupMenuButton<_SectionMenu>(
                icon: Icon(
                  Icons.more_horiz,
                  size: PolarisIconSize.standard,
                  color: tokens.textDim,
                ),
                tooltip: l10n.gitToolbarOverflowTooltip,
                onSelected: (action) => switch (action) {
                  _SectionMenu.prune => ref
                      .read(gitViewModelProvider(tabId).notifier)
                      .pruneWorktrees(),
                  _SectionMenu.repair => ref
                      .read(gitViewModelProvider(tabId).notifier)
                      .repairWorktrees(),
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _SectionMenu.prune,
                    enabled: !state.isBusy,
                    child: Text(l10n.worktreeMenuPrune),
                  ),
                  PopupMenuItem(
                    value: _SectionMenu.repair,
                    enabled: !state.isBusy,
                    child: Text(l10n.worktreeMenuRepair),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!collapsed.value) ...[
          if (hasPrunable)
            Container(
              width: double.infinity,
              color: tokens.surface,
              padding: const EdgeInsets.fromLTRB(
                PolarisTokens.space3,
                0,
                PolarisTokens.space3,
                PolarisTokens.space1,
              ),
              child: Text(
                l10n.worktreePrunableHint,
                style: tokens.meta.copyWith(color: tokens.textDim),
              ),
            ),
          for (final entry in state.worktrees)
            _WorktreeRow(tabId: tabId, state: state, entry: entry),
          const Divider(height: 1),
        ],
      ],
    );
  }
}

enum _SectionMenu { prune, repair }

enum _RowMenu { openTerminal, openClaude, cleanup, remove }

class _WorktreeRow extends ConsumerWidget {
  const _WorktreeRow({
    required this.tabId,
    required this.state,
    required this.entry,
  });

  final String tabId;
  final GitViewState state;
  final GitWorktreeEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = PolarisTokens.of(context);
    final wt = entry.worktree;
    final summary = entry.summary;
    final claudeAvailable = ref.watch(claudeAvailableProvider);

    // detached HEAD は短縮ハッシュをブランチ表示の代わりに使う（design D4）。
    final title =
        wt.branch ??
        (wt.head.length >= 7 ? wt.head.substring(0, 7) : wt.head);

    return Container(
      height: 28,
      padding: const EdgeInsets.only(left: PolarisTokens.space3),
      child: Row(
        children: [
          Icon(
            wt.isMain ? Icons.home_outlined : Icons.fork_right,
            size: PolarisIconSize.small,
            color: tokens.textDim,
          ),
          const SizedBox(width: PolarisTokens.space2),
          Text(
            title,
            style: tokens.body.copyWith(
              color: wt.isPrunable ? tokens.textFaint : tokens.text,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: PolarisTokens.space2),
          Expanded(
            child: Text(
              p.basename(wt.path),
              style: tokens.meta.copyWith(color: tokens.textFaint),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (wt.isMain) _Chip(label: l10n.worktreeChipMain),
          if (wt.isPrunable)
            _Chip(label: l10n.worktreeChipPrunable, color: tokens.signalConflict)
          else ...[
            if (summary?.isDirty ?? false)
              _Chip(label: l10n.worktreeChipDirty, color: tokens.accent),
            if ((summary?.ahead ?? 0) > 0 || (summary?.behind ?? 0) > 0)
              _Chip(label: '↑${summary!.ahead} ↓${summary.behind}'),
            if (entry.isMerged) _Chip(label: l10n.worktreeChipMerged),
          ],
          if (wt.isMain || wt.isPrunable)
            // 行高さを揃えるためのスペーサ（メニュー無し行）。
            const SizedBox(width: 40)
          else
            PopupMenuButton<_RowMenu>(
              icon: Icon(
                Icons.more_horiz,
                size: PolarisIconSize.small,
                color: tokens.textDim,
              ),
              tooltip: l10n.gitToolbarOverflowTooltip,
              onSelected: (action) => _handle(context, ref, action),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _RowMenu.openTerminal,
                  child: Text(l10n.worktreeMenuOpenTerminal),
                ),
                if (claudeAvailable)
                  PopupMenuItem(
                    value: _RowMenu.openClaude,
                    child: Text(l10n.worktreeMenuOpenClaude),
                  ),
                const PopupMenuDivider(),
                if (entry.isMerged)
                  PopupMenuItem(
                    value: _RowMenu.cleanup,
                    enabled: !state.isBusy,
                    child: Text(l10n.worktreeMenuCleanup),
                  ),
                PopupMenuItem(
                  value: _RowMenu.remove,
                  enabled: !state.isBusy,
                  child: Text(l10n.worktreeMenuRemove),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    _RowMenu action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(gitViewModelProvider(tabId).notifier);
    switch (action) {
      case _RowMenu.openTerminal:
        openWorktreeShellTab(ref, worktreePath: entry.worktree.path);
      case _RowMenu.openClaude:
        openWorktreeClaudeTab(ref, worktreePath: entry.worktree.path);
      case _RowMenu.cleanup:
        final ok = await gitConfirm(
          context,
          title: l10n.worktreeCleanupTitle,
          message: l10n.worktreeCleanupMessage(
            entry.worktree.branch ?? '',
            state.defaultBranchName ?? '',
          ),
          confirmLabel: l10n.worktreeCleanupButton,
        );
        if (ok) {
          await notifier.cleanupWorktree(entry);
        }
      case _RowMenu.remove:
        final result = await _showRemoveDialog(context, entry);
        if (result != null) {
          await notifier.removeWorktree(
            entry,
            force: result.force,
            deleteBranch: result.deleteBranch,
          );
        }
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: PolarisTokens.space2),
      child: Text(
        label,
        style: tokens.meta.copyWith(color: color ?? tokens.textDim),
      ),
    );
  }
}

/// 削除ダイアログの結果。
typedef _RemoveChoice = ({bool force, bool deleteBranch});

/// worktree 削除の確認ダイアログ（design D5）。
///
/// dirty な worktree では「未コミットの変更ごと削除される」警告を出し、
/// 確定ボタンを破壊色にする（force 削除）。「ブランチも削除」は既定 OFF で、
/// 未マージブランチを消す場合はコミットが失われうる旨を併記する。
Future<_RemoveChoice?> _showRemoveDialog(
  BuildContext context,
  GitWorktreeEntry entry,
) {
  final isDirty = entry.summary?.isDirty ?? false;
  return showDialog<_RemoveChoice>(
    context: context,
    builder: (context) => _RemoveDialog(entry: entry, isDirty: isDirty),
  );
}

class _RemoveDialog extends HookWidget {
  const _RemoveDialog({required this.entry, required this.isDirty});

  final GitWorktreeEntry entry;
  final bool isDirty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = PolarisTokens.of(context);
    final deleteBranch = useState(false);
    final branch = entry.worktree.branch;

    return PolarisDialog(
      title: l10n.worktreeRemoveTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.worktreeRemoveMessage(p.basename(entry.worktree.path)),
            style: tokens.body.copyWith(color: tokens.textDim),
          ),
          if (isDirty) ...[
            const SizedBox(height: PolarisTokens.space2),
            Text(
              l10n.worktreeRemoveDirtyWarning,
              style: tokens.body.copyWith(color: tokens.signalConflict),
            ),
          ],
          if (branch != null) ...[
            const SizedBox(height: PolarisTokens.space3),
            InkWell(
              onTap: () => deleteBranch.value = !deleteBranch.value,
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: Checkbox(
                      value: deleteBranch.value,
                      onChanged: (v) => deleteBranch.value = v ?? false,
                    ),
                  ),
                  const SizedBox(width: PolarisTokens.space2),
                  Expanded(
                    child: Text(
                      l10n.worktreeRemoveBranchToo(branch),
                      style: tokens.body.copyWith(color: tokens.text),
                    ),
                  ),
                ],
              ),
            ),
            if (deleteBranch.value && !entry.isMerged) ...[
              const SizedBox(height: PolarisTokens.space2),
              Text(
                l10n.worktreeRemoveUnmergedBranchWarning,
                style: tokens.meta.copyWith(color: tokens.signalConflict),
              ),
            ],
          ],
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(
          style: isDirty
              ? FilledButton.styleFrom(
                  backgroundColor: tokens.signalConflict,
                  foregroundColor: tokens.text,
                )
              : null,
          onPressed: () => Navigator.of(context).pop((
            force: isDirty,
            deleteBranch: deleteBranch.value,
          )),
          child: Text(
            isDirty
                ? l10n.worktreeRemoveForceButton
                : l10n.worktreeRemoveButton,
          ),
        ),
      ],
    );
  }
}
