import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/exceptions/app_exception.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:roola/data/locale/app_locale.dart';
import 'package:roola/data/locale/locale_settings_repository.dart';

/// `<appSupport>/locale_settings.json` を保存先とする実装（ADR-0034）。
///
/// 設定値は `AppLocale` という単一の enum のため、`appearance` のような
/// DTO ⇄ モデル分離は置かず、JSON（`{"locale": "<code>"}`）と enum を
/// このクラスで直接変換する。
class LocaleSettingsRepositoryImpl implements LocaleSettingsRepository {
  LocaleSettingsRepositoryImpl({required this.paths});

  final AppPaths paths;

  /// JSON のキー名。
  static const String _localeKey = 'locale';

  @override
  Future<AppLocale> load() async {
    final file = paths.localeSettingsFile;
    if (!file.existsSync()) {
      return AppLocale.defaultLocale;
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return AppLocale.defaultLocale;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return AppLocale.defaultLocale;
      }
      return AppLocale.fromCode(decoded[_localeKey] as String?);
    } on FormatException {
      return AppLocale.defaultLocale;
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }

  @override
  Future<void> save(AppLocale locale) async {
    await paths.ensureDirectories();
    try {
      await paths.localeSettingsFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert({_localeKey: locale.code}),
        flush: true,
      );
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }
}

/// `LocaleSettingsRepository` の Provider。
final localeSettingsRepositoryProvider = Provider<LocaleSettingsRepository>((
  ref,
) {
  return LocaleSettingsRepositoryImpl(paths: ref.watch(appPathsProvider));
});

/// 起動時に 1 度だけ読み込んだ表示言語の初期値。
///
/// `MaterialApp` は初回フレームから確定した言語で描画する必要があるため、
/// `appearance` のような `AsyncNotifier` 読み込みではなく `main()` で
/// 同期解決し、`overrideWithValue` で注入する（ADR-0028 / ADR-0034）。
final localeSettingsInitialProvider = Provider<AppLocale>((ref) {
  throw UnimplementedError(
    'localeSettingsInitialProvider must be overridden in main()',
  );
});

/// 現在の表示言語を保持し、切り替えを永続化する `Notifier`。
class AppLocaleNotifier extends Notifier<AppLocale> {
  LocaleSettingsRepository get _repository =>
      ref.read(localeSettingsRepositoryProvider);

  @override
  AppLocale build() => ref.read(localeSettingsInitialProvider);

  /// 表示言語を切り替え、`locale_settings.json` へ即保存する。
  Future<void> setLocale(AppLocale locale) async {
    if (state == locale) {
      return;
    }
    state = locale;
    await _repository.save(locale);
  }
}

/// アプリ全体の表示言語の Provider。`MaterialApp` と設定画面が参照する。
final appLocaleProvider = NotifierProvider<AppLocaleNotifier, AppLocale>(
  AppLocaleNotifier.new,
);
