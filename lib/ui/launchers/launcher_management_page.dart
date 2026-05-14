import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/router.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/launcher_entry/launcher_entries_provider.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/ui/common/macos_window_app_bar.dart';

/// 登録済みランチャーエントリの管理画面。
///
/// 旧来は SettingsPage に混在していたが、エントリ一覧は「アプリ設定」ではなく
/// 「コンテンツ管理」なので独立画面に分離した。サイドバーのランチャーセクション
/// 末尾の「管理…」ボタンから push される。
///
/// 一覧表示・追加導線・削除確認を提供する。各エントリの編集は ListTile タップで
/// [EntryEditRoute] へ遷移。
class LauncherManagementPage extends ConsumerWidget {
  const LauncherManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(launcherEntriesProvider);
    return Scaffold(
      appBar: MacosWindowAppBar(
        title: const Text('ランチャー管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'エントリ追加',
            onPressed: () => const EntryNewRoute().push<void>(context),
          ),
        ],
      ),
      body: state.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const _EmptyPlaceholder();
          }
          return _EntryList(entries: entries);
        },
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
            onPressed: () => const EntryNewRoute().push<void>(context),
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
            '${entry.workingDirectory}\n${_actionLabel(entry.action)}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          isThreeLine: true,
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '削除',
            onPressed: () => _confirmDelete(context, ref, entry),
          ),
          onTap: () => EntryEditRoute(entryId: entry.id).push<void>(context),
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
      await ref.read(launcherEntriesProvider.notifier).delete(entry.id);
    }
  }
}

/// subtitle に表示する 1 行分の動作説明。
String _actionLabel(LauncherAction action) => switch (action) {
  OpenHereAction() => '動作: 開くだけ',
  RunCommandAction(:final command) => '動作: コマンド実行 — $command',
  ClaudeSkillAction(:final skillName) => '動作: Claude Skill — $skillName',
};

class _EntryIcon extends StatelessWidget {
  const _EntryIcon({required this.iconPath});

  final String? iconPath;

  @override
  Widget build(BuildContext context) {
    final path = iconPath;
    if (path != null && File(path).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(File(path), width: 48, height: 48, fit: BoxFit.cover),
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
