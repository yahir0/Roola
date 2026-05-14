import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:roola/core/health/claude_health_check.dart';
import 'package:roola/core/skill/skill_scanner.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/launcher_entry/launcher_entries_provider.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:uuid/uuid.dart';

part 'entry_edit_view_model.freezed.dart';
part 'entry_edit_view_model.g.dart';

/// 編集フォームの状態。
///
/// View はこの状態を購読し、入力イベントを ViewModel のメソッドへ送る。
/// `errors` はフィールド名 → エラーメッセージのマップ。空なら検証成功。
///
/// 動作タイプ別の入力値（`editedCommand` / `editedKeepShell` /
/// `editedSkillName`）は、ユーザーが segment を切り替えた後に元タイプへ
/// 戻したときに値が消えないよう、`action` とは別フィールドとして保持する。
/// バリデーション・保存時にはアクティブな `action` 内のフィールドを参照する。
@freezed
abstract class EntryEditState with _$EntryEditState {
  const factory EntryEditState({
    required String displayName,
    required String workingDirectory,
    required LauncherAction action,

    /// 「⚡ コマンド実行」セグメント用の編集中コマンド文字列。
    @Default('') String editedCommand,

    /// 「⚡ コマンド実行」セグメント用の「終了後シェル残留」フラグ。
    @Default(true) bool editedKeepShellAfterExit,

    /// 「🤖 Claude Skill」セグメント用の編集中 Skill 名。
    @Default('') String editedSkillName,

    /// 現在の作業ディレクトリ配下で検出された Skill 名候補。
    /// `<dir>/.claude/skills/<name>/SKILL.md` の `<name>` を集めたもの。
    @Default(<String>[]) List<String> availableSkills,

    /// 所属させるフォルダ ID。null なら root（フォルダなし、ADR-0019）。
    String? folderId,
    @Default(<String, String>{}) Map<String, String> errors,
    @Default(false) bool isSubmitting,
  }) = _EntryEditState;
}

/// エントリ編集 ViewModel。`entryId == null` で新規、それ以外で既存編集。
///
/// 動作タイプは [LauncherActionType] のセグメント切替で変わる。各タイプの
/// 入力値は [EntryEditState] の `editedXxx` 一時フィールドに保持し、
/// アクティブタイプを示す `state.action` と双方向に同期する（ユーザーが
/// 別タイプへ切り替えた後に戻ったときに値が消えないようにする）。
@riverpod
class EntryEditViewModel extends _$EntryEditViewModel {
  static const _uuid = Uuid();
  static const _scanner = SkillScanner();

  @override
  EntryEditState build(String? entryId) {
    // Claude 未導入時は Skill 候補スキャンを行わない（ADR-0022）。Skill タイプ
    // 自体が UI でほぼ無効化されるので候補列を出す意味が無い。
    final scanSkills = ref.read(claudeAvailableProvider);
    if (entryId == null) {
      return const EntryEditState(
        displayName: '',
        workingDirectory: '',
        action: LauncherAction.openHere(),
      );
    }
    final entries = ref.read(launcherEntriesProvider).value ?? const [];
    final entry = entries.firstWhere(
      (e) => e.id == entryId,
      orElse: () => throw StateError('Entry not found: $entryId'),
    );
    final command = switch (entry.action) {
      RunCommandAction(:final command) => command,
      _ => '',
    };
    final keepShell = switch (entry.action) {
      RunCommandAction(:final keepShellAfterExit) => keepShellAfterExit,
      _ => true,
    };
    final skillName = switch (entry.action) {
      ClaudeSkillAction(:final skillName) => skillName,
      _ => '',
    };
    return EntryEditState(
      displayName: entry.displayName,
      workingDirectory: entry.workingDirectory,
      action: entry.action,
      editedCommand: command,
      editedKeepShellAfterExit: keepShell,
      editedSkillName: skillName,
      availableSkills: scanSkills
          ? _scanner.scan(entry.workingDirectory)
          : const [],
      folderId: entry.folderId,
    );
  }

  /// 所属フォルダを変更する。null は root（フォルダなし）。
  void setFolderId(String? folderId) =>
      state = state.copyWith(folderId: folderId);

  void setDisplayName(String value) => state = state.copyWith(
    displayName: value,
    errors: _clearError('displayName'),
  );

  void setWorkingDirectory(String value) {
    final scanSkills = ref.read(claudeAvailableProvider);
    state = state.copyWith(
      workingDirectory: value,
      errors: _clearError('workingDirectory'),
      availableSkills: scanSkills ? _scanner.scan(value) : const [],
    );
  }

  /// 動作タイプを切り替える。タイプ切替時は state.action を新タイプ +
  /// 一時値で再構築し、新タイプ用キーのエラーだけクリアする
  /// （他キーのエラーは _validate で再判定するので温存しておく）。
  void setActionType(LauncherActionType type) {
    final next = switch (type) {
      LauncherActionType.openHere => const LauncherAction.openHere(),
      LauncherActionType.runCommand => LauncherAction.runCommand(
        command: state.editedCommand,
        keepShellAfterExit: state.editedKeepShellAfterExit,
      ),
      LauncherActionType.claudeSkill => LauncherAction.claudeSkill(
        skillName: state.editedSkillName,
      ),
    };
    state = state.copyWith(
      action: next,
      errors: _clearErrors(['command', 'skillName']),
    );
  }

  /// 「⚡ コマンド実行」のコマンド文字列を更新する。一時値と state.action
  /// の対応フィールドを同時に書き換える。
  void setCommand(String value) {
    final action = state.action;
    state = state.copyWith(
      editedCommand: value,
      action: action is RunCommandAction
          ? action.copyWith(command: value)
          : action,
      errors: _clearError('command'),
    );
  }

  void setKeepShellAfterExit(bool value) {
    final action = state.action;
    state = state.copyWith(
      editedKeepShellAfterExit: value,
      action: action is RunCommandAction
          ? action.copyWith(keepShellAfterExit: value)
          : action,
    );
  }

  /// 「🤖 Claude Skill」の Skill 名を更新する。一時値と state.action の
  /// 対応フィールドを同時に書き換える。
  void setSkillName(String value) {
    final action = state.action;
    state = state.copyWith(
      editedSkillName: value,
      action: action is ClaudeSkillAction
          ? action.copyWith(skillName: value)
          : action,
      errors: _clearError('skillName'),
    );
  }

  /// 入力値を検証し、エラーがあれば state に乗せて false を返す。
  /// action タイプ別に必須フィールドが異なる（ADR-0016 / spec:
  /// launcher-config「動作タイプの相互排他性」）。
  bool _validate() {
    final errors = <String, String>{};
    if (state.displayName.trim().isEmpty) {
      errors['displayName'] = '表示名を入力してください';
    }
    final dir = state.workingDirectory.trim();
    if (dir.isEmpty) {
      errors['workingDirectory'] = '作業ディレクトリを入力してください';
    } else if (!Directory(dir).existsSync()) {
      errors['workingDirectory'] = '指定されたディレクトリが見つかりません';
    }
    switch (state.action) {
      case OpenHereAction():
        break;
      case RunCommandAction(:final command):
        if (command.trim().isEmpty) {
          errors['command'] = 'コマンドを入力してください';
        }
      case ClaudeSkillAction(:final skillName):
        if (skillName.trim().isEmpty) {
          errors['skillName'] = 'Skill 名を入力してください';
        }
    }
    state = state.copyWith(errors: errors);
    return errors.isEmpty;
  }

  /// 保存処理。バリデーション → リポジトリ書き込みの順。
  ///
  /// 成功時に true、検証エラー時に false を返す。保存される `action` は
  /// アクティブタイプの値で、他タイプ用の編集中値（editedXxx）は永続化
  /// されない。
  Future<bool> submit() async {
    if (!_validate()) {
      return false;
    }
    state = state.copyWith(isSubmitting: true);
    try {
      final isNew = entryId == null;
      final id = isNew ? _uuid.v4() : entryId!;
      final entry = LauncherEntry(
        id: id,
        displayName: state.displayName.trim(),
        workingDirectory: state.workingDirectory.trim(),
        action: _trimmedAction(state.action),
        folderId: state.folderId,
        createdAt: isNew
            ? DateTime.now()
            : _existingCreatedAt(id) ?? DateTime.now(),
      );
      final entries = ref.read(launcherEntriesProvider.notifier);
      if (isNew) {
        await entries.add(entry);
      } else {
        await entries.updateEntry(entry);
      }
      state = state.copyWith(isSubmitting: false);
      return true;
    } finally {
      if (state.isSubmitting) {
        state = state.copyWith(isSubmitting: false);
      }
    }
  }

  /// 保存直前に action 内の文字列フィールドを trim する。一時値の編集中
  /// 空白は削除して永続化する（フォームに残った末尾スペース等の事故を防ぐ）。
  LauncherAction _trimmedAction(LauncherAction action) => switch (action) {
    OpenHereAction() => action,
    RunCommandAction(:final command, :final keepShellAfterExit) =>
      LauncherAction.runCommand(
        command: command.trim(),
        keepShellAfterExit: keepShellAfterExit,
      ),
    ClaudeSkillAction(:final skillName) => LauncherAction.claudeSkill(
      skillName: skillName.trim(),
    ),
  };

  DateTime? _existingCreatedAt(String id) {
    final entries = ref.read(launcherEntriesProvider).value ?? const [];
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

  Map<String, String> _clearErrors(List<String> keys) {
    final next = Map<String, String>.from(state.errors);
    for (final key in keys) {
      next.remove(key);
    }
    return next;
  }
}
