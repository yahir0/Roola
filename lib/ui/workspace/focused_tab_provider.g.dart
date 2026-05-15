// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focused_tab_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// フォーカス中タブを保持する Notifier。各ペイン body 最上位の操作検出から
/// `focusExplorer` / `focusTerminal` が呼ばれる。

@ProviderFor(FocusedTab)
final focusedTabProvider = FocusedTabProvider._();

/// フォーカス中タブを保持する Notifier。各ペイン body 最上位の操作検出から
/// `focusExplorer` / `focusTerminal` が呼ばれる。
final class FocusedTabProvider
    extends $NotifierProvider<FocusedTab, FocusedTabState> {
  /// フォーカス中タブを保持する Notifier。各ペイン body 最上位の操作検出から
  /// `focusExplorer` / `focusTerminal` が呼ばれる。
  FocusedTabProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusedTabProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusedTabHash();

  @$internal
  @override
  FocusedTab create() => FocusedTab();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FocusedTabState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FocusedTabState>(value),
    );
  }
}

String _$focusedTabHash() => r'0f4deae17d576749a1662c3a2e336b5654fa6df6';

/// フォーカス中タブを保持する Notifier。各ペイン body 最上位の操作検出から
/// `focusExplorer` / `focusTerminal` が呼ばれる。

abstract class _$FocusedTab extends $Notifier<FocusedTabState> {
  FocusedTabState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FocusedTabState, FocusedTabState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FocusedTabState, FocusedTabState>,
              FocusedTabState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
