import 'package:freezed_annotation/freezed_annotation.dart';

part 'skill_run_state.freezed.dart';

/// `SkillRunner` の実行状態。
///
/// View は `state.when` や Dart 3 のパターンマッチングでハンドリングし、
/// ヘッダー表示・終了ボタンの活性化などを切り替える。
@freezed
sealed class SkillRunState with _$SkillRunState {
  /// まだ start() を呼んでいない初期状態。
  const factory SkillRunState.idle() = SkillRunIdle;

  /// 起動処理中（PTY を作っている途中）。
  const factory SkillRunState.starting() = SkillRunStarting;

  /// PTY 上でプロセスが走っている。
  const factory SkillRunState.running() = SkillRunRunning;

  /// プロセスが正常終了した。`exitCode` は POSIX の終了コード。
  const factory SkillRunState.completed(int exitCode) = SkillRunCompleted;

  /// 起動・実行が失敗した。`message` はユーザー向けに表示するメッセージ。
  const factory SkillRunState.failed(String message) = SkillRunFailed;

  /// ユーザーがキャンセルした、または画面離脱でプロセスが破棄された。
  const factory SkillRunState.cancelled() = SkillRunCancelled;
}
