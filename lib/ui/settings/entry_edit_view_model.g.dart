// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_edit_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// エントリ編集 ViewModel。`entryId == null` で新規、それ以外で既存編集。

@ProviderFor(EntryEditViewModel)
final entryEditViewModelProvider = EntryEditViewModelFamily._();

/// エントリ編集 ViewModel。`entryId == null` で新規、それ以外で既存編集。
final class EntryEditViewModelProvider
    extends $NotifierProvider<EntryEditViewModel, EntryEditState> {
  /// エントリ編集 ViewModel。`entryId == null` で新規、それ以外で既存編集。
  EntryEditViewModelProvider._({
    required EntryEditViewModelFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'entryEditViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$entryEditViewModelHash();

  @override
  String toString() {
    return r'entryEditViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EntryEditViewModel create() => EntryEditViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EntryEditState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EntryEditState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EntryEditViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$entryEditViewModelHash() =>
    r'b625990e80f9f75b6cb50a91ce37f00de14643f6';

/// エントリ編集 ViewModel。`entryId == null` で新規、それ以外で既存編集。

final class EntryEditViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          EntryEditViewModel,
          EntryEditState,
          EntryEditState,
          EntryEditState,
          String?
        > {
  EntryEditViewModelFamily._()
    : super(
        retry: null,
        name: r'entryEditViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// エントリ編集 ViewModel。`entryId == null` で新規、それ以外で既存編集。

  EntryEditViewModelProvider call(String? entryId) =>
      EntryEditViewModelProvider._(argument: entryId, from: this);

  @override
  String toString() => r'entryEditViewModelProvider';
}

/// エントリ編集 ViewModel。`entryId == null` で新規、それ以外で既存編集。

abstract class _$EntryEditViewModel extends $Notifier<EntryEditState> {
  late final _$args = ref.$arg as String?;
  String? get entryId => _$args;

  EntryEditState build(String? entryId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<EntryEditState, EntryEditState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EntryEditState, EntryEditState>,
              EntryEditState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
