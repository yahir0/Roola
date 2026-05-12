import 'package:claude_skills_launcher/core/skill/skill_scanner.dart';
import 'package:claude_skills_launcher/data/repo_explorer/explorer_node.dart';
import 'package:claude_skills_launcher/ui/common/macos_window_app_bar.dart';
import 'package:claude_skills_launcher/ui/explorer/explorer_node_tile.dart';
import 'package:claude_skills_launcher/ui/explorer/explorer_view_model.dart';
import 'package:claude_skills_launcher/ui/shell/app_tab_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// エクスプローラ画面。ルート配下のディレクトリを直下リストで表示し、
/// Skill 検知ありフォルダは右側にバッジ、右クリックで起動 / 登録メニュー。
///
/// AppBar 左上の戻る矢印は、ルートより下にいる時は「親ディレクトリへ」、
/// ルートにいる時は非表示。タブ root としてシェル内に居るので
/// `Navigator.canPop` は false のままで OK（ホームに戻る場合はタブを
/// 切り替える）。
class ExplorerPage extends ConsumerWidget {
  const ExplorerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(explorerViewModelProvider);
    final isAtRoot = state.currentPath == state.root;
    return Scaffold(
      appBar: MacosWindowAppBar(
        title: Text(_collapsePath(state.currentPath, state.root)),
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
          Expanded(child: _ExplorerBody(state: state)),
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

  /// ルートからの相対表記でパスを短縮表示する。`<root>/sub` → `~/sub`。
  String _collapsePath(String currentPath, String root) {
    if (currentPath == root) {
      return root;
    }
    if (currentPath.startsWith('$root/')) {
      return '~${currentPath.substring(root.length)}';
    }
    return currentPath;
  }
}

class _ExplorerBody extends ConsumerWidget {
  const _ExplorerBody({required this.state});

  final ExplorerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 8)),
        if (state.children.isNotEmpty)
          SliverList.separated(
            itemCount: state.children.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => ExplorerNodeTile(node: state.children[i]),
          ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: _CurrentDirBackdrop(
            currentPath: state.currentPath,
            showEmptyHint: state.children.isEmpty,
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
        showExplorerContextMenu(context, ref, node, details.globalPosition);
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
          Text('表示できる子ディレクトリがありません'),
        ],
      ),
    );
  }
}
