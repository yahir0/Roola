import 'package:freezed_annotation/freezed_annotation.dart';

part 'git_status.freezed.dart';

/// 作業ツリー上の 1 ファイルの変更種別。
///
/// `git status --porcelain` の XY ステータスコードを正規化したもの。
enum GitChangeType {
  /// 変更（M）。
  modified,

  /// 追加（A）。
  added,

  /// 削除（D）。
  deleted,

  /// リネーム（R）。
  renamed,

  /// コピー（C）。
  copied,

  /// 未追跡（??）。
  untracked,

  /// マージコンフリクト（U / DD / AA など）。
  conflicted,

  /// 型変更（T、シンボリックリンク化など）。
  typeChanged,
}

/// 作業ツリーまたは index 上の 1 ファイルの変更。
@freezed
abstract class GitFileChange with _$GitFileChange {
  const factory GitFileChange({
    /// リポジトリルートからの相対パス。
    required String path,

    /// 変更種別。
    required GitChangeType type,

    /// index に載っている（staged）か、作業ツリー上の変更（unstaged）か。
    required bool staged,

    /// リネーム / コピー元のパス。それ以外では `null`。
    String? originalPath,
  }) = _GitFileChange;

  const GitFileChange._();

  /// 一覧表示用のパス文字列。リネームは「元 → 先」。
  String get displayPath =>
      originalPath != null ? '$originalPath → $path' : path;
}

/// リポジトリの作業ツリー状態のスナップショット。
@freezed
abstract class GitStatus with _$GitStatus {
  const factory GitStatus({
    /// 現在のブランチ名。detached HEAD では `null`。
    String? branch,

    /// upstream の short 名（例 `origin/main`）。未設定なら `null`。
    String? upstream,

    /// upstream に対して先行しているコミット数。
    @Default(0) int ahead,

    /// upstream に対して遅れているコミット数。
    @Default(0) int behind,

    /// index に載っている変更（staged）。
    @Default(<GitFileChange>[]) List<GitFileChange> staged,

    /// 作業ツリー上の変更（unstaged、未追跡を含む）。
    @Default(<GitFileChange>[]) List<GitFileChange> unstaged,
  }) = _GitStatus;

  const GitStatus._();

  /// 作業ツリーがクリーン（staged / unstaged ともに無し）か。
  bool get isClean => staged.isEmpty && unstaged.isEmpty;

  /// コンフリクト中のファイルが 1 つでもあるか。
  bool get hasConflicts =>
      staged.any((c) => c.type == GitChangeType.conflicted) ||
      unstaged.any((c) => c.type == GitChangeType.conflicted);
}
