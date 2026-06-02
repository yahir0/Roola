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
import 'package:roola/data/terminal_runner/windows_shell.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_dialog.dart';
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
  final l10n = AppLocalizations.of(context);
  final defaultName = isDirectory
      ? l10n.explorerDefaultFolderName
      : l10n.explorerDefaultFileName;
  final name = await promptName(
    context,
    title: isDirectory
        ? l10n.explorerNewFolderTitle
        : l10n.explorerNewFileTitle,
    initialValue: defaultName,
    confirmLabel: l10n.buttonCreate,
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
    _snack(context, l10n.explorerSnackbarCreateFailed(e.message));
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
  final l10n = AppLocalizations.of(context);
  final newName = await promptName(
    context,
    title: l10n.explorerRenameTitle,
    initialValue: currentName,
    confirmLabel: l10n.buttonChange,
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
    _snack(context, l10n.explorerSnackbarRenameFailed(e.message));
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
  final l10n = AppLocalizations.of(context);
  if (lastError != null) {
    _snack(context, l10n.explorerSnackbarPasteFailed(lastError));
  } else if (missing.isNotEmpty) {
    _snack(context, l10n.explorerSnackbarSourceNotFound(missing.join(', ')));
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
  final l10n = AppLocalizations.of(context);
  final confirmed = await showPolarisConfirm(
    context,
    title: l10n.explorerDeleteConfirmTitle,
    message: l10n.explorerDeleteConfirmMessage(displayName),
    confirmLabel: l10n.buttonDelete,
    cancelLabel: l10n.buttonCancel,
    destructive: true,
  );
  if (!confirmed || !context.mounted) {
    return;
  }
  try {
    await ref.read(trashServiceProvider).moveToTrash(path);
    _refreshTab(ref, explorerTabId);
    if (!context.mounted) {
      return;
    }
    _snack(context, l10n.explorerSnackbarMovedToTrash(displayName));
  } on PlatformException catch (e) {
    if (!context.mounted) {
      return;
    }
    _snack(
      context,
      l10n.explorerSnackbarMoveToTrashFailed(e.message ?? e.code),
    );
  }
}

/// 絶対パス文字列を OS クリップボードにテキストとして書き込む。
Future<void> runCopyPath(BuildContext context, {required String path}) async {
  await Clipboard.setData(ClipboardData(text: path));
  if (!context.mounted) {
    return;
  }
  _snack(
    context,
    AppLocalizations.of(context).explorerSnackbarPathCopied(path),
  );
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
  _snack(
    context,
    AppLocalizations.of(context).explorerSnackbarItemCopied(displayName),
  );
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
  _snack(
    context,
    AppLocalizations.of(context).explorerSnackbarAddedFavorite(name),
  );
}

/// [dirPath] でターミナルを開く（bottom ペインに新規ターミナルタブ）。
/// [windowsShell] を指定すると設定値より優先して使用する。
void runOpenTerminalHere(
  WidgetRef ref, {
  required String dirPath,
  required String displayName,
  WindowsShell? windowsShell,
}) {
  final args = AdhocRunArgs(
    adhocId: 'adhoc-${_uuid.v4()}',
    workingDirectory: dirPath,
    displayName: '$displayName (Terminal)',
    action: const LauncherAction.openHere(),
    windowsShell: windowsShell,
  );
  ref
      .read(workspaceProvider.notifier)
      .addTerminalTab(PaneSlotId.bottom, args: args);
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
  ref
      .read(workspaceProvider.notifier)
      .addTerminalTab(PaneSlotId.bottom, args: args);
}
