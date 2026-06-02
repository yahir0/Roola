import 'package:local_notifier/local_notifier.dart';
import 'package:roola/data/task_notification/task_notification_repository.dart';

/// Windows 実装: `local_notifier` パッケージを使って Toast 通知を送る。
///
/// Windows では OS レベルの通知許可はシステム設定で管理するため、
/// `requestAuthorization` は常に `authorized` を返す。
class NotificationServiceWindows implements TaskNotificationRepository {
  const NotificationServiceWindows();

  @override
  Future<void> notify({required String title, required String body}) async {
    try {
      final notification = LocalNotification(
        title: title,
        body: body,
      );
      await notification.show();
    } catch (_) {
      // 通知失敗は無視する。
    }
  }

  @override
  Future<bool> requestAuthorization() async {
    // Windows は OS レベルで通知を管理するため常に許可済み扱い。
    return true;
  }

  @override
  Future<NotificationAuthorizationStatus> authorizationStatus() async {
    return NotificationAuthorizationStatus.authorized;
  }

  @override
  Future<void> openSystemSettings() async {
    // Windows の通知設定は「設定 > システム > 通知」。
    // shell execute で開くことも可能だが V1 は no-op。
  }
}
