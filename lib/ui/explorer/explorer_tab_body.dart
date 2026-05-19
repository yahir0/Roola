import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/core/skill/skill_scanner.dart';
import 'package:roola/data/repo_explorer/explorer_node.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_display_panel.dart';
import 'package:roola/ui/explorer/explorer_item_selection.dart';
import 'package:roola/ui/explorer/explorer_node_tile.dart';
import 'package:roola/ui/explorer/explorer_path_bar.dart';
import 'package:roola/ui/explorer/explorer_view_model.dart';
import 'package:roola/ui/git/git_view_model.dart';
import 'package:roola/ui/workspace/current_tab_id_provider.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
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
    final tokens = PolarisTokens.of(context);
    // 筐体（bg）の中に計器ディスプレイパネル（well）を 1 枚嵌め込む。
    // パネル内は [コントロール行][1px 継ぎ目][一覧] を地続きに並べ、ヘッダと
    // 一覧を「1 個の計器」として見せる（ADR-0038 D3）。
    return ColoredBox(
      color: tokens.bg,
      child: PolarisDisplayPanel(
        child: Column(
          children: [
            _PaneHeader(tabId: tabId, currentPath: state.currentPath),
            Container(height: 1, color: tokens.line),
            Expanded(
              child: _DirectoryListing(tabId: tabId, state: state),
            ),
          ],
        ),
      ),
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
    final l10n = AppLocalizations.of(context);
    // 計器パネル内側の最上段＝コントロール行。4px グリッドに乗せる。
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PolarisTokens.space2,
        PolarisTokens.space1,
        PolarisTokens.space2,
        PolarisTokens.space1,
      ),
      child: Row(
        children: [
          _NavButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: l10n.navBack,
            onPressed: notifier.canGoBack ? notifier.goBack : null,
          ),
          _NavButton(
            icon: Icons.arrow_forward_ios_rounded,
            tooltip: l10n.navForward,
            onPressed: notifier.canGoForward ? notifier.goForward : null,
          ),
          _NavButton(
            icon: Icons.arrow_upward_rounded,
            tooltip: l10n.navUp,
            onPressed: notifier.goUp,
          ),
          const SizedBox(width: PolarisTokens.space2),
          Expanded(
            child: ExplorerPathBar(tabId: tabId, currentPath: currentPath),
          ),
          const SizedBox(width: PolarisTokens.space2),
          _OpenGitButton(currentPath: currentPath),
        ],
      ),
    );
  }
}

/// コントロール行のナビゲーションボタン。28px 角の `IconButton`。
/// 戻る / 進む / 上の主要操作のため、視認とクリックに十分な大きさを確保する
/// （機能優先・視認性を犠牲にしない / ADR-0038）。
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: PolarisIconSize.standard),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
      onPressed: onPressed,
    );
  }
}

/// カレントパスが Git 管理下のとき Git ビューを開くツールバーボタン
/// （ADR-0030 / tasks 7.4）。Git 管理下でなければ無効表示。
class _OpenGitButton extends ConsumerWidget {
  const _OpenGitButton({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 結果は gitRepositoryRootProvider が family(パス)単位でキャッシュする。
    final repoRoot = ref.watch(gitRepositoryRootProvider(currentPath)).value;
    final l10n = AppLocalizations.of(context);
    return IconButton(
      icon: const Icon(
        Icons.account_tree_outlined,
        size: PolarisIconSize.standard,
      ),
      tooltip: repoRoot != null
          ? l10n.explorerOpenGitViewTooltip
          : l10n.explorerNotGitRepository,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
      onPressed: repoRoot == null
          ? null
          : () => ref.read(workspaceProvider.notifier).openGitTab(repoRoot),
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

    final body = CustomScrollView(
      // currentPath を含む ValueKey で、ディレクトリ切替時に再生成して
      // スクロール位置を先頭に戻す。
      key: ValueKey('explorer-body:$tabId:${state.currentPath}'),
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.only(top: PolarisTokens.space1),
        ),
        if (showParentTile)
          SliverToBoxAdapter(
            child: ExplorerParentDropTile(currentPath: state.currentPath),
          ),
        // 計器ディスプレイの走査線のように行を密に並べる。仕切り線は引かず
        // ホバー / 選択の塗りで行を分ける（ADR-0038 D3）。
        if (!isEmpty)
          SliverList.builder(
            itemCount: state.children.length,
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

    // パスのコピーは `copyPath` コマンド（メニューバー / 設定でカスタマイズ
    // 可能）に統合した（ADR-0033）。旧 C C 連打検出はここで廃止。
    return body;
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
    final tokens = PolarisTokens.of(context);
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
          color: isHovering.value ? tokens.surface : null,
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
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_off_outlined, size: PolarisIconSize.hero),
          const SizedBox(height: PolarisTokens.space3),
          Text(l10n.explorerNoItems),
        ],
      ),
    );
  }
}
