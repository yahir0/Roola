// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_preview_layout_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Explorer タブごとに [FilePreviewLayout] を保持する Notifier。

@ProviderFor(FilePreviewLayoutNotifier)
final filePreviewLayoutProvider = FilePreviewLayoutNotifierFamily._();

/// Explorer タブごとに [FilePreviewLayout] を保持する Notifier。
final class FilePreviewLayoutNotifierProvider
    extends $NotifierProvider<FilePreviewLayoutNotifier, FilePreviewLayout> {
  /// Explorer タブごとに [FilePreviewLayout] を保持する Notifier。
  FilePreviewLayoutNotifierProvider._({
    required FilePreviewLayoutNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'filePreviewLayoutProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filePreviewLayoutNotifierHash();

  @override
  String toString() {
    return r'filePreviewLayoutProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FilePreviewLayoutNotifier create() => FilePreviewLayoutNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FilePreviewLayout value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FilePreviewLayout>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilePreviewLayoutNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filePreviewLayoutNotifierHash() =>
    r'83b07382f7be0eded3ad5ce72721f489da4527b7';

/// Explorer タブごとに [FilePreviewLayout] を保持する Notifier。

final class FilePreviewLayoutNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          FilePreviewLayoutNotifier,
          FilePreviewLayout,
          FilePreviewLayout,
          FilePreviewLayout,
          String
        > {
  FilePreviewLayoutNotifierFamily._()
    : super(
        retry: null,
        name: r'filePreviewLayoutProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Explorer タブごとに [FilePreviewLayout] を保持する Notifier。

  FilePreviewLayoutNotifierProvider call(String tabId) =>
      FilePreviewLayoutNotifierProvider._(argument: tabId, from: this);

  @override
  String toString() => r'filePreviewLayoutProvider';
}

/// Explorer タブごとに [FilePreviewLayout] を保持する Notifier。

abstract class _$FilePreviewLayoutNotifier
    extends $Notifier<FilePreviewLayout> {
  late final _$args = ref.$arg as String;
  String get tabId => _$args;

  FilePreviewLayout build(String tabId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FilePreviewLayout, FilePreviewLayout>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FilePreviewLayout, FilePreviewLayout>,
              FilePreviewLayout,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
