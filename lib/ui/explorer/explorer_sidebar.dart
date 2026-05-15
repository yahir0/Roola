import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/router.dart';
import 'package:roola/data/launcher_entry/launcher_entries_provider.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/launcher_entry/launcher_folder.dart';
import 'package:roola/data/launcher_entry/launcher_folders_provider.dart';
import 'package:roola/data/repo_explorer/explorer_settings.dart';
import 'package:roola/data/repo_explorer/explorer_settings_repository_impl.dart';
import 'package:roola/data/skill_session/active_sessions.dart';
import 'package:roola/data/terminal_runner/terminal_run_state.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/common/prompt_name_dialog.dart';
import 'package:roola/ui/common/session_state_icon.dart';
import 'package:roola/ui/explorer/explorer_node_tile.dart'
    show decideDropOperation, performFileDrop;
import 'package:roola/ui/explorer/launcher_actions.dart';
import 'package:roola/ui/run/adhoc_run_view_model.dart';
import 'package:roola/ui/workspace/focused_tab_provider.dart';
import 'package:roola/ui/workspace/workspace_navigation.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// ワークスペース左側のサイドバー。Finder のサイドバー相当（ウィンドウ共通・
/// ペインに属さない / ADR-0026）。
///
/// 4 セクション構成（上から）:
/// - **場所**: ホーム / ダウンロード / デスクトップ / ドキュメント /
///   アプリケーション + 「別のフォルダを開く…」
/// - **お気に入り**: ユーザー登録のフォルダ
/// - **ランチャー**: 登録済み LauncherEntry
/// - **実行中**: active session
///
/// 場所 / お気に入りのクリックや「現在のディレクトリを登録」は、最後に
/// フォーカスされたエクスプローラタブを対象に動作する（`workspace_navigation`）。
class ExplorerSidebar extends HookConsumerWidget {
  const ExplorerSidebar({super.key});

  static const double width = 220;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(explorerSettingsProvider).value ??
        ExplorerSettings.defaults();
    final favorites = settings.favorites;
    final entries = ref.watch(launcherEntriesProvider).value ?? const [];
    final folders = ref.watch(launcherFoldersProvider).value ?? const [];
    final sessions = ref.watch(activeSessionsProvider);

    // フォーカス中エクスプローラタブのカレントパス。場所 / お気に入りの
    // ハイライト判定に使う。エクスプローラタブが無ければ null。
    final focusedExplorerId = ref.watch(focusedTabProvider).lastExplorerTabId;
    final focusedTab = ref.watch(workspaceProvider).tabById(focusedExplorerId);
    final currentPath = focusedTab is ExplorerTab
        ? focusedTab.currentPath
        : null;

    // フォルダの展開状態をセッション内で保持する（永続化しない / ADR-0019）。
    final expandedFolderIds = useState<Set<String>>({
      for (final f in folders) f.id,
    });
    useEffect(() {
      final missing = folders
          .where((f) => !expandedFolderIds.value.contains(f.id))
          .map((f) => f.id)
          .toSet();
      if (missing.isNotEmpty) {
        expandedFolderIds.value = {...expandedFolderIds.value, ...missing};
      }
      return null;
    }, [folders]);

    final favoritePaths = {for (final f in favorites) f.path};
    final hasFavoriteAtCurrent =
        currentPath != null && favoritePaths.contains(currentPath);

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
            _PlaceTile(
              place: place,
              currentPath: currentPath,
              suppressHighlight: hasFavoriteAtCurrent,
            ),
          _OpenOtherFolderTile(),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // お気に入り
          _FavoritesHeader(currentPath: currentPath),
          if (favorites.isEmpty)
            const _EmptyFavoritesHint()
          else
            for (final fav in favorites)
              _FavoriteTile(favorite: fav, isCurrent: fav.path == currentPath),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // ランチャー
          _LauncherHeader(),
          if (entries.isEmpty && folders.isEmpty)
            const _EmptyLauncherHint()
          else ...[
            for (final folder in folders) ...[
              _LauncherFolderTile(
                folder: folder,
                expanded: expandedFolderIds.value.contains(folder.id),
                onToggle: () {
                  final next = Set<String>.from(expandedFolderIds.value);
                  if (!next.add(folder.id)) {
                    next.remove(folder.id);
                  }
                  expandedFolderIds.value = next;
                },
              ),
              if (expandedFolderIds.value.contains(folder.id))
                for (final e in entries.where((e) => e.folderId == folder.id))
                  _LauncherTile(entry: e, indented: true),
            ],
            if (folders.isNotEmpty) const _LauncherRootDropZone(),
            for (final e in entries.where((e) => e.folderId == null))
              _LauncherTile(entry: e),
          ],
          const _LauncherManageTile(),
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

class _Place {
  const _Place(this.label, this.icon, this.envVar, this.relPath);

  final String label;
  final IconData icon;
  final String envVar;
  final String relPath;

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

const _defaultPlaces = <_Place>[
  _Place('ホーム', Icons.home_outlined, 'HOME', ''),
  _Place('ダウンロード', Icons.download_outlined, 'HOME', 'Downloads'),
  _Place('デスクトップ', Icons.desktop_mac_outlined, 'HOME', 'Desktop'),
  _Place('ドキュメント', Icons.description_outlined, 'HOME', 'Documents'),
  _Place('アプリケーション', Icons.apps, '__abs__', '/Applications'),
];

class _PlaceTile extends ConsumerWidget {
  const _PlaceTile({
    required this.place,
    required this.currentPath,
    required this.suppressHighlight,
  });

  final _Place place;
  final String? currentPath;
  final bool suppressHighlight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final path = place.envVar == '__abs__' ? place.relPath : place.resolve();
    final isCurrent = path != null && path == currentPath && !suppressHighlight;
    return InkWell(
      onTap: path == null ? null : () => navigateInFocusedExplorer(ref, path),
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

/// 「別のフォルダを開く…」エントリ。
class _OpenOtherFolderTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () async {
        final picked = await FilePicker.getDirectoryPath();
        if (picked == null) {
          return;
        }
        navigateInFocusedExplorer(ref, picked);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Icon(Icons.more_horiz, size: 18, color: colors.onSurfaceVariant),
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

  final String? currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final path = currentPath;
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
            tooltip: 'フォーカス中のディレクトリを登録',
            visualDensity: VisualDensity.compact,
            onPressed: path == null
                ? null
                : () => _addCurrent(context, ref, path),
          ),
        ],
      ),
    );
  }

  Future<void> _addCurrent(
    BuildContext context,
    WidgetRef ref,
    String path,
  ) async {
    final name = await promptName(
      context,
      title: '表示名',
      initialValue: _basename(path),
      hintText: 'お気に入りの表示名',
    );
    if (name == null || name.trim().isEmpty) {
      return;
    }
    await ref
        .read(explorerSettingsProvider.notifier)
        .addFavorite(
          ExplorerFavorite(
            id: 'fav-${_uuid.v4()}',
            path: path,
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
        '上の + でフォーカス中のディレクトリを登録',
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
    final Color? backgroundColor = isHovering.value
        ? colors.primary.withValues(alpha: 0.18)
        : isCurrent
        ? colors.primary.withValues(alpha: 0.1)
        : null;
    return DropRegion(
      formats: const [Formats.fileUri],
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver: (event) => decideDropOperation(event.session, favorite.path),
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
          onTap: () => navigateInFocusedExplorer(ref, favorite.path),
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

class _LauncherHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onSecondaryTapDown: (details) =>
          _showContextMenu(context, ref, details.globalPosition),
      child: Padding(
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
              tooltip: '新規エントリを登録（右クリックでフォルダも作成）',
              visualDensity: VisualDensity.compact,
              onPressed: () => const EntryNewRoute().push<void>(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showContextMenu(
    BuildContext context,
    WidgetRef ref,
    Offset globalPosition,
  ) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final action = await showMenu<_LauncherHeaderAction>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem(
          value: _LauncherHeaderAction.newFolder,
          child: Text('新しいフォルダ'),
        ),
        PopupMenuItem(
          value: _LauncherHeaderAction.newEntry,
          child: Text('新しいエントリ'),
        ),
      ],
    );
    if (action == null || !context.mounted) {
      return;
    }
    switch (action) {
      case _LauncherHeaderAction.newFolder:
        final name = await promptName(
          context,
          title: 'フォルダ名',
          hintText: '例: dev / ops',
        );
        if (name == null || name.trim().isEmpty) {
          return;
        }
        await ref
            .read(launcherFoldersProvider.notifier)
            .add(
              LauncherFolder(
                id: _uuid.v4(),
                name: name.trim(),
                createdAt: DateTime.now(),
              ),
            );
      case _LauncherHeaderAction.newEntry:
        await const EntryNewRoute().push<void>(context);
    }
  }
}

enum _LauncherHeaderAction { newFolder, newEntry }

class _EmptyLauncherHint extends StatelessWidget {
  const _EmptyLauncherHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Text(
        '上の + でエントリを登録',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// ランチャーセクション末尾の「管理…」タイル（ADR-0018）。
class _LauncherManageTile extends StatelessWidget {
  const _LauncherManageTile();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => const LauncherManagementRoute().push<void>(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Icon(Icons.tune, size: 18, color: colors.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'ランチャーを管理…',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
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

/// ランチャー登録エントリ 1 件のタイル。クリックで `launchLauncherEntry`
/// を呼び、bottom ペインにターミナルタブとして開く（ADR-0026）。
class _LauncherTile extends ConsumerWidget {
  const _LauncherTile({required this.entry, this.indented = false});

  final LauncherEntry entry;
  final bool indented;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LongPressDraggable<LauncherEntry>(
      data: entry,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(2),
        child: SizedBox(
          width: ExplorerSidebar.width - 16,
          child: _tile(context, ref, dragging: false),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _tile(context, ref, dragging: true),
      ),
      child: _tile(context, ref, dragging: false),
    );
  }

  Widget _tile(BuildContext context, WidgetRef ref, {required bool dragging}) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: dragging ? null : () => launchLauncherEntry(ref, entry),
      child: Padding(
        padding: EdgeInsets.fromLTRB(indented ? 32 : 16, 6, 16, 6),
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

/// フォルダ 1 件分のヘッダタイル（ADR-0019 / Phase 4）。
class _LauncherFolderTile extends ConsumerWidget {
  const _LauncherFolderTile({
    required this.folder,
    required this.expanded,
    required this.onToggle,
  });

  final LauncherFolder folder;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<LauncherEntry>(
      onWillAcceptWithDetails: (details) => details.data.folderId != folder.id,
      onAcceptWithDetails: (details) async {
        await ref
            .read(launcherEntriesProvider.notifier)
            .updateEntry(details.data.copyWith(folderId: folder.id));
      },
      builder: (context, candidate, rejected) {
        final colors = Theme.of(context).colorScheme;
        final hover = candidate.isNotEmpty;
        return GestureDetector(
          onSecondaryTapDown: (details) =>
              _showContextMenu(context, ref, details.globalPosition),
          child: InkWell(
            onTap: onToggle,
            child: Container(
              color: hover ? colors.primary.withValues(alpha: 0.12) : null,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    expanded ? Icons.arrow_drop_down : Icons.arrow_right,
                    size: 20,
                    color: colors.onSurfaceVariant,
                  ),
                  Icon(
                    Icons.folder_outlined,
                    size: 18,
                    color: colors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      folder.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showContextMenu(
    BuildContext context,
    WidgetRef ref,
    Offset globalPosition,
  ) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final action = await showMenu<_LauncherFolderAction>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem(value: _LauncherFolderAction.rename, child: Text('リネーム')),
        PopupMenuItem(
          value: _LauncherFolderAction.delete,
          child: Text('削除（中身は未分類に戻る）'),
        ),
      ],
    );
    if (action == null || !context.mounted) {
      return;
    }
    switch (action) {
      case _LauncherFolderAction.rename:
        final newName = await promptName(
          context,
          title: 'フォルダ名',
          initialValue: folder.name,
        );
        if (newName == null || newName.trim().isEmpty) {
          return;
        }
        await ref
            .read(launcherFoldersProvider.notifier)
            .updateFolder(folder.copyWith(name: newName.trim()));
      case _LauncherFolderAction.delete:
        if (!context.mounted) {
          return;
        }
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('フォルダを削除しますか？'),
            content: Text('「${folder.name}」を削除します。中身のエントリは未分類に戻ります。'),
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
          await ref.read(launcherFoldersProvider.notifier).delete(folder.id);
        }
    }
  }
}

enum _LauncherFolderAction { rename, delete }

/// フォルダ群と root エントリの間に挟む「未分類」mini-header 兼 drop zone。
class _LauncherRootDropZone extends ConsumerWidget {
  const _LauncherRootDropZone();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return DragTarget<LauncherEntry>(
      onWillAcceptWithDetails: (details) => details.data.folderId != null,
      onAcceptWithDetails: (details) async {
        await ref
            .read(launcherEntriesProvider.notifier)
            .updateEntry(details.data.copyWith(folderId: null));
      },
      builder: (context, candidate, rejected) {
        final hover = candidate.isNotEmpty;
        return Container(
          color: hover ? colors.primary.withValues(alpha: 0.12) : null,
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
          child: Text(
            '未分類',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}

// ----- 実行中セクション -----

/// 実行中セッション 1 件のタイル。クリックで該当ターミナルタブにフォーカス
/// （無ければ bottom ペインに再作成）。✕ でタブごと破棄する（ADR-0026）。
class _RunningTile extends ConsumerWidget {
  const _RunningTile({required this.sessionId, required this.state});

  final String sessionId;
  final SkillRunState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adhocArgs = ref
        .read(activeSessionsProvider.notifier)
        .adhocArgsFor(sessionId);
    if (adhocArgs == null) {
      // 整合性が崩れている。表示しない。
      return const SizedBox.shrink();
    }
    final layout = ref.watch(workspaceProvider);
    final tab = _terminalTabFor(layout, sessionId);
    return InkWell(
      onTap: () {
        final workspace = ref.read(workspaceProvider.notifier);
        if (tab != null) {
          workspace.activateTab(tab.id);
        } else {
          workspace.addTerminalTab(PaneSlotId.bottom, args: adhocArgs);
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
                adhocArgs.displayName,
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
                if (tab != null) {
                  ref.read(workspaceProvider.notifier).closeTab(tab.id);
                } else {
                  // タブを持たない孤立セッション。直接破棄する。
                  ref
                      .read(activeSessionsProvider.notifier)
                      .unregister(sessionId);
                  ref.invalidate(adhocRunViewModelProvider(adhocArgs));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// `sessionId`（= adhocId）に対応するターミナルタブを workspace から探す。
  static TerminalTab? _terminalTabFor(
    WorkspaceLayout layout,
    String sessionId,
  ) {
    for (final slotId in PaneSlotId.values) {
      for (final t in layout.slot(slotId).tabs) {
        if (t is TerminalTab && t.args.adhocId == sessionId) {
          return t;
        }
      }
    }
    return null;
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
