import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_notification_settings.freezed.dart';

/// Claude Code タスク完了通知（ADR-0057）の設定。
///
/// 現状は機能の ON/OFF のみ。既定は無効（opt-in）で、ユーザーが設定画面で
/// 有効化したときに初めて macOS の通知許可を要求する。
@freezed
abstract class TaskNotificationSettings with _$TaskNotificationSettings {
  const factory TaskNotificationSettings({@Default(false) bool enabled}) =
      _TaskNotificationSettings;

  /// 既定値（無効）。
  factory TaskNotificationSettings.defaults() =>
      const TaskNotificationSettings();
}
