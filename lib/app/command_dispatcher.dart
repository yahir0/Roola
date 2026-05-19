import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/router.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/explorer/explorer_commands.dart';
import 'package:roola/ui/explorer/explorer_item_selection.dart';
import 'package:roola/ui/explorer/explorer_view_model.dart';
import 'package:roola/ui/git/git_view_model.dart';
import 'package:roola/ui/workspace/focused_tab_provider.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';

/// コマンドをフォーカス中のコンテキストに対して実行する単一のディスパッチ
/// 経路（ADR-0033）。メニューバーの `onSelected` と、メニューバーの
/// key equivalent からの実行がここを通る。
///
/// コンテキスト依存コマンドはフォーカス中タブ・選択アイテムを provider から
/// 解決する。対象が解決できないときは何もしない（no-op）。ダイアログ /
/// SnackBar を要するコマンドは `rootNavigatorKey.currentContext` を
/// `BuildContext` 源として使う。
void dispatchCommand(CommandId id, WidgetRef ref) {
  switch (id) {
    // ランチャー / アプリ
    case CommandId.openSettings:
      unawaited(ref.read(routerProvider).push(const SettingsRoute().location));
    case CommandId.openKeybindings:
      unawaited(ref.read(routerProvider).push('/keybindings'));
    case CommandId.openLauncherManagement:
      unawaited(
        ref.read(routerProvider).push(const LauncherManagementRoute().location),
      );

    // タブ / ペイン
    case CommandId.newExplorerTab:
      ref.read(workspaceProvider.notifier).addExplorerTab(_focusedSlot(ref));
    case CommandId.newTerminalTab:
      ref.read(workspaceProvider.notifier).addTerminalTab(_focusedSlot(ref));
    case CommandId.closeTab:
      final tabId = ref.read(focusedTabProvider).focusedTabId;
      if (tabId != null) {
        ref.read(workspaceProvider.notifier).closeTab(tabId);
      }
    case CommandId.nextTab:
      _cycleTab(ref, 1);
    case CommandId.previousTab:
      _cycleTab(ref, -1);
    case CommandId.moveTabTopLeft:
      _moveFocusedTab(ref, PaneSlotId.topLeft);
    case CommandId.moveTabTopRight:
      _moveFocusedTab(ref, PaneSlotId.topRight);
    case CommandId.moveTabBottom:
      _moveFocusedTab(ref, PaneSlotId.bottom);

    // ナビゲーション
    case CommandId.navigateBack:
      _explorerVm(ref)?.goBack();
    case CommandId.navigateForward:
      _explorerVm(ref)?.goForward();
    case CommandId.navigateUp:
      _explorerVm(ref)?.goUp();

    // エクスプローラ（カレントディレクトリ対象）
    case CommandId.newFolder:
      _inExplorerDir(ref, (context, tabId, dir) {
        unawaited(
          runCreateEntry(
            context,
            ref,
            parentPath: dir,
            explorerTabId: tabId,
            isDirectory: true,
          ),
        );
      });
    case CommandId.newFile:
      _inExplorerDir(ref, (context, tabId, dir) {
        unawaited(
          runCreateEntry(
            context,
            ref,
            parentPath: dir,
            explorerTabId: tabId,
            isDirectory: false,
          ),
        );
      });
    case CommandId.pasteItem:
      _inExplorerDir(ref, (context, tabId, dir) {
        unawaited(runPaste(context, ref, targetDir: dir, explorerTabId: tabId));
      });

    // エクスプローラ（選択中アイテム対象）
    case CommandId.copyPath:
      _onSelection(ref, (context, tabId, sel) {
        unawaited(runCopyPath(context, path: sel));
      });
    case CommandId.copyItem:
      _onSelection(ref, (context, tabId, sel) {
        unawaited(
          runCopyItem(context, ref, path: sel, displayName: _basename(sel)),
        );
      });
    case CommandId.renameItem:
      _onSelection(ref, (context, tabId, sel) {
        unawaited(
          runRename(
            context,
            ref,
            path: sel,
            currentName: _basename(sel),
            explorerTabId: tabId,
          ),
        );
      });
    case CommandId.moveToTrash:
      _onSelection(ref, (context, tabId, sel) {
        unawaited(
          runMoveToTrash(
            context,
            ref,
            path: sel,
            displayName: _basename(sel),
            explorerTabId: tabId,
          ),
        );
      });
    case CommandId.showProperties:
      _onSelection(ref, (context, tabId, sel) {
        unawaited(runShowProperties(context, path: sel));
      });
    case CommandId.revealInFinder:
      _onSelection(ref, (context, tabId, sel) {
        unawaited(runRevealInFinder(ref, path: sel));
      });
    case CommandId.openItem:
      _onSelection(ref, (context, tabId, sel) {
        if (Directory(sel).existsSync()) {
          ref.read(explorerViewModelProvider(tabId).notifier).navigateTo(sel);
        } else {
          unawaited(runOpenInDefaultApp(ref, path: sel));
        }
      });
    case CommandId.openTerminalHere:
      _onExplorerTargetDir(ref, (dir) {
        runOpenTerminalHere(ref, dirPath: dir, displayName: _basename(dir));
      });
    case CommandId.openClaudeHere:
      _onExplorerTargetDir(ref, (dir) {
        runOpenClaudeHere(ref, dirPath: dir, displayName: _basename(dir));
      });

    // Git（フォーカス中 Git タブ対象）
    case CommandId.gitRefresh:
      unawaited(_gitVm(ref)?.refresh());
    case CommandId.gitFetch:
      unawaited(_gitVm(ref)?.fetch());
    case CommandId.gitPull:
      unawaited(_gitVm(ref)?.pull());
    case CommandId.gitPush:
      unawaited(_gitVm(ref)?.push());
  }
}

/// パスの末尾セグメント（表示名）。
String _basename(String path) {
  final trimmed = path.endsWith('/') && path.length > 1
      ? path.substring(0, path.length - 1)
      : path;
  final slash = trimmed.lastIndexOf('/');
  return slash < 0 ? trimmed : trimmed.substring(slash + 1);
}

/// フォーカス中タブが属するペイン。解決できなければ左上ペイン。
PaneSlotId _focusedSlot(WidgetRef ref) {
  final tabId = ref.read(focusedTabProvider).focusedTabId;
  if (tabId != null) {
    final layout = ref.read(workspaceProvider);
    for (final slotId in PaneSlotId.values) {
      if (layout.slot(slotId).tabs.any((tab) => tab.id == tabId)) {
        return slotId;
      }
    }
  }
  return PaneSlotId.topLeft;
}

/// フォーカス中のエクスプローラタブ id。フォーカス中タブがエクスプローラ
/// でなければ直近のエクスプローラタブにフォールバックする。
String? _focusedExplorerTabId(WidgetRef ref) {
  final focus = ref.read(focusedTabProvider);
  final notifier = ref.read(workspaceProvider.notifier);
  final focused = focus.focusedTabId;
  if (focused != null && notifier.tabById(focused) is ExplorerTab) {
    return focused;
  }
  final last = focus.lastExplorerTabId;
  if (last != null && notifier.tabById(last) is ExplorerTab) {
    return last;
  }
  return null;
}

ExplorerViewModel? _explorerVm(WidgetRef ref) {
  final id = _focusedExplorerTabId(ref);
  return id == null ? null : ref.read(explorerViewModelProvider(id).notifier);
}

GitViewModel? _gitVm(WidgetRef ref) {
  final tabId = ref.read(focusedTabProvider).focusedTabId;
  if (tabId == null) {
    return null;
  }
  if (ref.read(workspaceProvider.notifier).tabById(tabId) is! GitTab) {
    return null;
  }
  return ref.read(gitViewModelProvider(tabId).notifier);
}

/// フォーカス中エクスプローラタブのカレントディレクトリに対して [action]。
void _inExplorerDir(
  WidgetRef ref,
  void Function(BuildContext context, String tabId, String dir) action,
) {
  final tabId = _focusedExplorerTabId(ref);
  if (tabId == null) {
    return;
  }
  final dir = ref.read(explorerViewModelProvider(tabId)).currentPath;
  final context = rootNavigatorKey.currentContext;
  if (context == null) {
    return;
  }
  action(context, tabId, dir);
}

/// フォーカス中エクスプローラタブの選択中アイテムに対して [action]。
/// 選択が無ければ何もしない。
void _onSelection(
  WidgetRef ref,
  void Function(BuildContext context, String tabId, String selectedPath) action,
) {
  final tabId = _focusedExplorerTabId(ref);
  if (tabId == null) {
    return;
  }
  final selectedPath = ref.read(explorerItemSelectionProvider(tabId)).primary;
  if (selectedPath == null) {
    return;
  }
  final context = rootNavigatorKey.currentContext;
  if (context == null) {
    return;
  }
  action(context, tabId, selectedPath);
}

/// 「ここで開く」系の対象ディレクトリに対して [action]。選択中アイテムが
/// ディレクトリならそれを、そうでなければカレントディレクトリを対象にする。
void _onExplorerTargetDir(WidgetRef ref, void Function(String dir) action) {
  final tabId = _focusedExplorerTabId(ref);
  if (tabId == null) {
    return;
  }
  final selectedPath = ref.read(explorerItemSelectionProvider(tabId)).primary;
  final dir = (selectedPath != null && Directory(selectedPath).existsSync())
      ? selectedPath
      : ref.read(explorerViewModelProvider(tabId)).currentPath;
  action(dir);
}

/// 同一ペイン内でアクティブタブを [delta] 個ずらす（端は巻き戻す）。
void _cycleTab(WidgetRef ref, int delta) {
  final tabId = ref.read(focusedTabProvider).focusedTabId;
  if (tabId == null) {
    return;
  }
  final layout = ref.read(workspaceProvider);
  for (final slotId in PaneSlotId.values) {
    final slot = layout.slot(slotId);
    final index = slot.tabs.indexWhere((tab) => tab.id == tabId);
    if (index < 0) {
      continue;
    }
    if (slot.tabs.length < 2) {
      return;
    }
    final raw = (index + delta) % slot.tabs.length;
    final next = raw < 0 ? raw + slot.tabs.length : raw;
    ref.read(workspaceProvider.notifier).activateTab(slot.tabs[next].id);
    return;
  }
}

/// フォーカス中タブを [target] ペインの末尾へ移動する。
void _moveFocusedTab(WidgetRef ref, PaneSlotId target) {
  final tabId = ref.read(focusedTabProvider).focusedTabId;
  if (tabId == null) {
    return;
  }
  final gapIndex = ref.read(workspaceProvider).slot(target).tabs.length;
  ref.read(workspaceProvider.notifier).moveTab(tabId, target, gapIndex);
}
