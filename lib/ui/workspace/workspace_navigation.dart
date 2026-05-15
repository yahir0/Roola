import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/explorer/explorer_view_model.dart';
import 'package:roola/ui/workspace/focused_tab_provider.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';

/// 最後にフォーカスされたエクスプローラタブを返す。無ければ `null`。
ExplorerTab? focusedExplorerTab(WidgetRef ref) {
  final focusedId = ref.read(focusedTabProvider).lastExplorerTabId;
  final tab = ref.read(workspaceProvider).tabById(focusedId);
  return tab is ExplorerTab ? tab : null;
}

/// フォーカス中のエクスプローラタブで [path] へ移動する。
///
/// エクスプローラタブが 1 つも無ければ `topLeft` に新規エクスプローラタブを
/// 作ってそのパスを開く（ADR-0026 design Decision 4 / spec explorer-tab）。
void navigateInFocusedExplorer(WidgetRef ref, String path) {
  final tab = focusedExplorerTab(ref);
  if (tab != null) {
    ref.read(explorerViewModelProvider(tab.id).notifier).navigateTo(path);
  } else {
    ref
        .read(workspaceProvider.notifier)
        .addExplorerTab(PaneSlotId.topLeft, path: path);
  }
}

/// フォーカス中のエクスプローラタブで履歴を 1 つ戻る。
void goBackInFocusedExplorer(WidgetRef ref) {
  final tab = focusedExplorerTab(ref);
  if (tab != null) {
    ref.read(explorerViewModelProvider(tab.id).notifier).goBack();
  }
}

/// フォーカス中のエクスプローラタブで履歴を 1 つ進む。
void goForwardInFocusedExplorer(WidgetRef ref) {
  final tab = focusedExplorerTab(ref);
  if (tab != null) {
    ref.read(explorerViewModelProvider(tab.id).notifier).goForward();
  }
}
