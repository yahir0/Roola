import 'package:roola/data/locale/app_locale.dart';

/// 表示言語設定の永続化抽象（ADR-0034）。
abstract interface class LocaleSettingsRepository {
  /// 保存済みの表示言語を返す。未保存なら既定（日本語）を返す。
  Future<AppLocale> load();

  /// 表示言語を上書き保存する。
  Future<void> save(AppLocale locale);
}
