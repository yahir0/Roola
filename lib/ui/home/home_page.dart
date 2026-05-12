import 'dart:io';

import 'package:claude_skills_launcher/app/router.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry.dart';
import 'package:claude_skills_launcher/data/skill_runner/skill_run_state.dart';
import 'package:claude_skills_launcher/data/skill_session/active_sessions.dart';
import 'package:claude_skills_launcher/ui/common/session_state_icon.dart';
import 'package:claude_skills_launcher/ui/home/active_sessions_strip.dart';
import 'package:claude_skills_launcher/ui/home/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// ホーム画面。登録済みランチャーエントリのアイコングリッドを表示する。
/// 上部に実行中・終了済みセッションの chip 列、各アイコン右上に状態バッジを
/// 重ねて、複数セッションの並行運用を可視化する。
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final sessions = ref.watch(activeSessionsProvider);
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
      body: Column(
        children: [
          const ActiveSessionsStrip(),
          Expanded(
            child: state.when(
              data: (entries) => entries.isEmpty
                  ? const _EmptyPlaceholder()
                  : _IconGrid(entries: entries, sessions: sessions),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('読み込みに失敗しました: $error'),
                ),
              ),
            ),
          ),
        ],
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
  const _IconGrid({required this.entries, required this.sessions});

  final List<LauncherEntry> entries;
  final Map<String, SkillRunState> sessions;

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
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _LauncherTile(entry: entry, sessionState: sessions[entry.id]);
      },
    );
  }
}

class _LauncherTile extends StatelessWidget {
  const _LauncherTile({required this.entry, required this.sessionState});

  final LauncherEntry entry;
  final SkillRunState? sessionState;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => RunRoute(entryId: entry.id).go(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _Icon(iconPath: entry.iconPath),
              if (sessionState != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: _SessionBadge(state: sessionState!),
                ),
            ],
          ),
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

class _SessionBadge extends StatelessWidget {
  const _SessionBadge({required this.state});

  final SkillRunState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      alignment: Alignment.center,
      child: sessionStateAvatar(state, size: 14),
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
