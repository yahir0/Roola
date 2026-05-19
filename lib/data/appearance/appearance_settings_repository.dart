import 'package:roola/data/appearance/appearance_settings.dart';

/// 外観設定の永続化抽象。
abstract interface class AppearanceSettingsRepository {
  /// 保存済みの設定を返す。未保存なら既定値（不透明）を返す。
  Future<AppearanceSettings> load();

  /// 設定を上書き保存する。
  Future<void> save(AppearanceSettings settings);
}
