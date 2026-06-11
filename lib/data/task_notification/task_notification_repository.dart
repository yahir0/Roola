import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/task_notification/notification_service_macos.dart';
import 'package:roola/data/task_notification/notification_service_windows.dart';

/// macOS の `UNAuthorizationStatus` を Dart 側で表現したもの。
enum NotificationAuthorizationStatus {
  notDetermined,
  authorized,
  denied;

  static NotificationAuthorizationStatus fromName(String? name) =>
      NotificationAuthorizationStatus.values.firstWhere(
        (s) => s.name == name,
        orElse: () => NotificationAuthorizationStatus.notDetermined,
      );
}

/// ローカル通知の抽象インタフェース（ADR-0057 / ADR-0066）。
abstract interface class TaskNotificationRepository {
  /// 通知を 1 件発射する。[sessionId] を渡すと、クリック時に
  /// [onNotificationClick] が同じ id で呼ばれる（該当ペインへのフォーカス
  /// 復帰に使う。ADR-0066）。
  Future<void> notify({
    required String title,
    required String body,
    String? sessionId,
  });

  /// [sessionId] 付き通知がクリックされたときに呼ばれるハンドラ。
  set onNotificationClick(void Function(String sessionId)? handler);

  Future<bool> requestAuthorization();
  Future<NotificationAuthorizationStatus> authorizationStatus();
  Future<void> openSystemSettings();
}

final taskNotificationRepositoryProvider = Provider<TaskNotificationRepository>(
  (ref) {
    if (Platform.isMacOS) return NotificationServiceMacos();
    if (Platform.isWindows) return NotificationServiceWindows();
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  },
);

final notificationAuthorizationProvider =
    FutureProvider<NotificationAuthorizationStatus>((ref) {
      return ref.read(taskNotificationRepositoryProvider).authorizationStatus();
    });
