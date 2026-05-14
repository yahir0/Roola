// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adhoc_run_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// エクスプローラ右クリックから起動する一時セッションの ViewModel。
///
/// 永続エントリを持たない（`launcherEntriesProvider` に乗らない）点が
/// `RunViewModel` との違い。`ActiveSessions` には `adhocLabel` 付きで
/// 登録され、chip 列での表示名はそこから fallback で取得される。
/// 設計の背景は ADR-0009 を参照。
///
/// 動作タイプの分岐は `args.action`（[LauncherAction]）に統合されており、
/// runner 構築は [PtyTerminalRunner.fromAction] が一括で処理する
/// （ADR-0016）。

@ProviderFor(AdhocRunViewModel)
final adhocRunViewModelProvider = AdhocRunViewModelFamily._();

/// エクスプローラ右クリックから起動する一時セッションの ViewModel。
///
/// 永続エントリを持たない（`launcherEntriesProvider` に乗らない）点が
/// `RunViewModel` との違い。`ActiveSessions` には `adhocLabel` 付きで
/// 登録され、chip 列での表示名はそこから fallback で取得される。
/// 設計の背景は ADR-0009 を参照。
///
/// 動作タイプの分岐は `args.action`（[LauncherAction]）に統合されており、
/// runner 構築は [PtyTerminalRunner.fromAction] が一括で処理する
/// （ADR-0016）。
final class AdhocRunViewModelProvider
    extends $NotifierProvider<AdhocRunViewModel, RunPageState> {
  /// エクスプローラ右クリックから起動する一時セッションの ViewModel。
  ///
  /// 永続エントリを持たない（`launcherEntriesProvider` に乗らない）点が
  /// `RunViewModel` との違い。`ActiveSessions` には `adhocLabel` 付きで
  /// 登録され、chip 列での表示名はそこから fallback で取得される。
  /// 設計の背景は ADR-0009 を参照。
  ///
  /// 動作タイプの分岐は `args.action`（[LauncherAction]）に統合されており、
  /// runner 構築は [PtyTerminalRunner.fromAction] が一括で処理する
  /// （ADR-0016）。
  AdhocRunViewModelProvider._({
    required AdhocRunViewModelFamily super.from,
    required AdhocRunArgs super.argument,
  }) : super(
         retry: null,
         name: r'adhocRunViewModelProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adhocRunViewModelHash();

  @override
  String toString() {
    return r'adhocRunViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AdhocRunViewModel create() => AdhocRunViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RunPageState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RunPageState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AdhocRunViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adhocRunViewModelHash() => r'0e28dd7d29fbb02af0dfaa289ba1c866cee4c46b';

/// エクスプローラ右クリックから起動する一時セッションの ViewModel。
///
/// 永続エントリを持たない（`launcherEntriesProvider` に乗らない）点が
/// `RunViewModel` との違い。`ActiveSessions` には `adhocLabel` 付きで
/// 登録され、chip 列での表示名はそこから fallback で取得される。
/// 設計の背景は ADR-0009 を参照。
///
/// 動作タイプの分岐は `args.action`（[LauncherAction]）に統合されており、
/// runner 構築は [PtyTerminalRunner.fromAction] が一括で処理する
/// （ADR-0016）。

final class AdhocRunViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          AdhocRunViewModel,
          RunPageState,
          RunPageState,
          RunPageState,
          AdhocRunArgs
        > {
  AdhocRunViewModelFamily._()
    : super(
        retry: null,
        name: r'adhocRunViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// エクスプローラ右クリックから起動する一時セッションの ViewModel。
  ///
  /// 永続エントリを持たない（`launcherEntriesProvider` に乗らない）点が
  /// `RunViewModel` との違い。`ActiveSessions` には `adhocLabel` 付きで
  /// 登録され、chip 列での表示名はそこから fallback で取得される。
  /// 設計の背景は ADR-0009 を参照。
  ///
  /// 動作タイプの分岐は `args.action`（[LauncherAction]）に統合されており、
  /// runner 構築は [PtyTerminalRunner.fromAction] が一括で処理する
  /// （ADR-0016）。

  AdhocRunViewModelProvider call(AdhocRunArgs args) =>
      AdhocRunViewModelProvider._(argument: args, from: this);

  @override
  String toString() => r'adhocRunViewModelProvider';
}

/// エクスプローラ右クリックから起動する一時セッションの ViewModel。
///
/// 永続エントリを持たない（`launcherEntriesProvider` に乗らない）点が
/// `RunViewModel` との違い。`ActiveSessions` には `adhocLabel` 付きで
/// 登録され、chip 列での表示名はそこから fallback で取得される。
/// 設計の背景は ADR-0009 を参照。
///
/// 動作タイプの分岐は `args.action`（[LauncherAction]）に統合されており、
/// runner 構築は [PtyTerminalRunner.fromAction] が一括で処理する
/// （ADR-0016）。

abstract class _$AdhocRunViewModel extends $Notifier<RunPageState> {
  late final _$args = ref.$arg as AdhocRunArgs;
  AdhocRunArgs get args => _$args;

  RunPageState build(AdhocRunArgs args);
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
