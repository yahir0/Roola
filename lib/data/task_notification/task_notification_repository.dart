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

/// ローカル通知の抽象インタフェース（ADR-0057）。
abstract interface class TaskNotificationRepository {
  Future<void> notify({required String title, required String body});
  Future<bool> requestAuthorization();
  Future<NotificationAuthorizationStatus> authorizationStatus();
  Future<void> openSystemSettings();
}

final taskNotificationRepositoryProvider = Provider<TaskNotificationRepository>(
  (ref) {
    if (Platform.isMacOS) return const NotificationServiceMacos();
    if (Platform.isWindows) return const NotificationServiceWindows();
    throw UnsupportedError(
      'Unsupported platform: ${Platform.operatingSystem}',
    );
  },
);

final notificationAuthorizationProvider =
    FutureProvider<NotificationAuthorizationStatus>((ref) {
      return ref.read(taskNotificationRepositoryProvider).authorizationStatus();
    });
