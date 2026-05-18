import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/exceptions/app_exception.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/key_chord.dart';
import 'package:roola/data/keybindings/keybindings.dart';
import 'package:roola/data/keybindings/keybindings_dto.dart';
import 'package:roola/data/keybindings/keybindings_repository.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';

/// `<appSupport>/keybindings.json` を保存先とする実装。
class KeybindingsRepositoryImpl implements KeybindingsRepository {
  KeybindingsRepositoryImpl({required this.paths});

  final AppPaths paths;

  @override
  Future<Keybindings> load() async {
    final file = paths.keybindingsFile;
    if (!file.existsSync()) {
      return Keybindings.empty();
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return Keybindings.empty();
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return Keybindings.empty();
      }
      return KeybindingsDto.fromJson(decoded).toEntity();
    } on FormatException {
      return Keybindings.empty();
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }

  @override
  Future<void> save(Keybindings keybindings) async {
    await paths.ensureDirectories();
    try {
      await paths.keybindingsFile.writeAsString(
        const JsonEncoder.withIndent(
          '  ',
        ).convert(KeybindingsDto.fromEntity(keybindings).toJson()),
        flush: true,
      );
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }
}

/// `KeybindingsRepository` の Provider。
final keybindingsRepositoryProvider = Provider<KeybindingsRepository>((ref) {
  return KeybindingsRepositoryImpl(paths: ref.watch(appPathsProvider));
});

/// ユーザーのキー割り当て上書きを保持・更新する AsyncNotifier。
///
/// 既定キーコンビは `CommandRegistry` 側にあり、本 Notifier は「既定から
/// 変更した分」だけを持つ。`effectiveKeybindingsProvider` が両者をマージする。
class KeybindingsNotifier extends AsyncNotifier<Keybindings> {
  KeybindingsRepository get _repository =>
      ref.read(keybindingsRepositoryProvider);

  @override
  Future<Keybindings> build() => _repository.load();

  /// コマンドにキーコンビを割り当てる（上書き）。
  Future<void> setChord(CommandId id, KeyChord chord) async {
    final current = state.value ?? Keybindings.empty();
    final next = current.copyWith(
      overrides: {...current.overrides, id: chord},
    );
    state = await AsyncValue.guard(() async {
      await _repository.save(next);
      return next;
    });
  }

  /// コマンドの上書きを削除し、既定キーコンビに戻す。
  Future<void> resetToDefault(CommandId id) async {
    final current = state.value ?? Keybindings.empty();
    if (!current.overrides.containsKey(id)) {
      return;
    }
    final next = current.copyWith(
      overrides: {...current.overrides}..remove(id),
    );
    state = await AsyncValue.guard(() async {
      await _repository.save(next);
      return next;
    });
  }

  /// 全コマンドの上書きを削除し、すべて既定キーコンビに戻す。
  Future<void> resetAll() async {
    const next = Keybindings();
    state = await AsyncValue.guard(() async {
      await _repository.save(next);
      return next;
    });
  }
}

/// ユーザーのキー割り当て上書きの Provider。
final keybindingsProvider =
    AsyncNotifierProvider<KeybindingsNotifier, Keybindings>(
      KeybindingsNotifier.new,
    );
