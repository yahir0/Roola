import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/router.dart';
import 'package:roola/core/health/claude_health_check.dart';
import 'package:roola/core/system/explorer_file_ops.dart';
import 'package:roola/core/system/file_opener.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/repo_explorer/explorer_node.dart';
import 'package:roola/data/repo_explorer/explorer_settings.dart';
import 'package:roola/data/repo_explorer/explorer_settings_repository_impl.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/ui/common/command_menu_item.dart';
import 'package:roola/ui/explorer/explorer_clipboard_provider.dart';
import 'package:roola/ui/explorer/explorer_commands.dart';
import 'package:roola/ui/explorer/explorer_item_selection.dart';
import 'package:roola/ui/explorer/explorer_properties_dialog.dart';
import 'package:roola/ui/explorer/explorer_view_model.dart';
import 'package:roola/ui/run/adhoc_run_view_model.dart';
import 'package:roola/ui/workspace/current_tab_id_provider.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// ディレクトリに対する右クリックメニューを表示する。
/// タイル本体（[ExplorerNodeTile]）と、リスト下部の空き領域（カレント
/// ディレクトリを対象にする）の両方から呼ばれる。
///
/// `showRename` はカレントディレクトリを対象とする backdrop からの呼び出し
/// では false にする（「自分自身のリネーム」を同画面でやらせない）。
Future<void> showExplorerContextMenu(
  BuildContext context,
  WidgetRef ref,
  ExplorerDirectoryNode node,
  Offset position, {
  bool showRename = true,
  bool showCopy = true,
  bool showDelete = true,
}) async {
  // OS クリップボードの状態は非同期でしか取れないため、showMenu の前に
  // 一度問い合わせて「ペースト」項目の表示可否を確定させる。
  final hasClipboard = await ref.read(osClipboardServiceProvider).hasFile();
  // Claude CLI 未導入時は Claude 起動 / Skill 系メニューを非表示にする
  // （ADR-0022）。判定は cached な claudeHealthProvider を参照するだけで
  // I/O は発生しない。
  final claudeAvailable = ref.read(claudeAvailableProvider);
  if (!context.mounted) {
    return;
  }
  final items = <PopupMenuEntry<ExplorerNodeAction>>[
    if (claudeAvailable)
      commandPopupMenuItem<ExplorerNodeAction>(
        context,
        ref,
        command: CommandId.openClaudeHere,
        value: const _ActionOpenClaude(),
      ),
    commandPopupMenuItem<ExplorerNodeAction>(
      context,
      ref,
      command: CommandId.openTerminalHere,
      value: const _ActionOpenTerminal(),
    ),
    commandPopupMenuItem<ExplorerNodeAction>(
      context,
      ref,
      command: CommandId.revealInFinder,
      value: const _ActionRevealInFinder(),
    ),
    const PopupMenuItem(
      value: _ActionAddToFavorite(),
      child: ListTile(
        leading: Icon(Icons.star_outline),
        title: Text('お気に入りに追加'),
      ),
    ),
    const PopupMenuDivider(),
    commandPopupMenuItem<ExplorerNodeAction>(
      context,
      ref,
      command: CommandId.newFolder,
      value: const _ActionNewFolder(),
    ),
    commandPopupMenuItem<ExplorerNodeAction>(
      context,
      ref,
      command: CommandId.newFile,
      value: const _ActionNewFile(),
    ),
    if (showRename)
      commandPopupMenuItem<ExplorerNodeAction>(
        context,
        ref,
        command: CommandId.renameItem,
        value: const _ActionRename(),
      ),
    const PopupMenuDivider(),
    if (showCopy)
      commandPopupMenuItem<ExplorerNodeAction>(
        context,
        ref,
        command: CommandId.copyItem,
        value: const _ActionCopy(),
      ),
    commandPopupMenuItem<ExplorerNodeAction>(
      context,
      ref,
      command: CommandId.copyPath,
      value: const _ActionCopyPath(),
    ),
    if (hasClipboard)
      commandPopupMenuItem<ExplorerNodeAction>(
        context,
        ref,
        command: CommandId.pasteItem,
        value: const _ActionPaste(),
      ),
    if (showDelete) ...[
      const PopupMenuDivider(),
      commandPopupMenuItem<ExplorerNodeAction>(
        context,
        ref,
        command: CommandId.moveToTrash,
        value: const _ActionMoveToTrash(),
      ),
    ],
    const PopupMenuDivider(),
    commandPopupMenuItem<ExplorerNodeAction>(
      context,
      ref,
      command: CommandId.showProperties,
      value: const _ActionProperties(),
    ),
  ];
  if (claudeAvailable && node.skillNames.isNotEmpty) {
    items.add(const PopupMenuDivider());
    for (final skill in node.skillNames) {
      items.add(
        PopupMenuItem(
          value: _ActionRunSkill(skill),
          child: ListTile(
            leading: const Icon(Icons.play_arrow),
            title: Text('「$skill」を即実行'),
          ),
        ),
      );
    }
    items.add(const PopupMenuDivider());
    for (final skill in node.skillNames) {
      items.add(
        PopupMenuItem(
          value: _ActionRegisterSkill(skill),
          child: ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: Text('「$skill」をランチャーに登録'),
          ),
        ),
      );
    }
  }

  final selected = await showMenu<ExplorerNodeAction>(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx,
      position.dy,
    ),
    items: items,
  );
  if (selected == null || !context.mounted) {
    return;
  }
  await _handleDirectoryAction(context, ref, node, selected);
}

/// ファイル用の右クリックメニュー（開く / OpenWith / Finder 表示 /
/// 名前変更 / コピー / プロパティ）。
Future<void> showFileContextMenu(
  BuildContext context,
  WidgetRef ref,
  ExplorerFileNode node,
  Offset position,
) async {
  final selected = await showMenu<_FileAction>(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx,
      position.dy,
    ),
    items: [
      commandPopupMenuItem<_FileAction>(
        context,
        ref,
        command: CommandId.openItem,
        value: _FileAction.open,
      ),
      const PopupMenuItem(
        value: _FileAction.openWith,
        child: ListTile(
          leading: Icon(Icons.apps),
          title: Text('別のアプリケーションで開く…'),
        ),
      ),
      const PopupMenuItem(
        value: _FileAction.openInVim,
        child: ListTile(
          leading: Icon(Icons.edit_note),
          title: Text('vim で開く'),
        ),
      ),
      commandPopupMenuItem<_FileAction>(
        context,
        ref,
        command: CommandId.revealInFinder,
        value: _FileAction.revealInFinder,
      ),
      const PopupMenuDivider(),
      commandPopupMenuItem<_FileAction>(
        context,
        ref,
        command: CommandId.renameItem,
        value: _FileAction.rename,
      ),
      commandPopupMenuItem<_FileAction>(
        context,
        ref,
        command: CommandId.copyItem,
        value: _FileAction.copy,
      ),
      commandPopupMenuItem<_FileAction>(
        context,
        ref,
        command: CommandId.copyPath,
        value: _FileAction.copyPath,
      ),
      const PopupMenuDivider(),
      commandPopupMenuItem<_FileAction>(
        context,
        ref,
        command: CommandId.moveToTrash,
        value: _FileAction.moveToTrash,
      ),
      const PopupMenuDivider(),
      commandPopupMenuItem<_FileAction>(
        context,
        ref,
        command: CommandId.showProperties,
        value: _FileAction.properties,
      ),
    ],
  );
  if (selected == null || !context.mounted) {
    return;
  }
  switch (selected) {
    case _FileAction.open:
      await ref.read(fileOpenerProvider).open(node.path);
    case _FileAction.openWith:
      await _openWith(context, node.path);
    case _FileAction.openInVim:
      // vim はターミナルアプリのため、新規ターミナルタブを開いて起動する
      // （ADR-0026）。vim 終了時にシェルも閉じる
      // （keepShellAfterExit: false）。
      // タブは操作元のエクスプローラと同じペインに開き、追加と同時に
      // アクティブ化される（addTerminalTab が末尾を activeIndex にする）。
      final adhocId = 'adhoc-${_uuid.v4()}';
      final args = AdhocRunArgs(
        adhocId: adhocId,
        workingDirectory: parentOfPath(node.path),
        displayName: '${node.name} (vim)',
        action: LauncherAction.runCommand(
          command: 'vim ${_shellQuote(node.path)}',
          keepShellAfterExit: false,
        ),
      );
      final slotId = _slotContainingTab(
        ref.read(workspaceProvider),
        ref.read(currentTabIdProvider),
      );
      ref.read(workspaceProvider.notifier).addTerminalTab(slotId, args: args);
    case _FileAction.revealInFinder:
      await ref.read(fileOpenerProvider).revealInFinder(node.path);
    case _FileAction.rename:
      await _renameAndRefresh(context, ref, node.path, node.name);
    case _FileAction.copy:
      await ref.read(osClipboardServiceProvider).writeFile(node.path);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('コピーしました: ${node.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
    case _FileAction.copyPath:
      await _copyPathToClipboard(context, node.path);
    case _FileAction.moveToTrash:
      await _moveToTrash(context, ref, node.path, node.name);
    case _FileAction.properties:
      await showPropertiesDialog(context, node.path);
  }
}

enum _FileAction {
  open,
  openWith,
  openInVim,
  revealInFinder,
  rename,
  copy,
  copyPath,
  moveToTrash,
  properties,
}

Future<void> _handleDirectoryAction(
  BuildContext context,
  WidgetRef ref,
  ExplorerDirectoryNode node,
  ExplorerNodeAction action,
) async {
  switch (action) {
    case _ActionOpenClaude():
      final adhocId = 'adhoc-${_uuid.v4()}';
      // 「Claude Code を開く」は素の `claude` 起動。新モデルでは
      // ClaudeSkillAction が必ず非空の skillName を要求するため、Skill 名
      // 無し起動は RunCommandAction(command: 'claude') で表現する
      // （ADR-0016 / design.md Decision 4）。
      final args = AdhocRunArgs(
        adhocId: adhocId,
        workingDirectory: node.path,
        displayName: '${node.name} (Claude)',
        action: const LauncherAction.runCommand(
          command: 'claude',
          keepShellAfterExit: false,
        ),
      );
      // bottom ペインに新規ターミナルタブとして開く（ADR-0026）。
      ref
          .read(workspaceProvider.notifier)
          .addTerminalTab(PaneSlotId.bottom, args: args);
    case _ActionOpenTerminal():
      final adhocId = 'adhoc-${_uuid.v4()}';
      final args = AdhocRunArgs(
        adhocId: adhocId,
        workingDirectory: node.path,
        displayName: '${node.name} (Terminal)',
        action: const LauncherAction.openHere(),
      );
      ref
          .read(workspaceProvider.notifier)
          .addTerminalTab(PaneSlotId.bottom, args: args);
    case _ActionRevealInFinder():
      await ref.read(fileOpenerProvider).open(node.path);
    case _ActionAddToFavorite():
      await ref
          .read(explorerSettingsProvider.notifier)
          .addFavorite(
            ExplorerFavorite(
              id: 'fav-${_uuid.v4()}',
              path: node.path,
              name: node.name,
            ),
          );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('お気に入りに追加しました: ${node.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
    case _ActionNewFolder():
      await _createNew(context, ref, node.path, isDirectory: true);
    case _ActionNewFile():
      await _createNew(context, ref, node.path, isDirectory: false);
    case _ActionRename():
      await _renameAndRefresh(context, ref, node.path, node.name);
    case _ActionCopy():
      await ref.read(osClipboardServiceProvider).writeFile(node.path);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('コピーしました: ${node.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
    case _ActionCopyPath():
      await _copyPathToClipboard(context, node.path);
    case _ActionPaste():
      await _pasteInto(context, ref, node.path);
    case _ActionMoveToTrash():
      await _moveToTrash(context, ref, node.path, node.name);
    case _ActionProperties():
      await showPropertiesDialog(context, node.path);
    case _ActionRunSkill(:final skillName):
      final adhocId = 'adhoc-${_uuid.v4()}';
      final args = AdhocRunArgs(
        adhocId: adhocId,
        workingDirectory: node.path,
        displayName: '${node.name} / $skillName',
        action: LauncherAction.claudeSkill(skillName: skillName),
      );
      ref
          .read(workspaceProvider.notifier)
          .addTerminalTab(PaneSlotId.bottom, args: args);
    case _ActionRegisterSkill(:final skillName):
      unawaited(
        EntryNewRoute(
          initialRepositoryPath: node.path,
          initialSkillName: skillName,
        ).push<void>(context),
      );
  }
}

/// 新規フォルダ / 新規ファイルを [parentPath] 直下に作成する。
/// 実処理は `explorer_commands.dart` の `runCreateEntry`（ADR-0033）。
Future<void> _createNew(
  BuildContext context,
  WidgetRef ref,
  String parentPath, {
  required bool isDirectory,
}) {
  return runCreateEntry(
    context,
    ref,
    parentPath: parentPath,
    explorerTabId: ref.read(currentTabIdProvider),
    isDirectory: isDirectory,
  );
}

/// [oldPath] を新しい名前にリネームする。実処理は `runRename`。
Future<void> _renameAndRefresh(
  BuildContext context,
  WidgetRef ref,
  String oldPath,
  String oldName,
) {
  return runRename(
    context,
    ref,
    path: oldPath,
    currentName: oldName,
    explorerTabId: ref.read(currentTabIdProvider),
  );
}

/// OS クリップボードのファイル URI を [targetDir] にコピーする。
/// 実処理は `runPaste`。
Future<void> _pasteInto(
  BuildContext context,
  WidgetRef ref,
  String targetDir,
) {
  return runPaste(
    context,
    ref,
    targetDir: targetDir,
    explorerTabId: ref.read(currentTabIdProvider),
  );
}

/// [path] を OS のゴミ箱に移動する。実処理は `runMoveToTrash`。
Future<void> _moveToTrash(
  BuildContext context,
  WidgetRef ref,
  String path,
  String displayName,
) {
  return runMoveToTrash(
    context,
    ref,
    path: path,
    displayName: displayName,
    explorerTabId: ref.read(currentTabIdProvider),
  );
}

/// 絶対パス文字列を OS クリップボードにテキストとして書き込む。
/// 実処理は `runCopyPath`。
Future<void> _copyPathToClipboard(BuildContext context, String path) {
  return runCopyPath(context, path: path);
}

/// [tabId] のタブが属するペインスロットを返す。見つからなければ
/// `PaneSlotId.bottom` にフォールバックする。
/// 右クリック起点のタブ（vim 等）を、操作元のエクスプローラと同じペインに
/// 開くために使う。
PaneSlotId _slotContainingTab(WorkspaceLayout layout, String tabId) {
  for (final slotId in PaneSlotId.values) {
    if (layout.slot(slotId).tabs.any((tab) => tab.id == tabId)) {
      return slotId;
    }
  }
  return PaneSlotId.bottom;
}

/// シェルコマンド文字列に埋め込む引数を安全にクォートする。
/// `RunCommandAction` は `$SHELL -ilc '<command>'` の単一文字列として
/// コマンドを渡すため、スペースや特殊文字を含むパスはそのままだと壊れる。
/// シングルクォートで囲み、内部の `'` は `'\''` でエスケープする。
String _shellQuote(String value) {
  return "'${value.replaceAll("'", r"'\''")}'";
}

/// macOS の `open -a` でファイルを指定アプリで開く。アプリ選択は
/// FilePicker で `/Applications` 配下の `.app` バンドルから選んでもらう。
Future<void> _openWith(BuildContext context, String filePath) async {
  final picked = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['app'],
    initialDirectory: '/Applications',
    dialogTitle: '開くアプリを選択',
  );
  if (picked == null || picked.files.isEmpty) {
    return;
  }
  final appPath = picked.files.single.path;
  if (appPath == null) {
    return;
  }
  final result = await Process.run('open', ['-a', appPath, filePath]);
  if (result.exitCode != 0 && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('開けませんでした: ${result.stderr}')));
  }
}

/// ドラッグ＆ドロップで [sourcePath] を [targetDir] へ「移動」または
/// 「コピー」する。Finder と同等のセマンティクスを実現する:
///
/// - 同一ボリューム & 修飾キー無し: 移動
/// - 異ボリューム: コピー（rename が失敗するため自動でコピーに倒す）
/// - `prefersCopy = true` (⌥ 押下や drop 元のセマンティクス指定): コピー
/// - それ以外: 移動
///
/// 例外時は SnackBar でエラーを通知。完了後は ViewModel を refresh する。
///
/// 注意: 異ボリュームでの「強制移動」（Finder の ⌘+drag に相当する
/// copy + 元削除）は未対応。⌘ 指定で異ボリュームに drag した場合も
/// このヘルパーはコピーになる。
Future<void> moveOrCopyInto(
  BuildContext context,
  WidgetRef ref,
  String sourcePath,
  String targetDir, {
  required bool prefersCopy,
}) async {
  final ops = ref.read(explorerFileOpsProvider);
  final crossVolume = _volumeKey(sourcePath) != _volumeKey(targetDir);
  final shouldCopy = prefersCopy || crossVolume;
  try {
    if (shouldCopy) {
      await ops.copyInto(sourcePath, targetDir);
    } else {
      await ops.moveInto(sourcePath, targetDir);
    }
    ref
        .read(
          explorerViewModelProvider(ref.read(currentTabIdProvider)).notifier,
        )
        .refresh();
  } on FileSystemException catch (e) {
    if (!context.mounted) {
      return;
    }
    final verb = shouldCopy ? 'コピー' : '移動';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$verbに失敗しました: ${e.message}')));
  }
}

/// drag セッションが完了したらエクスプローラを refresh する `dragCompleted`
/// リスナを登録する。
///
/// 主目的はアプリ外（Finder / 他アプリ）へ drag したときに、移動で消えた
/// source ファイルを即座にリスト反映させること。内部 drop でも fire する
/// が、そちらは `performFileDrop` 経由でも refresh されるため二重 refresh
/// になる（実害は軽微なので許容）。
///
/// `dragCompleted.value` は drag 終了時に [DropOperation] が入る。`null` の
/// まま終わった場合はキャンセル扱いなので refresh しない。リスナは一度だけ
/// 発火させて自分自身を外す。
void _refreshOnDragCompleted(WidgetRef ref, DragSession session) {
  final notifier = ref.read(
    explorerViewModelProvider(ref.read(currentTabIdProvider)).notifier,
  );
  void listener() {
    if (session.dragCompleted.value == null) {
      return;
    }
    notifier.refresh();
    session.dragCompleted.removeListener(listener);
  }

  session.dragCompleted.addListener(listener);
}

/// macOS の絶対パスからボリュームを識別するキーを取り出す。
///
/// - 起動ボリューム配下（`/Volumes/` 以外）: `/`
/// - 外部・ネットワーク等のマウント: `/Volumes/<name>`
///
/// 同じキーなら同一ボリュームと判断する。bind mount 等のレアケースまで
/// は扱わない（実用上は `/Volumes/` 配下の判定で十分なため）。
String _volumeKey(String path) {
  const prefix = '/Volumes/';
  if (path.startsWith(prefix)) {
    final next = path.indexOf('/', prefix.length);
    return next == -1 ? path : path.substring(0, next);
  }
  return '/';
}

/// パスから親ディレクトリの絶対パスを計算する。`/` の場合は `/`。
String parentOfPath(String path) {
  final normalized = path.endsWith('/') && path.length > 1
      ? path.substring(0, path.length - 1)
      : path;
  final lastSlash = normalized.lastIndexOf('/');
  if (lastSlash <= 0) {
    return '/';
  }
  return normalized.substring(0, lastSlash);
}

/// リストの先頭に置く「上の階層へ」専用タイル。
///
/// クリックで親ディレクトリに移動。ドラッグ＆ドロップで対象を親に
/// 移動できる。ルート（`/`）にいる時は呼び出し側で非表示にすること。
class ExplorerParentDropTile extends HookConsumerWidget {
  const ExplorerParentDropTile({required this.currentPath, super.key});

  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabId = ref.watch(currentTabIdProvider);
    final parentPath = parentOfPath(currentPath);
    final colors = Theme.of(context).colorScheme;
    final isHovering = useState(false);
    return DropRegion(
      formats: const [Formats.fileUri],
      hitTestBehavior: HitTestBehavior.opaque,
      // 既に親に居る項目を「親に移動」しても no-op なので、視覚フィー
      // ドバックを出さない（disallowSameParent: true）。自身や祖先を
      // 親に移動するのもセマンティクス的におかしい（moveOrCopyInto
      // 側でも弾く）。
      onDropOver: (event) => decideDropOperation(
        event.session,
        parentPath,
        disallowSameParent: true,
      ),
      onDropEnter: (_) => isHovering.value = true,
      onDropLeave: (_) => isHovering.value = false,
      onPerformDrop: (event) async {
        isHovering.value = false;
        await performFileDrop(context, ref, event, parentPath);
      },
      child: InkWell(
        // ADR-0021: 他ディレクトリと同様にダブルクリックで遷移する。
        onDoubleTap: () => ref
            .read(explorerViewModelProvider(tabId).notifier)
            .navigateTo(parentPath),
        child: Container(
          color: isHovering.value
              ? colors.primary.withValues(alpha: 0.12)
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.arrow_upward, color: colors.onSurfaceVariant),
              const SizedBox(width: 16),
              Text('上の階層へ', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  parentPath,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 右クリックメニューで選べるアクション。Skill 検知あり時のみ Skill 系が
/// 含まれる。
sealed class ExplorerNodeAction {
  const ExplorerNodeAction();
}

class _ActionOpenClaude extends ExplorerNodeAction {
  const _ActionOpenClaude();
}

class _ActionOpenTerminal extends ExplorerNodeAction {
  const _ActionOpenTerminal();
}

class _ActionRevealInFinder extends ExplorerNodeAction {
  const _ActionRevealInFinder();
}

class _ActionAddToFavorite extends ExplorerNodeAction {
  const _ActionAddToFavorite();
}

class _ActionNewFolder extends ExplorerNodeAction {
  const _ActionNewFolder();
}

class _ActionNewFile extends ExplorerNodeAction {
  const _ActionNewFile();
}

class _ActionRename extends ExplorerNodeAction {
  const _ActionRename();
}

class _ActionCopy extends ExplorerNodeAction {
  const _ActionCopy();
}

class _ActionCopyPath extends ExplorerNodeAction {
  const _ActionCopyPath();
}

class _ActionPaste extends ExplorerNodeAction {
  const _ActionPaste();
}

class _ActionMoveToTrash extends ExplorerNodeAction {
  const _ActionMoveToTrash();
}

class _ActionProperties extends ExplorerNodeAction {
  const _ActionProperties();
}

class _ActionRunSkill extends ExplorerNodeAction {
  const _ActionRunSkill(this.skillName);
  final String skillName;
}

class _ActionRegisterSkill extends ExplorerNodeAction {
  const _ActionRegisterSkill(this.skillName);
  final String skillName;
}

/// 1 ノード（ディレクトリ or ファイル）を表す行。タイル全体（テキスト以外
/// の余白部分も含む）で左クリック / 右クリックを受け付ける。
/// ディレクトリはドラッグソース＋ドロップターゲット、ファイルは
/// ドラッグソースのみ。
class ExplorerNodeTile extends ConsumerWidget {
  const ExplorerNodeTile({required this.node, super.key});

  final ExplorerNode node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (node) {
      ExplorerDirectoryNode() => _DirectoryTile(
        node: node as ExplorerDirectoryNode,
      ),
      ExplorerFileNode() => _FileTile(node: node as ExplorerFileNode),
    };
  }
}

class _DirectoryTile extends HookConsumerWidget {
  const _DirectoryTile({required this.node});

  final ExplorerDirectoryNode node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovering = useState(false);
    return DropRegion(
      formats: const [Formats.fileUri],
      hitTestBehavior: HitTestBehavior.opaque,
      // 内部 drag は自身 / 子孫への drop を弾く（loop 防止）。modifier
      // とボリューム判定は decideDropOperation 側で済ませて move / copy
      // を返す。
      onDropOver: (event) => decideDropOperation(event.session, node.path),
      onDropEnter: (_) => isHovering.value = true,
      onDropLeave: (_) => isHovering.value = false,
      onPerformDrop: (event) async {
        isHovering.value = false;
        await performFileDrop(context, ref, event, node.path);
      },
      child: DragItemWidget(
        allowedOperations: () => const [DropOperation.move, DropOperation.copy],
        dragItemProvider: (request) async {
          _refreshOnDragCompleted(ref, request.session);
          return DragItem(suggestedName: node.name, localData: node.path)
            ..add(Formats.fileUri(Uri.file(node.path)));
        },
        child: DraggableWidget(child: _content(context, ref, isHovering.value)),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, bool isDropHovering) {
    // Claude CLI 未導入時は Skill 検知関連の表示を完全に消す（ADR-0022）。
    final claudeAvailable = ref.watch(claudeAvailableProvider);
    final hasSkill = claudeAvailable && node.skillNames.isNotEmpty;
    final colors = Theme.of(context).colorScheme;
    final tabId = ref.watch(currentTabIdProvider);
    final isSelected =
        ref.watch(explorerItemSelectionProvider(tabId)) == node.path;
    // ADR-0024: compact ではサイドバーと同じ縦幅・1 行表示にして Skill 表示を省略する。
    final density =
        ref.watch(explorerSettingsProvider).value?.listDensity ??
        ExplorerListDensity.comfortable;
    final isCompact = density == ExplorerListDensity.compact;
    final showSkill = hasSkill && !isCompact;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) =>
          showExplorerContextMenu(context, ref, node, details.globalPosition),
      child: InkWell(
        // ADR-0021: シングルクリックで選択、ダブルクリックで遷移。
        onTap: () => ref
            .read(explorerItemSelectionProvider(tabId).notifier)
            .select(node.path),
        onDoubleTap: () => ref
            .read(explorerViewModelProvider(tabId).notifier)
            .navigateTo(node.path),
        child: Container(
          color: isDropHovering
              ? colors.primary.withValues(alpha: 0.12)
              : (isSelected ? colors.primary.withValues(alpha: 0.16) : null),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isCompact ? 6 : 12,
          ),
          child: Row(
            children: [
              Icon(
                hasSkill ? Icons.folder_special : Icons.folder,
                size: isCompact ? 18 : null,
                color: hasSkill ? colors.primary : colors.onSurfaceVariant,
              ),
              SizedBox(width: isCompact ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showSkill)
                      Text(
                        'Skill: ${node.skillNames.join(', ')}',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (showSkill)
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text('${node.skillNames.length}'),
                  avatar: const Icon(Icons.bolt, size: 14),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileTile extends ConsumerWidget {
  const _FileTile({required this.node});

  final ExplorerFileNode node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final icon = _iconForName(node.name);
    final tabId = ref.watch(currentTabIdProvider);
    final isSelected =
        ref.watch(explorerItemSelectionProvider(tabId)) == node.path;
    // ADR-0024: ディレクトリタイルと同じく compact ではサイドバーと同じ縦幅。
    final density =
        ref.watch(explorerSettingsProvider).value?.listDensity ??
        ExplorerListDensity.comfortable;
    final isCompact = density == ExplorerListDensity.compact;
    final content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) =>
          showFileContextMenu(context, ref, node, details.globalPosition),
      child: InkWell(
        // ADR-0021: シングルクリックで選択、ダブルクリックで開く。
        onTap: () => ref
            .read(explorerItemSelectionProvider(tabId).notifier)
            .select(node.path),
        onDoubleTap: () => ref.read(fileOpenerProvider).open(node.path),
        child: Container(
          color: isSelected ? colors.primary.withValues(alpha: 0.16) : null,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isCompact ? 6 : 12,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: isCompact ? 18 : null,
                color: colors.onSurfaceVariant,
              ),
              SizedBox(width: isCompact ? 12 : 16),
              Expanded(
                child: Text(
                  node.name,
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
    return DragItemWidget(
      allowedOperations: () => const [DropOperation.move, DropOperation.copy],
      dragItemProvider: (request) async {
        _refreshOnDragCompleted(ref, request.session);
        return DragItem(suggestedName: node.name, localData: node.path)
          ..add(Formats.fileUri(Uri.file(node.path)));
      },
      child: DraggableWidget(child: content),
    );
  }

  /// 拡張子からざっくりアイコンを決める。厳密に判別する必要は無く、
  /// ディレクトリと区別がつけばよい程度。
  IconData _iconForName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.md') || lower.endsWith('.txt')) {
      return Icons.description;
    }
    if (lower.endsWith('.json') ||
        lower.endsWith('.yaml') ||
        lower.endsWith('.yml') ||
        lower.endsWith('.toml')) {
      return Icons.data_object;
    }
    if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.svg')) {
      return Icons.image;
    }
    if (lower.endsWith('.zip') ||
        lower.endsWith('.tar') ||
        lower.endsWith('.gz')) {
      return Icons.folder_zip;
    }
    return Icons.insert_drive_file;
  }
}

/// DropRegion の `onDropOver` で「drop を受け入れるか / 何の操作にするか」
/// を Finder と同等のセマンティクスで判定する。
///
/// 受け入れ条件:
/// - drag セッションの 1 件目が `Formats.fileUri` を提供する
/// - 内部 drag（`localData` に String パスが入る）の場合のみ、self-loop
///   を防ぐガードを掛ける:
///     - source == target
///     - target が source の子孫 (`target.startsWith('source/')`)
///     - `disallowSameParent` 指定時、source の親 == target（同一親内
///       no-op 移動の抑止。「上の階層へ」タイル用）
///
/// 操作判定（Finder 等価）:
/// - ⌥ (option) 押下中: copy
/// - ⌘ (command) 押下中: move
/// - 内部 drag で異ボリューム: copy（rename が失敗する側に倒れるため）
/// - それ以外: move
///
/// 外部 drag では source のボリュームが onDropOver 同期で取れないため、
/// 修飾キーが無ければ move を返す。実際の操作判定（必要なら copy に倒す）
/// は [performFileDrop] 側で行うので、カーソル表示と最終操作が一瞬ずれ
/// るケースが残る（実用上の影響は軽微）。
DropOperation decideDropOperation(
  DropSession session,
  String targetPath, {
  bool disallowSameParent = false,
}) {
  final items = session.items;
  if (items.isEmpty) {
    return DropOperation.none;
  }
  final first = items.first;
  if (!first.canProvide(Formats.fileUri)) {
    return DropOperation.none;
  }
  final source = first.localData;
  if (source is String) {
    if (source == targetPath || targetPath.startsWith('$source/')) {
      return DropOperation.none;
    }
    if (disallowSameParent && parentOfPath(source) == targetPath) {
      return DropOperation.none;
    }
  }
  final keyboard = HardwareKeyboard.instance;
  if (keyboard.isAltPressed) {
    return DropOperation.copy;
  }
  if (keyboard.isMetaPressed) {
    return DropOperation.move;
  }
  if (source is String && _volumeKey(source) != _volumeKey(targetPath)) {
    return DropOperation.copy;
  }
  return DropOperation.move;
}

/// DropRegion の `onPerformDrop` で、drag セッション内のすべての fileUri
/// アイテムを順番に [targetDir] へ移動 or コピーする。[event] の
/// `reader.getValue` は非同期コールバックなので、`Completer` で順序を
/// 待ち合わせる。
///
/// 操作種別は [PerformDropEvent.acceptedOperation]（= 直前の `onDropOver`
/// が返した結果）を参照する。実際の rename / cp は [moveOrCopyInto] に
/// 委譲し、cross-volume での move 試行はそこで自動 copy にフォールバ
/// ックされる。エラー UX も同関数の SnackBar 経路に乗る。
Future<void> performFileDrop(
  BuildContext context,
  WidgetRef ref,
  PerformDropEvent event,
  String targetDir,
) async {
  final prefersCopy = event.acceptedOperation == DropOperation.copy;
  for (final item in event.session.items) {
    final reader = item.dataReader;
    if (reader == null || !reader.canProvide(Formats.fileUri)) {
      continue;
    }
    final completer = Completer<Uri?>();
    reader.getValue(
      Formats.fileUri,
      (uri) {
        if (!completer.isCompleted) {
          completer.complete(uri);
        }
      },
      onError: (_) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      },
    );
    final uri = await completer.future;
    if (uri == null || !context.mounted) {
      continue;
    }
    await moveOrCopyInto(
      context,
      ref,
      uri.toFilePath(),
      targetDir,
      prefersCopy: prefersCopy,
    );
  }
}
