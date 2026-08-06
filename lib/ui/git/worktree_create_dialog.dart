import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:roola/app/theme.dart';
import 'package:roola/core/exceptions/app_exception.dart';
import 'package:roola/core/health/claude_health_check.dart';
import 'package:roola/data/git/git_worktree.dart';
import 'package:roola/data/git/process_git_repository.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/skill_session/adhoc_run_args.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_dialog.dart';
import 'package:roola/ui/common/polaris_toggle.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// worktree 作成後に起動するセッション。
enum WorktreePostAction { none, shell, claude }

/// 作成ダイアログの結果。[newBranch] / [existingBranch] / [trackRemote] の
/// いずれか 1 つが入る（`GitRepository.addWorktree` の引数と対応）。
class WorktreeCreateChoice {
  const WorktreeCreateChoice({
    this.newBranch,
    this.base,
    this.existingBranch,
    this.trackRemote,
    required this.postAction,
  });

  final String? newBranch;
  final String? base;
  final String? existingBranch;
  final String? trackRemote;
  final WorktreePostAction postAction;

  /// worktree のフォルダ名の元になるブランチ名。
  String get branchNameForPath {
    if (newBranch != null) {
      return newBranch!;
    }
    if (existingBranch != null) {
      return existingBranch!;
    }
    final remote = trackRemote!;
    return remote.substring(remote.indexOf('/') + 1);
  }
}

/// 「Worktree を切って開く」の一連のフロー（ADR-0067 / design D6）。
///
/// ブランチ情報を読み込み → 作成ダイアログ → `git worktree add` →
/// 作成後アクション（シェル / Claude）を隣ペインのターミナルタブとして起動。
/// エクスプローラの右クリックと Git ビューの「+」の両方から呼ばれる。
Future<void> runCreateWorktree(
  BuildContext context,
  WidgetRef ref, {
  required String repoRoot,
}) async {
  final repo = ref.read(gitRepositoryProvider);
  final messenger = ScaffoldMessenger.of(context);

  final List<String> localBranches;
  final List<String> remoteBranches;
  final Set<String> checkedOut;
  try {
    final branches = await repo.branches(repoRoot);
    final worktrees = await repo.listWorktrees(repoRoot);
    final localNames = {
      for (final b in branches.where((b) => !b.isRemote)) b.name,
    };
    localBranches = localNames.toList();
    // ローカルに同名ブランチが既にあるリモートは候補から外す
    // （`--track -b` が衝突するため。その場合は既存ブランチ側から選ぶ）。
    remoteBranches = [
      for (final b in branches.where((b) => b.isRemote))
        if (!localNames.contains(b.name.substring(b.name.indexOf('/') + 1)))
          b.name,
    ];
    checkedOut = {
      for (final wt in worktrees)
        if (wt.branch != null) wt.branch!,
    };
  } on AppException catch (e) {
    _snack(messenger, _messageOf(e));
    return;
  }
  if (!context.mounted) {
    return;
  }

  final claudeAvailable = ref.read(claudeAvailableProvider);
  final choice = await showDialog<WorktreeCreateChoice>(
    context: context,
    builder: (context) => _WorktreeCreateDialog(
      repoRoot: repoRoot,
      localBranches: localBranches,
      remoteBranches: remoteBranches,
      checkedOut: checkedOut,
      claudeAvailable: claudeAvailable,
    ),
  );
  if (choice == null || !context.mounted) {
    return;
  }

  final l10n = AppLocalizations.of(context);
  final path = resolveWorktreePath(repoRoot, choice.branchNameForPath);
  try {
    await repo.addWorktree(
      repoRoot,
      path,
      newBranch: choice.newBranch,
      base: choice.base,
      existingBranch: choice.existingBranch,
      trackRemote: choice.trackRemote,
    );
  } on AppException catch (e) {
    _snack(messenger, _messageOf(e));
    return;
  }
  _snack(messenger, l10n.worktreeCreatedSnack(p.basename(path)));

  switch (choice.postAction) {
    case WorktreePostAction.none:
      break;
    case WorktreePostAction.shell:
      openWorktreeShellTab(ref, worktreePath: path);
    case WorktreePostAction.claude:
      openWorktreeClaudeTab(ref, worktreePath: path);
  }
}

/// worktree を作業ディレクトリにした素のシェルタブを左下ペインに開く。
void openWorktreeShellTab(WidgetRef ref, {required String worktreePath}) {
  ref
      .read(workspaceProvider.notifier)
      .addTerminalTab(
        PaneSlotId.bottomLeft,
        args: AdhocRunArgs(
          adhocId: 'adhoc-${_uuid.v4()}',
          workingDirectory: worktreePath,
          displayName: '${p.basename(worktreePath)} (Terminal)',
          action: const LauncherAction.openHere(),
        ),
      );
}

/// worktree を作業ディレクトリにした claude セッションタブを左下ペインに開く。
void openWorktreeClaudeTab(WidgetRef ref, {required String worktreePath}) {
  ref
      .read(workspaceProvider.notifier)
      .addTerminalTab(
        PaneSlotId.bottomLeft,
        args: AdhocRunArgs(
          adhocId: 'adhoc-${_uuid.v4()}',
          workingDirectory: worktreePath,
          displayName: '${p.basename(worktreePath)} (Claude)',
          action: const LauncherAction.runCommand(
            command: 'claude',
            keepShellAfterExit: false,
          ),
        ),
      );
}

void _snack(ScaffoldMessengerState messenger, String message) {
  messenger.showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
  );
}

String _messageOf(AppException e) => switch (e) {
  GitNotFound() => 'git コマンドが見つかりません',
  GitCommandFailure(:final message) => message,
  _ => e.toString(),
};

enum _Mode { newBranch, existingBranch }

class _WorktreeCreateDialog extends HookWidget {
  const _WorktreeCreateDialog({
    required this.repoRoot,
    required this.localBranches,
    required this.remoteBranches,
    required this.checkedOut,
    required this.claudeAvailable,
  });

  final String repoRoot;
  final List<String> localBranches;
  final List<String> remoteBranches;
  final Set<String> checkedOut;
  final bool claudeAvailable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = PolarisTokens.of(context);

    final mode = useState(_Mode.newBranch);
    final nameController = useTextEditingController();
    useListenable(nameController);
    // 分岐元。null = 現在の HEAD（空欄のときの既定）。フィールドを空にしたら
    // HEAD へ戻す（一度 HEAD ラベルを消さないと入力できない不便を避ける）。
    final baseController = useTextEditingController();
    final base = useState<String?>(null);
    useEffect(() {
      void onChanged() {
        if (baseController.text.isEmpty) {
          base.value = null;
        }
      }

      baseController.addListener(onChanged);
      return () => baseController.removeListener(onChanged);
    }, [baseController]);
    final selectedBranch = useState<String?>(null);
    final postAction = useState(
      claudeAvailable ? WorktreePostAction.claude : WorktreePostAction.shell,
    );

    // DropdownMenu のエントリを Polaris らしく詰める（既定 48px は背が高い）。
    final entryStyle = MenuItemButton.styleFrom(
      visualDensity: VisualDensity.compact,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(
        horizontal: PolarisTokens.space3,
        vertical: PolarisTokens.space1,
      ),
    );

    final newName = nameController.text.trim();
    final nameTaken = localBranches.contains(newName);
    final canSubmit = switch (mode.value) {
      _Mode.newBranch => newName.isNotEmpty && !nameTaken,
      _Mode.existingBranch => selectedBranch.value != null,
    };

    // 作成先パスのプレビュー（`../<repo>.worktrees/<slug>/`）。
    final previewBranch = switch (mode.value) {
      _Mode.newBranch => newName,
      _Mode.existingBranch => switch (selectedBranch.value) {
        null => '',
        final s when remoteBranches.contains(s) => s.substring(
          s.indexOf('/') + 1,
        ),
        final s => s,
      },
    };
    final previewPath = previewBranch.isEmpty
        ? null
        : p.join(
            worktreeContainerPath(repoRoot),
            worktreeSlug(previewBranch),
          );

    void submit() {
      if (!canSubmit) {
        return;
      }
      final selected = selectedBranch.value;
      final choice = switch (mode.value) {
        _Mode.newBranch => WorktreeCreateChoice(
          newBranch: newName,
          // null = 現在の HEAD（addWorktree が HEAD 既定にする）。
          base: base.value,
          postAction: postAction.value,
        ),
        _Mode.existingBranch when remoteBranches.contains(selected) =>
          WorktreeCreateChoice(
            trackRemote: selected,
            postAction: postAction.value,
          ),
        _Mode.existingBranch => WorktreeCreateChoice(
          existingBranch: selected,
          postAction: postAction.value,
        ),
      };
      Navigator.of(context).pop(choice);
    }

    return PolarisDialog(
      width: 420,
      title: l10n.worktreeCreateTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PolarisToggle<_Mode>(
            segments: [
              PolarisToggleSegment(
                value: _Mode.newBranch,
                label: l10n.worktreeModeNewBranch,
              ),
              PolarisToggleSegment(
                value: _Mode.existingBranch,
                label: l10n.worktreeModeExistingBranch,
              ),
            ],
            selected: mode.value,
            onChanged: (v) => mode.value = v,
          ),
          const SizedBox(height: PolarisTokens.space4),
          if (mode.value == _Mode.newBranch) ...[
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.worktreeBranchNameLabel,
                hintText: 'feat/my-task',
                errorText: nameTaken ? l10n.worktreeBranchNameTaken : null,
                isDense: true,
              ),
              onSubmitted: (_) => submit(),
            ),
            const SizedBox(height: PolarisTokens.space4),
            DropdownMenu<String>(
              controller: baseController,
              // テキストフィールド直下にメニューを開き（前面中央に被さらない）、
              // 高さを制限してスクロールさせる。文字入力でブランチを絞り込める。
              // 空欄のままなら現在の HEAD から分岐する（hint で明示）。
              requestFocusOnTap: true,
              enableFilter: true,
              expandedInsets: EdgeInsets.zero,
              menuHeight: 240,
              label: Text(l10n.worktreeBaseLabel),
              hintText: l10n.worktreeBaseHead,
              // ラベルを常時フロートさせ、空欄時に hint「現在の HEAD」を見せる。
              // Polaris の枠線スタイルは引き継ぐ。
              inputDecorationTheme: Theme.of(context).inputDecorationTheme
                  .copyWith(floatingLabelBehavior: FloatingLabelBehavior.always),
              onSelected: (v) => base.value = v,
              dropdownMenuEntries: [
                for (final b in localBranches)
                  DropdownMenuEntry(value: b, label: b, style: entryStyle),
              ],
            ),
          ] else
            DropdownMenu<String>(
              initialSelection: selectedBranch.value,
              requestFocusOnTap: true,
              enableFilter: true,
              expandedInsets: EdgeInsets.zero,
              menuHeight: 240,
              label: Text(l10n.worktreeBranchPickerLabel),
              onSelected: (v) => selectedBranch.value = v,
              dropdownMenuEntries: [
                for (final b in localBranches)
                  DropdownMenuEntry(
                    value: b,
                    // チェックアウト済みは enabled: false で自動的にグレーアウト。
                    label: checkedOut.contains(b)
                        ? l10n.worktreeBranchCheckedOut(b)
                        : b,
                    labelWidget: Text(
                      checkedOut.contains(b)
                          ? l10n.worktreeBranchCheckedOut(b)
                          : b,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    enabled: !checkedOut.contains(b),
                    style: entryStyle,
                  ),
                for (final b in remoteBranches)
                  DropdownMenuEntry(
                    value: b,
                    label: b,
                    labelWidget: Text(
                      b,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: entryStyle,
                  ),
              ],
            ),
          const SizedBox(height: PolarisTokens.space4),
          Text(
            l10n.worktreePostActionLabel,
            style: tokens.meta.copyWith(color: tokens.textDim),
          ),
          const SizedBox(height: PolarisTokens.space2),
          PolarisToggle<WorktreePostAction>(
            segments: [
              PolarisToggleSegment(
                value: WorktreePostAction.none,
                label: l10n.worktreePostActionNone,
              ),
              PolarisToggleSegment(
                value: WorktreePostAction.shell,
                label: l10n.worktreePostActionShell,
              ),
              if (claudeAvailable)
                const PolarisToggleSegment(
                  value: WorktreePostAction.claude,
                  label: 'Claude',
                ),
            ],
            selected: postAction.value,
            onChanged: (v) => postAction.value = v,
          ),
          if (previewPath != null) ...[
            const SizedBox(height: PolarisTokens.space4),
            Text(
              previewPath,
              style: tokens.meta.copyWith(color: tokens.textDim),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(
          onPressed: canSubmit ? submit : null,
          child: Text(l10n.worktreeCreateButton),
        ),
      ],
    );
  }
}
