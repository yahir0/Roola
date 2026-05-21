// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_preview_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Explorer タブごとのファイルプレビュー ViewModel（ADR-0046 / ADR-0027）。
///
/// `explorerItemSelectionProvider(tabId)` の主選択（`primary`）を watch し、
/// ファイルなら [FilePreviewRepository.load] で内容を読み出して
/// [FilePreviewContent] を返す。ディレクトリ / 非選択は null を返す
/// （UI 側で空状態 placeholder を出す）。
///
/// keepAlive はしない。タブを閉じた瞬間に通常の autoDispose で破棄される。
/// 履歴等の状態を持たないため、再選択時に再読込されてもユーザー体感の
/// コストは小さい。

@ProviderFor(FilePreviewViewModel)
final filePreviewViewModelProvider = FilePreviewViewModelFamily._();

/// Explorer タブごとのファイルプレビュー ViewModel（ADR-0046 / ADR-0027）。
///
/// `explorerItemSelectionProvider(tabId)` の主選択（`primary`）を watch し、
/// ファイルなら [FilePreviewRepository.load] で内容を読み出して
/// [FilePreviewContent] を返す。ディレクトリ / 非選択は null を返す
/// （UI 側で空状態 placeholder を出す）。
///
/// keepAlive はしない。タブを閉じた瞬間に通常の autoDispose で破棄される。
/// 履歴等の状態を持たないため、再選択時に再読込されてもユーザー体感の
/// コストは小さい。
final class FilePreviewViewModelProvider
    extends $AsyncNotifierProvider<FilePreviewViewModel, FilePreviewContent?> {
  /// Explorer タブごとのファイルプレビュー ViewModel（ADR-0046 / ADR-0027）。
  ///
  /// `explorerItemSelectionProvider(tabId)` の主選択（`primary`）を watch し、
  /// ファイルなら [FilePreviewRepository.load] で内容を読み出して
  /// [FilePreviewContent] を返す。ディレクトリ / 非選択は null を返す
  /// （UI 側で空状態 placeholder を出す）。
  ///
  /// keepAlive はしない。タブを閉じた瞬間に通常の autoDispose で破棄される。
  /// 履歴等の状態を持たないため、再選択時に再読込されてもユーザー体感の
  /// コストは小さい。
  FilePreviewViewModelProvider._({
    required FilePreviewViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'filePreviewViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filePreviewViewModelHash();

  @override
  String toString() {
    return r'filePreviewViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FilePreviewViewModel create() => FilePreviewViewModel();

  @override
  bool operator ==(Object other) {
    return other is FilePreviewViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filePreviewViewModelHash() =>
    r'ea1f0384755fd21525e53f92eb8c79ae17019db6';

/// Explorer タブごとのファイルプレビュー ViewModel（ADR-0046 / ADR-0027）。
///
/// `explorerItemSelectionProvider(tabId)` の主選択（`primary`）を watch し、
/// ファイルなら [FilePreviewRepository.load] で内容を読み出して
/// [FilePreviewContent] を返す。ディレクトリ / 非選択は null を返す
/// （UI 側で空状態 placeholder を出す）。
///
/// keepAlive はしない。タブを閉じた瞬間に通常の autoDispose で破棄される。
/// 履歴等の状態を持たないため、再選択時に再読込されてもユーザー体感の
/// コストは小さい。

final class FilePreviewViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          FilePreviewViewModel,
          AsyncValue<FilePreviewContent?>,
          FilePreviewContent?,
          FutureOr<FilePreviewContent?>,
          String
        > {
  FilePreviewViewModelFamily._()
    : super(
        retry: null,
        name: r'filePreviewViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Explorer タブごとのファイルプレビュー ViewModel（ADR-0046 / ADR-0027）。
  ///
  /// `explorerItemSelectionProvider(tabId)` の主選択（`primary`）を watch し、
  /// ファイルなら [FilePreviewRepository.load] で内容を読み出して
  /// [FilePreviewContent] を返す。ディレクトリ / 非選択は null を返す
  /// （UI 側で空状態 placeholder を出す）。
  ///
  /// keepAlive はしない。タブを閉じた瞬間に通常の autoDispose で破棄される。
  /// 履歴等の状態を持たないため、再選択時に再読込されてもユーザー体感の
  /// コストは小さい。

  FilePreviewViewModelProvider call(String tabId) =>
      FilePreviewViewModelProvider._(argument: tabId, from: this);

  @override
  String toString() => r'filePreviewViewModelProvider';
}

/// Explorer タブごとのファイルプレビュー ViewModel（ADR-0046 / ADR-0027）。
///
/// `explorerItemSelectionProvider(tabId)` の主選択（`primary`）を watch し、
/// ファイルなら [FilePreviewRepository.load] で内容を読み出して
/// [FilePreviewContent] を返す。ディレクトリ / 非選択は null を返す
/// （UI 側で空状態 placeholder を出す）。
///
/// keepAlive はしない。タブを閉じた瞬間に通常の autoDispose で破棄される。
/// 履歴等の状態を持たないため、再選択時に再読込されてもユーザー体感の
/// コストは小さい。

abstract class _$FilePreviewViewModel
    extends $AsyncNotifier<FilePreviewContent?> {
  late final _$args = ref.$arg as String;
  String get tabId => _$args;

  FutureOr<FilePreviewContent?> build(String tabId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<FilePreviewContent?>, FilePreviewContent?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FilePreviewContent?>, FilePreviewContent?>,
              AsyncValue<FilePreviewContent?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
