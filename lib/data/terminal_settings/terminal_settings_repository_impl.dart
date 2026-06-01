import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:roola/data/terminal_runner/windows_shell.dart';
import 'package:roola/data/terminal_settings/terminal_settings.dart';
import 'package:roola/data/terminal_settings/terminal_settings_dto.dart';
import 'package:roola/data/terminal_settings/terminal_settings_repository.dart';

class TerminalSettingsRepositoryImpl implements TerminalSettingsRepository {
  const TerminalSettingsRepositoryImpl({required this.paths});

  final AppPaths paths;

  @override
  Future<TerminalSettings> load() async {
    final file = paths.terminalSettingsFile;
    if (!file.existsSync()) {
      return TerminalSettings.defaults();
    }
    try {
      final json =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      return TerminalSettingsDto.fromJson(json).toModel();
    } catch (_) {
      return TerminalSettings.defaults();
    }
  }

  @override
  Future<void> save(TerminalSettings settings) async {
    final file = paths.terminalSettingsFile;
    final json = jsonEncode(TerminalSettingsDto.fromModel(settings).toJson());
    await file.writeAsString(json);
  }
}

/// ターミナル設定の Riverpod Provider。
final terminalSettingsRepositoryProvider =
    Provider<TerminalSettingsRepository>((ref) {
      final paths = ref.watch(appPathsProvider);
      return TerminalSettingsRepositoryImpl(paths: paths);
    });

/// ターミナル設定の状態を保持する Provider。
final terminalSettingsProvider =
    AsyncNotifierProvider<TerminalSettingsNotifier, TerminalSettings>(
      TerminalSettingsNotifier.new,
    );

class TerminalSettingsNotifier extends AsyncNotifier<TerminalSettings> {
  @override
  Future<TerminalSettings> build() async {
    final repo = ref.watch(terminalSettingsRepositoryProvider);
    return repo.load();
  }

  Future<void> setWindowsShell(WindowsShell shell) async {
    final current = await future;
    final next = current.copyWith(windowsShell: shell);
    state = AsyncData(next);
    await ref.read(terminalSettingsRepositoryProvider).save(next);
  }
}
