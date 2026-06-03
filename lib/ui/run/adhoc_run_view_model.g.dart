// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adhoc_run_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ターミナルタブ 1 つ分の ViewModel（`family(AdhocRunArgs)` / keepAlive）。
///
/// build() で `PtyTerminalRunner` を 1 つ生成し、`ActiveSessions` に登録した
/// うえで状態 Stream を購読しながらプロセスを start する。keepAlive のため、
/// タブを別ペインへ DnD 移動して widget が remount されても PTY と出力履歴
/// は保持される。破棄はタブを閉じたときに `Workspace.closeTab` から明示
/// invalidate される。
///
/// 動作タイプの分岐は `args.action`（`LauncherAction`）に統合されており、
/// runner 構築は `PtyTerminalRunner.fromAction` が一括で処理する（ADR-0016）。

@ProviderFor(AdhocRunViewModel)
final adhocRunViewModelProvider = AdhocRunViewModelFamily._();

/// ターミナルタブ 1 つ分の ViewModel（`family(AdhocRunArgs)` / keepAlive）。
///
/// build() で `PtyTerminalRunner` を 1 つ生成し、`ActiveSessions` に登録した
/// うえで状態 Stream を購読しながらプロセスを start する。keepAlive のため、
/// タブを別ペインへ DnD 移動して widget が remount されても PTY と出力履歴
/// は保持される。破棄はタブを閉じたときに `Workspace.closeTab` から明示
/// invalidate される。
///
/// 動作タイプの分岐は `args.action`（`LauncherAction`）に統合されており、
/// runner 構築は `PtyTerminalRunner.fromAction` が一括で処理する（ADR-0016）。
final class AdhocRunViewModelProvider
    extends $NotifierProvider<AdhocRunViewModel, RunPageState> {
  /// ターミナルタブ 1 つ分の ViewModel（`family(AdhocRunArgs)` / keepAlive）。
  ///
  /// build() で `PtyTerminalRunner` を 1 つ生成し、`ActiveSessions` に登録した
  /// うえで状態 Stream を購読しながらプロセスを start する。keepAlive のため、
  /// タブを別ペインへ DnD 移動して widget が remount されても PTY と出力履歴
  /// は保持される。破棄はタブを閉じたときに `Workspace.closeTab` から明示
  /// invalidate される。
  ///
  /// 動作タイプの分岐は `args.action`（`LauncherAction`）に統合されており、
  /// runner 構築は `PtyTerminalRunner.fromAction` が一括で処理する（ADR-0016）。
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

String _$adhocRunViewModelHash() => r'5a61bc2aa1eff92ac1611333e4227b95f6560fcc';

/// ターミナルタブ 1 つ分の ViewModel（`family(AdhocRunArgs)` / keepAlive）。
///
/// build() で `PtyTerminalRunner` を 1 つ生成し、`ActiveSessions` に登録した
/// うえで状態 Stream を購読しながらプロセスを start する。keepAlive のため、
/// タブを別ペインへ DnD 移動して widget が remount されても PTY と出力履歴
/// は保持される。破棄はタブを閉じたときに `Workspace.closeTab` から明示
/// invalidate される。
///
/// 動作タイプの分岐は `args.action`（`LauncherAction`）に統合されており、
/// runner 構築は `PtyTerminalRunner.fromAction` が一括で処理する（ADR-0016）。

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

  /// ターミナルタブ 1 つ分の ViewModel（`family(AdhocRunArgs)` / keepAlive）。
  ///
  /// build() で `PtyTerminalRunner` を 1 つ生成し、`ActiveSessions` に登録した
  /// うえで状態 Stream を購読しながらプロセスを start する。keepAlive のため、
  /// タブを別ペインへ DnD 移動して widget が remount されても PTY と出力履歴
  /// は保持される。破棄はタブを閉じたときに `Workspace.closeTab` から明示
  /// invalidate される。
  ///
  /// 動作タイプの分岐は `args.action`（`LauncherAction`）に統合されており、
  /// runner 構築は `PtyTerminalRunner.fromAction` が一括で処理する（ADR-0016）。

  AdhocRunViewModelProvider call(AdhocRunArgs args) =>
      AdhocRunViewModelProvider._(argument: args, from: this);

  @override
  String toString() => r'adhocRunViewModelProvider';
}

/// ターミナルタブ 1 つ分の ViewModel（`family(AdhocRunArgs)` / keepAlive）。
///
/// build() で `PtyTerminalRunner` を 1 つ生成し、`ActiveSessions` に登録した
/// うえで状態 Stream を購読しながらプロセスを start する。keepAlive のため、
/// タブを別ペインへ DnD 移動して widget が remount されても PTY と出力履歴
/// は保持される。破棄はタブを閉じたときに `Workspace.closeTab` から明示
/// invalidate される。
///
/// 動作タイプの分岐は `args.action`（`LauncherAction`）に統合されており、
/// runner 構築は `PtyTerminalRunner.fromAction` が一括で処理する（ADR-0016）。

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
