import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/exceptions/app_exception.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/appearance/appearance_settings.dart';
import 'package:roola/data/appearance/appearance_settings_dto.dart';
import 'package:roola/data/appearance/appearance_settings_repository.dart';
import 'package:roola/data/appearance/polaris_accent.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';

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

  /// Polaris のアクセント色を切り替える（ADR-0038 D4）。背景モードには
  /// 影響しない独立した設定。
  Future<void> setAccent(PolarisAccent accent) async {
    final current = state.value ?? AppearanceSettings.defaults();
    final next = current.copyWith(accent: accent);
    state = await AsyncValue.guard(() async {
      await _repository.save(next);
      return next;
    });
  }

  /// 透過モードの暗幕の不透明度を更新する。値は 0.0〜1.0 にクランプ。
  Future<void> setTransparencyOpacity(double opacity) async {
    final clamped = opacity.clamp(0.0, 1.0);
    final current = state.value ?? AppearanceSettings.defaults();
    final next = current.copyWith(transparencyOpacity: clamped);
    state = await AsyncValue.guard(() async {
      await _repository.save(next);
      return next;
    });
  }

  /// 透過モード時の中央画像パスを設定する。null を渡すとクリア。
  /// 同じパスに上書きしたケースでも state の equality を確実に破る
  /// ため、ファイルの更新時刻（mtime）も併せて state に書き込む。
  /// これがないと Riverpod が「state 変化なし」と判定し widget の
  /// rebuild が走らず、Image widget が古いままになる。
  Future<void> setTransparentCenterImagePath(String? path) async {
    final mtime = path != null && File(path).existsSync()
        ? File(path).lastModifiedSync().millisecondsSinceEpoch
        : null;
    final current = state.value ?? AppearanceSettings.defaults();
    final next = current.copyWith(
      transparentCenterImagePath: path,
      transparentCenterImageMtime: mtime,
    );
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
