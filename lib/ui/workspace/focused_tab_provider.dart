import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'focused_tab_provider.g.dart';

/// 最後にフォーカスされたタブの追跡状態。
///
/// [focusedTabId] は直近でフォーカスされた任意種別のタブ。
/// [lastExplorerTabId] は直近でフォーカスされた「エクスプローラ種別」タブ。
/// サイドバーの場所 / お気に入りクリックや「現在のディレクトリを登録」は、
/// ターミナルタブにフォーカスがあっても遷移先を決められるよう
/// [lastExplorerTabId] を参照する（ADR-0026 design Decision 4）。
class FocusedTabState {
  const FocusedTabState({this.focusedTabId, this.lastExplorerTabId});

  final String? focusedTabId;
  final String? lastExplorerTabId;
}

/// フォーカス中タブを保持する Notifier。各ペイン body 最上位の操作検出から
/// `focusExplorer` / `focusTerminal` が呼ばれる。
@Riverpod(keepAlive: true)
class FocusedTab extends _$FocusedTab {
  @override
  FocusedTabState build() => const FocusedTabState();

  /// エクスプローラタブにフォーカスが入ったことを記録する。
  void focusExplorer(String tabId) {
    state = FocusedTabState(focusedTabId: tabId, lastExplorerTabId: tabId);
  }

  /// ターミナルタブにフォーカスが入ったことを記録する。
  /// `lastExplorerTabId` は据え置く。
  void focusTerminal(String tabId) {
    state = FocusedTabState(
      focusedTabId: tabId,
      lastExplorerTabId: state.lastExplorerTabId,
    );
  }
}
