import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/exceptions/app_exception.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:roola/data/repo_explorer/explorer_settings.dart';
import 'package:roola/data/repo_explorer/explorer_settings_dto.dart';
import 'package:roola/data/repo_explorer/explorer_settings_repository.dart';

/// `<appSupport>/repo_explorer_settings.json` を保存先とする実装。
class ExplorerSettingsRepositoryImpl implements ExplorerSettingsRepository {
  ExplorerSettingsRepositoryImpl({required this.paths});

  final AppPaths paths;

  @override
  Future<ExplorerSettings> load() async {
    final file = paths.repoExplorerSettingsFile;
    if (!file.existsSync()) {
      return ExplorerSettings.defaults();
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return ExplorerSettings.defaults();
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return ExplorerSettings.defaults();
      }
      return ExplorerSettingsDto.fromJson(decoded).toEntity();
    } on FormatException {
      return ExplorerSettings.defaults();
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }

  @override
  Future<void> save(ExplorerSettings settings) async {
    await paths.ensureDirectories();
    try {
      await paths.repoExplorerSettingsFile.writeAsString(
        const JsonEncoder.withIndent(
          '  ',
        ).convert(ExplorerSettingsDto.fromEntity(settings).toJson()),
        flush: true,
      );
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }
}

/// `ExplorerSettingsRepository` の Provider。
final explorerSettingsRepositoryProvider = Provider<ExplorerSettingsRepository>(
  (ref) {
    return ExplorerSettingsRepositoryImpl(paths: ref.watch(appPathsProvider));
  },
);

/// エクスプローラ設定そのものの AsyncNotifier。
class ExplorerSettingsNotifier extends AsyncNotifier<ExplorerSettings> {
  ExplorerSettingsRepository get _repository =>
      ref.read(explorerSettingsRepositoryProvider);

  @override
  Future<ExplorerSettings> build() => _repository.load();

  Future<void> setRootPath(String? path) async {
    final current = state.value ?? ExplorerSettings.defaults();
    final next = current.copyWith(rootPath: path);
    state = await AsyncValue.guard(() async {
      await _repository.save(next);
      return next;
    });
  }

  /// お気に入りを末尾に追加する。同一 path が既にある場合は何もしない。
  Future<void> addFavorite(ExplorerFavorite favorite) async {
    final current = state.value ?? ExplorerSettings.defaults();
    if (current.favorites.any((f) => f.path == favorite.path)) {
      return;
    }
    final next = current.copyWith(favorites: [...current.favorites, favorite]);
    state = await AsyncValue.guard(() async {
      await _repository.save(next);
      return next;
    });
  }

  /// id 一致のお気に入りを削除する。
  Future<void> removeFavorite(String id) async {
    final current = state.value ?? ExplorerSettings.defaults();
    final next = current.copyWith(
      favorites: current.favorites
          .where((f) => f.id != id)
          .toList(growable: false),
    );
    state = await AsyncValue.guard(() async {
      await _repository.save(next);
      return next;
    });
  }

  /// id 一致のお気に入りの表示名を更新する。
  Future<void> renameFavorite(String id, String newName) async {
    final current = state.value ?? ExplorerSettings.defaults();
    final next = current.copyWith(
      favorites: [
        for (final f in current.favorites)
          if (f.id == id) f.copyWith(name: newName) else f,
      ],
    );
    state = await AsyncValue.guard(() async {
      await _repository.save(next);
      return next;
    });
  }

  /// ファイルリストの表示密度を切替える（ADR-0024）。
  Future<void> setListDensity(ExplorerListDensity density) async {
    final current = state.value ?? ExplorerSettings.defaults();
    if (current.listDensity == density) {
      return;
    }
    final next = current.copyWith(listDensity: density);
    state = await AsyncValue.guard(() async {
      await _repository.save(next);
      return next;
    });
  }
}

final explorerSettingsProvider =
    AsyncNotifierProvider<ExplorerSettingsNotifier, ExplorerSettings>(
      ExplorerSettingsNotifier.new,
    );
