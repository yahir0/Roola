import 'package:roola/data/privacy/privacy_settings.dart';

/// 利用規約の同意状態とアナリティクス設定の永続化抽象（ADR-0065）。
abstract interface class PrivacySettingsRepository {
  /// 保存済みの設定を返す。未保存なら既定値（未同意・アナリティクス ON）を返す。
  Future<PrivacySettings> load();

  /// 設定を上書き保存する。
  Future<void> save(PrivacySettings settings);
}
