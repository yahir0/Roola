import 'dart:convert';
import 'dart:io';

import 'package:claude_skills_launcher/core/exceptions/app_exception.dart';
import 'package:claude_skills_launcher/core/storage/app_paths.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:claude_skills_launcher/data/repo_explorer/explorer_settings.dart';
import 'package:claude_skills_launcher/data/repo_explorer/explorer_settings_dto.dart';
import 'package:claude_skills_launcher/data/repo_explorer/explorer_settings_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    final next = ExplorerSettings(rootPath: path);
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
