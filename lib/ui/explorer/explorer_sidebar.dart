import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/router.dart';
import 'package:roola/data/launcher_entry/launcher_entries_provider.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/repo_explorer/explorer_settings.dart';
import 'package:roola/data/repo_explorer/explorer_settings_repository_impl.dart';
import 'package:roola/data/skill_runner/skill_run_state.dart';
import 'package:roola/data/skill_session/active_sessions.dart';
import 'package:roola/ui/common/prompt_name_dialog.dart';
import 'package:roola/ui/common/session_state_icon.dart';
import 'package:roola/ui/explorer/explorer_node_tile.dart'
    show decideDropOperation, performFileDrop;
import 'package:roola/ui/explorer/explorer_selection.dart';
import 'package:roola/ui/explorer/explorer_view_model.dart';
import 'package:roola/ui/explorer/launcher_actions.dart';
import 'package:roola/ui/run/adhoc_run_view_model.dart';
import 'package:roola/ui/run/run_view_model.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// エクスプローラ左側のサイドバー。Finder のサイドバー相当。
///
/// 4 セクション構成（上から）:
/// - **場所**: ホーム / ダウンロード / デスクトップ / ドキュメント /
///   アプリケーション + 「別のフォルダを開く…」
/// - **お気に入り**: ユーザー登録のフォルダ。クリックで navigate、右クリック
///   でリネーム / 削除、ドラッグ受け（`moveOrCopyInto`）
/// - **ランチャー**: 登録済み LauncherEntry。クリックで Skill セッション起動
/// - **実行中**: active session。空のときは「なし」プレースホルダ
///
/// 各セクションは見出し + 中身の縦並びで、サイドバー全体は `ListView` で
/// スクロール可能。
class ExplorerSidebar extends ConsumerWidget {
  const ExplorerSidebar({required this.currentPath, super.key});

  static const double width = 220;

  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(explorerSettingsProvider).value ??
        ExplorerSettings.defaults();
    final favorites = settings.favorites;
    final entries = ref.watch(launcherEntriesProvider).value ?? const [];
    final sessions = ref.watch(activeSessionsProvider);

    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 4),
        children: [
          // 場所
          const _SectionHeader('場所'),
          for (final place in _defaultPlaces)
            _PlaceTile(place: place, currentPath: currentPath),
          _OpenOtherFolderTile(),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // お気に入り
          _FavoritesHeader(currentPath: currentPath),
          if (favorites.isEmpty)
            const _EmptyFavoritesHint()
          else
            for (final fav in favorites)
              _FavoriteTile(
                favorite: fav,
                isCurrent: fav.path == currentPath,
              ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // ランチャー
          _LauncherHeader(),
          if (entries.isEmpty)
            const _EmptyLauncherHint()
          else
            for (final e in entries) _LauncherTile(entry: e),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // 実行中
          const _SectionHeader('実行中'),
          if (sessions.isEmpty)
            const _RunningEmptyTile()
          else
            for (final entry in sessions.entries)
              _RunningTile(sessionId: entry.key, state: entry.value),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ----- 共通 -----

/// セクション見出し（小さめ・控えめなラベル）。
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ----- 場所セクション -----

/// 場所セクションの固定エントリ定義。
class _Place {
  const _Place(this.label, this.icon, this.envVar, this.relPath);

  final String label;
  final IconData icon;

  /// 環境変数名（通常は HOME）。
  final String envVar;

  /// HOME 配下の相対パス。空文字なら HOME 直下を指す。
  final String relPath;

  /// 解決済みの絶対パス。`HOME` 未設定時は `null`。
  String? resolve() {
    final base = Platform.environment[envVar];
    if (base == null || base.isEmpty) {
      return null;
    }
    if (relPath.isEmpty) {
      return base;
    }
    return '$base/$relPath';
  }
}

/// 場所セクションに並ぶ固定 5 件 + 「アプリケーション」は絶対パス固定。
const _defaultPlaces = <_Place>[
  _Place('ホーム', Icons.home_outlined, 'HOME', ''),
  _Place('ダウンロード', Icons.download_outlined, 'HOME', 'Downloads'),
  _Place('デスクトップ', Icons.desktop_mac_outlined, 'HOME', 'Desktop'),
  _Place('ドキュメント', Icons.description_outlined, 'HOME', 'Documents'),
  // アプリケーションは HOME 配下ではなく `/Applications` 固定。
  _Place('アプリケーション', Icons.apps, '__abs__', '/Applications'),
];

class _PlaceTile extends ConsumerWidget {
  const _PlaceTile({required this.place, required this.currentPath});

  final _Place place;
  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final path = place.envVar == '__abs__' ? place.relPath : place.resolve();
    final isCurrent = path != null && path == currentPath;
    return InkWell(
      onTap: path == null
          ? null
          : () =>
                ref.read(explorerViewModelProvider.notifier).navigateTo(path),
      child: Container(
        color: isCurrent ? colors.primary.withValues(alpha: 0.1) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Icon(
              place.icon,
              size: 18,
              color: isCurrent ? colors.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                place.label,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 「別のフォルダを開く…」エントリ。file_picker でディレクトリを選ばせ、
/// `navigateTo` する。場所セクションの末尾に置く。
class _OpenOtherFolderTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () async {
        final picked = await FilePicker.getDirectoryPath();
        if (picked == null || !context.mounted) {
          return;
        }
        ref.read(explorerViewModelProvider.notifier).navigateTo(picked);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Icon(
              Icons.more_horiz,
              size: 18,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '別のフォルダを開く…',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----- お気に入りセクション -----

class _FavoritesHeader extends ConsumerWidget {
  const _FavoritesHeader({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'お気に入り',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            tooltip: '現在のディレクトリを登録',
            visualDensity: VisualDensity.compact,
            onPressed: () => _addCurrent(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _addCurrent(BuildContext context, WidgetRef ref) async {
    final defaultName = _basename(currentPath);
    final name = await promptName(
      context,
      title: '表示名',
      initialValue: defaultName,
      hintText: 'お気に入りの表示名',
    );
    if (name == null || name.trim().isEmpty || !context.mounted) {
      return;
    }
    await ref
        .read(explorerSettingsProvider.notifier)
        .addFavorite(
          ExplorerFavorite(
            id: 'fav-${_uuid.v4()}',
            path: currentPath,
            name: name.trim(),
          ),
        );
  }

  static String _basename(String path) {
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    return segments.isEmpty ? path : segments.last;
  }
}

class _EmptyFavoritesHint extends StatelessWidget {
  const _EmptyFavoritesHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Text(
        '上の + で現在のディレクトリを登録',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _FavoriteTile extends HookConsumerWidget {
  const _FavoriteTile({required this.favorite, required this.isCurrent});

  final ExplorerFavorite favorite;
  final bool isCurrent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isHovering = useState(false);
    // 「現在地」「ドラッグホバー中」の二状態をまとめる。両方とも
    // primary 色のうっすら背景。ホバーの方が濃く見えるよう alpha を
    // 大きめに取る。
    final Color? backgroundColor = isHovering.value
        ? colors.primary.withValues(alpha: 0.18)
        : isCurrent
        ? colors.primary.withValues(alpha: 0.1)
        : null;
    return DropRegion(
      formats: const [Formats.fileUri],
      hitTestBehavior: HitTestBehavior.opaque,
      // 内部 drag は自身・自身の祖先への drop を弾く（loop 防止）。
      // modifier とボリューム判定は decideDropOperation 内で済ませて
      // move / copy を返す。
      onDropOver: (event) =>
          decideDropOperation(event.session, favorite.path),
      onDropEnter: (_) => isHovering.value = true,
      onDropLeave: (_) => isHovering.value = false,
      onPerformDrop: (event) async {
        isHovering.value = false;
        await performFileDrop(context, ref, event, favorite.path);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onSecondaryTapDown: (details) =>
            _showMenu(context, ref, details.globalPosition),
        child: InkWell(
          onTap: () => ref
              .read(explorerViewModelProvider.notifier)
              .navigateTo(favorite.path),
          child: Container(
            color: backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 18,
                  color: isCurrent ? colors.primary : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    favorite.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showMenu(
    BuildContext context,
    WidgetRef ref,
    Offset position,
  ) async {
    final selected = await showMenu<_FavoriteAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: const [
        PopupMenuItem(
          value: _FavoriteAction.rename,
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('リネーム'),
          ),
        ),
        PopupMenuItem(
          value: _FavoriteAction.remove,
          child: ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('お気に入りから削除'),
          ),
        ),
      ],
    );
    if (selected == null || !context.mounted) {
      return;
    }
    final notifier = ref.read(explorerSettingsProvider.notifier);
    switch (selected) {
      case _FavoriteAction.rename:
        final newName = await promptName(
          context,
          title: '表示名',
          initialValue: favorite.name,
        );
        if (newName == null || newName.trim().isEmpty) {
          return;
        }
        await notifier.renameFavorite(favorite.id, newName.trim());
      case _FavoriteAction.remove:
        await notifier.removeFavorite(favorite.id);
    }
  }
}

enum _FavoriteAction { rename, remove }

// ----- ランチャーセクション -----

class _LauncherHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'ランチャー',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            tooltip: '新規エントリを登録',
            visualDensity: VisualDensity.compact,
            onPressed: () =>
                const EntryNewRoute().push<void>(context),
          ),
        ],
      ),
    );
  }
}

class _EmptyLauncherHint extends StatelessWidget {
  const _EmptyLauncherHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Text(
        '上の + で Skill エントリを登録',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// ランチャー登録エントリ 1 件のタイル。クリックで `launchLauncherEntry`
/// を呼ぶ。初回は永続セッション、すでに動いていれば連番付きの ad-hoc
/// セッションが起動する。selection も合わせて切替わるので body が PTY
/// ターミナルになる。
class _LauncherTile extends ConsumerWidget {
  const _LauncherTile({required this.entry});

  final LauncherEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => launchLauncherEntry(ref, entry),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Icon(Icons.bolt, size: 18, color: colors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                entry.displayName,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----- 実行中セクション -----

/// 実行中セッション 1 件のタイル。クリックで body をその PTY ターミナル
/// に切替える。✕ で完全破棄。
class _RunningTile extends ConsumerWidget {
  const _RunningTile({required this.sessionId, required this.state});

  final String sessionId;
  final SkillRunState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(launcherEntriesProvider).value ?? const [];
    final entry = entries.where((e) => e.id == sessionId).firstOrNull;
    final adhocArgs = entry == null
        ? ref.read(activeSessionsProvider.notifier).adhocArgsFor(sessionId)
        : null;
    if (entry == null && adhocArgs == null) {
      // 整合性が崩れている。表示しない。
      return const SizedBox.shrink();
    }
    final label = entry?.displayName ?? adhocArgs!.displayName;
    return InkWell(
      onTap: () {
        final selection = ref.read(explorerSelectionProvider.notifier);
        if (entry != null) {
          selection.selectEntrySession(sessionId);
        } else {
          selection.selectAdhocSession(adhocArgs!);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            SizedBox(width: 18, height: 18, child: sessionStateAvatar(state)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              tooltip: 'セッションを完全に破棄',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              onPressed: () {
                // 破棄対象が「いま body に表示されているセッション」と
                // 同じ場合、先に selection をディレクトリに切替えて
                // SessionView を unmount しないと、invalidate 直後の
                // rebuild で provider が再評価されて新しい runner が
                // build される（PTY が「破棄されない」ように見える）。
                final selection = ref.read(explorerSelectionProvider);
                final isCurrentlyViewed = switch (selection) {
                  ExplorerSelectionEntrySession(:final entryId) =>
                    entry != null && entryId == sessionId,
                  ExplorerSelectionAdhocSession(:final args) =>
                    adhocArgs != null && args.adhocId == adhocArgs.adhocId,
                  _ => false,
                };
                if (isCurrentlyViewed) {
                  final st = ref.read(explorerViewModelProvider);
                  ref
                      .read(explorerSelectionProvider.notifier)
                      .selectDirectory(st.currentPath);
                }
                if (entry != null) {
                  terminateSkillSession(ref, sessionId);
                } else if (adhocArgs != null) {
                  terminateAdhocSession(ref, adhocArgs);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RunningEmptyTile extends StatelessWidget {
  const _RunningEmptyTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Text(
        'なし',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
