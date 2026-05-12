import 'package:claude_skills_launcher/app/router.dart';
import 'package:claude_skills_launcher/data/repo_explorer/explorer_node.dart';
import 'package:claude_skills_launcher/data/skill_session/adhoc_run_args.dart';
import 'package:claude_skills_launcher/ui/explorer/explorer_view_model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// 任意の `ExplorerDirectoryNode` に対する右クリックメニューを表示する。
/// タイル本体（[ExplorerNodeTile]）と、リスト下部の空き領域（カレント
/// ディレクトリを対象にする）の両方から呼ばれる。
Future<void> showExplorerContextMenu(
  BuildContext context,
  WidgetRef ref,
  ExplorerDirectoryNode node,
  Offset position,
) async {
  final items = <PopupMenuEntry<ExplorerNodeAction>>[
    const PopupMenuItem(
      value: _ActionOpenClaude(),
      child: ListTile(
        leading: Icon(Icons.terminal),
        title: Text('このディレクトリで Claude Code を開く'),
      ),
    ),
  ];
  if (node.skillNames.isNotEmpty) {
    items.add(const PopupMenuDivider());
    for (final skill in node.skillNames) {
      items.add(
        PopupMenuItem(
          value: _ActionRunSkill(skill),
          child: ListTile(
            leading: const Icon(Icons.play_arrow),
            title: Text('「$skill」を即実行'),
          ),
        ),
      );
    }
    items.add(const PopupMenuDivider());
    for (final skill in node.skillNames) {
      items.add(
        PopupMenuItem(
          value: _ActionRegisterSkill(skill),
          child: ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: Text('「$skill」をホームに登録'),
          ),
        ),
      );
    }
  }

  final selected = await showMenu<ExplorerNodeAction>(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx,
      position.dy,
    ),
    items: items,
  );
  if (selected == null || !context.mounted) {
    return;
  }
  _handleSelected(context, node, selected);
}

void _handleSelected(
  BuildContext context,
  ExplorerDirectoryNode node,
  ExplorerNodeAction action,
) {
  switch (action) {
    case _ActionOpenClaude():
      final adhocId = 'adhoc-${_uuid.v4()}';
      final args = AdhocRunArgs(
        adhocId: adhocId,
        repositoryPath: node.path,
        displayName: '${node.name} (Claude)',
      );
      RunAdhocRoute(adhocId: adhocId, $extra: args).push<void>(context);
    case _ActionRunSkill(:final skillName):
      final adhocId = 'adhoc-${_uuid.v4()}';
      final args = AdhocRunArgs(
        adhocId: adhocId,
        repositoryPath: node.path,
        displayName: '${node.name} / $skillName',
        skillName: skillName,
      );
      RunAdhocRoute(adhocId: adhocId, $extra: args).push<void>(context);
    case _ActionRegisterSkill(:final skillName):
      EntryNewRoute(
        initialRepositoryPath: node.path,
        initialSkillName: skillName,
      ).push<void>(context);
  }
}

/// 右クリックメニューで選べるアクション。Skill 検知あり時のみ Skill 系が
/// 含まれる。
sealed class ExplorerNodeAction {
  const ExplorerNodeAction();
}

class _ActionOpenClaude extends ExplorerNodeAction {
  const _ActionOpenClaude();
}

class _ActionRunSkill extends ExplorerNodeAction {
  const _ActionRunSkill(this.skillName);
  final String skillName;
}

class _ActionRegisterSkill extends ExplorerNodeAction {
  const _ActionRegisterSkill(this.skillName);
  final String skillName;
}

/// 1 ディレクトリを表す行。タイル全体（テキスト以外の余白部分も含む）で
/// 左クリック / 右クリックを受け付ける。`ListTile` の代わりに自前 layout を
/// 使うのは、ListTile + GestureDetector の組み合わせで右クリックが文字部分
/// にしか効かない問題を回避するため。
class ExplorerNodeTile extends ConsumerWidget {
  const ExplorerNodeTile({required this.node, super.key});

  final ExplorerDirectoryNode node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSkill = node.skillNames.isNotEmpty;
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) =>
          showExplorerContextMenu(context, ref, node, details.globalPosition),
      child: InkWell(
        onTap: () =>
            ref.read(explorerViewModelProvider.notifier).enter(node.path),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                hasSkill ? Icons.folder_special : Icons.folder,
                color: hasSkill ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (hasSkill)
                      Text(
                        'Skill: ${node.skillNames.join(', ')}',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (hasSkill)
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text('${node.skillNames.length}'),
                  avatar: const Icon(Icons.bolt, size: 14),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
