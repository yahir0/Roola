// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explorer_item_selection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// エクスプローラタブごとに選択状態を保持する Notifier
/// （`family(tabId)` / ADR-0027）。
///
/// 操作モデル（ADR-0021 / ADR-0038 D12）: シングルクリックで単一選択、
/// ⌘+クリックで選択へ加除（主選択はクリックした行へ移る）、ダブルクリックで
/// 遷移／オープン。
///
/// 永続化は不要。別ディレクトリへ navigate したタイミングでクリアする運用
/// （呼び出し側で [clear]）。タブを閉じたときは `Workspace.closeTab` から
/// 明示 invalidate される。

@ProviderFor(ExplorerItemSelection)
final explorerItemSelectionProvider = ExplorerItemSelectionFamily._();

/// エクスプローラタブごとに選択状態を保持する Notifier
/// （`family(tabId)` / ADR-0027）。
///
/// 操作モデル（ADR-0021 / ADR-0038 D12）: シングルクリックで単一選択、
/// ⌘+クリックで選択へ加除（主選択はクリックした行へ移る）、ダブルクリックで
/// 遷移／オープン。
///
/// 永続化は不要。別ディレクトリへ navigate したタイミングでクリアする運用
/// （呼び出し側で [clear]）。タブを閉じたときは `Workspace.closeTab` から
/// 明示 invalidate される。
final class ExplorerItemSelectionProvider
    extends $NotifierProvider<ExplorerItemSelection, ExplorerSelection> {
  /// エクスプローラタブごとに選択状態を保持する Notifier
  /// （`family(tabId)` / ADR-0027）。
  ///
  /// 操作モデル（ADR-0021 / ADR-0038 D12）: シングルクリックで単一選択、
  /// ⌘+クリックで選択へ加除（主選択はクリックした行へ移る）、ダブルクリックで
  /// 遷移／オープン。
  ///
  /// 永続化は不要。別ディレクトリへ navigate したタイミングでクリアする運用
  /// （呼び出し側で [clear]）。タブを閉じたときは `Workspace.closeTab` から
  /// 明示 invalidate される。
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
  Override overrideWithValue(ExplorerSelection value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExplorerSelection>(value),
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
    r'1a9370a731fadc28f6a74f9def0b7adcf47b8fb3';

/// エクスプローラタブごとに選択状態を保持する Notifier
/// （`family(tabId)` / ADR-0027）。
///
/// 操作モデル（ADR-0021 / ADR-0038 D12）: シングルクリックで単一選択、
/// ⌘+クリックで選択へ加除（主選択はクリックした行へ移る）、ダブルクリックで
/// 遷移／オープン。
///
/// 永続化は不要。別ディレクトリへ navigate したタイミングでクリアする運用
/// （呼び出し側で [clear]）。タブを閉じたときは `Workspace.closeTab` から
/// 明示 invalidate される。

final class ExplorerItemSelectionFamily extends $Family
    with
        $ClassFamilyOverride<
          ExplorerItemSelection,
          ExplorerSelection,
          ExplorerSelection,
          ExplorerSelection,
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

  /// エクスプローラタブごとに選択状態を保持する Notifier
  /// （`family(tabId)` / ADR-0027）。
  ///
  /// 操作モデル（ADR-0021 / ADR-0038 D12）: シングルクリックで単一選択、
  /// ⌘+クリックで選択へ加除（主選択はクリックした行へ移る）、ダブルクリックで
  /// 遷移／オープン。
  ///
  /// 永続化は不要。別ディレクトリへ navigate したタイミングでクリアする運用
  /// （呼び出し側で [clear]）。タブを閉じたときは `Workspace.closeTab` から
  /// 明示 invalidate される。

  ExplorerItemSelectionProvider call(String tabId) =>
      ExplorerItemSelectionProvider._(argument: tabId, from: this);

  @override
  String toString() => r'explorerItemSelectionProvider';
}

/// エクスプローラタブごとに選択状態を保持する Notifier
/// （`family(tabId)` / ADR-0027）。
///
/// 操作モデル（ADR-0021 / ADR-0038 D12）: シングルクリックで単一選択、
/// ⌘+クリックで選択へ加除（主選択はクリックした行へ移る）、ダブルクリックで
/// 遷移／オープン。
///
/// 永続化は不要。別ディレクトリへ navigate したタイミングでクリアする運用
/// （呼び出し側で [clear]）。タブを閉じたときは `Workspace.closeTab` から
/// 明示 invalidate される。

abstract class _$ExplorerItemSelection extends $Notifier<ExplorerSelection> {
  late final _$args = ref.$arg as String;
  String get tabId => _$args;

  ExplorerSelection build(String tabId);
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
    element.handleCreate(ref, () => build(_$args));
  }
}
