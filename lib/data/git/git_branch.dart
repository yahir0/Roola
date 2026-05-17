import 'package:freezed_annotation/freezed_annotation.dart';

part 'git_branch.freezed.dart';

/// ブランチ 1 件。ローカル・リモート追跡ブランチの双方を表す。
@freezed
abstract class GitBranch with _$GitBranch {
  const factory GitBranch({
    /// short 名。ローカルは `main`、リモートは `origin/main`。
    required String name,

    /// リモート追跡ブランチか。
    required bool isRemote,

    /// 現在チェックアウト中のブランチか。
    required bool isCurrent,

    /// upstream の short 名。未設定なら `null`。
    String? upstream,

    /// upstream に対して先行しているコミット数。
    @Default(0) int ahead,

    /// upstream に対して遅れているコミット数。
    @Default(0) int behind,
  }) = _GitBranch;
}
