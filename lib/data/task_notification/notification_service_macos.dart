import 'package:flutter/services.dart';
import 'package:roola/data/task_notification/task_notification_repository.dart';

/// macOS 実装: `UNUserNotificationCenter` を MethodChannel 経由で呼ぶ。
///
/// 通知クリック（`UNUserNotificationCenterDelegate.didReceive`）はネイティブが
/// 同じチャネルの `notificationClicked` で逆方向に通知してくる（ADR-0066）。
class NotificationServiceMacos implements TaskNotificationRepository {
  NotificationServiceMacos() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  static const MethodChannel _channel = MethodChannel('roola/notification');

  void Function(String sessionId)? _onNotificationClick;

  @override
  set onNotificationClick(void Function(String sessionId)? handler) {
    _onNotificationClick = handler;
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (call.method == 'notificationClicked') {
      final sessionId = (call.arguments as Map?)?['sessionId'] as String?;
      if (sessionId != null && sessionId.isNotEmpty) {
        _onNotificationClick?.call(sessionId);
      }
    }
    return null;
  }

  @override
  Future<void> notify({
    required String title,
    required String body,
    String? sessionId,
  }) async {
    try {
      await _channel.invokeMethod<void>('notify', {
        'title': title,
        'body': body,
        'sessionId': ?sessionId,
      });
    } on PlatformException {
      // 通知発射の失敗は無視する。
    } on MissingPluginException {
      // ネイティブ未登録環境（テスト等）では no-op。
    }
  }

  @override
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

  @override
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

  @override
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
