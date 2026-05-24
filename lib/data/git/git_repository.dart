import 'package:roola/data/git/git_branch.dart';
import 'package:roola/data/git/git_commit.dart';
import 'package:roola/data/git/git_diff.dart';
import 'package:roola/data/git/git_stash_entry.dart';
import 'package:roola/data/git/git_status.dart';

/// Git リポジトリへのアクセスを抽象化する Repository（ADR-0030）。
///
/// 実装は `git` CLI を `dart:io` の `Process` で実行する
/// [ProcessGitRepository]。UI / ViewModel はこのインターフェースだけに依存し、
/// CLI 実行・出力パースの詳細を知らない。
///
/// 失敗時は `AppException.gitNotFound` / `AppException.gitCommandFailure` を
/// 投げる。
abstract interface class GitRepository {
  /// `git` コマンドが PATH 上で実行可能か。
  Future<bool> isGitAvailable();

  /// [path] が属する Git リポジトリのルート絶対パスを返す。Git 管理下で
  /// なければ `null`。
  Future<String?> repositoryRoot(String path);

  /// 作業ツリーの状態を取得する。
  Future<GitStatus> status(String repoRoot);

  /// [paths] を index に追加する（stage）。
  Future<void> stage(String repoRoot, List<String> paths);

  /// [paths] を index から外す（unstage）。
  Future<void> unstage(String repoRoot, List<String> paths);

  /// [changes] の作業ツリー変更を破棄する。未追跡ファイルは削除する。
  Future<void> discard(String repoRoot, List<GitFileChange> changes);

  /// staged の内容を [message] でコミットする。[amend] が `true` なら直前の
  /// コミットを書き換える。
  Future<void> commit(String repoRoot, String message, {bool amend});

  /// リモートを fetch する。
  Future<void> fetch(String repoRoot);

  /// upstream から pull する。
  Future<void> pull(String repoRoot);

  /// upstream へ push する。[force] が `true` なら `--force-with-lease`。
  Future<void> push(String repoRoot, {bool force});

  /// コミット履歴を取得する。[skip] 件スキップして [limit] 件返す。
  Future<List<GitCommit>> log(String repoRoot, {int skip, int limit});

  /// ローカル・リモート追跡ブランチの一覧を取得する。
  Future<List<GitBranch>> branches(String repoRoot);

  /// [name] のブランチをチェックアウトする。
  Future<void> checkoutBranch(String repoRoot, String name);

  /// 現在の HEAD から [name] のブランチを作成し、チェックアウトする。
  Future<void> createBranch(String repoRoot, String name);

  /// [name] のブランチを現在ブランチへマージする。
  Future<void> mergeBranch(String repoRoot, String name);

  /// [name] のローカルブランチを削除する。
  Future<void> deleteBranch(String repoRoot, String name);

  /// [sha] のコミットで変更されたファイル一覧を取得する。
  Future<List<GitFileChange>> commitFiles(String repoRoot, String sha);

  /// 作業ツリー上のファイル [path] の diff を取得する。[staged] が `true`
  /// なら index と HEAD の diff。[untracked] が `true`（未追跡の新規ファイル）
  /// なら `/dev/null` との比較で全行を追加として diff 化する。
  Future<GitDiff> diffWorkingFile(
    String repoRoot,
    String path, {
    required bool staged,
    bool untracked = false,
  });

  /// コミット [sha] におけるファイル [path] の diff を取得する。
  Future<GitDiff> diffCommitFile(String repoRoot, String sha, String path);

  /// stash の一覧を取得する。
  Future<List<GitStashEntry>> stashes(String repoRoot);

  /// 作業ツリーの変更を stash に退避する。
  Future<void> stashSave(String repoRoot, {String? message});

  /// stash を作業ツリーへ適用する。[pop] が `true` なら適用後に stash から
  /// 削除する。
  Future<void> stashApply(String repoRoot, int index, {required bool pop});

  /// stash を破棄する。
  Future<void> stashDrop(String repoRoot, int index);
}
