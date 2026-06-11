import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/exceptions/app_exception.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:roola/data/privacy/privacy_settings.dart';
import 'package:roola/data/privacy/privacy_settings_dto.dart';
import 'package:roola/data/privacy/privacy_settings_repository.dart';

/// `<appSupport>/privacy_settings.json` を保存先とする実装。
class PrivacySettingsRepositoryImpl implements PrivacySettingsRepository {
  PrivacySettingsRepositoryImpl({required this.paths});

  final AppPaths paths;

  @override
  Future<PrivacySettings> load() async {
    final file = paths.privacySettingsFile;
    if (!file.existsSync()) {
      return PrivacySettings.defaults();
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return PrivacySettings.defaults();
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return PrivacySettings.defaults();
      }
      return PrivacySettingsDto.fromJson(decoded).toEntity();
    } on FormatException {
      return PrivacySettings.defaults();
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }

  @override
  Future<void> save(PrivacySettings settings) async {
    await paths.ensureDirectories();
    try {
      await paths.privacySettingsFile.writeAsString(
        const JsonEncoder.withIndent(
          '  ',
        ).convert(PrivacySettingsDto.fromEntity(settings).toJson()),
        flush: true,
      );
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }
}

/// `PrivacySettingsRepository` の Provider。
final privacySettingsRepositoryProvider = Provider<PrivacySettingsRepository>((
  ref,
) {
  return PrivacySettingsRepositoryImpl(paths: ref.watch(appPathsProvider));
});

/// 同意状態 + アナリティクス設定そのものの AsyncNotifier。
class PrivacySettingsNotifier extends AsyncNotifier<PrivacySettings> {
  PrivacySettingsRepository get _repository =>
      ref.read(privacySettingsRepositoryProvider);

  @override
  Future<PrivacySettings> build() => _repository.load();

  /// 利用規約への同意を記録する（同意モーダルの「同意して開始」）。
  ///
  /// [analyticsEnabled] は同意モーダル上のトグルの確定値。同意と同時に
  /// 保存することで「トグル OFF で同意 → 1 件も送信されない」を保証する。
  Future<void> acceptTerms({
    required int version,
    required bool analyticsEnabled,
  }) async {
    final current = state.value ?? PrivacySettings.defaults();
    final next = current.copyWith(
      acceptedTermsVersion: version,
      analyticsEnabled: analyticsEnabled,
    );
    state = await AsyncValue.guard(() async {
      await _repository.save(next);
      return next;
    });
  }

  /// アナリティクス送信可否を切り替える（設定画面のトグル）。
  Future<void> setAnalyticsEnabled(bool enabled) async {
    final current = state.value ?? PrivacySettings.defaults();
    final next = current.copyWith(analyticsEnabled: enabled);
    state = await AsyncValue.guard(() async {
      await _repository.save(next);
      return next;
    });
  }
}

final privacySettingsProvider =
    AsyncNotifierProvider<PrivacySettingsNotifier, PrivacySettings>(
      PrivacySettingsNotifier.new,
    );
