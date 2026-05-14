import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/router.dart';
import 'package:roola/core/system/explorer_file_ops.dart';
import 'package:roola/core/system/file_opener.dart';
import 'package:roola/core/system/trash_service.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/repo_explorer/explorer_node.dart';
import 'package:roola/data/repo_explorer/explorer_settings.dart';
import 'package:roola/data/repo_explorer/explorer_settings_repository_impl.dart';
import 'package:roola/ui/common/prompt_name_dialog.dart';
import 'package:roola/ui/explorer/explorer_clipboard_provider.dart';
import 'package:roola/ui/explorer/explorer_properties_dialog.dart';
import 'package:roola/ui/explorer/explorer_selection.dart';
import 'package:roola/ui/explorer/explorer_view_model.dart';
import 'package:roola/ui/run/adhoc_run_view_model.dart';
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
      // PTY を起動してから selection を切替える（順序逆だと body が
      // build される前に Notifier 側で runner が無くて空表示になる）。
      ref.read(adhocRunViewModelProvider(args));
      ref.read(explorerSelectionProvider.notifier).selectAdhocSession(args);
    case _ActionOpenTerminal():
      final adhocId = 'adhoc-${_uuid.v4()}';
      final args = AdhocRunArgs(
        adhocId: adhocId,
        workingDirectory: node.path,
        displayName: '${node.name} (Terminal)',
        action: const LauncherAction.openHere(),
      );
      ref.read(adhocRunViewModelProvider(args));
      ref.read(explorerSelectionProvider.notifier).selectAdhocSession(args);
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
      ref.read(adhocRunViewModelProvider(args));
      ref.read(explorerSelectionProvider.notifier).selectAdhocSession(args);
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
    ref.read(explorerViewModelProvider.notifier).refresh();
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
  final notifier = ref.read(explorerViewModelProvider.notifier);
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
        onTap: () =>
            ref.read(explorerViewModelProvider.notifier).navigateTo(parentPath),
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
        allowedOperations: () =>
            const [DropOperation.move, DropOperation.copy],
        dragItemProvider: (request) async {
          _refreshOnDragCompleted(ref, request.session);
          return DragItem(suggestedName: node.name, localData: node.path)
            ..add(Formats.fileUri(Uri.file(node.path)));
        },
        child: DraggableWidget(
          child: _content(context, ref, isHovering.value),
        ),
      ),
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
  if (source is String &&
      _volumeKey(source) != _volumeKey(targetPath)) {
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
