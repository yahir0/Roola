import 'dart:io';

import 'package:claude_skills_launcher/core/image/icon_image_processor.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:claude_skills_launcher/ui/settings/settings_view_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'entry_edit_view_model.freezed.dart';
part 'entry_edit_view_model.g.dart';

/// 編集フォームの状態。
///
/// View はこの状態を購読し、入力イベントを ViewModel のメソッドへ送る。
/// `errors` はフィールド名 → エラーメッセージのマップ。空なら検証成功。
@freezed
abstract class EntryEditState with _$EntryEditState {
  const factory EntryEditState({
    required String displayName,
    required String repositoryPath,
    required String skillName,

    /// 表示中のアイコンパス。新規選択中はソース画像の絶対パス、
    /// 保存済みエントリ編集時は永続化先のパス。
    String? iconPath,

    /// 「保存ボタンを押したらこのソース画像をリサイズして保存する」用の
    /// 一時的なソースパス。null なら既存 iconPath を維持する。
    String? pendingIconSource,
    @Default(<String, String>{}) Map<String, String> errors,
    @Default(false) bool isSubmitting,
  }) = _EntryEditState;
}

/// エントリ編集 ViewModel。`entryId == null` で新規、それ以外で既存編集。
@riverpod
class EntryEditViewModel extends _$EntryEditViewModel {
  static const _uuid = Uuid();

  @override
  EntryEditState build(String? entryId) {
    if (entryId == null) {
      return const EntryEditState(
        displayName: '',
        repositoryPath: '',
        skillName: '',
      );
    }
    final entries = ref.read(settingsViewModelProvider).value ?? const [];
    final entry = entries.firstWhere(
      (e) => e.id == entryId,
      orElse: () => throw StateError('Entry not found: $entryId'),
    );
    return EntryEditState(
      displayName: entry.displayName,
      repositoryPath: entry.repositoryPath,
      skillName: entry.skillName,
      iconPath: entry.iconPath,
    );
  }

  void setDisplayName(String value) =>
      state = state.copyWith(displayName: value, errors: _clearError('displayName'));

  void setRepositoryPath(String value) => state =
      state.copyWith(repositoryPath: value, errors: _clearError('repositoryPath'));

  void setSkillName(String value) =>
      state = state.copyWith(skillName: value, errors: _clearError('skillName'));

  /// アイコン画像のソースパスを設定する。実際の保存処理は `submit` で行う。
  void setPendingIcon(String sourcePath) =>
      state = state.copyWith(pendingIconSource: sourcePath, iconPath: sourcePath);

  void clearIcon() =>
      state = state.copyWith(iconPath: null, pendingIconSource: null);

  /// 入力値を検証し、エラーがあれば state に乗せて false を返す。
  bool _validate() {
    final errors = <String, String>{};
    if (state.displayName.trim().isEmpty) {
      errors['displayName'] = '表示名を入力してください';
    }
    final repoPath = state.repositoryPath.trim();
    if (repoPath.isEmpty) {
      errors['repositoryPath'] = 'リポジトリパスを入力してください';
    } else if (!Directory(repoPath).existsSync()) {
      errors['repositoryPath'] = '指定されたディレクトリが見つかりません';
    }
    if (state.skillName.trim().isEmpty) {
      errors['skillName'] = 'Skill 名を入力してください';
    }
    state = state.copyWith(errors: errors);
    return errors.isEmpty;
  }

  /// 保存処理。バリデーション → アイコン保存 → リポジトリ書き込みの順。
  ///
  /// 成功時に true、検証エラー時に false を返す。
  Future<bool> submit() async {
    if (!_validate()) {
      return false;
    }
    state = state.copyWith(isSubmitting: true);
    try {
      final paths = await ref.read(appPathsProvider.future);
      final isNew = entryId == null;
      final id = isNew ? _uuid.v4() : entryId!;
      String? finalIconPath = state.iconPath;
      final pending = state.pendingIconSource;
      if (pending != null) {
        final destination = File('${paths.iconsDir.path}/$id.png');
        await const IconImageProcessor().resizeAndSave(File(pending), destination);
        finalIconPath = destination.path;
      }
      final entry = LauncherEntry(
        id: id,
        displayName: state.displayName.trim(),
        repositoryPath: state.repositoryPath.trim(),
        skillName: state.skillName.trim(),
        iconPath: finalIconPath,
        createdAt: isNew
            ? DateTime.now()
            : _existingCreatedAt(id) ?? DateTime.now(),
      );
      final settings = ref.read(settingsViewModelProvider.notifier);
      if (isNew) {
        await settings.addEntry(entry);
      } else {
        await settings.updateEntry(entry);
      }
      state = state.copyWith(isSubmitting: false, pendingIconSource: null);
      return true;
    } finally {
      if (state.isSubmitting) {
        state = state.copyWith(isSubmitting: false);
      }
    }
  }

  DateTime? _existingCreatedAt(String id) {
    final entries = ref.read(settingsViewModelProvider).value ?? const [];
    for (final e in entries) {
      if (e.id == id) {
        return e.createdAt;
      }
    }
    return null;
  }

  Map<String, String> _clearError(String key) {
    if (!state.errors.containsKey(key)) {
      return state.errors;
    }
    final next = Map<String, String>.from(state.errors)..remove(key);
    return next;
  }
}
