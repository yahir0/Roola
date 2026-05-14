import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/router.dart';
import 'package:roola/data/launcher_entry/launcher_entries_provider.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/skill_runner/skill_run_state.dart';
import 'package:roola/data/skill_session/active_sessions.dart';
import 'package:roola/ui/common/session_state_icon.dart';
import 'package:roola/ui/explorer/explorer_selection.dart';

/// AppBar の ⚡ popover で表示するランチャー一覧グリッド。
///
/// 登録済み LauncherEntry を大きめのタイル + カスタムアイコンで並べる。
/// クリックで対応するセッションを起動し、エクスプローラ body をその PTY
/// ターミナルに切替える（[ExplorerSelectionNotifier.selectEntrySession]）。
///
/// このグリッドは旧ホーム画面の `_IconGrid` を popover 内で再利用できる
/// よう独立 widget 化したもの。chip strip や Scaffold は持たない。
class LauncherGrid extends ConsumerWidget {
  const LauncherGrid({super.key});

  /// popover の最大サイズ（高さ・幅）。横は 1 行 3 タイル分、縦は
  /// 4 行収まる程度。中身がこれを超える場合は内側のスクロール ListView
  /// が縦スクロールする。
  static const double maxWidth = 560;
  static const double maxHeight = 480;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(launcherEntriesProvider);
    final sessions = ref.watch(activeSessionsProvider);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          minWidth: 240,
        ),
        child: state.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text('読み込みに失敗しました: $error'),
          ),
          data: (entries) {
            if (entries.isEmpty) {
              return const _Empty();
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 160,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _Tile(
                        entry: entry,
                        sessionState: sessions[entry.id],
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                _Footer(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.apps, size: 48),
          const SizedBox(height: 12),
          const Text('登録されたランチャーがまだありません'),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('新規登録'),
            onPressed: () {
              Navigator.of(context).maybePop();
              const EntryNewRoute().push<void>(context);
            },
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          TextButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('新規登録'),
            onPressed: () {
              Navigator.of(context).maybePop();
              const EntryNewRoute().push<void>(context);
            },
          ),
          const Spacer(),
          TextButton.icon(
            icon: const Icon(Icons.settings_outlined, size: 18),
            label: const Text('管理…'),
            onPressed: () {
              Navigator.of(context).maybePop();
              const SettingsRoute().push<void>(context);
            },
          ),
        ],
      ),
    );
  }
}

class _Tile extends ConsumerWidget {
  const _Tile({required this.entry, required this.sessionState});

  final LauncherEntry entry;
  final SkillRunState? sessionState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // popover を閉じてから selection 更新。閉じる順序を逆にすると、
        // popover の Navigator が pop 中の selection 変更で再評価され、
        // 一瞬奇妙な見た目になることがある。
        Navigator.of(context).maybePop();
        ref
            .read(explorerSelectionProvider.notifier)
            .selectEntrySession(entry.id);
      },
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
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              entry.displayName,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
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
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      alignment: Alignment.center,
      child: sessionStateAvatar(state, size: 12),
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
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasIcon
          ? Image.file(File(path), fit: BoxFit.cover)
          : Icon(
              Icons.apps,
              size: 40,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
    );
  }
}
