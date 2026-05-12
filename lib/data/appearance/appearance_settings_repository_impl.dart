import 'dart:convert';
import 'dart:io';

import 'package:claude_skills_launcher/core/exceptions/app_exception.dart';
import 'package:claude_skills_launcher/core/storage/app_paths.dart';
import 'package:claude_skills_launcher/data/appearance/appearance_settings.dart';
import 'package:claude_skills_launcher/data/appearance/appearance_settings_dto.dart';
import 'package:claude_skills_launcher/data/appearance/appearance_settings_repository.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// `<appSupport>/appearance.json` を保存先とする実装。
class AppearanceSettingsRepositoryImpl implements AppearanceSettingsRepository {
  AppearanceSettingsRepositoryImpl({required this.paths});

  final AppPaths paths;

  @override
  Future<AppearanceSettings> load() async {
    final file = paths.appearanceSettingsFile;
    if (!file.existsSync()) {
      return AppearanceSettings.defaults();
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return AppearanceSettings.defaults();
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return AppearanceSettings.defaults();
      }
      return AppearanceSettingsDto.fromJson(decoded).toEntity();
    } on FormatException {
      return AppearanceSettings.defaults();
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }

  @override
  Future<void> save(AppearanceSettings settings) async {
    await paths.ensureDirectories();
    try {
      await paths.appearanceSettingsFile.writeAsString(
        const JsonEncoder.withIndent(
          '  ',
        ).convert(AppearanceSettingsDto.fromEntity(settings).toJson()),
        flush: true,
      );
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }
}

/// `AppearanceSettingsRepository` の Provider。
final appearanceSettingsRepositoryProvider =
    Provider<AppearanceSettingsRepository>((ref) {
      return AppearanceSettingsRepositoryImpl(
        paths: ref.watch(appPathsProvider),
      );
    });

/// 外観設定そのものの AsyncNotifier。
class AppearanceSettingsNotifier extends AsyncNotifier<AppearanceSettings> {
  AppearanceSettingsRepository get _repository =>
      ref.read(appearanceSettingsRepositoryProvider);

  @override
  Future<AppearanceSettings> build() => _repository.load();

  Future<void> setMode(AppearanceMode mode) async {
    final current = state.value ?? AppearanceSettings.defaults();
    final next = current.copyWith(mode: mode);
    state = await AsyncValue.guard(() async {
      await _repository.save(next);
      return next;
    });
  }

  Future<void> setSolidColor(int argb) async {
    final current = state.value ?? AppearanceSettings.defaults();
    final next = current.copyWith(mode: AppearanceMode.solid, solidColor: argb);
    state = await AsyncValue.guard(() async {
      await _repository.save(next);
      return next;
    });
  }

  Future<void> setImagePath(String path) async {
    final current = state.value ?? AppearanceSettings.defaults();
    final next = current.copyWith(mode: AppearanceMode.image, imagePath: path);
    state = await AsyncValue.guard(() async {
      await _repository.save(next);
      return next;
    });
  }
}

final appearanceSettingsProvider =
    AsyncNotifierProvider<AppearanceSettingsNotifier, AppearanceSettings>(
      AppearanceSettingsNotifier.new,
    );
