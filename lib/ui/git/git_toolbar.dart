import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/git/git_stash_entry.dart';
import 'package:roola/ui/git/git_branch_menu.dart';
import 'package:roola/ui/git/git_dialogs.dart';
import 'package:roola/ui/git/git_view_model.dart';
import 'package:roola/ui/git/git_view_state.dart';

/// Git ビュー上端のツールバー。
///
/// ブランチセレクタ・ahead/behind 表示・Fetch / Pull / Push ボタン・
/// オーバーフローメニューを横に並べる（ADR-0030）。
class GitToolbar extends ConsumerWidget {
  const GitToolbar({required this.tabId, required this.state, super.key});

  final String tabId;
  final GitViewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gitViewModelProvider(tabId).notifier);
    final colors = Theme.of(context).colorScheme;
    final running = state.runningOperation;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          // ブランチセレクタ。
          Flexible(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.account_tree_outlined, size: 15),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      state.branch ?? '(detached)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 16),
                ],
              ),
              onPressed: state.isBusy
                  ? null
                  : () => showGitBranchMenu(context, tabId),
            ),
          ),
          const SizedBox(width: 8),
          if (state.ahead > 0 || state.behind > 0)
            _AheadBehind(ahead: state.ahead, behind: state.behind),
          const Spacer(),
          _ToolbarButton(
            icon: Icons.sync,
            label: 'Fetch',
            busy: running == GitOperation.fetch,
            enabled: !state.isBusy,
            onPressed: notifier.fetch,
          ),
          _ToolbarButton(
            icon: Icons.arrow_downward,
            label: 'Pull',
            busy: running == GitOperation.pull,
            enabled: !state.isBusy,
            onPressed: notifier.pull,
          ),
          _ToolbarButton(
            icon: Icons.arrow_upward,
            label: 'Push',
            busy: running == GitOperation.push,
            enabled: !state.isBusy,
            onPressed: notifier.push,
          ),
          PopupMenuButton<_GitOverflow>(
            enabled: !state.isBusy,
            tooltip: 'その他の操作',
            icon: Icon(Icons.more_vert, size: 18, color: colors.onSurface),
            onSelected: (value) => _onOverflow(context, ref, value),
            itemBuilder: (context) => [
              _overflowItem(_GitOverflow.refresh, Icons.refresh, '再読込'),
              _overflowItem(
                _GitOverflow.stashSave,
                Icons.inventory_2_outlined,
                '変更を stash に退避',
              ),
              _overflowItem(
                _GitOverflow.stashList,
                Icons.list_alt,
                'stash 一覧 (${state.stashes.length})',
              ),
              const PopupMenuDivider(),
              _overflowItem(
                _GitOverflow.forcePush,
                Icons.published_with_changes,
                'Push (--force-with-lease)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<_GitOverflow> _overflowItem(
    _GitOverflow value,
    IconData icon,
    String label,
  ) => PopupMenuItem(
    value: value,
    child: ListTile(
      leading: Icon(icon),
      title: Text(label),
      dense: true,
      contentPadding: EdgeInsets.zero,
    ),
  );

  Future<void> _onOverflow(
    BuildContext context,
    WidgetRef ref,
    _GitOverflow value,
  ) async {
    final notifier = ref.read(gitViewModelProvider(tabId).notifier);
    switch (value) {
      case _GitOverflow.refresh:
        await notifier.refresh();
      case _GitOverflow.stashSave:
        final message = await gitPrompt(
          context,
          title: '変更を stash に退避',
          label: 'メッセージ（任意）',
          confirmLabel: '退避',
          allowEmpty: true,
        );
        if (message != null) {
          await notifier.stashSave(message: message.isEmpty ? null : message);
        }
      case _GitOverflow.stashList:
        if (context.mounted) {
          await showGitStashMenu(context, tabId);
        }
      case _GitOverflow.forcePush:
        final ok = await gitConfirm(
          context,
          title: 'force push',
          message: 'リモートブランチを --force-with-lease で上書きします。',
          confirmLabel: 'Push',
        );
        if (ok) {
          await notifier.push(force: true);
        }
    }
  }
}

enum _GitOverflow { refresh, stashSave, stashList, forcePush }

class _AheadBehind extends StatelessWidget {
  const _AheadBehind({required this.ahead, required this.behind});

  final int ahead;
  final int behind;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelSmall;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (behind > 0) ...[
          Icon(Icons.arrow_downward, size: 13, color: colors.onSurfaceVariant),
          Text('$behind', style: style),
          const SizedBox(width: 6),
        ],
        if (ahead > 0) ...[
          Icon(Icons.arrow_upward, size: 13, color: colors.onSurfaceVariant),
          Text('$ahead', style: style),
        ],
      ],
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.busy,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool busy;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton.icon(
        icon: busy
            ? const SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, size: 15),
        label: Text(label),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}

/// stash 一覧（適用 / pop / 破棄）のダイアログを開く。
Future<void> showGitStashMenu(BuildContext context, String tabId) {
  return showDialog<void>(
    context: context,
    builder: (context) => _StashDialog(tabId: tabId),
  );
}

class _StashDialog extends ConsumerWidget {
  const _StashDialog({required this.tabId});

  final String tabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gitViewModelProvider(tabId)).value;
    final notifier = ref.read(gitViewModelProvider(tabId).notifier);
    final stashes = state?.stashes ?? const <GitStashEntry>[];

    return Dialog(
      child: SizedBox(
        width: 460,
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'stash 一覧',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: '閉じる',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: stashes.isEmpty
                  ? const Center(child: Text('stash はありません'))
                  : ListView(
                      children: [
                        for (final stash in stashes)
                          ListTile(
                            dense: true,
                            enabled: !(state?.isBusy ?? true),
                            leading: const Icon(
                              Icons.inventory_2_outlined,
                              size: 16,
                            ),
                            title: Text(
                              stash.message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(stash.ref),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: (state?.isBusy ?? true)
                                      ? null
                                      : () => notifier.stashApply(
                                          stash.index,
                                          pop: false,
                                        ),
                                  child: const Text('適用'),
                                ),
                                TextButton(
                                  onPressed: (state?.isBusy ?? true)
                                      ? null
                                      : () => notifier.stashApply(
                                          stash.index,
                                          pop: true,
                                        ),
                                  child: const Text('pop'),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                  ),
                                  tooltip: '破棄',
                                  onPressed: (state?.isBusy ?? true)
                                      ? null
                                      : () async {
                                          final ok = await gitConfirm(
                                            context,
                                            title: 'stash を破棄',
                                            message: '${stash.ref} を破棄します。',
                                            confirmLabel: '破棄',
                                          );
                                          if (ok) {
                                            await notifier.stashDrop(
                                              stash.index,
                                            );
                                          }
                                        },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
