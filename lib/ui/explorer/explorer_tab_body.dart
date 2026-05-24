import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/core/health/claude_health_check.dart';
import 'package:roola/core/skill/skill_scanner.dart';
import 'package:roola/core/system/file_opener.dart';
import 'package:roola/data/repo_explorer/explorer_node.dart';
import 'package:roola/data/repo_explorer/explorer_settings.dart';
import 'package:roola/data/repo_explorer/explorer_settings_repository_impl.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_display_panel.dart';
import 'package:roola/ui/explorer/dnd_ready_provider.dart';
import 'package:roola/ui/explorer/explorer_item_selection.dart';
import 'package:roola/ui/explorer/explorer_node_tile.dart';
import 'package:roola/ui/explorer/explorer_path_bar.dart';
import 'package:roola/ui/explorer/explorer_view_model.dart';
import 'package:roola/ui/explorer/file_preview/file_preview_layout_provider.dart';
import 'package:roola/ui/explorer/file_preview/file_preview_pane.dart';
import 'package:roola/ui/explorer/file_preview/file_preview_view_model.dart';
import 'package:roola/ui/git/git_view_model.dart';
import 'package:roola/ui/workspace/current_tab_id_provider.dart';
import 'package:roola/ui/workspace/focused_tab_provider.dart';
import 'package:roola/ui/workspace/window_activation_provider.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

/// エクスプローラタブ 1 つ分の body（ADR-0026 / ADR-0046）。
///
/// 上端にペインヘッダ（戻る / 進む / パスバー）、その下にディレクトリ一覧と
/// 読み取り専用ファイルプレビューを横並びで表示する。プレビューパネルは
/// pane header のトグルで表示 / 非表示を切替えられる。`currentTabIdProvider`
/// から自タブ id を取得し、per-tab の `explorerViewModelProvider(tabId)`
/// を購読する（ADR-0027）。
class ExplorerTabBody extends ConsumerWidget {
  const ExplorerTabBody({super.key});

  /// プレビュー表示時の最小幅 — 左ペイン（ディレクトリ一覧）と右ペイン
  /// （プレビュー）。これより狭くなるレイアウトでは split 自体を諦めて
  /// 一覧のみを描画する（ADR-0046 / Decision 2）。
  static const double _listingMinWidth = 240;
  static const double _previewMinWidth = 280;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabId = ref.watch(currentTabIdProvider);
    final state = ref.watch(explorerViewModelProvider(tabId));
    final layout = ref.watch(filePreviewLayoutProvider(tabId));
    final tokens = PolarisTokens.of(context);

    // 主選択の内容に応じてプレビューパネルを自動開閉する（ADR-0050）。
    // text / image / pdf を選択したら開き、ディレクトリ / バイナリ /
    // 大きすぎ / 失敗を選択したら閉じる。ローディング中は据え置き
    // （直前の状態を保ってちらつきを防ぐ）。`ref.listen` は内容 provider を
    // パネル非表示時も生かし続けるため、閉じた状態からの自動オープンが効く。
    // ヘッダの手動トグルは一時的な上書きで、次の選択変更でこの自動判定に
    // 再び従う。
    ref.listen(filePreviewViewModelProvider(tabId), (_, next) {
      next.when(
        data: (content) => ref
            .read(filePreviewLayoutProvider(tabId).notifier)
            .setVisible(visible: content?.isPreviewable ?? false),
        loading: () {},
        error: (_, _) => ref
            .read(filePreviewLayoutProvider(tabId).notifier)
            .setVisible(visible: false),
      );
    });
    // 筐体（bg）の中に計器ディスプレイパネル（well）を 1 枚嵌め込む。
    // パネル内は [コントロール行][1px 継ぎ目][一覧（+ プレビュー）] を地続き
    // に並べ、1 個の計器として見せる（ADR-0038 D3）。プレビュー有効時は
    // 一覧の右に 1px の縦線で区切ってプレビューパネルを並べる（ADR-0046）。
    return ColoredBox(
      color: tokens.bg,
      child: PolarisDisplayPanel(
        child: Column(
          children: [
            _PaneHeader(tabId: tabId, currentPath: state.currentPath),
            Container(height: 1, color: tokens.line),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final listing = _DirectoryListing(tabId: tabId, state: state);
                  if (!layout.visible) return listing;
                  // splitter（中央 1px の縦線 + ドラッグ用 6px ヒット領域）を
                  // 1 本挟む。タブ body が狭すぎるときは split を諦めて
                  // 一覧のみ表示する。splitter の実幅は `_PreviewSplitter`
                  // 側の Container(width: 6) に一致させる必要がある（不一致
                  // だと listing + splitter + preview の合計が usable と
                  // ズレて Row が overflow する）。
                  final total = constraints.maxWidth;
                  const splitterWidth = _PreviewSplitter.hitWidth;
                  final usable = total - splitterWidth;
                  if (usable < _listingMinWidth + _previewMinWidth) {
                    return listing;
                  }
                  var listingWidth = usable * layout.ratio;
                  if (listingWidth < _listingMinWidth) {
                    listingWidth = _listingMinWidth;
                  }
                  if (usable - listingWidth < _previewMinWidth) {
                    listingWidth = usable - _previewMinWidth;
                  }
                  final previewWidth = usable - listingWidth;
                  return Row(
                    children: [
                      SizedBox(width: listingWidth, child: listing),
                      _PreviewSplitter(tabId: tabId, usableWidth: usable),
                      SizedBox(
                        width: previewWidth,
                        child: FilePreviewPane(tabId: tabId),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 一覧とプレビューの間を区切る 1px の縦線 + ドラッグハンドル
/// （ADR-0046 / Decision 2）。
///
/// 視覚は 1px だが、当たり判定を 6px に広げてドラッグしやすくする。マウス
/// カーソルは左右リサイズのものに切り替える。Drag で `setRatio` を更新する。
class _PreviewSplitter extends ConsumerWidget {
  const _PreviewSplitter({required this.tabId, required this.usableWidth});

  /// splitter の総幅（中央 1px 線 + 左右の透明ヒット領域）。親の Row 側で
  /// listing / preview のサイズ計算に用いるため public な定数として公開する。
  static const double hitWidth = 6;

  final String tabId;
  final double usableWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PolarisTokens.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) {
          if (usableWidth <= 0) return;
          final currentRatio = ref.read(filePreviewLayoutProvider(tabId)).ratio;
          final deltaRatio = details.delta.dx / usableWidth;
          ref
              .read(filePreviewLayoutProvider(tabId).notifier)
              .setRatio(currentRatio + deltaRatio);
        },
        child: Container(
          width: hitWidth,
          alignment: Alignment.center,
          child: Container(width: 1, color: tokens.line),
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
          // パスバー前後の余白は space1（4px）まで詰める。3 ペイン × タブの
          // 狭い構成では Explorer ペインが横半分しか無く、余白を空けると
          // overflow しやすいため（ADR-0046 で 5px overflow が観測された）。
          const SizedBox(width: PolarisTokens.space1),
          Expanded(
            child: ExplorerPathBar(tabId: tabId, currentPath: currentPath),
          ),
          const SizedBox(width: PolarisTokens.space1),
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

    // キーボード操作（十字キー / Enter）を受けるためのフォーカスと、選択行を
    // ビューポート内へ送るためのスクロール制御（ADR-0051）。一覧内の
    // ポインタ押下でこのフォーカスを獲得し、以降は矢印キーで選択を動かせる。
    final focusNode = useFocusNode();
    final scrollController = useScrollController();

    // ウィンドウ再アクティブ化時、このエクスプローラが直前にフォーカスされて
    // いたタブなら一覧フォーカスを戻す（ADR-0055）。既定では top-left ペインへ
    // 誤って移るのを上書きし、十字キー操作（ADR-0051）の対象を直前の一覧に
    // 戻す。
    ref.listen(windowActivationProvider, (_, _) {
      if (ref.read(focusedTabProvider).focusedTabId == tabId) {
        focusNode.requestFocus();
        // FlutterView が first responder を取り戻した直後の Flutter 側
        // フォーカス処理が即時の requestFocus を上書きしうるため、フレーム
        // 確定後にもう一度要求して確実に勝たせる。
        WidgetsBinding.instance.addPostFrameCallback((_) {
          focusNode.requestFocus();
        });
      }
    });
    // 行高は密度設定と Skill サブタイトル有無で変わる（ADR-0024 / D6）。
    // 選択行のスクロール位置を正確に求めるため、ここでも同じ条件で算出する。
    final density =
        ref.watch(explorerSettingsProvider).value?.listDensity ??
        ExplorerListDensity.comfortable;
    final isCompact = density == ExplorerListDensity.compact;
    final claudeAvailable = ref.watch(claudeAvailableProvider);

    // currentPath が変わったら item selection を解除する。
    ref.listen<String>(
      explorerViewModelProvider(tabId).select((s) => s.currentPath),
      (previous, next) {
        if (previous != next) {
          ref.read(explorerItemSelectionProvider(tabId).notifier).clear();
        }
      },
    );

    final keyHandler = _ExplorerKeyboardNavigator(
      ref: ref,
      tabId: tabId,
      children: state.children,
      scrollController: scrollController,
      showParentTile: showParentTile,
      isCompact: isCompact,
      claudeAvailable: claudeAvailable,
    );

    final body = CustomScrollView(
      controller: scrollController,
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
    //
    // 一覧を Focus で包み、十字キー / Enter で選択を操作できるようにする
    // （ADR-0051）。Listener はジェスチャーアリーナと独立に pointer down を
    // 受けるため、タイルのタップ選択と両立しつつフォーカスを獲得できる。
    return Listener(
      onPointerDown: (_) => focusNode.requestFocus(),
      child: Focus(
        focusNode: focusNode,
        onKeyEvent: keyHandler.handle,
        child: body,
      ),
    );
  }
}

/// 一覧のキーボード操作（ADR-0051）。十字キーで選択を上下に動かし、Enter /
/// → で開く（ディレクトリは遷移、ファイルは OS デフォルトアプリ）。← で親
/// ディレクトリへ戻る。選択が画面外に出たら最小限スクロールして見せる。
///
/// マウス選択（[ExplorerItemSelection]）と同じ「主選択 1 件」モデルを共有し、
/// 十字キーは常に単一選択を主選択へ移す。複数選択（Shift+矢印）は対象外。
class _ExplorerKeyboardNavigator {
  const _ExplorerKeyboardNavigator({
    required this.ref,
    required this.tabId,
    required this.children,
    required this.scrollController,
    required this.showParentTile,
    required this.isCompact,
    required this.claudeAvailable,
  });

  final WidgetRef ref;
  final String tabId;
  final List<ExplorerNode> children;
  final ScrollController scrollController;
  final bool showParentTile;
  final bool isCompact;
  final bool claudeAvailable;

  KeyEventResult handle(FocusNode node, KeyEvent event) {
    // キーリピート（押しっぱなし）も拾い、長押しで連続スクロールできるように
    // する。離した（Up）イベントは無視。
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveSelection(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveSelection(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.arrowRight) {
      // → はディレクトリへの侵入のみ（ファイルでは何もしない）。Enter は
      // ファイルも開く。
      _activatePrimary(directoryOnly: key == LogicalKeyboardKey.arrowRight);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      ref.read(explorerViewModelProvider(tabId).notifier).goUp();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// 主選択を [delta]（+1 / -1）方向へ動かす。未選択なら端から開始する。
  void _moveSelection(int delta) {
    if (children.isEmpty) {
      return;
    }
    final selection = ref.read(explorerItemSelectionProvider(tabId));
    final current = selection.primary == null
        ? -1
        : children.indexWhere((n) => n.path == selection.primary);
    final next = current < 0
        ? (delta > 0 ? 0 : children.length - 1)
        : (current + delta).clamp(0, children.length - 1);
    ref
        .read(explorerItemSelectionProvider(tabId).notifier)
        .select(children[next].path);
    _ensureVisible(next);
  }

  /// 主選択を開く。ディレクトリは遷移、ファイルは OS デフォルトアプリ。
  void _activatePrimary({required bool directoryOnly}) {
    final primary = ref.read(explorerItemSelectionProvider(tabId)).primary;
    if (primary == null) {
      return;
    }
    final index = children.indexWhere((n) => n.path == primary);
    if (index < 0) {
      return;
    }
    switch (children[index]) {
      case ExplorerDirectoryNode(:final path):
        ref.read(explorerViewModelProvider(tabId).notifier).navigateTo(path);
      case ExplorerFileNode(:final path):
        if (directoryOnly) {
          return;
        }
        unawaited(ref.read(fileOpenerProvider).open(path));
    }
  }

  /// 行 [index] が画面外なら最小限だけスクロールして見せる。行高は密度設定と
  /// Skill サブタイトル有無で可変なため、先頭からの累積高で正確に求める
  /// （[explorerRowHeight] と同じ条件で算出）。
  void _ensureVisible(int index) {
    if (!scrollController.hasClients) {
      return;
    }
    var top = PolarisTokens.space1.toDouble();
    if (showParentTile) {
      top += explorerRowHeight(isCompact);
    }
    for (var i = 0; i < index; i++) {
      top += _rowHeight(children[i]);
    }
    final bottom = top + _rowHeight(children[index]);
    final position = scrollController.position;
    final viewTop = position.pixels;
    final viewBottom = viewTop + position.viewportDimension;
    final double? target;
    if (top < viewTop) {
      target = top;
    } else if (bottom > viewBottom) {
      target = bottom - position.viewportDimension;
    } else {
      target = null;
    }
    if (target != null) {
      scrollController.jumpTo(
        target.clamp(position.minScrollExtent, position.maxScrollExtent),
      );
    }
  }

  double _rowHeight(ExplorerNode node) {
    final hasSkillSubtitle =
        !isCompact &&
        node is ExplorerDirectoryNode &&
        claudeAvailable &&
        node.skillNames.isNotEmpty;
    return explorerRowHeight(isCompact, skillSubtitle: hasSkillSubtitle);
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
    final content = GestureDetector(
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
    );
    // 起動直後は DnD を登録しない（ADR-0049）。
    if (!ref.watch(dndReadyProvider)) {
      return content;
    }
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
      child: content,
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
