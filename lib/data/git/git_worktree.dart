import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' as p;

part 'git_worktree.freezed.dart';

/// worktree 1 件（`git worktree list --porcelain` の 1 ブロック）。
@freezed
abstract class GitWorktree with _$GitWorktree {
  const factory GitWorktree({
    /// worktree のルート絶対パス。
    required String path,

    /// チェックアウト中のブランチ short 名。detached HEAD なら `null`。
    String? branch,

    /// HEAD のコミット SHA。
    required String head,

    /// 本体（main worktree）か。
    required bool isMain,

    /// フォルダが直接削除される等で管理情報だけ残った孤児か
    /// （`git worktree prune` の対象）。
    @Default(false) bool isPrunable,

    /// ロック済みか（`git worktree lock`）。
    @Default(false) bool isLocked,
  }) = _GitWorktree;
}

/// worktree の軽量な作業状態（Git ビューの一覧行に出す分だけ）。
@freezed
abstract class WorktreeStatusSummary with _$WorktreeStatusSummary {
  const factory WorktreeStatusSummary({
    /// 未コミットの変更（staged / unstaged / 未追跡）があるか。
    required bool isDirty,

    /// upstream に対して先行しているコミット数。upstream 未設定なら 0。
    @Default(0) int ahead,

    /// upstream に対して遅れているコミット数。upstream 未設定なら 0。
    @Default(0) int behind,
  }) = _WorktreeStatusSummary;
}

/// ブランチ名を worktree のフォルダ名に変換する（slug 化）。
///
/// パス区切りと衝突する `/` をハイフンへ置換する（design D1）。
/// 例: `feat/login-form` → `feat-login-form`。
String worktreeSlug(String branchName) => branchName.replaceAll('/', '-');

/// worktree を集約する兄弟ディレクトリ `../<repo>.worktrees` の絶対パス。
String worktreeContainerPath(String repoRoot) {
  final normalized = p.normalize(repoRoot);
  return p.join(p.dirname(normalized), '${p.basename(normalized)}.worktrees');
}

/// [branchName] 用の worktree 作成先パスを解決する。
///
/// 既定は `../<repo>.worktrees/<slug>/`。同名フォルダが既に存在する場合は
/// `-2`, `-3`, … のサフィックスで衝突を回避する（design D1）。
String resolveWorktreePath(String repoRoot, String branchName) {
  final container = worktreeContainerPath(repoRoot);
  final slug = worktreeSlug(branchName);
  var candidate = p.join(container, slug);
  var suffix = 2;
  while (Directory(candidate).existsSync() || File(candidate).existsSync()) {
    candidate = p.join(container, '$slug-$suffix');
    suffix++;
  }
  return candidate;
}
