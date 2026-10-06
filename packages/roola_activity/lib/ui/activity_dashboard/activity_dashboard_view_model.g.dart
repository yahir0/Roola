// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_dashboard_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// アクティビティタブのメトリクス（ADR-0067 / design D4）。
///
/// タブが表示中（所属ペインのアクティブタブ）の間だけ watch され、250ms ごとに
/// 累積値スナップショットを取得して前回との差分から使用率・レートを算出する。
/// autoDispose のため、タブが非表示になり watch が外れるとタイマーごと破棄
/// される。取得に失敗しても state は直近の値を保つ。

@ProviderFor(ActivityDashboardViewModel)
final activityDashboardViewModelProvider =
    ActivityDashboardViewModelProvider._();

/// アクティビティタブのメトリクス（ADR-0067 / design D4）。
///
/// タブが表示中（所属ペインのアクティブタブ）の間だけ watch され、250ms ごとに
/// 累積値スナップショットを取得して前回との差分から使用率・レートを算出する。
/// autoDispose のため、タブが非表示になり watch が外れるとタイマーごと破棄
/// される。取得に失敗しても state は直近の値を保つ。
final class ActivityDashboardViewModelProvider
    extends
        $NotifierProvider<ActivityDashboardViewModel, ActivityDashboardState> {
  /// アクティビティタブのメトリクス（ADR-0067 / design D4）。
  ///
  /// タブが表示中（所属ペインのアクティブタブ）の間だけ watch され、250ms ごとに
  /// 累積値スナップショットを取得して前回との差分から使用率・レートを算出する。
  /// autoDispose のため、タブが非表示になり watch が外れるとタイマーごと破棄
  /// される。取得に失敗しても state は直近の値を保つ。
  ActivityDashboardViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityDashboardViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activityDashboardViewModelHash();

  @$internal
  @override
  ActivityDashboardViewModel create() => ActivityDashboardViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActivityDashboardState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActivityDashboardState>(value),
    );
  }
}

String _$activityDashboardViewModelHash() =>
    r'0ee68765590ace0ff7a80b75b4dbb2cc880aeda1';

/// アクティビティタブのメトリクス（ADR-0067 / design D4）。
///
/// タブが表示中（所属ペインのアクティブタブ）の間だけ watch され、250ms ごとに
/// 累積値スナップショットを取得して前回との差分から使用率・レートを算出する。
/// autoDispose のため、タブが非表示になり watch が外れるとタイマーごと破棄
/// される。取得に失敗しても state は直近の値を保つ。

abstract class _$ActivityDashboardViewModel
    extends $Notifier<ActivityDashboardState> {
  ActivityDashboardState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<ActivityDashboardState, ActivityDashboardState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ActivityDashboardState, ActivityDashboardState>,
              ActivityDashboardState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
