import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_exception.freezed.dart';

/// アプリ全体で扱う独自例外。
///
/// data 層は本型を投げ、ViewModel 側で `state.when` でハンドリングする。
/// 想定外（バグ起因）の例外はそのまま投げ直し、テスト・analyze で検出する。
@freezed
sealed class AppException with _$AppException implements Exception {
  /// 既定の状態でしか起きない不変条件の違反。
  const factory AppException.invariant(String message) = InvariantViolation;

  /// 指定したリポジトリパスが存在しない。
  const factory AppException.repositoryNotFound(String path) =
      RepositoryNotFound;

  /// `claude` CLI が PATH 上に見つからない。
  const factory AppException.claudeNotFound() = ClaudeNotFound;

  /// 永続化ファイルが読み書きできない。
  const factory AppException.persistenceFailure(String message) =
      PersistenceFailure;

  /// PTY プロセスの起動・実行で失敗した。
  const factory AppException.processFailure(String message) = ProcessFailure;

  /// `git` コマンドが PATH 上に見つからない（ADR-0030）。
  const factory AppException.gitNotFound() = GitNotFound;

  /// `git` コマンドが非ゼロ終了した。[message] は stderr の要約。
  const factory AppException.gitCommandFailure(String message) =
      GitCommandFailure;
}
