import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/skill/skill_scanner.dart';
import 'package:roola/data/repo_explorer/explorer_node.dart';
import 'package:roola/ui/explorer/explorer_item_selection.dart';
import 'package:roola/ui/explorer/explorer_node_tile.dart';
import 'package:roola/ui/explorer/explorer_path_bar.dart';
import 'package:roola/ui/explorer/explorer_view_model.dart';
import 'package:roola/ui/workspace/current_tab_id_provider.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

/// エクスプローラタブ 1 つ分の body（ADR-0026）。
///
/// 上端にペインヘッダ（戻る / 進む / パスバー）、その下にディレクトリ一覧を
/// 縦に並べる。`currentTabIdProvider` から自タブ id を取得し、per-tab の
/// `explorerViewModelProvider(tabId)` を購読する（ADR-0027）。
class ExplorerTabBody extends ConsumerWidget {
  const ExplorerTabBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabId = ref.watch(currentTabIdProvider);
    final state = ref.watch(explorerViewModelProvider(tabId));
    return Column(
      children: [
        _PaneHeader(tabId: tabId, currentPath: state.currentPath),
        const Divider(height: 1),
        Expanded(
          child: _DirectoryListing(tabId: tabId, state: state),
        ),
      ],
    );
  }
}

/// エクスプローラタブの上端ヘッダ。戻る / 進む / パスバーを横に並べる。
/// 戻る / 進むはウィンドウ AppBar からこのタブ単位へ移設したもの（ADR-0026）。
class _PaneHeader extends ConsumerWidget {
  const _PaneHeader({required this.tabId, required this.currentPath});

  final String tabId;
  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(explorerViewModelProvider(tabId).notifier);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
            tooltip: '戻る',
            visualDensity: VisualDensity.compact,
            onPressed: notifier.canGoBack ? notifier.goBack : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            tooltip: '進む',
            visualDensity: VisualDensity.compact,
            onPressed: notifier.canGoForward ? notifier.goForward : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_upward_rounded, size: 16),
            tooltip: '上の階層へ',
            visualDensity: VisualDensity.compact,
            onPressed: notifier.goUp,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: ExplorerPathBar(tabId: tabId, currentPath: currentPath),
          ),
        ],
      ),
    );
  }
}

/// ディレクトリビュー本体（旧 `explorer_page.dart` の `_DirectoryListing`）。
///
/// ADR-0021 の操作モデル: ノードへのシングルクリックは選択、ダブルクリック
/// で遷移/オープン。選択中アイテムがあるとき `C` を 500ms 以内に 2 回押すと、
/// 選択パスがクリップボードにコピーされる。
class _DirectoryListing extends HookConsumerWidget {
  const _DirectoryListing({required this.tabId, required this.state});

  final String tabId;
  final ExplorerState state;

  /// 末尾余白の高さ。リストが viewport を埋めても、ここに常に
  /// 右クリック可能な空きエリアを残す。
  static const double _bottomBackdropHeight = 160;

  /// CC 連打が同一シーケンスとみなされる猶予時間。
  static const Duration _ccGap = Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEmpty = state.children.isEmpty;
    final showParentTile = state.currentPath != '/';

    // currentPath が変わったら item selection を解除する。
    ref.listen<String>(
      explorerViewModelProvider(tabId).select((s) => s.currentPath),
      (previous, next) {
        if (previous != next) {
          ref.read(explorerItemSelectionProvider(tabId).notifier).clear();
        }
      },
    );

    final lastCAt = useRef<DateTime?>(null);
    final focusNode = useFocusNode();

    void handleC() {
      final selectedPath = ref.read(explorerItemSelectionProvider(tabId));
      if (selectedPath == null) {
        lastCAt.value = null;
        return;
      }
      final now = DateTime.now();
      final prev = lastCAt.value;
      if (prev != null && now.difference(prev) <= _ccGap) {
        Clipboard.setData(ClipboardData(text: selectedPath));
        lastCAt.value = null;
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.removeCurrentSnackBar();
        messenger?.showSnackBar(
          SnackBar(
            content: Text('パスをコピーしました: $selectedPath'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        lastCAt.value = now;
      }
    }

    final body = CustomScrollView(
      // currentPath を含む ValueKey で、ディレクトリ切替時に再生成して
      // スクロール位置を先頭に戻す。
      key: ValueKey('explorer-body:$tabId:${state.currentPath}'),
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 8)),
        if (showParentTile) ...[
          SliverToBoxAdapter(
            child: ExplorerParentDropTile(currentPath: state.currentPath),
          ),
          const SliverToBoxAdapter(child: Divider(height: 1)),
        ],
        if (!isEmpty)
          SliverList.separated(
            itemCount: state.children.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => ExplorerNodeTile(node: state.children[i]),
          ),
        if (isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _CurrentDirBackdrop(
              currentPath: state.currentPath,
              showEmptyHint: true,
            ),
          )
        else
          SliverToBoxAdapter(
            child: SizedBox(
              height: _bottomBackdropHeight,
              child: _CurrentDirBackdrop(
                currentPath: state.currentPath,
                showEmptyHint: false,
              ),
            ),
          ),
      ],
    );

    return Focus(
      focusNode: focusNode,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) {
          return KeyEventResult.ignored;
        }
        if (event.logicalKey == LogicalKeyboardKey.keyC) {
          handleC();
          return KeyEventResult.handled;
        }
        lastCAt.value = null;
        return KeyEventResult.ignored;
      },
      child: body,
    );
  }
}

/// リスト下部の空き領域 ＋ 何も無いときのプレースホルダ。
class _CurrentDirBackdrop extends HookConsumerWidget {
  const _CurrentDirBackdrop({
    required this.currentPath,
    required this.showEmptyHint,
  });

  final String currentPath;
  final bool showEmptyHint;

  static const _scanner = SkillScanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovering = useState(false);
    final colors = Theme.of(context).colorScheme;
    return DropRegion(
      formats: const [Formats.fileUri],
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver: (event) => decideDropOperation(event.session, currentPath),
      onDropEnter: (_) => isHovering.value = true,
      onDropLeave: (_) => isHovering.value = false,
      onPerformDrop: (event) async {
        isHovering.value = false;
        await performFileDrop(context, ref, event, currentPath);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onSecondaryTapDown: (details) {
          final node = ExplorerDirectoryNode(
            path: currentPath,
            name: _basenameOf(currentPath),
            skillNames: _scanner.scan(currentPath),
          );
          showExplorerContextMenu(
            context,
            ref,
            node,
            details.globalPosition,
            showRename: false,
            showCopy: false,
            showDelete: false,
          );
        },
        child: Container(
          color: isHovering.value
              ? colors.primary.withValues(alpha: 0.08)
              : null,
          child: showEmptyHint
              ? const _EmptyPlaceholder()
              : const SizedBox.expand(),
        ),
      ),
    );
  }

  static String _basenameOf(String path) {
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    return segments.isEmpty ? path : segments.last;
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 64),
          SizedBox(height: 12),
          Text('表示できる項目がありません'),
        ],
      ),
    );
  }
}
