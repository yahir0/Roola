import 'package:freezed_annotation/freezed_annotation.dart';

part 'git_stash_entry.freezed.dart';

/// stash 1 件。
@freezed
abstract class GitStashEntry with _$GitStashEntry {
  const factory GitStashEntry({
    /// stash スタック上の位置（0 が最新）。
    required int index,

    /// `git` に渡す参照（例 `stash@{0}`）。
    required String ref,

    /// stash メッセージ（例 `WIP on main: ...`）。
    required String message,
  }) = _GitStashEntry;
}
