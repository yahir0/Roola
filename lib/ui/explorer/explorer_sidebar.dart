import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/repo_explorer/explorer_settings.dart';
import 'package:roola/data/repo_explorer/explorer_settings_repository_impl.dart';
import 'package:roola/ui/common/prompt_name_dialog.dart';
import 'package:roola/ui/explorer/explorer_node_tile.dart'
    show decideDropOperation, performFileDrop;
import 'package:roola/ui/explorer/explorer_view_model.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// エクスプローラ左側のお気に入りサイドバー。Finder のサイドバー相当。
///
/// `explorerSettingsProvider.favorites` を購読して、タイルクリックで対象
/// パスに移動する。上部の「+」ボタンで現在地を登録、各タイルの右クリック
/// から削除・リネームができる。
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
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SidebarHeader(currentPath: currentPath),
          const Divider(height: 1),
          Expanded(
            child: favorites.isEmpty
                ? const _EmptyHint()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: favorites.length,
                    itemBuilder: (_, i) => _FavoriteTile(
                      favorite: favorites[i],
                      isCurrent: favorites[i].path == currentPath,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SidebarHeader extends ConsumerWidget {
  const _SidebarHeader({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text('お気に入り', style: Theme.of(context).textTheme.titleSmall),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        '上の + を押して現在のディレクトリを登録するとここに並びます',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
