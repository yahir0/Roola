// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explorer_item_selection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// エクスプローラタブごとに「いま選択中の 1 アイテム」の絶対パスを保持する
/// Notifier（`family(tabId)` / ADR-0027）。
///
/// 操作モデル（ADR-0021）: シングルクリックで選択（このパスをセット）、
/// ダブルクリックで遷移／オープン、選択中に `C` キー連打で選択パスを
/// クリップボードへコピー。
///
/// 永続化は不要。別ディレクトリへ navigate したタイミングでクリアする運用
/// （呼び出し側で `clear` または `select(null)`）。タブを閉じたときは
/// `Workspace.closeTab` から明示 invalidate される。

@ProviderFor(ExplorerItemSelection)
final explorerItemSelectionProvider = ExplorerItemSelectionFamily._();

/// エクスプローラタブごとに「いま選択中の 1 アイテム」の絶対パスを保持する
/// Notifier（`family(tabId)` / ADR-0027）。
///
/// 操作モデル（ADR-0021）: シングルクリックで選択（このパスをセット）、
/// ダブルクリックで遷移／オープン、選択中に `C` キー連打で選択パスを
/// クリップボードへコピー。
///
/// 永続化は不要。別ディレクトリへ navigate したタイミングでクリアする運用
/// （呼び出し側で `clear` または `select(null)`）。タブを閉じたときは
/// `Workspace.closeTab` から明示 invalidate される。
final class ExplorerItemSelectionProvider
    extends $NotifierProvider<ExplorerItemSelection, String?> {
  /// エクスプローラタブごとに「いま選択中の 1 アイテム」の絶対パスを保持する
  /// Notifier（`family(tabId)` / ADR-0027）。
  ///
  /// 操作モデル（ADR-0021）: シングルクリックで選択（このパスをセット）、
  /// ダブルクリックで遷移／オープン、選択中に `C` キー連打で選択パスを
  /// クリップボードへコピー。
  ///
  /// 永続化は不要。別ディレクトリへ navigate したタイミングでクリアする運用
  /// （呼び出し側で `clear` または `select(null)`）。タブを閉じたときは
  /// `Workspace.closeTab` から明示 invalidate される。
  ExplorerItemSelectionProvider._({
    required ExplorerItemSelectionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'explorerItemSelectionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$explorerItemSelectionHash();

  @override
  String toString() {
    return r'explorerItemSelectionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ExplorerItemSelection create() => ExplorerItemSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ExplorerItemSelectionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$explorerItemSelectionHash() =>
    r'01f52c9778c4129f9e9de5570618bb58b8634e1f';

/// エクスプローラタブごとに「いま選択中の 1 アイテム」の絶対パスを保持する
/// Notifier（`family(tabId)` / ADR-0027）。
///
/// 操作モデル（ADR-0021）: シングルクリックで選択（このパスをセット）、
/// ダブルクリックで遷移／オープン、選択中に `C` キー連打で選択パスを
/// クリップボードへコピー。
///
/// 永続化は不要。別ディレクトリへ navigate したタイミングでクリアする運用
/// （呼び出し側で `clear` または `select(null)`）。タブを閉じたときは
/// `Workspace.closeTab` から明示 invalidate される。

final class ExplorerItemSelectionFamily extends $Family
    with
        $ClassFamilyOverride<
          ExplorerItemSelection,
          String?,
          String?,
          String?,
          String
        > {
  ExplorerItemSelectionFamily._()
    : super(
        retry: null,
        name: r'explorerItemSelectionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// エクスプローラタブごとに「いま選択中の 1 アイテム」の絶対パスを保持する
  /// Notifier（`family(tabId)` / ADR-0027）。
  ///
  /// 操作モデル（ADR-0021）: シングルクリックで選択（このパスをセット）、
  /// ダブルクリックで遷移／オープン、選択中に `C` キー連打で選択パスを
  /// クリップボードへコピー。
  ///
  /// 永続化は不要。別ディレクトリへ navigate したタイミングでクリアする運用
  /// （呼び出し側で `clear` または `select(null)`）。タブを閉じたときは
  /// `Workspace.closeTab` から明示 invalidate される。

  ExplorerItemSelectionProvider call(String tabId) =>
      ExplorerItemSelectionProvider._(argument: tabId, from: this);

  @override
  String toString() => r'explorerItemSelectionProvider';
}

/// エクスプローラタブごとに「いま選択中の 1 アイテム」の絶対パスを保持する
/// Notifier（`family(tabId)` / ADR-0027）。
///
/// 操作モデル（ADR-0021）: シングルクリックで選択（このパスをセット）、
/// ダブルクリックで遷移／オープン、選択中に `C` キー連打で選択パスを
/// クリップボードへコピー。
///
/// 永続化は不要。別ディレクトリへ navigate したタイミングでクリアする運用
/// （呼び出し側で `clear` または `select(null)`）。タブを閉じたときは
/// `Workspace.closeTab` から明示 invalidate される。

abstract class _$ExplorerItemSelection extends $Notifier<String?> {
  late final _$args = ref.$arg as String;
  String get tabId => _$args;

  String? build(String tabId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
