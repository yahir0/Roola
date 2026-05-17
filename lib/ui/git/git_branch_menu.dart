import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/git/git_branch.dart';
import 'package:roola/ui/git/git_dialogs.dart';
import 'package:roola/ui/git/git_view_model.dart';

/// ブランチ操作（切替・作成・マージ・削除）のダイアログを開く（ADR-0030）。
Future<void> showGitBranchMenu(BuildContext context, String tabId) {
  return showDialog<void>(
    context: context,
    builder: (context) => _GitBranchDialog(tabId: tabId),
  );
}

class _GitBranchDialog extends HookConsumerWidget {
  const _GitBranchDialog({required this.tabId});

  final String tabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = useState('');
    final state = ref.watch(gitViewModelProvider(tabId)).value;
    final notifier = ref.read(gitViewModelProvider(tabId).notifier);

    final branches = state?.branches ?? const <GitBranch>[];
    final query = filter.value.toLowerCase();
    final local = branches
        .where((b) => !b.isRemote && b.name.toLowerCase().contains(query))
        .toList();
    final remote = branches
        .where((b) => b.isRemote && b.name.toLowerCase().contains(query))
        .toList();

    Future<void> close() async => Navigator.of(context).maybePop();

    return Dialog(
      child: SizedBox(
        width: 420,
        height: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.account_tree_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text('ブランチ', style: Theme.of(context).textTheme.titleSmall),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('新規作成'),
                    onPressed: () async {
                      final name = await gitPrompt(
                        context,
                        title: 'ブランチを作成',
                        label: 'ブランチ名',
                        confirmLabel: '作成',
                      );
                      if (name != null) {
                        await notifier.createBranch(name);
                        await close();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: '閉じる',
                    onPressed: close,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, size: 18),
                  hintText: 'ブランチを絞り込み',
                  isDense: true,
                ),
                onChanged: (v) => filter.value = v,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                children: [
                  if (local.isNotEmpty) const _SectionLabel(label: 'ローカル'),
                  for (final branch in local)
                    _BranchRow(
                      tabId: tabId,
                      branch: branch,
                      busy: state?.isBusy ?? true,
                    ),
                  if (remote.isNotEmpty) const _SectionLabel(label: 'リモート'),
                  for (final branch in remote)
                    _BranchRow(
                      tabId: tabId,
                      branch: branch,
                      busy: state?.isBusy ?? true,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

enum _BranchMenu { merge, delete }

class _BranchRow extends ConsumerWidget {
  const _BranchRow({
    required this.tabId,
    required this.branch,
    required this.busy,
  });

  final String tabId;
  final GitBranch branch;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gitViewModelProvider(tabId).notifier);
    final colors = Theme.of(context).colorScheme;

    Future<void> checkout() async {
      // リモートブランチは追跡名（remote/ を除いた部分）でチェックアウトする。
      final target = branch.isRemote
          ? branch.name.substring(branch.name.indexOf('/') + 1)
          : branch.name;
      await notifier.checkoutBranch(target);
      if (context.mounted) {
        await Navigator.of(context).maybePop();
      }
    }

    final trackText = StringBuffer();
    if (branch.ahead > 0) {
      trackText.write('↑${branch.ahead}');
    }
    if (branch.behind > 0) {
      if (trackText.isNotEmpty) {
        trackText.write(' ');
      }
      trackText.write('↓${branch.behind}');
    }

    return ListTile(
      dense: true,
      enabled: !busy,
      leading: Icon(
        branch.isCurrent ? Icons.check : Icons.account_tree_outlined,
        size: 16,
        color: branch.isCurrent ? colors.primary : colors.onSurfaceVariant,
      ),
      title: Text(
        branch.name,
        style: TextStyle(
          fontWeight: branch.isCurrent ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: branch.upstream == null && trackText.isEmpty
          ? null
          : Text(
              [
                if (branch.upstream != null) branch.upstream!,
                if (trackText.isNotEmpty) trackText.toString(),
              ].join('  '),
            ),
      trailing: PopupMenuButton<_BranchMenu>(
        enabled: !busy,
        tooltip: 'ブランチ操作',
        icon: const Icon(Icons.more_horiz, size: 18),
        onSelected: (value) async {
          switch (value) {
            case _BranchMenu.merge:
              await notifier.mergeBranch(branch.name);
              if (context.mounted) {
                await Navigator.of(context).maybePop();
              }
            case _BranchMenu.delete:
              final ok = await gitConfirm(
                context,
                title: 'ブランチを削除',
                message: 'ブランチ「${branch.name}」を削除します。',
                confirmLabel: '削除',
              );
              if (ok) {
                await notifier.deleteBranch(branch.name);
              }
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: _BranchMenu.merge,
            child: ListTile(
              leading: Icon(Icons.merge_type),
              title: Text('現在ブランチへマージ'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (!branch.isRemote && !branch.isCurrent)
            const PopupMenuItem(
              value: _BranchMenu.delete,
              child: ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('削除'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
      onTap: branch.isCurrent || busy ? null : checkout,
    );
  }
}
