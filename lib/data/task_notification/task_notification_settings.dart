import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_notification_settings.freezed.dart';

/// Claude Code タスク完了通知（ADR-0057）の設定。
///
/// 既定は無効（opt-in）で、ユーザーが設定画面で有効化したときに初めて
/// 通知許可を要求する。`preferredPort` は null のとき既定ポートを使う。
@freezed
abstract class TaskNotificationSettings with _$TaskNotificationSettings {
  const factory TaskNotificationSettings({
    @Default(false) bool enabled,
    int? preferredPort,
  }) = _TaskNotificationSettings;

  /// 既定値（無効・ポート未指定）。
  factory TaskNotificationSettings.defaults() =>
      const TaskNotificationSettings();
}
