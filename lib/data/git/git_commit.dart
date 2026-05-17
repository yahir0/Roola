import 'package:freezed_annotation/freezed_annotation.dart';

part 'git_commit.freezed.dart';

/// コミット 1 件のメタ情報。
@freezed
abstract class GitCommit with _$GitCommit {
  const factory GitCommit({
    /// 完全な commit SHA-1。
    required String sha,

    /// 親コミットの SHA 群。2 つ以上ならマージコミット。
    required List<String> parents,

    /// コミットメッセージの 1 行目。
    required String subject,

    /// 作者名。
    required String authorName,

    /// 作者メールアドレス。
    required String authorEmail,

    /// 作者日時。
    required DateTime date,

    /// このコミットを指す ref ラベル（ブランチ / タグ / `HEAD`）。
    @Default(<String>[]) List<String> refs,
  }) = _GitCommit;

  const GitCommit._();

  /// 表示用の短縮 SHA（先頭 7 桁）。
  String get shortSha => sha.length >= 7 ? sha.substring(0, 7) : sha;

  /// マージコミットか。
  bool get isMerge => parents.length > 1;
}
