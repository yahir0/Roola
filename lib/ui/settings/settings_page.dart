import 'dart:io';

import 'package:claude_skills_launcher/app/router.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry.dart';
import 'package:claude_skills_launcher/ui/settings/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 設定画面。登録済みランチャーエントリの一覧を表示し、追加・編集・削除へ
/// 導線を提供する。
class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'エントリ追加',
            onPressed: () => const EntryNewRoute().go(context),
          ),
        ],
      ),
      body: state.when(
        data: (entries) => entries.isEmpty
            ? const _EmptyPlaceholder()
            : _EntryList(entries: entries),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('読み込みに失敗しました: $error'),
          ),
        ),
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dashboard_customize, size: 64),
          const SizedBox(height: 16),
          const Text('登録されたランチャーがまだありません'),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('エントリを追加'),
            onPressed: () => const EntryNewRoute().go(context),
          ),
        ],
      ),
    );
  }
}

class _EntryList extends ConsumerWidget {
  const _EntryList({required this.entries});

  final List<LauncherEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ListTile(
          leading: _EntryIcon(iconPath: entry.iconPath),
          title: Text(entry.displayName),
          subtitle: Text(
            '${entry.repositoryPath}\nSkill: ${entry.skillName}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          isThreeLine: true,
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '削除',
            onPressed: () => _confirmDelete(context, ref, entry),
          ),
          onTap: () => EntryEditRoute(entryId: entry.id).go(context),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    LauncherEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('エントリを削除しますか？'),
        content: Text('「${entry.displayName}」を削除します。この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(settingsViewModelProvider.notifier).deleteEntry(entry.id);
    }
  }
}

class _EntryIcon extends StatelessWidget {
  const _EntryIcon({required this.iconPath});

  final String? iconPath;

  @override
  Widget build(BuildContext context) {
    final path = iconPath;
    if (path != null && File(path).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(path),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.apps,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
