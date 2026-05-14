// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explorer_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// エクスプローラの ViewModel。
///
/// ルートディレクトリは `explorerSettingsProvider` を購読して取得する。
/// `navigateTo` で任意の絶対パスに移動し、その都度直下を再ロードする。
/// `changeRoot` ではルート自体を永続化したうえでカレントも合わせて更新する。
///
/// マウスのサイドボタン（戻る / 進む）でブラウザのような履歴ナビゲーション
/// ができるよう、訪問パスを `_history` に保持し、`_historyCursor` で現在
/// 位置を指す。`navigateTo` は cursor 以降の forward 履歴を破棄して新しい
/// パスを末尾に積む。`goBack` / `goForward` は cursor を上下させるだけで
/// 履歴自体は変更しない。

@ProviderFor(ExplorerViewModel)
final explorerViewModelProvider = ExplorerViewModelProvider._();

/// エクスプローラの ViewModel。
///
/// ルートディレクトリは `explorerSettingsProvider` を購読して取得する。
/// `navigateTo` で任意の絶対パスに移動し、その都度直下を再ロードする。
/// `changeRoot` ではルート自体を永続化したうえでカレントも合わせて更新する。
///
/// マウスのサイドボタン（戻る / 進む）でブラウザのような履歴ナビゲーション
/// ができるよう、訪問パスを `_history` に保持し、`_historyCursor` で現在
/// 位置を指す。`navigateTo` は cursor 以降の forward 履歴を破棄して新しい
/// パスを末尾に積む。`goBack` / `goForward` は cursor を上下させるだけで
/// 履歴自体は変更しない。
final class ExplorerViewModelProvider
    extends $NotifierProvider<ExplorerViewModel, ExplorerState> {
  /// エクスプローラの ViewModel。
  ///
  /// ルートディレクトリは `explorerSettingsProvider` を購読して取得する。
  /// `navigateTo` で任意の絶対パスに移動し、その都度直下を再ロードする。
  /// `changeRoot` ではルート自体を永続化したうえでカレントも合わせて更新する。
  ///
  /// マウスのサイドボタン（戻る / 進む）でブラウザのような履歴ナビゲーション
  /// ができるよう、訪問パスを `_history` に保持し、`_historyCursor` で現在
  /// 位置を指す。`navigateTo` は cursor 以降の forward 履歴を破棄して新しい
  /// パスを末尾に積む。`goBack` / `goForward` は cursor を上下させるだけで
  /// 履歴自体は変更しない。
  ExplorerViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'explorerViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$explorerViewModelHash();

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
}

String _$explorerViewModelHash() => r'8b34ed6fe0ebff2463b768156492a339fe469722';

/// エクスプローラの ViewModel。
///
/// ルートディレクトリは `explorerSettingsProvider` を購読して取得する。
/// `navigateTo` で任意の絶対パスに移動し、その都度直下を再ロードする。
/// `changeRoot` ではルート自体を永続化したうえでカレントも合わせて更新する。
///
/// マウスのサイドボタン（戻る / 進む）でブラウザのような履歴ナビゲーション
/// ができるよう、訪問パスを `_history` に保持し、`_historyCursor` で現在
/// 位置を指す。`navigateTo` は cursor 以降の forward 履歴を破棄して新しい
/// パスを末尾に積む。`goBack` / `goForward` は cursor を上下させるだけで
/// 履歴自体は変更しない。

abstract class _$ExplorerViewModel extends $Notifier<ExplorerState> {
  ExplorerState build();
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
    element.handleCreate(ref, build);
  }
}
