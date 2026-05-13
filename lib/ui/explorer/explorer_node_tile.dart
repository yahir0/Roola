import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/router.dart';
import 'package:roola/core/system/explorer_file_ops.dart';
import 'package:roola/core/system/file_opener.dart';
import 'package:roola/core/system/trash_service.dart';
import 'package:roola/data/repo_explorer/explorer_node.dart';
import 'package:roola/data/repo_explorer/explorer_settings.dart';
import 'package:roola/data/repo_explorer/explorer_settings_repository_impl.dart';
import 'package:roola/data/skill_session/adhoc_run_args.dart';
import 'package:roola/ui/common/prompt_name_dialog.dart';
import 'package:roola/ui/explorer/explorer_clipboard_provider.dart';
import 'package:roola/ui/explorer/explorer_properties_dialog.dart';
import 'package:roola/ui/explorer/explorer_view_model.dart';
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
  if (!context.mounted) {
    return;
  }
  final items = <PopupMenuEntry<ExplorerNodeAction>>[
    const PopupMenuItem(
      value: _ActionOpenClaude(),
      child: ListTile(
        leading: Icon(Icons.terminal),
        title: Text('このディレクトリで Claude Code を開く'),
      ),
    ),
    const PopupMenuItem(
      value: _ActionOpenTerminal(),
      child: ListTile(
        leading: Icon(Icons.developer_mode),
        title: Text('ここでターミナルを開く'),
      ),
    ),
    const PopupMenuItem(
      value: _ActionRevealInFinder(),
      child: ListTile(
        leading: Icon(Icons.folder_open),
        title: Text('Finder で表示'),
      ),
    ),
    const PopupMenuItem(
      value: _ActionAddToFavorite(),
      child: ListTile(
        leading: Icon(Icons.star_outline),
        title: Text('お気に入りに追加'),
      ),
    ),
    const PopupMenuDivider(),
    const PopupMenuItem(
      value: _ActionNewFolder(),
      child: ListTile(
        leading: Icon(Icons.create_new_folder_outlined),
        title: Text('新規フォルダ'),
      ),
    ),
    const PopupMenuItem(
      value: _ActionNewFile(),
      child: ListTile(
        leading: Icon(Icons.note_add_outlined),
        title: Text('新規テキストファイル'),
      ),
    ),
    if (showRename)
      const PopupMenuItem(
        value: _ActionRename(),
        child: ListTile(
          leading: Icon(Icons.drive_file_rename_outline),
          title: Text('名前を変更'),
        ),
      ),
    const PopupMenuDivider(),
    if (showCopy)
      const PopupMenuItem(
        value: _ActionCopy(),
        child: ListTile(leading: Icon(Icons.content_copy), title: Text('コピー')),
      ),
    const PopupMenuItem(
      value: _ActionCopyPath(),
      child: ListTile(leading: Icon(Icons.link), title: Text('パスをコピー')),
    ),
    if (hasClipboard)
      const PopupMenuItem(
        value: _ActionPaste(),
        child: ListTile(
          leading: Icon(Icons.content_paste),
          title: Text('ペースト'),
        ),
      ),
    if (showDelete) ...const [
      PopupMenuDivider(),
      PopupMenuItem(
        value: _ActionMoveToTrash(),
        child: ListTile(
          leading: Icon(Icons.delete_outline),
          title: Text('削除'),
        ),
      ),
    ],
    const PopupMenuDivider(),
    const PopupMenuItem(
      value: _ActionProperties(),
      child: ListTile(leading: Icon(Icons.info_outline), title: Text('プロパティ')),
    ),
  ];
  if (node.skillNames.isNotEmpty) {
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
            title: Text('「$skill」をホームに登録'),
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
    items: const [
      PopupMenuItem(
        value: _FileAction.open,
        child: ListTile(
          leading: Icon(Icons.open_in_new),
          title: Text('OS デフォルトアプリで開く'),
        ),
      ),
      PopupMenuItem(
        value: _FileAction.openWith,
        child: ListTile(
          leading: Icon(Icons.apps),
          title: Text('別のアプリケーションで開く…'),
        ),
      ),
      PopupMenuItem(
        value: _FileAction.revealInFinder,
        child: ListTile(
          leading: Icon(Icons.folder_open),
          title: Text('Finder で表示'),
        ),
      ),
      PopupMenuDivider(),
      PopupMenuItem(
        value: _FileAction.rename,
        child: ListTile(
          leading: Icon(Icons.drive_file_rename_outline),
          title: Text('名前を変更'),
        ),
      ),
      PopupMenuItem(
        value: _FileAction.copy,
        child: ListTile(leading: Icon(Icons.content_copy), title: Text('コピー')),
      ),
      PopupMenuItem(
        value: _FileAction.copyPath,
        child: ListTile(leading: Icon(Icons.link), title: Text('パスをコピー')),
      ),
      PopupMenuDivider(),
      PopupMenuItem(
        value: _FileAction.moveToTrash,
        child: ListTile(
          leading: Icon(Icons.delete_outline),
          title: Text('削除'),
        ),
      ),
      PopupMenuDivider(),
      PopupMenuItem(
        value: _FileAction.properties,
        child: ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('プロパティ'),
        ),
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
      final args = AdhocRunArgs(
        adhocId: adhocId,
        repositoryPath: node.path,
        displayName: '${node.name} (Claude)',
      );
      unawaited(
        RunAdhocRoute(adhocId: adhocId, $extra: args).push<void>(context),
      );
    case _ActionOpenTerminal():
      final adhocId = 'adhoc-${_uuid.v4()}';
      final args = AdhocRunArgs(
        adhocId: adhocId,
        repositoryPath: node.path,
        displayName: '${node.name} (Terminal)',
        kind: AdhocRunKind.terminal,
      );
      unawaited(
        RunAdhocRoute(adhocId: adhocId, $extra: args).push<void>(context),
      );
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
        repositoryPath: node.path,
        displayName: '${node.name} / $skillName',
        skillName: skillName,
      );
      unawaited(
        RunAdhocRoute(adhocId: adhocId, $extra: args).push<void>(context),
      );
    case _ActionRegisterSkill(:final skillName):
      unawaited(
        EntryNewRoute(
          initialRepositoryPath: node.path,
          initialSkillName: skillName,
        ).push<void>(context),
      );
  }
}

/// 新規フォルダ / 新規ファイルを [parentPath] 直下に作成する。失敗時は
/// SnackBar でエラーを表示。成功時はビューモデルを refresh して反映。
Future<void> _createNew(
  BuildContext context,
  WidgetRef ref,
  String parentPath, {
  required bool isDirectory,
}) async {
  final defaultName = isDirectory ? '新規フォルダ' : '新規テキストファイル.txt';
  final name = await promptName(
    context,
    title: isDirectory ? '新規フォルダ名' : '新規ファイル名',
    initialValue: defaultName,
    confirmLabel: '作成',
  );
  if (name == null || name.trim().isEmpty || !context.mounted) {
    return;
  }
  final ops = ref.read(explorerFileOpsProvider);
  try {
    if (isDirectory) {
      await ops.createDirectory(parentPath, name.trim());
    } else {
      await ops.createFile(parentPath, name.trim());
    }
    ref.read(explorerViewModelProvider.notifier).refresh();
  } on FileSystemException catch (e) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('作成に失敗しました: ${e.message}')));
  }
}

/// [oldPath] を新しい名前にリネームし、ビューモデルを refresh する。
Future<void> _renameAndRefresh(
  BuildContext context,
  WidgetRef ref,
  String oldPath,
  String oldName,
) async {
  final newName = await promptName(
    context,
    title: '名前を変更',
    initialValue: oldName,
    confirmLabel: '変更',
  );
  if (newName == null || newName.trim().isEmpty || newName.trim() == oldName) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  final ops = ref.read(explorerFileOpsProvider);
  try {
    await ops.rename(oldPath, newName.trim());
    ref.read(explorerViewModelProvider.notifier).refresh();
  } on FileSystemException catch (e) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('リネームに失敗しました: ${e.message}')));
  }
}

/// OS クリップボードに乗っているファイル URI を [targetDir] にコピーする。
/// Finder で複数選択コピーした場合など複数 URI がある場合は順にコピーする。
/// 失敗時は SnackBar でエラー、成功時は ViewModel を refresh。
/// OS クリップボードの内容はこちらで消さない（連続ペースト可）。
Future<void> _pasteInto(
  BuildContext context,
  WidgetRef ref,
  String targetDir,
) async {
  final sources = await ref.read(osClipboardServiceProvider).readFilePaths();
  if (sources.isEmpty) {
    return;
  }
  final ops = ref.read(explorerFileOpsProvider);
  final missing = <String>[];
  String? lastError;
  for (final source in sources) {
    if (!File(source).existsSync() && !Directory(source).existsSync()) {
      missing.add(source);
      continue;
    }
    try {
      await ops.copyInto(source, targetDir);
    } on FileSystemException catch (e) {
      lastError = e.message;
    }
  }
  ref.read(explorerViewModelProvider.notifier).refresh();
  if (!context.mounted) {
    return;
  }
  if (lastError != null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('ペーストに失敗しました: $lastError')));
  } else if (missing.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('コピー元が見つかりません: ${missing.join(', ')}')),
    );
  }
}

/// [path] を OS のゴミ箱に移動する。実行前に必ず確認ダイアログを出し、
/// 承認された場合のみ実行する（誤クリック対策）。実体はゴミ箱送りで
/// 戻せるため、文言は「削除しますか？」と直接的に書く。
/// 完了後は ViewModel を refresh し、SnackBar で結果を通知する。
Future<void> _moveToTrash(
  BuildContext context,
  WidgetRef ref,
  String path,
  String displayName,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('削除しますか？'),
      content: Text('「$displayName」をゴミ箱に移動します。'),
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
  if (confirmed != true || !context.mounted) {
    return;
  }
  try {
    await ref.read(trashServiceProvider).moveToTrash(path);
    ref.read(explorerViewModelProvider.notifier).refresh();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ゴミ箱に移動しました: $displayName'),
        duration: const Duration(seconds: 2),
      ),
    );
  } on PlatformException catch (e) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('ゴミ箱に移動できませんでした: ${e.message ?? e.code}')));
  }
}

/// 絶対パス文字列を OS クリップボードにテキストとして書き込む。
/// ファイル URI 形式の「コピー」とは別経路で、他アプリのテキスト入力
/// 欄にそのまま貼れることを意図する。
Future<void> _copyPathToClipboard(BuildContext context, String path) async {
  await Clipboard.setData(ClipboardData(text: path));
  if (!context.mounted) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('パスをコピーしました: $path'),
      duration: const Duration(seconds: 2),
    ),
  );
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

/// ドラッグ＆ドロップで [sourcePath] を [targetDir] へ移動する。
/// 移動後はビューモデルを refresh。エラー時は SnackBar で通知。
Future<void> moveInto(
  BuildContext context,
  WidgetRef ref,
  String sourcePath,
  String targetDir,
) async {
  final ops = ref.read(explorerFileOpsProvider);
  try {
    await ops.moveInto(sourcePath, targetDir);
    ref.read(explorerViewModelProvider.notifier).refresh();
  } on FileSystemException catch (e) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('移動に失敗しました: ${e.message}')));
  }
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
class ExplorerParentDropTile extends ConsumerWidget {
  const ExplorerParentDropTile({required this.currentPath, super.key});

  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentPath = parentOfPath(currentPath);
    final colors = Theme.of(context).colorScheme;
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        // 既に親に居る項目を「親に移動」しても no-op なので、視覚
        // フィードバックを出さない。自身や祖先を親に移動するのも
        // セマンティクス的におかしい（moveInto 側でも弾く）。
        return parentOfPath(details.data) != parentPath &&
            details.data != parentPath &&
            !parentPath.startsWith('${details.data}/');
      },
      onAcceptWithDetails: (details) =>
          moveInto(context, ref, details.data, parentPath),
      builder: (context, candidate, _) {
        final isHovering = candidate.isNotEmpty;
        return InkWell(
          onTap: () => ref
              .read(explorerViewModelProvider.notifier)
              .navigateTo(parentPath),
          child: Container(
            color: isHovering ? colors.primary.withValues(alpha: 0.12) : null,
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
        );
      },
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

class _DirectoryTile extends ConsumerWidget {
  const _DirectoryTile({required this.node});

  final ExplorerDirectoryNode node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) =>
          details.data != node.path &&
          !node.path.startsWith('${details.data}/'),
      onAcceptWithDetails: (details) =>
          moveInto(context, ref, details.data, node.path),
      builder: (context, candidate, _) {
        final isHovering = candidate.isNotEmpty;
        return Draggable<String>(
          data: node.path,
          feedback: _DragFeedback(label: node.name, icon: Icons.folder),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _content(context, ref, false),
          ),
          child: _content(context, ref, isHovering),
        );
      },
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, bool isDropHovering) {
    final hasSkill = node.skillNames.isNotEmpty;
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) =>
          showExplorerContextMenu(context, ref, node, details.globalPosition),
      child: InkWell(
        onTap: () =>
            ref.read(explorerViewModelProvider.notifier).navigateTo(node.path),
        child: Container(
          color: isDropHovering ? colors.primary.withValues(alpha: 0.12) : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                hasSkill ? Icons.folder_special : Icons.folder,
                color: hasSkill ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (hasSkill)
                      Text(
                        'Skill: ${node.skillNames.join(', ')}',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (hasSkill)
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
    final content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) =>
          showFileContextMenu(context, ref, node, details.globalPosition),
      child: InkWell(
        onTap: () => ref.read(fileOpenerProvider).open(node.path),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: colors.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  node.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Draggable<String>(
      data: node.path,
      feedback: _DragFeedback(label: node.name, icon: icon),
      childWhenDragging: Opacity(opacity: 0.3, child: content),
      child: content,
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

/// ドラッグ中にカーソルに追従して表示する小さなチップ。
class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.primary, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: colors.primary),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
