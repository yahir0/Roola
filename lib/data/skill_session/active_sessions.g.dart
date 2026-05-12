// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_sessions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 実行中・終了済みのスキルセッションを `entryId` 単位で一元管理するレジストリ。
///
/// ライフサイクルは `RunViewModel.build()` での `register` から
/// 明示的な `unregister`（「閉じる」操作）まで。state 変化は `updateState`
/// で都度反映する。ホーム画面の chip 列とエントリアイコンのバッジは
/// この Notifier を購読することで状態変化を受け取る。

@ProviderFor(ActiveSessions)
final activeSessionsProvider = ActiveSessionsProvider._();

/// 実行中・終了済みのスキルセッションを `entryId` 単位で一元管理するレジストリ。
///
/// ライフサイクルは `RunViewModel.build()` での `register` から
/// 明示的な `unregister`（「閉じる」操作）まで。state 変化は `updateState`
/// で都度反映する。ホーム画面の chip 列とエントリアイコンのバッジは
/// この Notifier を購読することで状態変化を受け取る。
final class ActiveSessionsProvider
    extends $NotifierProvider<ActiveSessions, Map<String, SkillRunState>> {
  /// 実行中・終了済みのスキルセッションを `entryId` 単位で一元管理するレジストリ。
  ///
  /// ライフサイクルは `RunViewModel.build()` での `register` から
  /// 明示的な `unregister`（「閉じる」操作）まで。state 変化は `updateState`
  /// で都度反映する。ホーム画面の chip 列とエントリアイコンのバッジは
  /// この Notifier を購読することで状態変化を受け取る。
  ActiveSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeSessionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeSessionsHash();

  @$internal
  @override
  ActiveSessions create() => ActiveSessions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, SkillRunState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, SkillRunState>>(value),
    );
  }
}

String _$activeSessionsHash() => r'33b3a3099758f3fa94df545993a39195e120718d';

/// 実行中・終了済みのスキルセッションを `entryId` 単位で一元管理するレジストリ。
///
/// ライフサイクルは `RunViewModel.build()` での `register` から
/// 明示的な `unregister`（「閉じる」操作）まで。state 変化は `updateState`
/// で都度反映する。ホーム画面の chip 列とエントリアイコンのバッジは
/// この Notifier を購読することで状態変化を受け取る。

abstract class _$ActiveSessions extends $Notifier<Map<String, SkillRunState>> {
  Map<String, SkillRunState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<Map<String, SkillRunState>, Map<String, SkillRunState>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, SkillRunState>,
                Map<String, SkillRunState>
              >,
              Map<String, SkillRunState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
