import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/exceptions/app_exception.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:roola/data/task_notification/task_notification_settings.dart';
import 'package:roola/data/task_notification/task_notification_settings_dto.dart';
import 'package:roola/data/task_notification/task_notification_settings_repository.dart';

/// `<appSupport>/task_notification_settings.json` を保存先とする実装。
class TaskNotificationSettingsRepositoryImpl
    implements TaskNotificationSettingsRepository {
  TaskNotificationSettingsRepositoryImpl({required this.paths});

  final AppPaths paths;

  @override
  Future<TaskNotificationSettings> load() async {
    final file = paths.taskNotificationSettingsFile;
    if (!file.existsSync()) {
      return TaskNotificationSettings.defaults();
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return TaskNotificationSettings.defaults();
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return TaskNotificationSettings.defaults();
      }
      return TaskNotificationSettingsDto.fromJson(decoded).toEntity();
    } on FormatException {
      return TaskNotificationSettings.defaults();
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }

  @override
  Future<void> save(TaskNotificationSettings settings) async {
    await paths.ensureDirectories();
    try {
      await paths.taskNotificationSettingsFile.writeAsString(
        const JsonEncoder.withIndent(
          '  ',
        ).convert(TaskNotificationSettingsDto.fromEntity(settings).toJson()),
        flush: true,
      );
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }
}

/// `TaskNotificationSettingsRepository` の Provider。
final taskNotificationSettingsRepositoryProvider =
    Provider<TaskNotificationSettingsRepository>((ref) {
      return TaskNotificationSettingsRepositoryImpl(
        paths: ref.watch(appPathsProvider),
      );
    });

/// タスク完了通知設定の AsyncNotifier。
class TaskNotificationSettingsNotifier
    extends AsyncNotifier<TaskNotificationSettings> {
  TaskNotificationSettingsRepository get _repository =>
      ref.read(taskNotificationSettingsRepositoryProvider);

  @override
  Future<TaskNotificationSettings> build() => _repository.load();

  /// 機能の ON/OFF を切り替える。許可要求はネイティブ依存のため UI 側
  /// （有効化時）が別途呼ぶ。本メソッドは設定の永続化のみを行う。
  Future<void> setEnabled(bool enabled) async {
    final current = state.value ?? TaskNotificationSettings.defaults();
    if (current.enabled == enabled) return;
    final next = current.copyWith(enabled: enabled);
    state = await AsyncValue.guard(() async {
      await _repository.save(next);
      return next;
    });
  }

  /// 待受ポートを変更する。null を渡すと既定ポートにリセットする。
  Future<void> setPreferredPort(int? port) async {
    final current = state.value ?? TaskNotificationSettings.defaults();
    if (current.preferredPort == port) return;
    final next = current.copyWith(preferredPort: port);
    state = await AsyncValue.guard(() async {
      await _repository.save(next);
      return next;
    });
  }
}

final taskNotificationSettingsProvider =
    AsyncNotifierProvider<
      TaskNotificationSettingsNotifier,
      TaskNotificationSettings
    >(TaskNotificationSettingsNotifier.new);
