import 'package:roola/data/task_notification/task_notification_settings.dart';

/// タスク完了通知設定の永続化抽象（ADR-0057）。
abstract interface class TaskNotificationSettingsRepository {
  /// 保存済みの設定を返す。未保存なら既定値（無効）を返す。
  Future<TaskNotificationSettings> load();

  /// 設定を上書き保存する。
  Future<void> save(TaskNotificationSettings settings);
}
