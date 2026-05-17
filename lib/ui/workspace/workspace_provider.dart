import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:roola/data/skill_session/active_sessions.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_repository_impl.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/explorer/explorer_item_selection.dart';
import 'package:roola/ui/explorer/explorer_view_model.dart';
import 'package:roola/ui/git/git_view_model.dart';
import 'package:roola/ui/run/adhoc_run_view_model.dart';
import 'package:roola/ui/workspace/workspace_seed.dart';

part 'workspace_provider.g.dart';

/// ワークスペースのレイアウト（3 ペインスロット × タブ群）の単一の真実。
///
/// タブの生成 / 閉じる / アクティブ化 / 移動とスプリッタ比率を一手に扱う
/// （ADR-0026）。タブを閉じた / 移動した際の per-tab family プロバイダの
/// 破棄もここに集約する（ADR-0027）。
@Riverpod(keepAlive: true)
class Workspace extends _$Workspace {
  @override
  WorkspaceLayout build() => ref.read(workspaceInitialLayoutProvider);

  /// state を差し替え、新しいレイアウトを `workspace.json` に永続化する。
  ///
  /// タブ開閉 / アクティブ変更 / navigateTo（updateTabPath）/ スプリッタ
  /// 比率変更のすべての変更経路はここを通る（ADR-0028）。永続化は
  /// fire-and-forget で、失敗してもアプリは継続する。
  void _apply(WorkspaceLayout next) {
    state = next;
    unawaited(_persist(next));
  }

  Future<void> _persist(WorkspaceLayout layout) async {
    try {
      await ref.read(workspaceRepositoryProvider).save(layout);
    } on Object {
      // 永続化失敗はアプリを落とすほどではない（ADR-0028）。握り潰す。
    }
  }

  /// id 一致のタブを返す。見つからなければ `null`。
  WorkspaceTab? tabById(String tabId) {
    for (final slotId in PaneSlotId.values) {
      for (final tab in state.slot(slotId).tabs) {
        if (tab.id == tabId) {
          return tab;
        }
      }
    }
    return null;
  }

  /// 新しいエクスプローラタブを指定スロットに追加し、アクティブにする。
  /// 追加したタブの id を返す。
  String addExplorerTab(PaneSlotId slotId, {String? path}) {
    final tab = WorkspaceTab.explorer(
      id: newTabId(),
      currentPath: path ?? defaultWorkspaceHome(),
    );
    _appendTab(slotId, tab);
    return tab.id;
  }

  /// 新しいターミナルタブを指定スロットに追加し、アクティブにする。
  /// [args] 省略時は $HOME の素のシェル。追加したタブの id を返す。
  String addTerminalTab(PaneSlotId slotId, {AdhocRunArgs? args}) {
    final tab = WorkspaceTab.terminal(
      id: newTabId(),
      args: args ?? defaultTerminalArgs(),
    );
    _appendTab(slotId, tab);
    return tab.id;
  }

  /// 指定リポジトリの Git ビュータブを開く（ADR-0030）。
  ///
  /// 同一 `repoRoot` の [GitTab] が既に存在する場合は新規生成せず、その
  /// タブをアクティブにする。新規の場合は右上ペインに追加する。
  void openGitTab(String repoRoot) {
    for (final slotId in PaneSlotId.values) {
      for (final tab in state.slot(slotId).tabs) {
        if (tab is GitTab && tab.repoRoot == repoRoot) {
          activateTab(tab.id);
          return;
        }
      }
    }
    _appendTab(
      PaneSlotId.topRight,
      WorkspaceTab.git(id: newTabId(), repoRoot: repoRoot),
    );
  }

  void _appendTab(PaneSlotId slotId, WorkspaceTab tab) {
    final slot = state.slot(slotId);
    final tabs = [...slot.tabs, tab];
    _apply(
      state.withSlot(
        slotId,
        slot.copyWith(tabs: tabs, activeIndex: tabs.length - 1),
      ),
    );
  }

  /// id 一致のタブをアクティブにする。
  void activateTab(String tabId) {
    final loc = _locate(tabId);
    if (loc == null) {
      return;
    }
    final (slotId, index) = loc;
    _apply(
      state.withSlot(slotId, state.slot(slotId).copyWith(activeIndex: index)),
    );
  }

  /// id 一致のタブを閉じる。対応する per-tab 状態（エクスプローラ履歴 /
  /// ターミナルセッション）を破棄し、スロットが空になれば崩し再フローに
  /// 委ねる。全タブが消えた場合は $HOME のエクスプローラタブを seed する。
  void closeTab(String tabId) {
    final loc = _locate(tabId);
    if (loc == null) {
      return;
    }
    final (slotId, index) = loc;
    final slot = state.slot(slotId);
    final closing = slot.tabs[index];
    final tabs = [...slot.tabs]..removeAt(index);
    _apply(
      state.withSlot(
        slotId,
        slot.copyWith(
          tabs: tabs,
          activeIndex: tabs.isEmpty ? 0 : index.clamp(0, tabs.length - 1),
        ),
      ),
    );
    _disposeTab(closing);
    _ensureNotEmpty();
  }

  /// タブを別の位置へ移動する。同一スロット内の並べ替えとペイン間移動を
  /// 統一的に扱う（DnD のドロップから呼ばれる）。
  ///
  /// [gapIndex] は「移動前のタブ列におけるギャップ位置」（0..n）。タブ
  /// ストリップのタブ間 / 両端のドロップ受け口がそのまま渡せる。
  /// per-tab family は tabId キーのままなので状態は無損失で引き継がれる。
  void moveTab(String tabId, PaneSlotId toSlotId, int gapIndex) {
    final loc = _locate(tabId);
    if (loc == null) {
      return;
    }
    final (fromSlotId, fromIndex) = loc;

    // 同一スロットで自分の隣のギャップへの drop は no-op。
    if (fromSlotId == toSlotId &&
        (gapIndex == fromIndex || gapIndex == fromIndex + 1)) {
      return;
    }

    final tab = state.slot(fromSlotId).tabs[fromIndex];

    // まず元スロットから除去する。
    final fromSlot = state.slot(fromSlotId);
    final fromTabs = [...fromSlot.tabs]..removeAt(fromIndex);
    var layout = state.withSlot(
      fromSlotId,
      fromSlot.copyWith(
        tabs: fromTabs,
        activeIndex: fromTabs.isEmpty
            ? 0
            : fromSlot.activeIndex.clamp(0, fromTabs.length - 1),
      ),
    );

    // 移動先へ挿入する。同一スロット移動でドラッグ元より後ろのギャップを
    // 指していた場合、除去によって 1 つ詰まるので挿入位置を補正する。
    final insertAt = (fromSlotId == toSlotId && fromIndex < gapIndex)
        ? gapIndex - 1
        : gapIndex;
    final toSlot = layout.slot(toSlotId);
    final toTabs = [...toSlot.tabs];
    final at = insertAt.clamp(0, toTabs.length);
    toTabs.insert(at, tab);
    layout = layout.withSlot(
      toSlotId,
      toSlot.copyWith(tabs: toTabs, activeIndex: at),
    );
    _apply(layout);
  }

  /// エクスプローラタブのカレントパスを更新する（永続化用 / ADR-0028）。
  /// `ExplorerViewModel.navigateTo` などから呼ばれる。
  void updateTabPath(String tabId, String path) {
    final loc = _locate(tabId);
    if (loc == null) {
      return;
    }
    final (slotId, index) = loc;
    final slot = state.slot(slotId);
    final tab = slot.tabs[index];
    if (tab is! ExplorerTab || tab.currentPath == path) {
      return;
    }
    final tabs = [...slot.tabs];
    tabs[index] = tab.copyWith(currentPath: path);
    _apply(state.withSlot(slotId, slot.copyWith(tabs: tabs)));
  }

  /// 上下スプリッタの比率を更新する（上段の高さ比率）。
  void setTopRatio(double ratio) {
    _apply(state.copyWith(topRatio: ratio.clamp(0.15, 0.85)));
  }

  /// 上段左右スプリッタの比率を更新する（`topLeft` の幅比率）。
  void setLeftRatio(double ratio) {
    _apply(state.copyWith(leftRatio: ratio.clamp(0.15, 0.85)));
  }

  /// 全スロットが空になったら $HOME のエクスプローラタブを 1 つ seed する。
  void _ensureNotEmpty() {
    if (state.nonEmptySlots.isNotEmpty) {
      return;
    }
    addExplorerTab(PaneSlotId.topLeft);
  }

  /// 閉じたタブの per-tab family プロバイダを破棄する。
  void _disposeTab(WorkspaceTab tab) {
    switch (tab) {
      case ExplorerTab():
        ref.invalidate(explorerViewModelProvider(tab.id));
        ref.invalidate(explorerItemSelectionProvider(tab.id));
      case GitTab():
        ref.invalidate(gitViewModelProvider(tab.id));
      case TerminalTab(:final args):
        ref.read(activeSessionsProvider.notifier).unregister(args.adhocId);
        // adhocRunViewModelProvider は keepAlive。state からタブを除去した
        // 直後の同期実行内ではまだ IndexedStack の SessionView が mount
        // されており、listener が残っている。この状態で invalidate すると
        // provider は dispose されず rebuild され、build() が新しい PTY を
        // spawn してしまう（閉じたターミナルが再出現する）。SessionView が
        // unmount する次フレーム後に invalidate して確実に dispose させる。
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ref.invalidate(adhocRunViewModelProvider(args));
        });
    }
  }

  /// tabId が属するスロットと、そのスロット内インデックスを返す。
  (PaneSlotId, int)? _locate(String tabId) {
    for (final slotId in PaneSlotId.values) {
      final index = state.slot(slotId).tabs.indexWhere((t) => t.id == tabId);
      if (index >= 0) {
        return (slotId, index);
      }
    }
    return null;
  }
}
