// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ワークスペースのレイアウト（3 ペインスロット × タブ群）の単一の真実。
///
/// タブの生成 / 閉じる / アクティブ化 / 移動とスプリッタ比率を一手に扱う
/// （ADR-0026）。タブを閉じた / 移動した際の per-tab family プロバイダの
/// 破棄もここに集約する（ADR-0027）。

@ProviderFor(Workspace)
final workspaceProvider = WorkspaceProvider._();

/// ワークスペースのレイアウト（3 ペインスロット × タブ群）の単一の真実。
///
/// タブの生成 / 閉じる / アクティブ化 / 移動とスプリッタ比率を一手に扱う
/// （ADR-0026）。タブを閉じた / 移動した際の per-tab family プロバイダの
/// 破棄もここに集約する（ADR-0027）。
final class WorkspaceProvider
    extends $NotifierProvider<Workspace, WorkspaceLayout> {
  /// ワークスペースのレイアウト（3 ペインスロット × タブ群）の単一の真実。
  ///
  /// タブの生成 / 閉じる / アクティブ化 / 移動とスプリッタ比率を一手に扱う
  /// （ADR-0026）。タブを閉じた / 移動した際の per-tab family プロバイダの
  /// 破棄もここに集約する（ADR-0027）。
  WorkspaceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workspaceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workspaceHash();

  @$internal
  @override
  Workspace create() => Workspace();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkspaceLayout value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkspaceLayout>(value),
    );
  }
}

String _$workspaceHash() => r'a306af6ec1dd7e55fafc941aa826ee529fd6a810';

/// ワークスペースのレイアウト（3 ペインスロット × タブ群）の単一の真実。
///
/// タブの生成 / 閉じる / アクティブ化 / 移動とスプリッタ比率を一手に扱う
/// （ADR-0026）。タブを閉じた / 移動した際の per-tab family プロバイダの
/// 破棄もここに集約する（ADR-0027）。

abstract class _$Workspace extends $Notifier<WorkspaceLayout> {
  WorkspaceLayout build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WorkspaceLayout, WorkspaceLayout>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WorkspaceLayout, WorkspaceLayout>,
              WorkspaceLayout,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
