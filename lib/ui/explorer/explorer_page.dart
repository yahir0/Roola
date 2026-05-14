import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/router.dart';
import 'package:roola/core/skill/skill_scanner.dart';
import 'package:roola/data/repo_explorer/explorer_node.dart';
import 'package:roola/ui/common/logo_accent_line.dart';
import 'package:roola/ui/common/macos_window_app_bar.dart';
import 'package:roola/ui/explorer/explorer_node_tile.dart';
import 'package:roola/ui/explorer/explorer_path_bar.dart';
import 'package:roola/ui/explorer/explorer_selection.dart';
import 'package:roola/ui/explorer/explorer_sidebar.dart';
import 'package:roola/ui/explorer/explorer_view_model.dart';
import 'package:roola/ui/explorer/launcher_grid.dart';
import 'package:roola/ui/explorer/session_view.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

/// エクスプローラ画面（Phase 2 以降は唯一のメイン画面）。
///
/// レイアウト:
/// ```
/// AppBar (戻る / 進む / ⚡ / 起動時のディレクトリ / ⚙)
/// [path bar — selection が directory のときだけ]
/// ┌─ sidebar ─┬─ body ─────────────────────────┐
/// │           │ directory listing               │
/// │           │   OR                            │
/// │           │ SessionView (PTY terminal)      │
/// └───────────┴─────────────────────────────────┘
/// ```
///
/// `explorerSelectionProvider` を購読し、ディレクトリ / セッションの
/// いずれかをエクスプローラ body に排他的に描画する（ADR-0014）。
/// PTY 自体は keep-alive provider 側で保持されているので、selection 切替
/// で widget が unmount されても出力は失われない。
class ExplorerPage extends HookConsumerWidget {
  const ExplorerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(explorerViewModelProvider);
    final selection = ref.watch(explorerSelectionProvider);
    final isDirectory = selection is ExplorerSelectionDirectory;
    final menuController = useMemoized(MenuController.new);
    return Scaffold(
      appBar: MacosWindowAppBar(
        bottom: const LogoAccentLine(),
        onBack: _onBack(ref, state, selection),
        onForward: _onForward(ref, selection),
        actions: [
          MenuAnchor(
            controller: menuController,
            alignmentOffset: const Offset(0, 8),
            style: const MenuStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.transparent),
              padding: WidgetStatePropertyAll(EdgeInsets.zero),
              elevation: WidgetStatePropertyAll(0),
            ),
            menuChildren: const [LauncherGrid()],
            child: IconButton(
              icon: const Icon(Icons.bolt),
              tooltip: 'ランチャー',
              onPressed: () => menuController.isOpen
                  ? menuController.close()
                  : menuController.open(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.drive_folder_upload),
            tooltip: '起動時のディレクトリを変更',
            onPressed: () => _pickRoot(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '設定',
            onPressed: () => const SettingsRoute().push<void>(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (isDirectory) ExplorerPathBar(currentPath: state.currentPath),
          Expanded(
            child: Row(
              children: [
                ExplorerSidebar(currentPath: state.currentPath),
                Expanded(child: _Body(state: state, selection: selection)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// AppBar 左の戻る矢印が呼ぶコールバック。selection の種別と
  /// `ExplorerViewModel` の history で出し分ける。
  ///
  /// - selection が session: directory ビューに戻す（PTY は破棄しない）
  /// - selection が directory で history を遡れる: goBack
  /// - それ以外: null（ボタン非表示）
  VoidCallback? _onBack(
    WidgetRef ref,
    ExplorerState state,
    ExplorerSelection selection,
  ) {
    if (selection is! ExplorerSelectionDirectory) {
      return () => ref
          .read(explorerSelectionProvider.notifier)
          .selectDirectory(state.currentPath);
    }
    if (!ref.read(explorerViewModelProvider.notifier).canGoBack) {
      return null;
    }
    return () => ref.read(explorerViewModelProvider.notifier).goBack();
  }

  /// AppBar の進むボタンが呼ぶコールバック。
  ///
  /// - selection が directory で forward 履歴がある: goForward
  /// - それ以外（session 表示中 / forward 履歴なし）: null（ボタン非表示）
  ///
  /// session 表示中に forward を出さないのは、戻るは「ビューを directory に
  /// 戻す」と意味付けされているのに対し、進む方向に対応する操作が無いため。
  VoidCallback? _onForward(WidgetRef ref, ExplorerSelection selection) {
    if (selection is! ExplorerSelectionDirectory) {
      return null;
    }
    if (!ref.read(explorerViewModelProvider.notifier).canGoForward) {
      return null;
    }
    return () => ref.read(explorerViewModelProvider.notifier).goForward();
  }

  Future<void> _pickRoot(BuildContext context, WidgetRef ref) async {
    final picked = await FilePicker.getDirectoryPath();
    if (picked != null) {
      await ref.read(explorerViewModelProvider.notifier).changeRoot(picked);
    }
  }
}

/// selection の種別に応じて、ディレクトリ一覧 / セッションビューを描画する。
class _Body extends ConsumerWidget {
  const _Body({required this.state, required this.selection});

  final ExplorerState state;
  final ExplorerSelection selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (selection) {
      ExplorerSelectionDirectory() => _DirectoryListing(state: state),
      ExplorerSelectionEntrySession(:final entryId) => SessionView.fromEntry(
        entryId,
        key: ValueKey('session-entry:$entryId'),
        onClosed: () => ref
            .read(explorerSelectionProvider.notifier)
            .selectDirectory(state.currentPath),
      ),
      ExplorerSelectionAdhocSession(:final args) => SessionView.fromAdhoc(
        args,
        key: ValueKey('session-adhoc:${args.adhocId}'),
        onClosed: () => ref
            .read(explorerSelectionProvider.notifier)
            .selectDirectory(state.currentPath),
      ),
    };
  }
}

/// ディレクトリビュー本体（旧 `_ExplorerBody`）。
class _DirectoryListing extends ConsumerWidget {
  const _DirectoryListing({required this.state});

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
      // 先頭に戻る。
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
/// 加えて、Finder などアプリ外からこの領域へ drop されたファイルは
/// カレントディレクトリ直下に move / copy する。
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
