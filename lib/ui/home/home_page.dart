import 'dart:io';

import 'package:claude_skills_launcher/app/router.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry.dart';
import 'package:claude_skills_launcher/ui/home/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// ホーム画面。登録済みランチャーエントリのアイコングリッドを表示する。
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Claude Skills Launcher'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '設定',
            onPressed: () => const SettingsRoute().go(context),
          ),
        ],
      ),
      body: state.when(
        data: (entries) => entries.isEmpty
            ? const _EmptyPlaceholder()
            : _IconGrid(entries: entries),
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
          const Icon(Icons.apps, size: 64),
          const SizedBox(height: 16),
          const Text('登録されたランチャーがまだありません'),
          const SizedBox(height: 8),
          const Text('右上の設定からエントリを追加してください'),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.settings),
            label: const Text('設定画面を開く'),
            onPressed: () => const SettingsRoute().go(context),
          ),
        ],
      ),
    );
  }
}

class _IconGrid extends StatelessWidget {
  const _IconGrid({required this.entries});

  final List<LauncherEntry> entries;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 0.85,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) => _LauncherTile(entry: entries[index]),
    );
  }
}

class _LauncherTile extends StatelessWidget {
  const _LauncherTile({required this.entry});

  final LauncherEntry entry;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => RunRoute(entryId: entry.id).go(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Icon(iconPath: entry.iconPath),
          const SizedBox(height: 12),
          Text(
            entry.displayName,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon({required this.iconPath});

  final String? iconPath;

  @override
  Widget build(BuildContext context) {
    final path = iconPath;
    final hasIcon = path != null && File(path).existsSync();
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasIcon
          ? Image.file(File(path), fit: BoxFit.cover)
          : Icon(
              Icons.apps,
              size: 48,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
    );
  }
}
