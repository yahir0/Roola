import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/core/health/claude_health_check.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/launcher_entry/launcher_folders_provider.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/macos_window_app_bar.dart';
import 'package:roola/ui/launchers/entry_edit_view_model.dart';

/// エントリ追加・編集画面。
///
/// `entryId == null` の場合は新規作成、それ以外は既存編集。
/// 新規作成時に `initialRepositoryPath` / `initialSkillName` が渡されている
/// と、フォームの該当フィールドを事前入力する（エクスプローラからの
/// 「Skill を登録」経路で利用）。`initialSkillName` が来る = Skill 起動を
/// 想定した呼び出しなので、初期動作タイプは「🤖 Claude Skill」に設定する。
class EntryEditPage extends HookConsumerWidget {
  const EntryEditPage({
    required this.entryId,
    this.initialRepositoryPath,
    this.initialSkillName,
    super.key,
  });

  final String? entryId;
  final String? initialRepositoryPath;
  final String? initialSkillName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(entryEditViewModelProvider(entryId));
    final viewModel = ref.read(entryEditViewModelProvider(entryId).notifier);
    final isNew = entryId == null;

    // 新規作成 + プリフィル指定がある場合、1 回だけ ViewModel に初期値を流し
    // 込む。既存編集（entryId != null）では無視する。
    // flutter_hooks 0.21+ では useEffect が initHook から同期で呼ばれるため、
    // 初回 build 中の Notifier 書き換えになり Riverpod のガードに引っかかる。
    // Future.microtask で 1 tick 遅延させ、build 完了後に流し込む。
    useEffect(() {
      if (!isNew) {
        return null;
      }
      Future.microtask(() {
        if (initialRepositoryPath != null &&
            initialRepositoryPath!.isNotEmpty) {
          viewModel.setWorkingDirectory(initialRepositoryPath!);
        }
        if (initialSkillName != null && initialSkillName!.isNotEmpty) {
          // Skill 名指定で開かれた = ClaudeSkill タイプを想定。
          viewModel
            ..setActionType(LauncherActionType.claudeSkill)
            ..setSkillName(initialSkillName!);
        }
      });
      return null;
    }, const []);

    final displayNameController = useTextEditingController(
      text: state.displayName,
    );
    final workingDirectoryController = useTextEditingController(
      text: state.workingDirectory,
    );

    // state の errors / isSubmitting は ref.watch が自動追従するが、
    // テキストコントローラは初期表示後の外部変更（例: file_picker 経由・
    // プリフィル）を反映するため明示的に同期する。
    useEffect(() {
      if (workingDirectoryController.text != state.workingDirectory) {
        workingDirectoryController.text = state.workingDirectory;
      }
      return null;
    }, [state.workingDirectory]);

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: MacosWindowAppBar(
        title: Text(isNew ? l10n.entryEditTitleNew : l10n.entryEditTitleEdit),
      ),
      body: AbsorbPointer(
        absorbing: state.isSubmitting,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              controller: displayNameController,
              decoration: InputDecoration(
                labelText: l10n.entryEditDisplayNameLabel,
                errorText: state.errors['displayName'],
              ),
              onChanged: viewModel.setDisplayName,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: workingDirectoryController,
              decoration: InputDecoration(
                labelText: l10n.entryEditWorkingDirectoryLabel,
                hintText: l10n.entryEditWorkingDirectoryHint,
                errorText: state.errors['workingDirectory'],
                suffixIcon: IconButton(
                  icon: const Icon(Icons.folder_open),
                  tooltip: l10n.entryEditDirectorySelectTooltip,
                  onPressed: () => _pickDirectory(viewModel),
                ),
              ),
              onChanged: viewModel.setWorkingDirectory,
            ),
            const SizedBox(height: 16),
            _FolderSelector(
              selectedFolderId: state.folderId,
              onChanged: viewModel.setFolderId,
            ),
            const SizedBox(height: 24),
            _ActionTypeSelector(
              selected: launcherActionTypeOf(state.action),
              onChanged: viewModel.setActionType,
            ),
            const SizedBox(height: 16),
            _ActionFields(state: state, viewModel: viewModel),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(l10n.buttonCancel),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: state.isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    state.isSubmitting ? l10n.buttonSaving : l10n.buttonSave,
                  ),
                  onPressed: state.isSubmitting
                      ? null
                      : () async {
                          final saved = await viewModel.submit();
                          if (saved && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDirectory(EntryEditViewModel viewModel) async {
    final picked = await FilePicker.getDirectoryPath();
    if (picked != null) {
      viewModel.setWorkingDirectory(picked);
    }
  }
}

/// 所属フォルダを選ぶドロップダウン。ADR-0019 で追加。
///
/// 「フォルダなし（未分類）」 + 既存フォルダ一覧から 1 つ選ぶ。フォルダ自体の
/// 追加・編集はここでは行わず、管理画面の「+ フォルダ」ボタン経由とする。
class _FolderSelector extends ConsumerWidget {
  const _FolderSelector({
    required this.selectedFolderId,
    required this.onChanged,
  });

  final String? selectedFolderId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final folders = ref.watch(launcherFoldersProvider).value ?? const [];
    return DropdownButtonFormField<String?>(
      initialValue: selectedFolderId,
      decoration: InputDecoration(labelText: l10n.entryEditFolderLabel),
      items: [
        DropdownMenuItem<String?>(child: Text(l10n.entryEditFolderNone)),
        for (final f in folders)
          DropdownMenuItem<String?>(value: f.id, child: Text(f.name)),
      ],
      onChanged: onChanged,
    );
  }
}

/// 動作タイプを選ぶセグメント。3 タイル横並び（📂 / ⚡ / 🤖）。
///
/// Claude CLI 未導入時は「Claude Skill」セグメントを隠す（ADR-0022）。
/// ただし、既に編集中エントリが ClaudeSkillAction の場合は残す——強制的に
/// タイプ切替を要求するのは破壊的なので、状態維持と warning 表示で運用する。
class _ActionTypeSelector extends ConsumerWidget {
  const _ActionTypeSelector({required this.selected, required this.onChanged});

  final LauncherActionType selected;
  final ValueChanged<LauncherActionType> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final claudeAvailable = ref.watch(claudeAvailableProvider);
    final showClaudeSkill =
        claudeAvailable || selected == LauncherActionType.claudeSkill;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.entryEditActionTypeLabel,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        if (!claudeAvailable) ...[
          _ClaudeUnavailableNotice(currentIsClaudeSkill: showClaudeSkill),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<LauncherActionType>(
            segments: [
              ButtonSegment(
                value: LauncherActionType.openHere,
                icon: const Icon(Icons.folder_open),
                label: Text(l10n.entryEditActionOpenHere),
              ),
              ButtonSegment(
                value: LauncherActionType.runCommand,
                icon: const Icon(Icons.bolt),
                label: Text(l10n.entryEditActionRunCommand),
              ),
              if (showClaudeSkill)
                ButtonSegment(
                  value: LauncherActionType.claudeSkill,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(l10n.entryEditActionClaudeSkill),
                ),
            ],
            selected: {selected},
            onSelectionChanged: (set) => onChanged(set.first),
          ),
        ),
      ],
    );
  }
}

/// Claude CLI 未導入の警告バナー。Skill タイプの選択肢が消える / 既存エントリは
/// 実行不能になることをユーザーに伝える（ADR-0022）。
class _ClaudeUnavailableNotice extends StatelessWidget {
  const _ClaudeUnavailableNotice({required this.currentIsClaudeSkill});

  /// 現在の編集対象が ClaudeSkillAction かどうか。true のとき「保存しても
  /// 動かない」旨を追記する。
  final bool currentIsClaudeSkill;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final tokens = PolarisTokens.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(tokens.radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: PolarisIconSize.standard,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              currentIsClaudeSkill
                  ? l10n.entryEditClaudeUnavailableNoticeCurrent
                  : l10n.entryEditClaudeUnavailableNoticeGeneral,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// 選択された動作タイプに応じたフィールド群。progressive disclosure。
class _ActionFields extends StatelessWidget {
  const _ActionFields({required this.state, required this.viewModel});

  final EntryEditState state;
  final EntryEditViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return switch (state.action) {
      OpenHereAction() => const _OpenHereSection(),
      RunCommandAction() => _RunCommandSection(
        command: state.editedCommand,
        keepShellAfterExit: state.editedKeepShellAfterExit,
        errorText: state.errors['command'],
        onCommandChanged: viewModel.setCommand,
        onKeepShellChanged: viewModel.setKeepShellAfterExit,
      ),
      ClaudeSkillAction() => _ClaudeSkillSection(
        skillName: state.editedSkillName,
        availableSkills: state.availableSkills,
        workingDirectory: state.workingDirectory,
        errorText: state.errors['skillName'],
        onChanged: viewModel.setSkillName,
      ),
    };
  }
}

class _OpenHereSection extends StatelessWidget {
  const _OpenHereSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.entryEditOpenHereDescription)),
          ],
        ),
      ),
    );
  }
}

/// `RunCommand` セグメント用フィールド。コントローラを `key` で再生成して
/// 動作タイプ切替時の値表示を確実に同期する。
class _RunCommandSection extends StatefulWidget {
  const _RunCommandSection({
    required this.command,
    required this.keepShellAfterExit,
    required this.onCommandChanged,
    required this.onKeepShellChanged,
    this.errorText,
  });

  final String command;
  final bool keepShellAfterExit;
  final String? errorText;
  final ValueChanged<String> onCommandChanged;
  final ValueChanged<bool> onKeepShellChanged;

  @override
  State<_RunCommandSection> createState() => _RunCommandSectionState();
}

class _RunCommandSectionState extends State<_RunCommandSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.command);
  }

  @override
  void didUpdateWidget(covariant _RunCommandSection old) {
    super.didUpdateWidget(old);
    // 外部 (state.editedCommand) が変わったらコントローラに反映する。
    // ユーザー入力中の onChanged 経由で同じ値が戻ってくるケースは
    // ガードして無限ループを避ける。
    if (widget.command != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.command,
        selection: TextSelection.collapsed(offset: widget.command.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: l10n.entryEditCommandLabel,
            hintText: l10n.entryEditCommandHint,
            helperText: l10n.entryEditCommandHelper,
            errorText: widget.errorText,
          ),
          onChanged: widget.onCommandChanged,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.entryEditKeepShellAfterExitTitle),
          subtitle: Text(l10n.entryEditKeepShellAfterExitSubtitle),
          value: widget.keepShellAfterExit,
          onChanged: widget.onKeepShellChanged,
        ),
      ],
    );
  }
}

/// `ClaudeSkill` セグメント用フィールド。Skill 名 TextField + 候補プルダウン。
class _ClaudeSkillSection extends StatefulWidget {
  const _ClaudeSkillSection({
    required this.skillName,
    required this.availableSkills,
    required this.workingDirectory,
    required this.onChanged,
    this.errorText,
  });

  final String skillName;
  final List<String> availableSkills;
  final String workingDirectory;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  State<_ClaudeSkillSection> createState() => _ClaudeSkillSectionState();
}

class _ClaudeSkillSectionState extends State<_ClaudeSkillSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.skillName);
  }

  @override
  void didUpdateWidget(covariant _ClaudeSkillSection old) {
    super.didUpdateWidget(old);
    if (widget.skillName != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.skillName,
        selection: TextSelection.collapsed(offset: widget.skillName.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: l10n.entryEditSkillNameLabel,
        hintText: l10n.entryEditSkillNameHint,
        helperText: widget.availableSkills.isEmpty
            ? l10n.entryEditSkillNameHelperNoSkills
            : l10n.entryEditSkillNameHelperWithSkills(
                widget.availableSkills.length,
              ),
        errorText: widget.errorText,
        suffixIcon: widget.availableSkills.isEmpty
            ? null
            : PopupMenuButton<String>(
                // ValueKey で workingDirectory をひもづけ、ディレクトリ
                // 変更時に PopupMenuButton を強制的に作り直す。
                // InputDecorator が suffixIcon の同一性を保ったまま
                // 子の itemBuilder 差し替えだけでは更新が反映されない
                // macOS 実機の挙動を回避するための保険。
                key: ValueKey('skill-suggest-${widget.workingDirectory}'),
                icon: const Icon(Icons.arrow_drop_down),
                tooltip: l10n.entryEditSkillNameSelectTooltip,
                itemBuilder: (context) => widget.availableSkills
                    .map((s) => PopupMenuItem<String>(value: s, child: Text(s)))
                    .toList(),
                onSelected: widget.onChanged,
              ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
