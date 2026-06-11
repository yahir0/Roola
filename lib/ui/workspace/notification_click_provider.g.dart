// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_click_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 通知クリック → 該当ペインへのフォーカス復帰（ADR-0066）。
///
/// [TaskNotificationRepository.onNotificationClick] に復帰ハンドラを登録し、
/// クリックされた通知の `sessionId`（ad-hoc セッション id）からターミナル
/// タブを特定してアクティブ化する。ウィンドウの前面化は OS（通知クリックに
/// よるアプリ activate）に任せ、ペイン内のフォーカス復帰は ADR-0055 の
/// 復帰経路（`windowActivationProvider`）を `bump` で再利用する。
///
/// 通知元タブが既に閉じられている場合は何もしない（エラーも出さない）。
/// keepAlive: 起動時に `App` から watch して常駐させる。

@ProviderFor(NotificationClick)
final notificationClickProvider = NotificationClickProvider._();

/// 通知クリック → 該当ペインへのフォーカス復帰（ADR-0066）。
///
/// [TaskNotificationRepository.onNotificationClick] に復帰ハンドラを登録し、
/// クリックされた通知の `sessionId`（ad-hoc セッション id）からターミナル
/// タブを特定してアクティブ化する。ウィンドウの前面化は OS（通知クリックに
/// よるアプリ activate）に任せ、ペイン内のフォーカス復帰は ADR-0055 の
/// 復帰経路（`windowActivationProvider`）を `bump` で再利用する。
///
/// 通知元タブが既に閉じられている場合は何もしない（エラーも出さない）。
/// keepAlive: 起動時に `App` から watch して常駐させる。
final class NotificationClickProvider
    extends $NotifierProvider<NotificationClick, void> {
  /// 通知クリック → 該当ペインへのフォーカス復帰（ADR-0066）。
  ///
  /// [TaskNotificationRepository.onNotificationClick] に復帰ハンドラを登録し、
  /// クリックされた通知の `sessionId`（ad-hoc セッション id）からターミナル
  /// タブを特定してアクティブ化する。ウィンドウの前面化は OS（通知クリックに
  /// よるアプリ activate）に任せ、ペイン内のフォーカス復帰は ADR-0055 の
  /// 復帰経路（`windowActivationProvider`）を `bump` で再利用する。
  ///
  /// 通知元タブが既に閉じられている場合は何もしない（エラーも出さない）。
  /// keepAlive: 起動時に `App` から watch して常駐させる。
  NotificationClickProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationClickProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationClickHash();

  @$internal
  @override
  NotificationClick create() => NotificationClick();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$notificationClickHash() => r'd9af1b86f9ccc3cddb2507b998f870b9a1834701';

/// 通知クリック → 該当ペインへのフォーカス復帰（ADR-0066）。
///
/// [TaskNotificationRepository.onNotificationClick] に復帰ハンドラを登録し、
/// クリックされた通知の `sessionId`（ad-hoc セッション id）からターミナル
/// タブを特定してアクティブ化する。ウィンドウの前面化は OS（通知クリックに
/// よるアプリ activate）に任せ、ペイン内のフォーカス復帰は ADR-0055 の
/// 復帰経路（`windowActivationProvider`）を `bump` で再利用する。
///
/// 通知元タブが既に閉じられている場合は何もしない（エラーも出さない）。
/// keepAlive: 起動時に `App` から watch して常駐させる。

abstract class _$NotificationClick extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
