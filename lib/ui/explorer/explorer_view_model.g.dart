// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explorer_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// エクスプローラタブの ViewModel（`family(tabId)` / ADR-0027）。
///
/// 初期パスは `workspaceProvider` のタブ状態から `ref.read` で 1 度だけ取得
/// する（watch しない＝起動ディレクトリ変更で全タブがリセットされない）。
/// `navigateTo` で任意の絶対パスに移動し、その都度直下を再ロードして
/// `workspaceProvider.updateTabPath` でカレントパスを永続化用に反映する。
///
/// マウスのサイドボタン（戻る / 進む）でブラウザのような履歴ナビゲーション
/// ができるよう、訪問パスを `_history` に保持し、`_historyCursor` で現在
/// 位置を指す。`navigateTo` は cursor 以降の forward 履歴を破棄して新しい
/// パスを末尾に積む。`goBack` / `goForward` は cursor を上下させるだけで
/// 履歴自体は変更しない。
///
/// `keepAlive` のため、タブを別ペインへ DnD 移動しても履歴は保持される。
/// 破棄はタブを閉じたときに `Workspace.closeTab` から明示 invalidate する。

@ProviderFor(ExplorerViewModel)
final explorerViewModelProvider = ExplorerViewModelFamily._();

/// エクスプローラタブの ViewModel（`family(tabId)` / ADR-0027）。
///
/// 初期パスは `workspaceProvider` のタブ状態から `ref.read` で 1 度だけ取得
/// する（watch しない＝起動ディレクトリ変更で全タブがリセットされない）。
/// `navigateTo` で任意の絶対パスに移動し、その都度直下を再ロードして
/// `workspaceProvider.updateTabPath` でカレントパスを永続化用に反映する。
///
/// マウスのサイドボタン（戻る / 進む）でブラウザのような履歴ナビゲーション
/// ができるよう、訪問パスを `_history` に保持し、`_historyCursor` で現在
/// 位置を指す。`navigateTo` は cursor 以降の forward 履歴を破棄して新しい
/// パスを末尾に積む。`goBack` / `goForward` は cursor を上下させるだけで
/// 履歴自体は変更しない。
///
/// `keepAlive` のため、タブを別ペインへ DnD 移動しても履歴は保持される。
/// 破棄はタブを閉じたときに `Workspace.closeTab` から明示 invalidate する。
final class ExplorerViewModelProvider
    extends $NotifierProvider<ExplorerViewModel, ExplorerState> {
  /// エクスプローラタブの ViewModel（`family(tabId)` / ADR-0027）。
  ///
  /// 初期パスは `workspaceProvider` のタブ状態から `ref.read` で 1 度だけ取得
  /// する（watch しない＝起動ディレクトリ変更で全タブがリセットされない）。
  /// `navigateTo` で任意の絶対パスに移動し、その都度直下を再ロードして
  /// `workspaceProvider.updateTabPath` でカレントパスを永続化用に反映する。
  ///
  /// マウスのサイドボタン（戻る / 進む）でブラウザのような履歴ナビゲーション
  /// ができるよう、訪問パスを `_history` に保持し、`_historyCursor` で現在
  /// 位置を指す。`navigateTo` は cursor 以降の forward 履歴を破棄して新しい
  /// パスを末尾に積む。`goBack` / `goForward` は cursor を上下させるだけで
  /// 履歴自体は変更しない。
  ///
  /// `keepAlive` のため、タブを別ペインへ DnD 移動しても履歴は保持される。
  /// 破棄はタブを閉じたときに `Workspace.closeTab` から明示 invalidate する。
  ExplorerViewModelProvider._({
    required ExplorerViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'explorerViewModelProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$explorerViewModelHash();

  @override
  String toString() {
    return r'explorerViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ExplorerViewModel create() => ExplorerViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExplorerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExplorerState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ExplorerViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$explorerViewModelHash() => r'fd9e5578620b640d130de39d85e9748660f676c9';

/// エクスプローラタブの ViewModel（`family(tabId)` / ADR-0027）。
///
/// 初期パスは `workspaceProvider` のタブ状態から `ref.read` で 1 度だけ取得
/// する（watch しない＝起動ディレクトリ変更で全タブがリセットされない）。
/// `navigateTo` で任意の絶対パスに移動し、その都度直下を再ロードして
/// `workspaceProvider.updateTabPath` でカレントパスを永続化用に反映する。
///
/// マウスのサイドボタン（戻る / 進む）でブラウザのような履歴ナビゲーション
/// ができるよう、訪問パスを `_history` に保持し、`_historyCursor` で現在
/// 位置を指す。`navigateTo` は cursor 以降の forward 履歴を破棄して新しい
/// パスを末尾に積む。`goBack` / `goForward` は cursor を上下させるだけで
/// 履歴自体は変更しない。
///
/// `keepAlive` のため、タブを別ペインへ DnD 移動しても履歴は保持される。
/// 破棄はタブを閉じたときに `Workspace.closeTab` から明示 invalidate する。

final class ExplorerViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ExplorerViewModel,
          ExplorerState,
          ExplorerState,
          ExplorerState,
          String
        > {
  ExplorerViewModelFamily._()
    : super(
        retry: null,
        name: r'explorerViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// エクスプローラタブの ViewModel（`family(tabId)` / ADR-0027）。
  ///
  /// 初期パスは `workspaceProvider` のタブ状態から `ref.read` で 1 度だけ取得
  /// する（watch しない＝起動ディレクトリ変更で全タブがリセットされない）。
  /// `navigateTo` で任意の絶対パスに移動し、その都度直下を再ロードして
  /// `workspaceProvider.updateTabPath` でカレントパスを永続化用に反映する。
  ///
  /// マウスのサイドボタン（戻る / 進む）でブラウザのような履歴ナビゲーション
  /// ができるよう、訪問パスを `_history` に保持し、`_historyCursor` で現在
  /// 位置を指す。`navigateTo` は cursor 以降の forward 履歴を破棄して新しい
  /// パスを末尾に積む。`goBack` / `goForward` は cursor を上下させるだけで
  /// 履歴自体は変更しない。
  ///
  /// `keepAlive` のため、タブを別ペインへ DnD 移動しても履歴は保持される。
  /// 破棄はタブを閉じたときに `Workspace.closeTab` から明示 invalidate する。

  ExplorerViewModelProvider call(String tabId) =>
      ExplorerViewModelProvider._(argument: tabId, from: this);

  @override
  String toString() => r'explorerViewModelProvider';
}

/// エクスプローラタブの ViewModel（`family(tabId)` / ADR-0027）。
///
/// 初期パスは `workspaceProvider` のタブ状態から `ref.read` で 1 度だけ取得
/// する（watch しない＝起動ディレクトリ変更で全タブがリセットされない）。
/// `navigateTo` で任意の絶対パスに移動し、その都度直下を再ロードして
/// `workspaceProvider.updateTabPath` でカレントパスを永続化用に反映する。
///
/// マウスのサイドボタン（戻る / 進む）でブラウザのような履歴ナビゲーション
/// ができるよう、訪問パスを `_history` に保持し、`_historyCursor` で現在
/// 位置を指す。`navigateTo` は cursor 以降の forward 履歴を破棄して新しい
/// パスを末尾に積む。`goBack` / `goForward` は cursor を上下させるだけで
/// 履歴自体は変更しない。
///
/// `keepAlive` のため、タブを別ペインへ DnD 移動しても履歴は保持される。
/// 破棄はタブを閉じたときに `Workspace.closeTab` から明示 invalidate する。

abstract class _$ExplorerViewModel extends $Notifier<ExplorerState> {
  late final _$args = ref.$arg as String;
  String get tabId => _$args;

  ExplorerState build(String tabId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ExplorerState, ExplorerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExplorerState, ExplorerState>,
              ExplorerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
