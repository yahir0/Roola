import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/router.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/core/health/claude_health_check.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/launcher_entry/launcher_entries_provider.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/launcher_entry/launcher_folder.dart';
import 'package:roola/data/launcher_entry/launcher_folders_provider.dart';
import 'package:roola/data/repo_explorer/explorer_settings.dart';
import 'package:roola/data/repo_explorer/explorer_settings_repository_impl.dart';
import 'package:roola/data/repo_explorer/favorite_tree_provider.dart';
import 'package:roola/data/skill_session/active_sessions.dart';
import 'package:roola/data/terminal_runner/terminal_run_state.dart';
import 'package:roola/data/terminal_runner/windows_shell.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/command_menu_item.dart';
import 'package:roola/ui/common/polaris_dialog.dart';
import 'package:roola/ui/common/polaris_glyphs.dart';
import 'package:roola/ui/common/prompt_name_dialog.dart';
import 'package:roola/ui/common/session_state_icon.dart';
import 'package:roola/ui/explorer/dnd_ready_provider.dart';
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
    final favoriteFolders = settings.favoriteFolders;
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

    // お気に入りフォルダの展開状態（同上 / ADR-0029）。
    final expandedFavoriteFolderIds = useState<Set<String>>({
      for (final f in favoriteFolders) f.id,
    });
    useEffect(() {
      final missing = favoriteFolders
          .where((f) => !expandedFavoriteFolderIds.value.contains(f.id))
          .map((f) => f.id)
          .toSet();
      if (missing.isNotEmpty) {
        expandedFavoriteFolderIds.value = {
          ...expandedFavoriteFolderIds.value,
          ...missing,
        };
      }
      return null;
    }, [favoriteFolders]);

    // お気に入りツリーの展開状態（パスを保持・セッション内のみ・永続化なし）。
    // Win2000 風のディレクトリツリー表示用（_FavoriteTile / _FavoriteTreeChild）。
    final expandedTreePaths = useState<Set<String>>(const {});
    void toggleTreePath(String path) {
      final next = Set<String>.from(expandedTreePaths.value);
      if (!next.add(path)) {
        next.remove(path);
      }
      expandedTreePaths.value = next;
    }

    final favoritePaths = {for (final f in favorites) f.path};
    final hasFavoriteAtCurrent =
        currentPath != null && favoritePaths.contains(currentPath);

    final tokens = PolarisTokens.of(context);
    return Container(
      width: width,
      // サイドバーは筐体側のクローム＝bg トーン（ADR-0038 D3）。
      decoration: BoxDecoration(
        color: tokens.bg,
        border: Border(right: BorderSide(color: tokens.line)),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: PolarisTokens.space1),
        children: [
          // 場所
          const _SectionHeader('Places'),
          for (final place in _effectivePlaces())
            _PlaceTile(
              place: place,
              currentPath: currentPath,
              suppressHighlight: hasFavoriteAtCurrent,
            ),
          _OpenOtherFolderTile(),
          const SizedBox(height: PolarisTokens.space2),
          const Divider(height: 1),

          // お気に入り
          _FavoritesHeader(currentPath: currentPath),
          if (favorites.isEmpty && favoriteFolders.isEmpty)
            const _EmptyFavoritesHint()
          else ...[
            for (final folder in favoriteFolders) ...[
              _FavoriteFolderTile(
                folder: folder,
                expanded: expandedFavoriteFolderIds.value.contains(folder.id),
                onToggle: () {
                  final next = Set<String>.from(
                    expandedFavoriteFolderIds.value,
                  );
                  if (!next.add(folder.id)) {
                    next.remove(folder.id);
                  }
                  expandedFavoriteFolderIds.value = next;
                },
              ),
              if (expandedFavoriteFolderIds.value.contains(folder.id))
                for (final fav in favorites.where(
                  (f) => f.folderId == folder.id,
                ))
                  _FavoriteTile(
                    favorite: fav,
                    isCurrent: fav.path == currentPath,
                    indented: true,
                    expandedTreePaths: expandedTreePaths.value,
                    onToggleTreePath: toggleTreePath,
                    currentPath: currentPath,
                  ),
            ],
            if (favoriteFolders.isNotEmpty) const _FavoriteRootDropZone(),
            for (final fav in favorites.where((f) => f.folderId == null))
              _FavoriteTile(
                favorite: fav,
                isCurrent: fav.path == currentPath,
                expandedTreePaths: expandedTreePaths.value,
                onToggleTreePath: toggleTreePath,
                currentPath: currentPath,
              ),
          ],
          const SizedBox(height: PolarisTokens.space2),
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
          const SizedBox(height: PolarisTokens.space2),
          const Divider(height: 1),

          // 実行中
          const _SectionHeader('Running'),
          if (sessions.isEmpty)
            const _RunningEmptyTile()
          else
            for (final entry in sessions.entries)
              _RunningTile(sessionId: entry.key, state: entry.value),
          const SizedBox(height: PolarisTokens.space2),
        ],
      ),
    );
  }
}

// ----- 共通 -----

/// プレーンなセクション見出し（場所 / 実行中）。アクションを持たない。
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => _SidebarSectionHeader(label);
}

/// サイドバーの全セクション見出し（場所 / お気に入り / ランチャー / 実行中）の
/// 共通スキャフォールド。高さを固定し、右肩にアクション（「＋」ボタン等）を
/// 置いても行が膨らまないようにする。アクションの有無で高さがばらつくのを
/// 構造的に防ぐのが要点。
class _SidebarSectionHeader extends StatelessWidget {
  const _SidebarSectionHeader(this.label, {this.action});

  final String label;

  /// 見出し右端のアクション。null ならラベルのみ。
  final Widget? action;

  /// 見出し行の固定高さ。「＋」アイコン（18px）が収まり、ラベルのみの見出しと
  /// 共通になる値（6 グリッド = 24px / ADR-0038 D6）。
  static const double height = PolarisTokens.space6;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        // 高さは固定なので横方向のみ。右はアクション分を詰めて space2。
        padding: const EdgeInsets.fromLTRB(
          PolarisTokens.space4,
          0,
          PolarisTokens.space2,
          0,
        ),
        child: Row(
          children: [
            Expanded(child: _SectionLabelText(label)),
            ?action,
          ],
        ),
      ),
    );
  }
}

/// セクション見出し右肩の「＋」ボタン。タップ領域を見出しの固定高さに
/// 合わせて詰め、行を膨らませない。
class _SectionHeaderAddButton extends StatelessWidget {
  const _SectionHeaderAddButton({
    required this.tooltip,
    required this.onPressed,
  });

  final String tooltip;

  /// `buttonContext` はボタン自身を指す（ポップアップの表示位置算出に使う）。
  final void Function(BuildContext buttonContext) onPressed;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (buttonContext) => IconButton(
        icon: const Icon(Icons.add, size: PolarisIconSize.standard),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(
          width: _SidebarSectionHeader.height,
          height: _SidebarSectionHeader.height,
        ),
        onPressed: () => onPressed(buttonContext),
      ),
    );
  }
}

/// サイドバーのセクション見出し文字（全大文字トラッキング / ADR-0038 D9）。
/// `toUpperCase()` は日本語ラベルには影響せず、英語ロケールでのみ大文字化する。
class _SectionLabelText extends StatelessWidget {
  const _SectionLabelText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return Text(
      text.toUpperCase(),
      style: tokens.label.copyWith(color: tokens.textFaint),
    );
  }
}

// ----- 場所セクション -----

class _Place {
  const _Place(this.label, this.icon, this.envVar, this.relPath);

  /// 表示ラベル。ロケールに依存しない固定の英語表記（[_defaultPlaces] 参照）。
  final String label;
  final IconData icon;
  final String envVar;
  final String relPath;

  String? resolve() {
    // macOS / Linux: $HOME、Windows: %USERPROFILE%
    final base = Platform.environment[envVar]
        ?? (Platform.isWindows ? Platform.environment['USERPROFILE'] : null);
    if (base == null || base.isEmpty) {
      return null;
    }
    if (relPath.isEmpty) {
      return base;
    }
    return '$base/$relPath';
  }
}

/// 場所セクションの初期項目。`_effectivePlaces()` でプラットフォームごとに絞る。
const _allPlaces = <_Place>[
  _Place('Home', Icons.home_outlined, 'HOME', ''),
  _Place('Downloads', Icons.download_outlined, 'HOME', 'Downloads'),
  _Place('Desktop', Icons.desktop_mac_outlined, 'HOME', 'Desktop'),
  _Place('Documents', Icons.description_outlined, 'HOME', 'Documents'),
  // macOS 専用: /Applications はほかの OS には存在しない。
  _Place('Applications', Icons.apps, '__abs__', '/Applications'),
];

/// 現在の OS に合わせた場所リストを返す。
List<_Place> _effectivePlaces() {
  if (Platform.isMacOS) return _allPlaces;
  // Windows / Linux では Applications を除外する。
  return _allPlaces
      .where((p) => p.envVar != '__abs__')
      .toList();
}

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
    final tokens = PolarisTokens.of(context);
    final path = place.envVar == '__abs__' ? place.relPath : place.resolve();
    final isCurrent = path != null && path == currentPath && !suppressHighlight;
    return InkWell(
      onTap: path == null ? null : () => navigateInFocusedExplorer(ref, path),
      child: _SidebarRow(
        selected: isCurrent,
        icon: Icon(
          place.icon,
          size: PolarisIconSize.standard,
          color: isCurrent ? tokens.accent : tokens.textDim,
        ),
        label: place.label,
      ),
    );
  }
}

/// サイドバーの行 1 段の共通スキャフォールド（Polaris / ADR-0038 D12）。
/// 選択時は surfaceHi の塗り＋左 2px アクセントバー＋アクセント文字。
class _SidebarRow extends StatelessWidget {
  const _SidebarRow({
    required this.selected,
    required this.icon,
    required this.label,
  });

  final bool selected;
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return Stack(
      children: [
        Container(
          color: selected ? tokens.surfaceHi : null,
          // 行は固定高さ。中身（アイコン 18px）は中央寄せになる。詰まり／
          // 広がりをパディングで微調整せず、グリッド値の行高で決める。
          height: PolarisTokens.space7,
          padding: const EdgeInsets.fromLTRB(16, 0, PolarisTokens.space4, 0),
          child: Row(
            children: [
              icon,
              const SizedBox(width: PolarisTokens.space2),
              Expanded(
                child: Text(
                  label,
                  style: tokens.body.copyWith(
                    color: selected ? tokens.accent : tokens.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (selected)
          Positioned(
            left: 0,
            top: 4,
            bottom: 4,
            child: Container(width: 2, color: tokens.accent),
          ),
      ],
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
      child: Container(
        height: PolarisTokens.space7,
        padding: const EdgeInsets.symmetric(horizontal: PolarisTokens.space4),
        child: Row(
          children: [
            Icon(
              Icons.more_horiz,
              size: PolarisIconSize.standard,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: PolarisTokens.space2),
            Expanded(
              child: Text(
                AppLocalizations.of(context).explorerOpenOtherFolder,
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

/// セクションヘッダの「+」ボタン直下にポップアップメニューを出すための
/// グローバル座標を返す。[buttonContext] はボタン自身を指す `Builder`
/// のコンテキスト。
Offset _menuAnchorBelowButton(BuildContext buttonContext) {
  final box = buttonContext.findRenderObject() as RenderBox;
  return box.localToGlobal(Offset(0, box.size.height));
}

class _FavoritesHeader extends ConsumerWidget {
  const _FavoritesHeader({required this.currentPath});

  final String? currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onSecondaryTapDown: (details) =>
          _showContextMenu(context, ref, details.globalPosition),
      child: _SidebarSectionHeader(
        'Favorites',
        action: _SectionHeaderAddButton(
          tooltip: l10n.explorerFavoritesAddTooltip,
          onPressed: (buttonContext) => _showContextMenu(
            context,
            ref,
            _menuAnchorBelowButton(buttonContext),
          ),
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
    final l10n = AppLocalizations.of(context);
    final path = currentPath;
    final action = await showMenu<_FavoritesHeaderAction>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        polarisPopupMenuItem<_FavoritesHeaderAction>(
          context,
          value: _FavoritesHeaderAction.addCurrent,
          enabled: path != null,
          label: l10n.explorerRegisterCurrentDirectory,
        ),
        polarisPopupMenuItem<_FavoritesHeaderAction>(
          context,
          value: _FavoritesHeaderAction.newFolder,
          label: l10n.explorerNewFavoriteFolder,
        ),
      ],
    );
    if (action == null || !context.mounted) {
      return;
    }
    switch (action) {
      case _FavoritesHeaderAction.newFolder:
        final name = await promptName(
          context,
          title: l10n.launcherFolderNameTitle,
          hintText: l10n.explorerFavoriteFolderHint,
        );
        if (name == null || name.trim().isEmpty) {
          return;
        }
        await ref
            .read(explorerSettingsProvider.notifier)
            .addFavoriteFolder(
              ExplorerFavoriteFolder(
                id: _uuid.v4(),
                name: name.trim(),
                createdAt: DateTime.now(),
              ),
            );
      case _FavoritesHeaderAction.addCurrent:
        if (path != null && context.mounted) {
          await _addCurrent(context, ref, path);
        }
    }
  }

  Future<void> _addCurrent(
    BuildContext context,
    WidgetRef ref,
    String path,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = await promptName(
      context,
      title: l10n.entryEditDisplayNameLabel,
      initialValue: _basename(path),
      hintText: l10n.explorerFavoriteDisplayNameHint,
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
      padding: const EdgeInsets.fromLTRB(
        PolarisTokens.space4,
        PolarisTokens.space1,
        PolarisTokens.space4,
        PolarisTokens.space1,
      ),
      child: Text(
        AppLocalizations.of(context).explorerFavoritesEmptyHint,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _FavoriteTile extends HookConsumerWidget {
  const _FavoriteTile({
    required this.favorite,
    required this.isCurrent,
    required this.expandedTreePaths,
    required this.onToggleTreePath,
    required this.currentPath,
    this.indented = false,
  });

  final ExplorerFavorite favorite;
  final bool isCurrent;

  /// 展開中ツリーパスの集合（サイドバーで保持。永続化なし）。
  final Set<String> expandedTreePaths;

  /// ツリー展開のトグル。chevron クリックで呼ばれる。
  final void Function(String) onToggleTreePath;

  /// フォーカス中エクスプローラの currentPath。サブディレクトリツリーの
  /// 行をハイライト判定するために配下まで降りる。
  final String? currentPath;

  /// フォルダ配下のお気に入りなら `true`。先頭インデントを深くする。
  final bool indented;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovering = useState(false);
    final tokens = PolarisTokens.of(context);
    // 現在地、または drop ホバー中は強調（どちらも surfaceHi / D12）。
    final highlighted = isHovering.value || isCurrent;
    final isExpanded = expandedTreePaths.contains(favorite.path);
    // フォルダへ移動するための内部 DnD（ADR-0029、ランチャーと同パターン）。
    // OS ファイルドロップ用の DropRegion を内側に保持したまま、外側を
    // LongPressDraggable で包む。
    final tileBody = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) =>
          _showMenu(context, ref, details.globalPosition),
      child: InkWell(
        onTap: () => navigateInFocusedExplorer(ref, favorite.path),
        child: _row(context, highlighted: highlighted, isExpanded: isExpanded),
      ),
    );
    // 起動直後は OS ファイルドロップ受けを登録しない（ADR-0049）。内部
    // 並べ替え用の LongPressDraggable は Flutter 標準なのでそのまま包む。
    final dropTarget = ref.watch(dndReadyProvider)
        ? DropRegion(
            formats: const [Formats.fileUri],
            hitTestBehavior: HitTestBehavior.opaque,
            onDropOver: (event) =>
                decideDropOperation(event.session, favorite.path),
            onDropEnter: (_) => isHovering.value = true,
            onDropLeave: (_) => isHovering.value = false,
            onPerformDrop: (event) async {
              isHovering.value = false;
              await performFileDrop(context, ref, event, favorite.path);
            },
            child: tileBody,
          )
        : tileBody;
    final tile = LongPressDraggable<ExplorerFavorite>(
      data: favorite,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(tokens.radius),
        child: SizedBox(
          width: ExplorerSidebar.width - 16,
          child: _row(context, highlighted: false, isExpanded: isExpanded),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _row(context, highlighted: highlighted, isExpanded: isExpanded),
      ),
      child: dropTarget,
    );
    // 展開中はサブディレクトリツリーを下に並べる（Win2000 風）。
    // ツリー描画は [_FavoriteTreeChild] が再帰的に行う。
    if (!isExpanded) {
      return tile;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tile,
        for (final child in ref.watch(
          favoriteTreeChildrenProvider(favorite.path),
        ))
          _FavoriteTreeChild(
            path: child.path,
            name: child.name,
            depth: indented ? 2 : 1,
            currentPath: currentPath,
            expandedTreePaths: expandedTreePaths,
            onToggleTreePath: onToggleTreePath,
          ),
      ],
    );
  }

  Widget _row(
    BuildContext context, {
    required bool highlighted,
    required bool isExpanded,
  }) {
    return _FavoriteTreeRow(
      // 既存の _SidebarRow と同じ indent（top-level=16, indented=32）。
      // chevron はこの indent 内側に置く（label の開始位置は chevron 込みで
      // 右にずれる）。
      baseIndent: indented ? 32 : 16,
      isExpanded: isExpanded,
      onToggleChevron: () => onToggleTreePath(favorite.path),
      icon: PolarisTypeIcon(
        isDir: true,
        color: highlighted
            ? PolarisTokens.of(context).accent
            : PolarisTokens.of(context).textDim,
      ),
      label: favorite.name,
      highlighted: highlighted,
    );
  }

  Future<void> _showMenu(
    BuildContext context,
    WidgetRef ref,
    Offset position,
  ) async {
    final l10n = AppLocalizations.of(context);
    // Claude CLI 未導入時は「Claude Code で開く」を非表示にする（ADR-0022）。
    // cached な claudeHealthProvider を参照するだけで I/O は発生しない。
    final claudeAvailable = ref.read(claudeAvailableProvider);
    final selected = await showMenu<_FavoriteAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        polarisPopupMenuItem<_FavoriteAction>(
          context,
          value: _FavoriteAction.openInNewTab,
          icon: Icons.tab_outlined,
          label: l10n.explorerOpenInNewTab,
        ),
        if (claudeAvailable)
          commandPopupMenuItem<_FavoriteAction>(
            context,
            ref,
            command: CommandId.openClaudeHere,
            value: _FavoriteAction.openClaude,
          ),
        if (Platform.isWindows) ...[
          polarisPopupMenuItem<_FavoriteAction>(
            context,
            value: _FavoriteAction.openTerminalCmd,
            icon: Icons.developer_mode,
            label: l10n.explorerOpenTerminalCmdPrompt,
          ),
          polarisPopupMenuItem<_FavoriteAction>(
            context,
            value: _FavoriteAction.openTerminalPs,
            icon: Icons.developer_mode,
            label: l10n.explorerOpenTerminalPowerShell,
          ),
        ] else
          commandPopupMenuItem<_FavoriteAction>(
            context,
            ref,
            command: CommandId.openTerminalHere,
            value: _FavoriteAction.openTerminal,
          ),
        const PopupMenuDivider(height: polarisMenuDividerHeight),
        polarisPopupMenuItem<_FavoriteAction>(
          context,
          value: _FavoriteAction.rename,
          icon: Icons.edit_outlined,
          label: l10n.explorerRenameTitle,
        ),
        polarisPopupMenuItem<_FavoriteAction>(
          context,
          value: _FavoriteAction.remove,
          icon: Icons.delete_outline,
          label: l10n.explorerRemoveFromFavorites,
        ),
      ],
    );
    if (selected == null || !context.mounted) {
      return;
    }
    final notifier = ref.read(explorerSettingsProvider.notifier);
    switch (selected) {
      case _FavoriteAction.openInNewTab:
        // フォーカス追従ではなく、常に新規エクスプローラタブを開く。
        ref
            .read(workspaceProvider.notifier)
            .addExplorerTab(PaneSlotId.topLeft, path: favorite.path);
      case _FavoriteAction.openClaude:
        // 「Claude Code で開く」は素の `claude` 起動（ADR-0016）。
        ref.read(workspaceProvider.notifier).addTerminalTab(
              PaneSlotId.bottom,
              args: AdhocRunArgs(
                adhocId: 'adhoc-${_uuid.v4()}',
                workingDirectory: favorite.path,
                displayName: '${favorite.name} (Claude)',
                action: const LauncherAction.runCommand(
                  command: 'claude',
                  keepShellAfterExit: false,
                ),
              ),
            );
      case _FavoriteAction.openTerminal:
        ref.read(workspaceProvider.notifier).addTerminalTab(
              PaneSlotId.bottom,
              args: AdhocRunArgs(
                adhocId: 'adhoc-${_uuid.v4()}',
                workingDirectory: favorite.path,
                displayName: '${favorite.name} (Terminal)',
                action: const LauncherAction.openHere(),
              ),
            );
      case _FavoriteAction.openTerminalCmd:
        ref.read(workspaceProvider.notifier).addTerminalTab(
              PaneSlotId.bottom,
              args: AdhocRunArgs(
                adhocId: 'adhoc-${_uuid.v4()}',
                workingDirectory: favorite.path,
                displayName: '${favorite.name} (cmd)',
                action: const LauncherAction.openHere(),
                windowsShell: WindowsShell.cmd,
              ),
            );
      case _FavoriteAction.openTerminalPs:
        ref.read(workspaceProvider.notifier).addTerminalTab(
              PaneSlotId.bottom,
              args: AdhocRunArgs(
                adhocId: 'adhoc-${_uuid.v4()}',
                workingDirectory: favorite.path,
                displayName: '${favorite.name} (PowerShell)',
                action: const LauncherAction.openHere(),
                windowsShell: WindowsShell.powershell,
              ),
            );
      case _FavoriteAction.rename:
        final newName = await promptName(
          context,
          title: l10n.entryEditDisplayNameLabel,
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

enum _FavoriteAction {
  openInNewTab,
  openClaude,
  openTerminal,
  openTerminalCmd,
  openTerminalPs,
  rename,
  remove,
}

enum _FavoritesHeaderAction { newFolder, addCurrent }

/// お気に入りツリー（[_FavoriteTile] / [_FavoriteTreeChild]）の 1 行を描く
/// 共通行 widget。chevron + アイコン + ラベルを横並びにし、chevron だけは
/// 別 hit target で展開トグルを受ける。
///
/// `_FavoriteFolderTile`（フォルダ＝ユーザー命名グループ）は **太い三角**
/// `arrow_drop_down/arrow_right`（standard サイズ）を使うのに対し、こちら
/// （実ファイルシステムのツリー）は **細いシェブロン** `expand_more/chevron_right`
/// （small サイズ）を使う。chevron の太さと leading icon（Polaris カスタム）
/// で「ラベル付きグループ」と「filesystem パス」を視覚的に分ける。
class _FavoriteTreeRow extends StatelessWidget {
  const _FavoriteTreeRow({
    required this.baseIndent,
    required this.isExpanded,
    required this.onToggleChevron,
    required this.icon,
    required this.label,
    required this.highlighted,
  });

  /// 行の左端から chevron 領域開始までの px。階層が深くなるほど大きい。
  final double baseIndent;
  final bool isExpanded;
  final VoidCallback onToggleChevron;
  final Widget icon;
  final String label;
  final bool highlighted;

  /// chevron の見かけ + hit 領域の幅（px）。アイコン 16 + 余白で 20。
  static const double _chevronSlotWidth = 20;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return Stack(
      children: [
        Container(
          color: highlighted ? tokens.surfaceHi : null,
          height: PolarisTokens.space7,
          padding: EdgeInsets.fromLTRB(baseIndent, 0, PolarisTokens.space4, 0),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onToggleChevron,
                child: SizedBox(
                  width: _chevronSlotWidth,
                  height: PolarisTokens.space7,
                  child: Center(
                    child: Icon(
                      isExpanded ? Icons.expand_more : Icons.chevron_right,
                      size: PolarisIconSize.small,
                      color: tokens.textDim,
                    ),
                  ),
                ),
              ),
              icon,
              const SizedBox(width: PolarisTokens.space2),
              Expanded(
                child: Text(
                  label,
                  style: tokens.body.copyWith(
                    color: highlighted ? tokens.accent : tokens.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (highlighted)
          Positioned(
            left: 0,
            top: 4,
            bottom: 4,
            child: Container(width: 2, color: tokens.accent),
          ),
      ],
    );
  }
}

/// お気に入り配下のサブディレクトリツリー 1 ノード（再帰）。
///
/// chevron で展開すると配下のサブディレクトリをさらに [_FavoriteTreeChild]
/// として並べる。ラベルクリックで [navigateInFocusedExplorer] を呼んで
/// フォーカス中エクスプローラを当該パスへ遷移させる。
///
/// 内部 DnD（お気に入りグループ移動）や rename / remove メニューは持たない:
/// これは「実 filesystem のパス参照」で、お気に入りそのものではないため。
class _FavoriteTreeChild extends HookConsumerWidget {
  const _FavoriteTreeChild({
    required this.path,
    required this.name,
    required this.depth,
    required this.currentPath,
    required this.expandedTreePaths,
    required this.onToggleTreePath,
  });

  final String path;
  final String name;

  /// お気に入り根を 0 として、何階層下か。インデント幅の係数になる。
  final int depth;

  final String? currentPath;
  final Set<String> expandedTreePaths;
  final void Function(String) onToggleTreePath;

  /// 1 階層ごとに増やすインデント幅（px）。サイドバー幅が狭いので 12 で抑える。
  static const double _perLevelIndent = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovering = useState(false);
    final tokens = PolarisTokens.of(context);
    final isCurrent = path == currentPath;
    final highlighted = isHovering.value || isCurrent;
    final isExpanded = expandedTreePaths.contains(path);
    // depth=1 はお気に入り直下。お気に入り行の baseIndent（16）と chevron
    // 幅（20）= 36 を起点に、さらに depth ぶんインデントする。
    final baseIndent = 16 + (depth * _perLevelIndent);
    final row = MouseRegion(
      onEnter: (_) => isHovering.value = true,
      onExit: (_) => isHovering.value = false,
      child: InkWell(
        onTap: () => navigateInFocusedExplorer(ref, path),
        child: _FavoriteTreeRow(
          baseIndent: baseIndent,
          isExpanded: isExpanded,
          onToggleChevron: () => onToggleTreePath(path),
          icon: PolarisTypeIcon(
            isDir: true,
            color: highlighted ? tokens.accent : tokens.textDim,
          ),
          label: name,
          highlighted: highlighted,
        ),
      ),
    );
    if (!isExpanded) {
      return row;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row,
        for (final child in ref.watch(favoriteTreeChildrenProvider(path)))
          _FavoriteTreeChild(
            path: child.path,
            name: child.name,
            depth: depth + 1,
            currentPath: currentPath,
            expandedTreePaths: expandedTreePaths,
            onToggleTreePath: onToggleTreePath,
          ),
      ],
    );
  }
}

/// お気に入りフォルダ 1 件分のヘッダタイル（ADR-0029）。
///
/// ランチャーフォルダの `_LauncherFolderTile` と同じ構造。お気に入りタイル
/// を drop で受け入れて配下に取り込む。
class _FavoriteFolderTile extends ConsumerWidget {
  const _FavoriteFolderTile({
    required this.folder,
    required this.expanded,
    required this.onToggle,
  });

  final ExplorerFavoriteFolder folder;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<ExplorerFavorite>(
      onWillAcceptWithDetails: (details) => details.data.folderId != folder.id,
      onAcceptWithDetails: (details) async {
        await ref
            .read(explorerSettingsProvider.notifier)
            .moveFavoriteToFolder(details.data.id, folder.id);
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
              height: PolarisTokens.space7,
              padding: const EdgeInsets.symmetric(
                horizontal: PolarisTokens.space3,
              ),
              child: Row(
                children: [
                  Icon(
                    expanded ? Icons.arrow_drop_down : Icons.arrow_right,
                    size: PolarisIconSize.standard,
                    color: colors.onSurfaceVariant,
                  ),
                  Icon(
                    Icons.folder_outlined,
                    size: PolarisIconSize.standard,
                    color: colors.secondary,
                  ),
                  const SizedBox(width: PolarisTokens.space2),
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
    final l10n = AppLocalizations.of(context);
    final action = await showMenu<_FavoriteFolderAction>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        polarisPopupMenuItem<_FavoriteFolderAction>(
          context,
          value: _FavoriteFolderAction.rename,
          icon: Icons.edit_outlined,
          label: l10n.explorerRenameTitle,
        ),
        polarisPopupMenuItem<_FavoriteFolderAction>(
          context,
          value: _FavoriteFolderAction.delete,
          icon: Icons.delete_outline,
          label: l10n.folderDeleteWithContentsMenuItem,
        ),
      ],
    );
    if (action == null || !context.mounted) {
      return;
    }
    final notifier = ref.read(explorerSettingsProvider.notifier);
    switch (action) {
      case _FavoriteFolderAction.rename:
        final newName = await promptName(
          context,
          title: l10n.launcherFolderNameTitle,
          initialValue: folder.name,
        );
        if (newName == null || newName.trim().isEmpty) {
          return;
        }
        await notifier.renameFavoriteFolder(folder.id, newName.trim());
      case _FavoriteFolderAction.delete:
        if (!context.mounted) {
          return;
        }
        final confirmed = await showPolarisConfirm(
          context,
          title: l10n.folderDeleteConfirmTitle,
          message: l10n.folderDeleteConfirmMessage(folder.name),
          confirmLabel: l10n.buttonDelete,
          cancelLabel: l10n.buttonCancel,
          destructive: true,
        );
        if (confirmed) {
          await notifier.deleteFavoriteFolder(folder.id);
        }
    }
  }
}

enum _FavoriteFolderAction { rename, delete }

/// お気に入りフォルダ群と未分類お気に入りの間に挟む「未分類」mini-header
/// 兼 drop zone（ADR-0029）。
class _FavoriteRootDropZone extends ConsumerWidget {
  const _FavoriteRootDropZone();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PolarisTokens.of(context);
    return DragTarget<ExplorerFavorite>(
      onWillAcceptWithDetails: (details) => details.data.folderId != null,
      onAcceptWithDetails: (details) async {
        await ref
            .read(explorerSettingsProvider.notifier)
            .moveFavoriteToFolder(details.data.id, null);
      },
      builder: (context, candidate, rejected) {
        final hover = candidate.isNotEmpty;
        return Container(
          color: hover ? tokens.surfaceHi : null,
          padding: const EdgeInsets.fromLTRB(
            PolarisTokens.space4,
            PolarisTokens.space2,
            PolarisTokens.space4,
            PolarisTokens.space1,
          ),
          child: const _SectionLabelText('Unclassified'),
        );
      },
    );
  }
}

// ----- ランチャーセクション -----

class _LauncherHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onSecondaryTapDown: (details) =>
          _showContextMenu(context, ref, details.globalPosition),
      child: _SidebarSectionHeader(
        'Launcher',
        action: _SectionHeaderAddButton(
          tooltip: l10n.explorerLaunchersAddTooltip,
          onPressed: (buttonContext) => _showContextMenu(
            context,
            ref,
            _menuAnchorBelowButton(buttonContext),
          ),
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
    final l10n = AppLocalizations.of(context);
    final action = await showMenu<_LauncherHeaderAction>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        polarisPopupMenuItem<_LauncherHeaderAction>(
          context,
          value: _LauncherHeaderAction.newEntry,
          label: l10n.explorerNewLauncherEntry,
        ),
        polarisPopupMenuItem<_LauncherHeaderAction>(
          context,
          value: _LauncherHeaderAction.newFolder,
          label: l10n.explorerNewLauncherFolder,
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
          title: l10n.launcherFolderNameTitle,
          hintText: l10n.explorerLauncherFolderHint,
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
      padding: const EdgeInsets.fromLTRB(
        PolarisTokens.space4,
        PolarisTokens.space1,
        PolarisTokens.space4,
        PolarisTokens.space1,
      ),
      child: Text(
        AppLocalizations.of(context).explorerLaunchersRegisterHint,
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
      child: Container(
        height: PolarisTokens.space7,
        padding: const EdgeInsets.symmetric(horizontal: PolarisTokens.space4),
        child: Row(
          children: [
            Icon(
              Icons.tune,
              size: PolarisIconSize.standard,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: PolarisTokens.space2),
            Expanded(
              child: Text(
                AppLocalizations.of(context).explorerManageLaunchers,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
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
    final tokens = PolarisTokens.of(context);
    return LongPressDraggable<LauncherEntry>(
      data: entry,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(tokens.radius),
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
      child: Container(
        height: PolarisTokens.space7,
        padding: EdgeInsets.fromLTRB(
          indented ? PolarisTokens.space8 : PolarisTokens.space4,
          0,
          PolarisTokens.space4,
          0,
        ),
        child: Row(
          children: [
            Icon(
              Icons.bolt,
              size: PolarisIconSize.standard,
              color: colors.primary,
            ),
            const SizedBox(width: PolarisTokens.space2),
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
              height: PolarisTokens.space7,
              padding: const EdgeInsets.symmetric(
                horizontal: PolarisTokens.space3,
              ),
              child: Row(
                children: [
                  Icon(
                    expanded ? Icons.arrow_drop_down : Icons.arrow_right,
                    size: PolarisIconSize.standard,
                    color: colors.onSurfaceVariant,
                  ),
                  Icon(
                    Icons.folder_outlined,
                    size: PolarisIconSize.standard,
                    color: colors.secondary,
                  ),
                  const SizedBox(width: PolarisTokens.space2),
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
    final l10n = AppLocalizations.of(context);
    final action = await showMenu<_LauncherFolderAction>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        polarisPopupMenuItem<_LauncherFolderAction>(
          context,
          value: _LauncherFolderAction.rename,
          icon: Icons.edit_outlined,
          label: l10n.explorerRenameTitle,
        ),
        polarisPopupMenuItem<_LauncherFolderAction>(
          context,
          value: _LauncherFolderAction.delete,
          icon: Icons.delete_outline,
          label: l10n.folderDeleteWithContentsMenuItem,
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
          title: l10n.launcherFolderNameTitle,
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
        final confirmed = await showPolarisConfirm(
          context,
          title: l10n.folderDeleteConfirmTitle,
          message: l10n.folderDeleteConfirmMessage(folder.name),
          confirmLabel: l10n.buttonDelete,
          cancelLabel: l10n.buttonCancel,
          destructive: true,
        );
        if (confirmed) {
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
    final tokens = PolarisTokens.of(context);
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
          color: hover ? tokens.surfaceHi : null,
          padding: const EdgeInsets.fromLTRB(
            PolarisTokens.space4,
            PolarisTokens.space2,
            PolarisTokens.space4,
            PolarisTokens.space1,
          ),
          child: const _SectionLabelText('Unclassified'),
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
      child: Container(
        height: PolarisTokens.space7,
        padding: const EdgeInsets.symmetric(horizontal: PolarisTokens.space4),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: sessionStateAvatar(PolarisTokens.of(context), state),
            ),
            const SizedBox(width: PolarisTokens.space2),
            Expanded(
              child: Text(
                adhocArgs.displayName,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: PolarisIconSize.standard),
              tooltip: AppLocalizations.of(
                context,
              ).explorerSessionDiscardTooltip,
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
      padding: const EdgeInsets.fromLTRB(
        PolarisTokens.space4,
        PolarisTokens.space1,
        PolarisTokens.space4,
        PolarisTokens.space1,
      ),
      child: Text(
        AppLocalizations.of(context).explorerRunningEmpty,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
