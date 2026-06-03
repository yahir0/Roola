// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'git_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Git ビュータブ 1 つ分の ViewModel（`AsyncNotifier.family(tabId)` /
/// keepAlive / ADR-0027・ADR-0030）。
///
/// `build` で対象 `GitTab` の `repoRoot` を解決し、`git` の可用性を確認した
/// うえで status / 履歴 / ブランチ / stash をまとめて取得する。各アクションは
/// `runningOperation` で直列化し、完了後に必要なデータを再取得する。
///
/// keepAlive のため、タブを別ペインへ DnD 移動して widget が remount されても
/// 履歴・選択は保持される。破棄はタブを閉じたときに `Workspace.closeTab` から
/// 明示 invalidate される。

@ProviderFor(GitViewModel)
final gitViewModelProvider = GitViewModelFamily._();

/// Git ビュータブ 1 つ分の ViewModel（`AsyncNotifier.family(tabId)` /
/// keepAlive / ADR-0027・ADR-0030）。
///
/// `build` で対象 `GitTab` の `repoRoot` を解決し、`git` の可用性を確認した
/// うえで status / 履歴 / ブランチ / stash をまとめて取得する。各アクションは
/// `runningOperation` で直列化し、完了後に必要なデータを再取得する。
///
/// keepAlive のため、タブを別ペインへ DnD 移動して widget が remount されても
/// 履歴・選択は保持される。破棄はタブを閉じたときに `Workspace.closeTab` から
/// 明示 invalidate される。
final class GitViewModelProvider
    extends $AsyncNotifierProvider<GitViewModel, GitViewState> {
  /// Git ビュータブ 1 つ分の ViewModel（`AsyncNotifier.family(tabId)` /
  /// keepAlive / ADR-0027・ADR-0030）。
  ///
  /// `build` で対象 `GitTab` の `repoRoot` を解決し、`git` の可用性を確認した
  /// うえで status / 履歴 / ブランチ / stash をまとめて取得する。各アクションは
  /// `runningOperation` で直列化し、完了後に必要なデータを再取得する。
  ///
  /// keepAlive のため、タブを別ペインへ DnD 移動して widget が remount されても
  /// 履歴・選択は保持される。破棄はタブを閉じたときに `Workspace.closeTab` から
  /// 明示 invalidate される。
  GitViewModelProvider._({
    required GitViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'gitViewModelProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gitViewModelHash();

  @override
  String toString() {
    return r'gitViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GitViewModel create() => GitViewModel();

  @override
  bool operator ==(Object other) {
    return other is GitViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gitViewModelHash() => r'd1ea82df5020d694ac92ba4045524978b7090710';

/// Git ビュータブ 1 つ分の ViewModel（`AsyncNotifier.family(tabId)` /
/// keepAlive / ADR-0027・ADR-0030）。
///
/// `build` で対象 `GitTab` の `repoRoot` を解決し、`git` の可用性を確認した
/// うえで status / 履歴 / ブランチ / stash をまとめて取得する。各アクションは
/// `runningOperation` で直列化し、完了後に必要なデータを再取得する。
///
/// keepAlive のため、タブを別ペインへ DnD 移動して widget が remount されても
/// 履歴・選択は保持される。破棄はタブを閉じたときに `Workspace.closeTab` から
/// 明示 invalidate される。

final class GitViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          GitViewModel,
          AsyncValue<GitViewState>,
          GitViewState,
          FutureOr<GitViewState>,
          String
        > {
  GitViewModelFamily._()
    : super(
        retry: null,
        name: r'gitViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Git ビュータブ 1 つ分の ViewModel（`AsyncNotifier.family(tabId)` /
  /// keepAlive / ADR-0027・ADR-0030）。
  ///
  /// `build` で対象 `GitTab` の `repoRoot` を解決し、`git` の可用性を確認した
  /// うえで status / 履歴 / ブランチ / stash をまとめて取得する。各アクションは
  /// `runningOperation` で直列化し、完了後に必要なデータを再取得する。
  ///
  /// keepAlive のため、タブを別ペインへ DnD 移動して widget が remount されても
  /// 履歴・選択は保持される。破棄はタブを閉じたときに `Workspace.closeTab` から
  /// 明示 invalidate される。

  GitViewModelProvider call(String tabId) =>
      GitViewModelProvider._(argument: tabId, from: this);

  @override
  String toString() => r'gitViewModelProvider';
}

/// Git ビュータブ 1 つ分の ViewModel（`AsyncNotifier.family(tabId)` /
/// keepAlive / ADR-0027・ADR-0030）。
///
/// `build` で対象 `GitTab` の `repoRoot` を解決し、`git` の可用性を確認した
/// うえで status / 履歴 / ブランチ / stash をまとめて取得する。各アクションは
/// `runningOperation` で直列化し、完了後に必要なデータを再取得する。
///
/// keepAlive のため、タブを別ペインへ DnD 移動して widget が remount されても
/// 履歴・選択は保持される。破棄はタブを閉じたときに `Workspace.closeTab` から
/// 明示 invalidate される。

abstract class _$GitViewModel extends $AsyncNotifier<GitViewState> {
  late final _$args = ref.$arg as String;
  String get tabId => _$args;

  FutureOr<GitViewState> build(String tabId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<GitViewState>, GitViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GitViewState>, GitViewState>,
              AsyncValue<GitViewState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// [path] が属する Git リポジトリのルートを返す Provider（ADR-0030）。
///
/// エクスプローラの「Git ビューを開く」ボタンの活性判定に使う。`family`
/// 引数（パス）単位でキャッシュされるため、描画のたびに `git` を起動しない。

@ProviderFor(gitRepositoryRoot)
final gitRepositoryRootProvider = GitRepositoryRootFamily._();

/// [path] が属する Git リポジトリのルートを返す Provider（ADR-0030）。
///
/// エクスプローラの「Git ビューを開く」ボタンの活性判定に使う。`family`
/// 引数（パス）単位でキャッシュされるため、描画のたびに `git` を起動しない。

final class GitRepositoryRootProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// [path] が属する Git リポジトリのルートを返す Provider（ADR-0030）。
  ///
  /// エクスプローラの「Git ビューを開く」ボタンの活性判定に使う。`family`
  /// 引数（パス）単位でキャッシュされるため、描画のたびに `git` を起動しない。
  GitRepositoryRootProvider._({
    required GitRepositoryRootFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'gitRepositoryRootProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gitRepositoryRootHash();

  @override
  String toString() {
    return r'gitRepositoryRootProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return gitRepositoryRoot(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GitRepositoryRootProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gitRepositoryRootHash() => r'64d879eaf2e03635f83b43c25f1e442784088b08';

/// [path] が属する Git リポジトリのルートを返す Provider（ADR-0030）。
///
/// エクスプローラの「Git ビューを開く」ボタンの活性判定に使う。`family`
/// 引数（パス）単位でキャッシュされるため、描画のたびに `git` を起動しない。

final class GitRepositoryRootFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  GitRepositoryRootFamily._()
    : super(
        retry: null,
        name: r'gitRepositoryRootProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [path] が属する Git リポジトリのルートを返す Provider（ADR-0030）。
  ///
  /// エクスプローラの「Git ビューを開く」ボタンの活性判定に使う。`family`
  /// 引数（パス）単位でキャッシュされるため、描画のたびに `git` を起動しない。

  GitRepositoryRootProvider call(String path) =>
      GitRepositoryRootProvider._(argument: path, from: this);

  @override
  String toString() => r'gitRepositoryRootProvider';
}
