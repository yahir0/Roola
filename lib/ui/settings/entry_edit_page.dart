import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/ui/common/macos_window_app_bar.dart';
import 'package:roola/ui/settings/entry_edit_view_model.dart';

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

    // state の iconPath / errors / isSubmitting は ref.watch が自動追従するが、
    // テキストコントローラは初期表示後の外部変更（例: file_picker 経由・
    // プリフィル）を反映するため明示的に同期する。
    useEffect(() {
      if (workingDirectoryController.text != state.workingDirectory) {
        workingDirectoryController.text = state.workingDirectory;
      }
      return null;
    }, [state.workingDirectory]);

    return Scaffold(
      appBar: MacosWindowAppBar(title: Text(isNew ? 'エントリ追加' : 'エントリ編集')),
      body: AbsorbPointer(
        absorbing: state.isSubmitting,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _IconSection(
              iconPath: state.iconPath,
              onPick: () => _pickIcon(viewModel),
              onClear: viewModel.clearIcon,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: displayNameController,
              decoration: InputDecoration(
                labelText: '表示名',
                errorText: state.errors['displayName'],
                border: const OutlineInputBorder(),
              ),
              onChanged: viewModel.setDisplayName,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: workingDirectoryController,
              decoration: InputDecoration(
                labelText: '作業ディレクトリ',
                hintText: '/Users/you/path/to/dir',
                errorText: state.errors['workingDirectory'],
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.folder_open),
                  tooltip: 'ディレクトリを選択',
                  onPressed: () => _pickDirectory(viewModel),
                ),
              ),
              onChanged: viewModel.setWorkingDirectory,
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
                  child: const Text('キャンセル'),
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
                  label: Text(state.isSubmitting ? '保存中...' : '保存'),
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

  Future<void> _pickIcon(EntryEditViewModel viewModel) async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path != null) {
      viewModel.setPendingIcon(path);
    }
  }
}

/// 動作タイプを選ぶセグメント。3 タイル横並び（📂 / ⚡ / 🤖）。
class _ActionTypeSelector extends StatelessWidget {
  const _ActionTypeSelector({
    required this.selected,
    required this.onChanged,
  });

  final LauncherActionType selected;
  final ValueChanged<LauncherActionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('動作', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<LauncherActionType>(
            segments: const [
              ButtonSegment(
                value: LauncherActionType.openHere,
                icon: Icon(Icons.folder_open),
                label: Text('開くだけ'),
              ),
              ButtonSegment(
                value: LauncherActionType.runCommand,
                icon: Icon(Icons.bolt),
                label: Text('コマンド実行'),
              ),
              ButtonSegment(
                value: LauncherActionType.claudeSkill,
                icon: Icon(Icons.auto_awesome),
                label: Text('Claude Skill'),
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
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 12),
            Expanded(
              child: Text(r'指定した作業ディレクトリでログインシェル ($SHELL) を起動し、'
                  'プロンプトで停止します。'),
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: '実行コマンド',
            hintText: 'npm run dev',
            helperText: r'$SHELL -lc 経由で実行されます。&& や環境変数も使えます。',
            errorText: widget.errorText,
            border: const OutlineInputBorder(),
          ),
          onChanged: widget.onCommandChanged,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('コマンド終了後もターミナルを残す'),
          subtitle: const Text(
            '一発完結コマンド（make build 等）の結果を確認できます。'
            '常駐コマンド (npm run dev 等) では結果に影響しません。',
          ),
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
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'Skill 名',
        hintText: 'my-skill',
        helperText: widget.availableSkills.isEmpty
            ? '作業ディレクトリ内の `.claude/skills/` から候補を取得します'
            : '候補: ${widget.availableSkills.length} 件',
        errorText: widget.errorText,
        border: const OutlineInputBorder(),
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
                tooltip: '候補から選択',
                itemBuilder: (context) => widget.availableSkills
                    .map(
                      (s) =>
                          PopupMenuItem<String>(value: s, child: Text(s)),
                    )
                    .toList(),
                onSelected: widget.onChanged,
              ),
      ),
      onChanged: widget.onChanged,
    );
  }
}

class _IconSection extends StatelessWidget {
  const _IconSection({
    required this.iconPath,
    required this.onPick,
    required this.onClear,
  });

  final String? iconPath;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasIcon = iconPath != null && File(iconPath!).existsSync();
    return Row(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasIcon
              ? Image.file(File(iconPath!), fit: BoxFit.cover)
              : Icon(
                  Icons.apps,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('アイコンを選択'),
              onPressed: onPick,
            ),
            if (hasIcon) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.clear),
                label: const Text('クリア'),
                onPressed: onClear,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
