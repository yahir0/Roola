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
/// `enter` / `goUp` でカレントパスを切り替え、その都度直下を再ロードする。
/// `changeRoot` ではルート自体を永続化したうえでカレントも合わせて更新する。

@ProviderFor(ExplorerViewModel)
final explorerViewModelProvider = ExplorerViewModelProvider._();

/// エクスプローラの ViewModel。
///
/// ルートディレクトリは `explorerSettingsProvider` を購読して取得する。
/// `enter` / `goUp` でカレントパスを切り替え、その都度直下を再ロードする。
/// `changeRoot` ではルート自体を永続化したうえでカレントも合わせて更新する。
final class ExplorerViewModelProvider
    extends $NotifierProvider<ExplorerViewModel, ExplorerState> {
  /// エクスプローラの ViewModel。
  ///
  /// ルートディレクトリは `explorerSettingsProvider` を購読して取得する。
  /// `enter` / `goUp` でカレントパスを切り替え、その都度直下を再ロードする。
  /// `changeRoot` ではルート自体を永続化したうえでカレントも合わせて更新する。
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

String _$explorerViewModelHash() => r'ff1ba06f3bb2eaed7fc8e0f7c62d37aef8e79216';

/// エクスプローラの ViewModel。
///
/// ルートディレクトリは `explorerSettingsProvider` を購読して取得する。
/// `enter` / `goUp` でカレントパスを切り替え、その都度直下を再ロードする。
/// `changeRoot` ではルート自体を永続化したうえでカレントも合わせて更新する。

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
