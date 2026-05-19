import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/git/git_status.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/git/git_dialogs.dart';
import 'package:roola/ui/git/git_diff_view.dart';
import 'package:roola/ui/git/git_view_model.dart';
import 'package:roola/ui/git/git_view_state.dart';

/// 変更種別を表す 1 文字バッジ。
String gitChangeLetter(GitChangeType type) => switch (type) {
  GitChangeType.modified => 'M',
  GitChangeType.added => 'A',
  GitChangeType.deleted => 'D',
  GitChangeType.renamed => 'R',
  GitChangeType.copied => 'C',
  GitChangeType.untracked => 'U',
  GitChangeType.conflicted => '!',
  GitChangeType.typeChanged => 'T',
};

/// 変更種別の信号色（Polaris / ADR-0038 D5）。
///
/// 新規（added / untracked）= green、変更（modified / renamed / copied /
/// typeChanged）= steel blue、削除・コンフリクト（deleted / conflicted）
/// = red。色＝意味として扱い、変更色はアクセントのゴールドと区別する。
Color gitChangeColor(PolarisTokens tokens, GitChangeType type) =>
    switch (type) {
      GitChangeType.modified => tokens.signalModified,
      GitChangeType.added => tokens.signalNew,
      GitChangeType.deleted => tokens.signalConflict,
      GitChangeType.renamed => tokens.signalModified,
      GitChangeType.copied => tokens.signalModified,
      GitChangeType.untracked => tokens.signalNew,
      GitChangeType.conflicted => tokens.signalConflict,
      GitChangeType.typeChanged => tokens.signalModified,
    };

/// Git ビューの「Changes」セクション本体。
///
/// Staged / Unstaged のファイル一覧、stage / unstage / discard 操作、コミット
/// メッセージ入力欄と Commit ボタンを持つ（ADR-0030）。
class GitChangesSection extends HookConsumerWidget {
  const GitChangesSection({
    required this.tabId,
    required this.state,
    super.key,
  });

  final String tabId;
  final GitViewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gitViewModelProvider(tabId).notifier);
    final l10n = AppLocalizations.of(context);
    final messageController = useTextEditingController();
    // メッセージ欄の入力で Commit ボタンの活性を切り替えるため再ビルドさせる。
    useListenable(messageController);

    final status = state.status;
    if (status == null) {
      return const SizedBox.shrink();
    }
    final conflicts = [
      ...status.staged.where((c) => c.type == GitChangeType.conflicted),
      ...status.unstaged.where((c) => c.type == GitChangeType.conflicted),
    ];
    final unstaged = status.unstaged
        .where((c) => c.type != GitChangeType.conflicted)
        .toList();

    final canCommit =
        status.staged.isNotEmpty &&
        messageController.text.trim().isNotEmpty &&
        !state.isBusy;

    Future<void> doCommit({bool amend = false, bool thenPush = false}) async {
      final message = messageController.text.trim();
      await notifier.commit(message, amend: amend);
      // 失敗していなければメッセージ欄をクリアする。
      final latest = ref.read(gitViewModelProvider(tabId)).value;
      if (latest != null && latest.notice == null) {
        messageController.clear();
        if (thenPush) {
          await notifier.push();
        }
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // ペインが極端に低いとコミット欄が縦に収まらない。コミット欄の高さを
        // 「セクション高 − Divider」までに制限し、収まらない分は内部スクロール
        // させることで、Column のオーバーフローを防ぐ。
        final commitMaxHeight = (constraints.maxHeight - 1).clamp(
          0.0,
          double.infinity,
        );
        return Column(
          children: [
            Expanded(
              child: status.isClean
                  ? const _CleanPlaceholder()
                  : ListView(
                      padding: const EdgeInsets.only(
                        bottom: PolarisTokens.space2,
                      ),
                      children: [
                        if (conflicts.isNotEmpty)
                          _ChangeGroup(
                            tabId: tabId,
                            title: l10n.gitConflicts,
                            changes: conflicts,
                            state: state,
                          ),
                        if (status.staged.isNotEmpty)
                          _ChangeGroup(
                            tabId: tabId,
                            title: l10n.gitStaged,
                            changes: status.staged,
                            state: state,
                            onUnstageAll: notifier.unstageAll,
                          ),
                        if (unstaged.isNotEmpty)
                          _ChangeGroup(
                            tabId: tabId,
                            title: l10n.gitTabChanges,
                            changes: unstaged,
                            state: state,
                            onStageAll: notifier.stageAll,
                            onDiscardAll: () async {
                              final ok = await gitConfirm(
                                context,
                                title: l10n.gitDiscardChangeTooltip,
                                message: l10n.gitDiscardAllConfirmMessage(
                                  unstaged.length,
                                ),
                                confirmLabel: l10n.buttonDiscard,
                              );
                              if (ok) {
                                await notifier.discard(unstaged);
                              }
                            },
                          ),
                      ],
                    ),
            ),
            const Divider(height: 1),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: commitMaxHeight),
              child: SingleChildScrollView(
                child: _CommitBox(
                  controller: messageController,
                  canCommit: canCommit,
                  busy: state.isBusy,
                  onCommit: doCommit,
                  onCommitAndPush: () => doCommit(thenPush: true),
                  onAmend: () => doCommit(amend: true),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CleanPlaceholder extends StatelessWidget {
  const _CleanPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: PolarisIconSize.hero,
            color: colors.primary,
          ),
          const SizedBox(height: PolarisTokens.space2),
          Text(AppLocalizations.of(context).gitWorkingTreeClean),
        ],
      ),
    );
  }
}

class _ChangeGroup extends ConsumerWidget {
  const _ChangeGroup({
    required this.tabId,
    required this.title,
    required this.changes,
    required this.state,
    this.onStageAll,
    this.onUnstageAll,
    this.onDiscardAll,
  });

  final String tabId;
  final String title;
  final List<GitFileChange> changes;
  final GitViewState state;
  final VoidCallback? onStageAll;
  final VoidCallback? onUnstageAll;
  final VoidCallback? onDiscardAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 26,
          padding: const EdgeInsets.only(
            left: PolarisTokens.space3,
            right: PolarisTokens.space1,
          ),
          color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
          child: Row(
            children: [
              Text(
                '$title (${changes.length})',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const Spacer(),
              if (onStageAll != null)
                _GroupAction(
                  icon: Icons.add,
                  tooltip: l10n.gitStageAll,
                  enabled: !state.isBusy,
                  onPressed: onStageAll!,
                ),
              if (onDiscardAll != null)
                _GroupAction(
                  icon: Icons.undo,
                  tooltip: l10n.gitDiscardAllTooltip,
                  enabled: !state.isBusy,
                  onPressed: onDiscardAll!,
                ),
              if (onUnstageAll != null)
                _GroupAction(
                  icon: Icons.remove,
                  tooltip: l10n.gitUnstageAll,
                  enabled: !state.isBusy,
                  onPressed: onUnstageAll!,
                ),
            ],
          ),
        ),
        for (final change in changes)
          _ChangeRow(tabId: tabId, change: change, busy: state.isBusy),
      ],
    );
  }
}

class _GroupAction extends StatelessWidget {
  const _GroupAction({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: PolarisIconSize.small),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      onPressed: enabled ? onPressed : null,
    );
  }
}

class _ChangeRow extends ConsumerWidget {
  const _ChangeRow({
    required this.tabId,
    required this.change,
    required this.busy,
  });

  final String tabId;
  final GitFileChange change;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gitViewModelProvider(tabId).notifier);
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onDoubleTap: change.type == GitChangeType.untracked
          ? null
          : () => showGitDiffDialog(
              context,
              title: change.displayPath,
              load: () =>
                  notifier.workingFileDiff(change.path, staged: change.staged),
            ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: PolarisTokens.space3,
          right: PolarisTokens.space1,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              child: Text(
                gitChangeLetter(change.type),
                style: TextStyle(
                  color: gitChangeColor(PolarisTokens.of(context), change.type),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: PolarisTokens.space1,
                ),
                child: Text(
                  change.displayPath,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            if (!change.staged) ...[
              _RowAction(
                icon: Icons.undo,
                tooltip: l10n.gitDiscardChangeTooltip,
                color: colors.error,
                enabled: !busy,
                onPressed: () async {
                  final ok = await gitConfirm(
                    context,
                    title: l10n.gitDiscardChangeTooltip,
                    message: l10n.gitDiscardFileConfirmMessage(
                      change.displayPath,
                    ),
                    confirmLabel: l10n.buttonDiscard,
                  );
                  if (ok) {
                    await notifier.discard([change]);
                  }
                },
              ),
              _RowAction(
                icon: Icons.add,
                tooltip: l10n.gitStage,
                enabled: !busy,
                onPressed: () => notifier.stage([change]),
              ),
            ] else
              _RowAction(
                icon: Icons.remove,
                tooltip: l10n.gitUnstage,
                enabled: !busy,
                onPressed: () => notifier.unstage([change]),
              ),
          ],
        ),
      ),
    );
  }
}

class _RowAction extends StatelessWidget {
  const _RowAction({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: PolarisIconSize.small),
      tooltip: tooltip,
      color: color,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      onPressed: enabled ? onPressed : null,
    );
  }
}

/// コミットメッセージ入力欄と Commit ボタン。
class _CommitBox extends StatelessWidget {
  const _CommitBox({
    required this.controller,
    required this.canCommit,
    required this.busy,
    required this.onCommit,
    required this.onCommitAndPush,
    required this.onAmend,
  });

  final TextEditingController controller;
  final bool canCommit;
  final bool busy;
  final VoidCallback onCommit;
  final VoidCallback onCommitAndPush;
  final VoidCallback onAmend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PolarisTokens.space2,
        PolarisTokens.space2,
        PolarisTokens.space2,
        PolarisTokens.space2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            minLines: 1,
            maxLines: 3,
            style: Theme.of(context).textTheme.bodySmall,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).gitCommitMessageHint,
            ),
          ),
          const SizedBox(height: PolarisTokens.space2),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.check, size: PolarisIconSize.standard),
                  label: Text(AppLocalizations.of(context).gitCommitButton),
                  onPressed: canCommit ? onCommit : null,
                ),
              ),
              const SizedBox(width: PolarisTokens.space1),
              PopupMenuButton<_CommitMenu>(
                enabled: !busy,
                tooltip: AppLocalizations.of(context).gitCommitOptionsTooltip,
                onSelected: (value) => switch (value) {
                  _CommitMenu.commitAndPush => onCommitAndPush(),
                  _CommitMenu.amend => onAmend(),
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _CommitMenu.commitAndPush,
                    enabled: canCommit,
                    child: ListTile(
                      leading: const Icon(Icons.upload),
                      title: Text(
                        AppLocalizations.of(context).gitCommitAndPush,
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: _CommitMenu.amend,
                    enabled: canCommit,
                    child: ListTile(
                      leading: const Icon(Icons.edit_note),
                      title: Text(
                        AppLocalizations.of(context).gitAmendPreviousCommit,
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _CommitMenu { commitAndPush, amend }
