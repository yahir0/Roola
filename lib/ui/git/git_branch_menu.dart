import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/git/git_branch.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_glyphs.dart';
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
    final l10n = AppLocalizations.of(context);
    final tokens = PolarisTokens.of(context);

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
            // ヘッダ帯。
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PolarisTokens.space4,
                PolarisTokens.space3,
                PolarisTokens.space2,
                PolarisTokens.space3,
              ),
              child: Row(
                children: [
                  PolarisGlyph.gitBranch(color: tokens.textDim),
                  const SizedBox(width: PolarisTokens.space2),
                  Text(
                    l10n.gitBranchDialogTitle,
                    style: tokens.body.copyWith(color: tokens.text),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: PolarisIconSize.small),
                    label: Text(l10n.gitBranchNewButton),
                    onPressed: () async {
                      final name = await gitPrompt(
                        context,
                        title: l10n.gitBranchCreateTitle,
                        label: l10n.gitBranchNameLabel,
                        confirmLabel: l10n.buttonCreate,
                      );
                      if (name != null) {
                        await notifier.createBranch(name);
                        await close();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: PolarisIconSize.standard,
                    ),
                    tooltip: l10n.buttonClose,
                    visualDensity: VisualDensity.compact,
                    onPressed: close,
                  ),
                ],
              ),
            ),
            Container(height: 1, color: tokens.line),
            // 検索行。
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PolarisTokens.space3,
                PolarisTokens.space3,
                PolarisTokens.space3,
                PolarisTokens.space3,
              ),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search,
                    size: PolarisIconSize.standard,
                  ),
                  hintText: l10n.gitBranchFilterHint,
                  isDense: true,
                ),
                onChanged: (v) => filter.value = v,
              ),
            ),
            Container(height: 1, color: tokens.line),
            Expanded(
              child: ListView(
                children: [
                  if (local.isNotEmpty)
                    _SectionLabel(label: l10n.gitBranchLocalLabel),
                  for (final branch in local)
                    _BranchRow(
                      tabId: tabId,
                      branch: branch,
                      busy: state?.isBusy ?? true,
                    ),
                  if (remote.isNotEmpty)
                    _SectionLabel(label: l10n.gitBranchRemoteLabel),
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
    final tokens = PolarisTokens.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        PolarisTokens.space4,
        PolarisTokens.space2,
        PolarisTokens.space4,
        PolarisTokens.space1,
      ),
      color: tokens.surface,
      child: Text(
        label.toUpperCase(),
        style: tokens.label.copyWith(color: tokens.textFaint),
      ),
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
    final l10n = AppLocalizations.of(context);

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
      leading: branch.isCurrent
          ? Icon(Icons.check, color: colors.primary)
          : PolarisGlyph.gitBranch(color: colors.onSurfaceVariant),
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
        tooltip: l10n.gitBranchOperationsTooltip,
        icon: const Icon(Icons.more_horiz, size: PolarisIconSize.standard),
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
                title: l10n.gitBranchDeleteConfirmTitle,
                message: l10n.gitBranchDeleteConfirmMessage(branch.name),
                confirmLabel: l10n.buttonDelete,
              );
              if (ok) {
                await notifier.deleteBranch(branch.name);
              }
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _BranchMenu.merge,
            child: ListTile(
              leading: const Icon(Icons.merge_type),
              title: Text(l10n.gitBranchMergeMenuItem),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (!branch.isRemote && !branch.isCurrent)
            PopupMenuItem(
              value: _BranchMenu.delete,
              child: ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.gitBranchDeleteMenuItem),
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
