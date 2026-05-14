// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explorer_selection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// エクスプローラの現在 selection を保持する Notifier。`keepAlive: true`
/// のため、画面 widget が rebuild しても state は失われない。
///
/// 初期値はディレクトリビューで `rootPath`（未設定なら `$HOME`）を指す。
/// `rootPath` は ADR-0015 で「起動時の開始位置」のみを意味するように
/// なったので、selection は起動後に自由に書き換わる。

@ProviderFor(ExplorerSelectionNotifier)
final explorerSelectionProvider = ExplorerSelectionNotifierProvider._();

/// エクスプローラの現在 selection を保持する Notifier。`keepAlive: true`
/// のため、画面 widget が rebuild しても state は失われない。
///
/// 初期値はディレクトリビューで `rootPath`（未設定なら `$HOME`）を指す。
/// `rootPath` は ADR-0015 で「起動時の開始位置」のみを意味するように
/// なったので、selection は起動後に自由に書き換わる。
final class ExplorerSelectionNotifierProvider
    extends $NotifierProvider<ExplorerSelectionNotifier, ExplorerSelection> {
  /// エクスプローラの現在 selection を保持する Notifier。`keepAlive: true`
  /// のため、画面 widget が rebuild しても state は失われない。
  ///
  /// 初期値はディレクトリビューで `rootPath`（未設定なら `$HOME`）を指す。
  /// `rootPath` は ADR-0015 で「起動時の開始位置」のみを意味するように
  /// なったので、selection は起動後に自由に書き換わる。
  ExplorerSelectionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'explorerSelectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$explorerSelectionNotifierHash();

  @$internal
  @override
  ExplorerSelectionNotifier create() => ExplorerSelectionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExplorerSelection value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExplorerSelection>(value),
    );
  }
}

String _$explorerSelectionNotifierHash() =>
    r'9e08ec54673e42239265ecb38eb946a1ddbe3abf';

/// エクスプローラの現在 selection を保持する Notifier。`keepAlive: true`
/// のため、画面 widget が rebuild しても state は失われない。
///
/// 初期値はディレクトリビューで `rootPath`（未設定なら `$HOME`）を指す。
/// `rootPath` は ADR-0015 で「起動時の開始位置」のみを意味するように
/// なったので、selection は起動後に自由に書き換わる。

abstract class _$ExplorerSelectionNotifier
    extends $Notifier<ExplorerSelection> {
  ExplorerSelection build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ExplorerSelection, ExplorerSelection>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExplorerSelection, ExplorerSelection>,
              ExplorerSelection,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
