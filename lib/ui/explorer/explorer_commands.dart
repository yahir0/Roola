import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/system/explorer_file_ops.dart';
import 'package:roola/core/system/file_opener.dart';
import 'package:roola/core/system/trash_service.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/repo_explorer/explorer_settings.dart';
import 'package:roola/data/repo_explorer/explorer_settings_repository_impl.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/ui/common/prompt_name_dialog.dart';
import 'package:roola/ui/explorer/explorer_clipboard_provider.dart';
import 'package:roola/ui/explorer/explorer_properties_dialog.dart';
import 'package:roola/ui/explorer/explorer_view_model.dart';
import 'package:roola/ui/run/adhoc_run_view_model.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:uuid/uuid.dart';

/// エクスプローラ系コマンドの実処理（ADR-0033）。
///
/// コンテキストメニュー（右クリックした対象に作用）と `CommandDispatcher`
/// （フォーカス中タブの選択アイテムに作用）の両方が、ここの公開関数を呼ぶ。
/// 対象パスと「リフレッシュすべきエクスプローラタブ id」は呼び出し側が
/// 明示的に渡す（`currentTabIdProvider` はタブ body スコープ内でしか
/// 解決できないため）。

const _uuid = Uuid();

void _refreshTab(WidgetRef ref, String explorerTabId) {
  ref.read(explorerViewModelProvider(explorerTabId).notifier).refresh();
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}

/// 新規フォルダ / 新規ファイルを [parentPath] 直下に作成する。
Future<void> runCreateEntry(
  BuildContext context,
  WidgetRef ref, {
  required String parentPath,
  required String explorerTabId,
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
    _refreshTab(ref, explorerTabId);
  } on FileSystemException catch (e) {
    if (!context.mounted) {
      return;
    }
    _snack(context, '作成に失敗しました: ${e.message}');
  }
}

/// [path] を新しい名前にリネームし、エクスプローラタブを refresh する。
Future<void> runRename(
  BuildContext context,
  WidgetRef ref, {
  required String path,
  required String currentName,
  required String explorerTabId,
}) async {
  final newName = await promptName(
    context,
    title: '名前を変更',
    initialValue: currentName,
    confirmLabel: '変更',
  );
  if (newName == null ||
      newName.trim().isEmpty ||
      newName.trim() == currentName) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  final ops = ref.read(explorerFileOpsProvider);
  try {
    await ops.rename(path, newName.trim());
    _refreshTab(ref, explorerTabId);
  } on FileSystemException catch (e) {
    if (!context.mounted) {
      return;
    }
    _snack(context, 'リネームに失敗しました: ${e.message}');
  }
}

/// OS クリップボードのファイル URI を [targetDir] にコピーする。
Future<void> runPaste(
  BuildContext context,
  WidgetRef ref, {
  required String targetDir,
  required String explorerTabId,
}) async {
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
  _refreshTab(ref, explorerTabId);
  if (!context.mounted) {
    return;
  }
  if (lastError != null) {
    _snack(context, 'ペーストに失敗しました: $lastError');
  } else if (missing.isNotEmpty) {
    _snack(context, 'コピー元が見つかりません: ${missing.join(', ')}');
  }
}

/// [path] を OS のゴミ箱へ移動する。実行前に確認ダイアログを出す。
Future<void> runMoveToTrash(
  BuildContext context,
  WidgetRef ref, {
  required String path,
  required String displayName,
  required String explorerTabId,
}) async {
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
    _refreshTab(ref, explorerTabId);
    if (!context.mounted) {
      return;
    }
    _snack(context, 'ゴミ箱に移動しました: $displayName');
  } on PlatformException catch (e) {
    if (!context.mounted) {
      return;
    }
    _snack(context, 'ゴミ箱に移動できませんでした: ${e.message ?? e.code}');
  }
}

/// 絶対パス文字列を OS クリップボードにテキストとして書き込む。
Future<void> runCopyPath(
  BuildContext context, {
  required String path,
}) async {
  await Clipboard.setData(ClipboardData(text: path));
  if (!context.mounted) {
    return;
  }
  _snack(context, 'パスをコピーしました: $path');
}

/// アイテムを OS クリップボードへファイルとしてコピーする。
Future<void> runCopyItem(
  BuildContext context,
  WidgetRef ref, {
  required String path,
  required String displayName,
}) async {
  await ref.read(osClipboardServiceProvider).writeFile(path);
  if (!context.mounted) {
    return;
  }
  _snack(context, 'コピーしました: $displayName');
}

/// [path] を Finder で表示する。
Future<void> runRevealInFinder(WidgetRef ref, {required String path}) async {
  await ref.read(fileOpenerProvider).revealInFinder(path);
}

/// [path]（ファイル）を OS デフォルトアプリで開く。
Future<void> runOpenInDefaultApp(WidgetRef ref, {required String path}) async {
  await ref.read(fileOpenerProvider).open(path);
}

/// [path] のプロパティダイアログを表示する。
Future<void> runShowProperties(
  BuildContext context, {
  required String path,
}) async {
  await showPropertiesDialog(context, path);
}

/// [path] をお気に入りに追加する。
Future<void> runAddToFavorite(
  BuildContext context,
  WidgetRef ref, {
  required String path,
  required String name,
}) async {
  await ref
      .read(explorerSettingsProvider.notifier)
      .addFavorite(
        ExplorerFavorite(id: 'fav-${_uuid.v4()}', path: path, name: name),
      );
  if (!context.mounted) {
    return;
  }
  _snack(context, 'お気に入りに追加しました: $name');
}

/// [dirPath] でターミナルを開く（bottom ペインに新規ターミナルタブ）。
void runOpenTerminalHere(
  WidgetRef ref, {
  required String dirPath,
  required String displayName,
}) {
  final args = AdhocRunArgs(
    adhocId: 'adhoc-${_uuid.v4()}',
    workingDirectory: dirPath,
    displayName: '$displayName (Terminal)',
    action: const LauncherAction.openHere(),
  );
  ref.read(workspaceProvider.notifier).addTerminalTab(
        PaneSlotId.bottom,
        args: args,
      );
}

/// [dirPath] で Claude Code を開く（bottom ペインに新規ターミナルタブ）。
void runOpenClaudeHere(
  WidgetRef ref, {
  required String dirPath,
  required String displayName,
}) {
  final args = AdhocRunArgs(
    adhocId: 'adhoc-${_uuid.v4()}',
    workingDirectory: dirPath,
    displayName: '$displayName (Claude)',
    action: const LauncherAction.runCommand(
      command: 'claude',
      keepShellAfterExit: false,
    ),
  );
  ref.read(workspaceProvider.notifier).addTerminalTab(
        PaneSlotId.bottom,
        args: args,
      );
}
