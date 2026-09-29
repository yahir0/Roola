import 'package:roola/data/activity_dashboard/activity_dashboard_settings.dart';

/// アクティビティタブ表示設定の永続化抽象。
abstract interface class ActivityDashboardSettingsRepository {
  /// 保存済みの設定を返す。未保存・破損時は既定値を返す。
  Future<ActivityDashboardSettings> load();

  /// 設定を上書き保存する。
  Future<void> save(ActivityDashboardSettings settings);
}
