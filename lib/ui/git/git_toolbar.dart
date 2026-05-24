import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/git/git_stash_entry.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_glyphs.dart';
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
    final l10n = AppLocalizations.of(context);

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: PolarisTokens.space2),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 横幅が狭いときはアクションボタンをアイコンのみに切り替え、
          // ブランチセレクタに十分な余地を残す。
          final compact = constraints.maxWidth < 520;
          return Row(
            children: [
              // ブランチセレクタ。
              Flexible(
                child: _BranchButton(
                  label: state.branch ?? '(detached)',
                  onPressed: state.isBusy
                      ? null
                      : () => showGitBranchMenu(context, tabId),
                ),
              ),
              const SizedBox(width: PolarisTokens.space2),
              if ((state.ahead > 0 || state.behind > 0) && !compact)
                _AheadBehind(ahead: state.ahead, behind: state.behind),
              const Spacer(),
              _ToolbarButton(
                icon: Icons.sync,
                label: 'Fetch',
                compact: compact,
                busy: running == GitOperation.fetch,
                enabled: !state.isBusy,
                onPressed: notifier.fetch,
              ),
              _ToolbarButton(
                icon: Icons.arrow_downward,
                label: 'Pull',
                compact: compact,
                busy: running == GitOperation.pull,
                enabled: !state.isBusy,
                onPressed: notifier.pull,
              ),
              _ToolbarButton(
                icon: Icons.arrow_upward,
                label: 'Push',
                compact: compact,
                busy: running == GitOperation.push,
                enabled: !state.isBusy,
                onPressed: notifier.push,
              ),
              PopupMenuButton<_GitOverflow>(
                enabled: !state.isBusy,
                tooltip: l10n.gitToolbarOverflowTooltip,
                icon: Icon(
                  Icons.more_vert,
                  size: PolarisIconSize.standard,
                  color: colors.onSurface,
                ),
                onSelected: (value) => _onOverflow(context, ref, value),
                itemBuilder: (context) => [
                  _overflowItem(
                    _GitOverflow.refresh,
                    Icons.refresh,
                    l10n.gitMenuRefresh,
                  ),
                  _overflowItem(
                    _GitOverflow.stashSave,
                    Icons.inventory_2_outlined,
                    l10n.gitMenuStashSave,
                  ),
                  _overflowItem(
                    _GitOverflow.stashList,
                    Icons.list_alt,
                    l10n.gitMenuStashList(state.stashes.length),
                  ),
                  const PopupMenuDivider(),
                  _overflowItem(
                    _GitOverflow.forcePush,
                    Icons.published_with_changes,
                    l10n.gitMenuForcePush,
                  ),
                ],
              ),
            ],
          );
        },
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
    final l10n = AppLocalizations.of(context);
    switch (value) {
      case _GitOverflow.refresh:
        await notifier.refresh();
      case _GitOverflow.stashSave:
        final message = await gitPrompt(
          context,
          title: l10n.gitStashSaveTitle,
          label: l10n.gitStashMessageLabel,
          confirmLabel: l10n.gitStashSaveButton,
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
          title: l10n.gitForcePushTitle,
          message: l10n.gitForcePushMessage,
          confirmLabel: l10n.gitForcePushButton,
        );
        if (ok) {
          await notifier.push(force: true);
        }
    }
  }
}

enum _GitOverflow { refresh, stashSave, stashList, forcePush }

/// ブランチセレクタボタン。
///
/// アイコンをインライン（`WidgetSpan`）にして子に `Row`（Flex）を持たせない。
/// こうするとボタンが極端に狭い幅まで絞られても、`Row` のように
/// オーバーフローのアサーションを出さず単に省略表示になる。
class _BranchButton extends StatelessWidget {
  const _BranchButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return OutlinedButton(
      // minimumSize は指定せず、テーマの buttonMinSize（高さ 32px・幅 0）に
      // 委ねる。幅 0 なので狭い幅まで絞れる挙動は維持しつつ、高さは他の
      // ボタンと同じ 32px に揃う。
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: PolarisTokens.space3),
      ),
      onPressed: onPressed,
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(right: PolarisTokens.space2),
                child: PolarisGlyph.gitBranch(
                  size: PolarisIconSize.small,
                  // ボタンの前景（accent）に揃える。無効時は faint。
                  color: onPressed == null ? tokens.textFaint : tokens.accent,
                ),
              ),
            ),
            TextSpan(text: label),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

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
          Icon(
            Icons.arrow_downward,
            size: PolarisIconSize.small,
            color: colors.onSurfaceVariant,
          ),
          Text('$behind', style: style),
          const SizedBox(width: PolarisTokens.space2),
        ],
        if (ahead > 0) ...[
          Icon(
            Icons.arrow_upward,
            size: PolarisIconSize.small,
            color: colors.onSurfaceVariant,
          ),
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
    required this.compact,
    required this.busy,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool compact;
  final bool busy;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final iconWidget = busy
        ? const SizedBox(
            width: 13,
            height: 13,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(icon, size: PolarisIconSize.small);

    // 横幅が狭いときはラベルを省きアイコンのみのボタンにする。
    // 高さ 40 のツールバーに収まるようサイズを明示的に絞る。
    if (compact) {
      return IconButton(
        icon: iconWidget,
        tooltip: label,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        iconSize: 15,
        onPressed: enabled ? onPressed : null,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton.icon(
        icon: iconWidget,
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
    final l10n = AppLocalizations.of(context);
    final tokens = PolarisTokens.of(context);

    return Dialog(
      child: SizedBox(
        width: 460,
        height: 420,
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
                  Icon(
                    Icons.inventory_2_outlined,
                    size: PolarisIconSize.standard,
                    color: tokens.textDim,
                  ),
                  const SizedBox(width: PolarisTokens.space2),
                  Text(
                    l10n.gitStashListTitle,
                    style: tokens.body.copyWith(color: tokens.text),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: PolarisIconSize.standard,
                    ),
                    tooltip: l10n.buttonClose,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: tokens.line),
            Expanded(
              child: stashes.isEmpty
                  ? Center(child: Text(l10n.gitStashEmpty))
                  : ListView(
                      children: [
                        for (final stash in stashes)
                          ListTile(
                            dense: true,
                            enabled: !(state?.isBusy ?? true),
                            leading: const Icon(
                              Icons.inventory_2_outlined,
                              size: PolarisIconSize.standard,
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
                                  child: Text(l10n.gitStashApplyButton),
                                ),
                                TextButton(
                                  onPressed: (state?.isBusy ?? true)
                                      ? null
                                      : () => notifier.stashApply(
                                          stash.index,
                                          pop: true,
                                        ),
                                  child: Text(l10n.gitStashPopButton),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: PolarisIconSize.standard,
                                  ),
                                  tooltip: l10n.gitStashDiscardTooltip,
                                  onPressed: (state?.isBusy ?? true)
                                      ? null
                                      : () async {
                                          final ok = await gitConfirm(
                                            context,
                                            title: l10n.gitStashDropTitle,
                                            message: l10n.gitStashDropMessage(
                                              stash.ref,
                                            ),
                                            confirmLabel:
                                                l10n.gitStashDropButton,
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
