import 'package:claude_skills_launcher/core/skill/skill_scanner.dart';
import 'package:claude_skills_launcher/data/repo_explorer/explorer_node.dart';
import 'package:claude_skills_launcher/ui/common/macos_window_app_bar.dart';
import 'package:claude_skills_launcher/ui/explorer/explorer_node_tile.dart';
import 'package:claude_skills_launcher/ui/explorer/explorer_path_bar.dart';
import 'package:claude_skills_launcher/ui/explorer/explorer_sidebar.dart';
import 'package:claude_skills_launcher/ui/explorer/explorer_view_model.dart';
import 'package:claude_skills_launcher/ui/shell/app_tab_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// エクスプローラ画面。
///
/// 上から: AppBar / タブバー / 編集可能なパスバー / [左サイドバー + 本体リスト]。
/// 本体は currentPath 直下のディレクトリとファイルを一覧表示する。
/// 戻る矢印はカレントが root と一致する場合のみ非表示。
class ExplorerPage extends ConsumerWidget {
  const ExplorerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(explorerViewModelProvider);
    final isAtRoot = state.currentPath == state.root;
    return Scaffold(
      appBar: MacosWindowAppBar(
        // パス表示はすぐ下の編集可能パスバー（[ExplorerPathBar]）に
        // 移したため、ヘッダは固定のラベルだけにする。
        title: const Text('エクスプローラ'),
        onBack: isAtRoot
            ? null
            : () => ref.read(explorerViewModelProvider.notifier).goUp(),
        actions: [
          IconButton(
            icon: const Icon(Icons.drive_folder_upload),
            tooltip: 'ルートディレクトリを変更',
            onPressed: () => _pickRoot(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          const AppTabBar(),
          ExplorerPathBar(currentPath: state.currentPath),
          Expanded(
            child: Row(
              children: [
                ExplorerSidebar(currentPath: state.currentPath),
                Expanded(child: _ExplorerBody(state: state)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickRoot(BuildContext context, WidgetRef ref) async {
    final picked = await FilePicker.getDirectoryPath();
    if (picked != null) {
      await ref.read(explorerViewModelProvider.notifier).changeRoot(picked);
    }
  }
}

class _ExplorerBody extends ConsumerWidget {
  const _ExplorerBody({required this.state});

  final ExplorerState state;

  /// 末尾余白の高さ。リストが viewport を埋めても、ここに常に
  /// 右クリック可能な空きエリアを残す。
  static const double _bottomBackdropHeight = 160;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEmpty = state.children.isEmpty;
    final showParentTile = state.currentPath != '/';
    return CustomScrollView(
      // currentPath を含む ValueKey を付与することで、ディレクトリ
      // 切替時に CustomScrollView が再生成され、スクロール位置が必ず
      // 先頭に戻る。同じ key のままだと Flutter は既存の Sliver 要素を
      // 再利用してスクロール位置を保持してしまう。
      key: ValueKey('explorer-body:${state.currentPath}'),
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
        // 空のときは viewport を埋めてヒント表示。非空のときは固定高さの
        // 右クリック可能領域を末尾に追加して、リストがどれだけ長くても
        // スクロール下端に余白を確保する。
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
  }
}

/// リスト下部の空き領域 ＋ 何も無いときのプレースホルダ。
///
/// 右クリックでカレントディレクトリを対象とした context menu を開く。
/// Skill 検知はこの時点でだけ走らせる（毎ナビゲートで走らせる必要はない）。
class _CurrentDirBackdrop extends ConsumerWidget {
  const _CurrentDirBackdrop({
    required this.currentPath,
    required this.showEmptyHint,
  });

  final String currentPath;
  final bool showEmptyHint;

  static const _scanner = SkillScanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
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
          // backdrop はカレントディレクトリ自身を指すため、「自身を
          // リネーム / コピー / 削除」は許可しない（親フォルダから
          // 操作してもらう）。プロパティとペーストは backdrop でも
          // 有効。
          showRename: false,
          showCopy: false,
          showDelete: false,
        );
      },
      child: showEmptyHint
          ? const _EmptyPlaceholder()
          : const SizedBox.expand(),
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
