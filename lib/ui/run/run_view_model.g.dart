// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `RunPage` 用 ViewModel。
///
/// build() で PtySkillRunner を 1 つ生成し、`session-registry` に登録した
/// うえで状態 Stream を購読しながらプロセスを start する。
/// keepAlive のため、実行画面ウィジェットの離脱後もインスタンスは維持され、
/// 明示的な `close()` か `restart()` まで生存する。

@ProviderFor(RunViewModel)
final runViewModelProvider = RunViewModelFamily._();

/// `RunPage` 用 ViewModel。
///
/// build() で PtySkillRunner を 1 つ生成し、`session-registry` に登録した
/// うえで状態 Stream を購読しながらプロセスを start する。
/// keepAlive のため、実行画面ウィジェットの離脱後もインスタンスは維持され、
/// 明示的な `close()` か `restart()` まで生存する。
final class RunViewModelProvider
    extends $NotifierProvider<RunViewModel, RunPageState> {
  /// `RunPage` 用 ViewModel。
  ///
  /// build() で PtySkillRunner を 1 つ生成し、`session-registry` に登録した
  /// うえで状態 Stream を購読しながらプロセスを start する。
  /// keepAlive のため、実行画面ウィジェットの離脱後もインスタンスは維持され、
  /// 明示的な `close()` か `restart()` まで生存する。
  RunViewModelProvider._({
    required RunViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'runViewModelProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$runViewModelHash();

  @override
  String toString() {
    return r'runViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RunViewModel create() => RunViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RunPageState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RunPageState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RunViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$runViewModelHash() => r'883bdff827a0591ea0594e808c2ee10a93763c27';

/// `RunPage` 用 ViewModel。
///
/// build() で PtySkillRunner を 1 つ生成し、`session-registry` に登録した
/// うえで状態 Stream を購読しながらプロセスを start する。
/// keepAlive のため、実行画面ウィジェットの離脱後もインスタンスは維持され、
/// 明示的な `close()` か `restart()` まで生存する。

final class RunViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          RunViewModel,
          RunPageState,
          RunPageState,
          RunPageState,
          String
        > {
  RunViewModelFamily._()
    : super(
        retry: null,
        name: r'runViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// `RunPage` 用 ViewModel。
  ///
  /// build() で PtySkillRunner を 1 つ生成し、`session-registry` に登録した
  /// うえで状態 Stream を購読しながらプロセスを start する。
  /// keepAlive のため、実行画面ウィジェットの離脱後もインスタンスは維持され、
  /// 明示的な `close()` か `restart()` まで生存する。

  RunViewModelProvider call(String entryId) =>
      RunViewModelProvider._(argument: entryId, from: this);

  @override
  String toString() => r'runViewModelProvider';
}

/// `RunPage` 用 ViewModel。
///
/// build() で PtySkillRunner を 1 つ生成し、`session-registry` に登録した
/// うえで状態 Stream を購読しながらプロセスを start する。
/// keepAlive のため、実行画面ウィジェットの離脱後もインスタンスは維持され、
/// 明示的な `close()` か `restart()` まで生存する。

abstract class _$RunViewModel extends $Notifier<RunPageState> {
  late final _$args = ref.$arg as String;
  String get entryId => _$args;

  RunPageState build(String entryId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RunPageState, RunPageState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RunPageState, RunPageState>,
              RunPageState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
