import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// macOS の通知許可状態（`UNAuthorizationStatus` を Dart 側で表現したもの）。
enum NotificationAuthorizationStatus {
  /// まだユーザーに許可を求めていない。
  notDetermined,

  /// ユーザーが許可した。
  authorized,

  /// ユーザーが拒否した（システム設定からの再許可が必要）。
  denied;

  static NotificationAuthorizationStatus fromName(String? name) =>
      NotificationAuthorizationStatus.values.firstWhere(
        (s) => s.name == name,
        orElse: () => NotificationAuthorizationStatus.notDetermined,
      );
}

/// macOS のローカル通知をネイティブ層（`UNUserNotificationCenter`）から
/// 発射する（ADR-0057）。
///
/// `roola/notification` の `MethodChannel` をラップするだけの薄い具象クラス。
/// 差し替え可能性のある箇所ではないため interface は設けない（CLAUDE.md）。
/// テストでは Riverpod の provider override でサブクラスへ差し替える。
class TaskNotificationRepository {
  const TaskNotificationRepository();

  static const MethodChannel _channel = MethodChannel('roola/notification');

  /// ローカル通知を 1 件発射する。失敗しても例外は投げず握り潰す
  /// （通知の取りこぼしは致命ではないため）。
  Future<void> notify({required String title, required String body}) async {
    try {
      await _channel.invokeMethod<void>('notify', {
        'title': title,
        'body': body,
      });
    } on PlatformException {
      // 通知発射の失敗は無視する。
    } on MissingPluginException {
      // ネイティブ未登録環境（テスト等）では no-op。
    }
  }

  /// 初回の通知許可をユーザーに要求する。許可されたら `true`。
  Future<bool> requestAuthorization() async {
    try {
      final granted = await _channel.invokeMethod<bool>('requestAuthorization');
      return granted ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// 現在の通知許可状態を返す。取得できなければ [notDetermined]。
  Future<NotificationAuthorizationStatus> authorizationStatus() async {
    try {
      final name = await _channel.invokeMethod<String>('authorizationStatus');
      return NotificationAuthorizationStatus.fromName(name);
    } on PlatformException {
      return NotificationAuthorizationStatus.notDetermined;
    } on MissingPluginException {
      return NotificationAuthorizationStatus.notDetermined;
    }
  }

  /// macOS のシステム通知設定を開く（拒否後の再許可導線）。
  Future<void> openSystemSettings() async {
    try {
      await _channel.invokeMethod<void>('openSystemSettings');
    } on PlatformException {
      // 失敗は無視する。
    } on MissingPluginException {
      // no-op。
    }
  }
}

/// [TaskNotificationRepository] の DI。テストでは override してネイティブ
/// 呼び出しを伴わない fake に差し替える。
final taskNotificationRepositoryProvider = Provider<TaskNotificationRepository>(
  (ref) => const TaskNotificationRepository(),
);

/// 現在の通知許可状態。設定画面で表示し、許可要求後に
/// `ref.invalidate` して再取得する。
final notificationAuthorizationProvider =
    FutureProvider<NotificationAuthorizationStatus>((ref) {
      return ref.read(taskNotificationRepositoryProvider).authorizationStatus();
    });
