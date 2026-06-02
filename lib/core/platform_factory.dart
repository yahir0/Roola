import 'dart:io';

/// プラットフォーム別サービス実装のセレクタユーティリティ。
///
/// 各サービスの Riverpod Provider は対応する service ファイルで
/// `Platform.isMacOS` / `Platform.isWindows` の分岐により実装を選択する:
///
/// - `TrashService`           → lib/core/system/trash_service.dart
/// - `FileOpener`             → lib/core/system/file_opener.dart
/// - `UpdateChecker`          → lib/core/system/update_checker.dart
/// - `SystemMetricsRepository`→ lib/data/activity_metrics/system_metrics_repository.dart
/// - `TaskNotificationRepository` → lib/data/task_notification/task_notification_repository.dart
///
/// 新しいプラットフォーム固有サービスを追加するときは、上記リストに追記し
/// 対応する `_macos.dart` / `_windows.dart` ファイルを作成する。

/// 現在のプラットフォームに応じた値を返すシンプルなセレクタ。
///
/// [macOS] と [windows] のどちらか一方を遅延評価（thunk）で渡す。
/// 未サポートのプラットフォームでは [UnsupportedError] を投げる。
T selectPlatform<T>({
  required T Function() macOS,
  required T Function() windows,
}) {
  if (Platform.isMacOS) return macOS();
  if (Platform.isWindows) return windows();
  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
}
