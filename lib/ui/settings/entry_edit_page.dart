import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/ui/common/macos_window_app_bar.dart';
import 'package:roola/ui/settings/entry_edit_view_model.dart';

/// エントリ追加・編集画面。
///
/// `entryId == null` の場合は新規作成、それ以外は既存編集。
/// 新規作成時に `initialRepositoryPath` / `initialSkillName` が渡されている
/// と、フォームの該当フィールドを事前入力する（エクスプローラからの
/// 「Skill を登録」経路で利用）。
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
          viewModel.setRepositoryPath(initialRepositoryPath!);
        }
        if (initialSkillName != null && initialSkillName!.isNotEmpty) {
          viewModel.setSkillName(initialSkillName!);
        }
      });
      return null;
    }, const []);

    final displayNameController = useTextEditingController(
      text: state.displayName,
    );
    final repositoryPathController = useTextEditingController(
      text: state.repositoryPath,
    );
    final skillNameController = useTextEditingController(text: state.skillName);

    // state の iconPath / errors / isSubmitting は ref.watch が自動追従するが、
    // テキストコントローラは初期表示後の外部変更（例: file_picker 経由・
    // Skill 候補プルダウン選択）を反映するため明示的に同期する。
    useEffect(() {
      if (repositoryPathController.text != state.repositoryPath) {
        repositoryPathController.text = state.repositoryPath;
      }
      return null;
    }, [state.repositoryPath]);

    useEffect(() {
      if (skillNameController.text != state.skillName) {
        skillNameController.value = TextEditingValue(
          text: state.skillName,
          selection: TextSelection.collapsed(offset: state.skillName.length),
        );
      }
      return null;
    }, [state.skillName]);

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
              controller: repositoryPathController,
              decoration: InputDecoration(
                labelText: 'リポジトリパス',
                hintText: '/Users/you/path/to/repo',
                errorText: state.errors['repositoryPath'],
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.folder_open),
                  tooltip: 'ディレクトリを選択',
                  onPressed: () => _pickDirectory(viewModel),
                ),
              ),
              onChanged: viewModel.setRepositoryPath,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: skillNameController,
              decoration: InputDecoration(
                labelText: 'Skill 名',
                hintText: 'my-skill',
                helperText: state.availableSkills.isEmpty
                    ? 'リポジトリ内の `.claude/skills/` から候補を取得します'
                    : '候補: ${state.availableSkills.length} 件',
                errorText: state.errors['skillName'],
                border: const OutlineInputBorder(),
                suffixIcon: state.availableSkills.isEmpty
                    ? null
                    : PopupMenuButton<String>(
                        // ValueKey で repositoryPath をひもづけ、リポジトリ
                        // パス変更時に PopupMenuButton を強制的に作り直す。
                        // InputDecorator が suffixIcon の同一性を保ったまま
                        // 子の itemBuilder 差し替えだけでは更新が反映されない
                        // macOS 実機の挙動を回避するための保険。
                        key: ValueKey('skill-suggest-${state.repositoryPath}'),
                        icon: const Icon(Icons.arrow_drop_down),
                        tooltip: '候補から選択',
                        itemBuilder: (context) => state.availableSkills
                            .map(
                              (s) => PopupMenuItem<String>(
                                value: s,
                                child: Text(s),
                              ),
                            )
                            .toList(),
                        onSelected: viewModel.setSkillName,
                      ),
              ),
              onChanged: viewModel.setSkillName,
            ),
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
      viewModel.setRepositoryPath(picked);
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
