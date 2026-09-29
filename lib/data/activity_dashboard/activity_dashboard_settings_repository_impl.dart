import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/exceptions/app_exception.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/activity_dashboard/activity_dashboard_settings.dart';
import 'package:roola/data/activity_dashboard/activity_dashboard_settings_dto.dart';
import 'package:roola/data/activity_dashboard/activity_dashboard_settings_repository.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';

/// `<appSupport>/activity_dashboard.json` を保存先とする実装。
class ActivityDashboardSettingsRepositoryImpl
    implements ActivityDashboardSettingsRepository {
  ActivityDashboardSettingsRepositoryImpl({required this.paths});

  final AppPaths paths;

  @override
  Future<ActivityDashboardSettings> load() async {
    final file = paths.activityDashboardSettingsFile;
    if (!file.existsSync()) {
      return ActivityDashboardSettings.defaults();
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return ActivityDashboardSettings.defaults();
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return ActivityDashboardSettings.defaults();
      }
      return ActivityDashboardSettingsDto.fromJson(decoded).toEntity();
    } on FormatException {
      return ActivityDashboardSettings.defaults();
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }

  @override
  Future<void> save(ActivityDashboardSettings settings) async {
    await paths.ensureDirectories();
    try {
      await paths.activityDashboardSettingsFile.writeAsString(
        const JsonEncoder.withIndent(
          '  ',
        ).convert(ActivityDashboardSettingsDto.fromEntity(settings).toJson()),
        flush: true,
      );
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }
}

/// `ActivityDashboardSettingsRepository` の Provider。
final activityDashboardSettingsRepositoryProvider =
    Provider<ActivityDashboardSettingsRepository>((ref) {
      return ActivityDashboardSettingsRepositoryImpl(
        paths: ref.watch(appPathsProvider),
      );
    });

/// アクティビティタブ表示設定の AsyncNotifier。
///
/// 変更は即座に state へ反映し（切替の体感を遅らせない）、保存は後追いで行う。
/// 保存に失敗しても表示は変更後のまま保つ（次回起動時に戻るだけで実害は小さい）。
class ActivityDashboardSettingsNotifier
    extends AsyncNotifier<ActivityDashboardSettings> {
  ActivityDashboardSettingsRepository get _repository =>
      ref.read(activityDashboardSettingsRepositoryProvider);

  @override
  Future<ActivityDashboardSettings> build() => _repository.load();

  Future<void> setMode(ActivityDisplayMode mode) =>
      _update((s) => s.copyWith(mode: mode));

  Future<void> setTachoStyle(TachoStyle style) =>
      _update((s) => s.copyWith(tachoStyle: style));

  Future<void> setShowAllCores({required bool value}) =>
      _update((s) => s.copyWith(showAllCores: value));

  Future<void> _update(
    ActivityDashboardSettings Function(ActivityDashboardSettings) change,
  ) async {
    final next = change(state.value ?? ActivityDashboardSettings.defaults());
    state = AsyncData(next);
    try {
      await _repository.save(next);
    } on AppException {
      // 保存失敗は表示に影響させない。
    }
  }
}

final activityDashboardSettingsProvider =
    AsyncNotifierProvider<
      ActivityDashboardSettingsNotifier,
      ActivityDashboardSettings
    >(ActivityDashboardSettingsNotifier.new);
