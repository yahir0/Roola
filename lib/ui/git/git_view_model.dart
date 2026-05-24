import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:roola/core/exceptions/app_exception.dart';
import 'package:roola/data/fs_watcher/directory_watcher.dart';
import 'package:roola/data/git/git_diff.dart';
import 'package:roola/data/git/git_graph_layout.dart';
import 'package:roola/data/git/git_status.dart';
import 'package:roola/data/git/process_git_repository.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/git/git_view_state.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';

part 'git_view_model.g.dart';

/// 履歴の 1 ページあたりの取得件数（ADR-0030 / design D4）。
const int _historyPageSize = 200;

/// Git ビュータブ 1 つ分の ViewModel（`AsyncNotifier.family(tabId)` /
/// keepAlive / ADR-0027・ADR-0030）。
///
/// `build` で対象 `GitTab` の `repoRoot` を解決し、`git` の可用性を確認した
/// うえで status / 履歴 / ブランチ / stash をまとめて取得する。各アクションは
/// `runningOperation` で直列化し、完了後に必要なデータを再取得する。
///
/// keepAlive のため、タブを別ペインへ DnD 移動して widget が remount されても
/// 履歴・選択は保持される。破棄はタブを閉じたときに `Workspace.closeTab` から
/// 明示 invalidate される。
@Riverpod(keepAlive: true)
class GitViewModel extends _$GitViewModel {
  static const _watcher = DirectoryWatcher();

  StreamSubscription<void>? _watchSub;

  @override
  Future<GitViewState> build(String tabId) async {
    final tab = ref.read(workspaceProvider.notifier).tabById(tabId);
    final repoRoot = tab is GitTab ? tab.repoRoot : null;
    if (repoRoot == null) {
      // GitTab として解決できない（通常起きない）。
      return const GitViewState(repoRoot: '', gitMissing: true);
    }

    final repo = ref.read(gitRepositoryProvider);
    if (!await repo.isGitAvailable()) {
      return GitViewState(repoRoot: repoRoot, gitMissing: true);
    }

    ref.onDispose(() {
      _watchSub?.cancel();
      _watchSub = null;
    });
    _startWatch(repoRoot);

    try {
      return await _load(repoRoot);
    } on AppException catch (e) {
      // リポジトリ状態の取得に失敗。toolbar は出しつつ通知で知らせる。
      return GitViewState(
        repoRoot: repoRoot,
        notice: GitNotice(kind: GitNoticeKind.error, message: _messageOf(e)),
      );
    }
  }

  /// repoRoot を再帰監視し、作業ツリー / `.git` の変更で再ロードする
  /// （ADR-0041）。`.git/objects/`・`.git/logs/`・`.git/lfs/` 配下はノイズ源と
  /// して除外する。自プロセスが git コマンド実行中（`runningOperation != null`）
  /// は再ロードをスキップする（_perform 側が完了時に再ロードするため）。
  void _startWatch(String repoRoot) {
    _watchSub?.cancel();
    _watchSub = _watcher
        .watch(repoRoot, recursive: true, exclude: _shouldIgnoreGitPath)
        .listen((_) async {
          final current = _current;
          if (current == null || current.isBusy) {
            return;
          }
          try {
            final reloaded = await _load(current.repoRoot);
            // 監視イベントは時間差で到着し得るので、再ロード中に他の操作で
            // state が動いていた場合は notice 等の最新情報を温存する。
            final latest = _current ?? current;
            state = AsyncData(
              reloaded.copyWith(
                runningOperation: latest.runningOperation,
                notice: latest.notice,
                selectedSha: latest.selectedSha,
                selectedCommitFiles: latest.selectedCommitFiles,
              ),
            );
          } on AppException {
            // 監視起因の再ロード失敗は notice を立てないで握り潰す。次の
            // 変更イベント、もしくはユーザー操作で復帰すれば良い。
          }
        });
  }

  /// `.git/` 配下でノイズ源になりやすいサブパスを除外する。
  static bool _shouldIgnoreGitPath(String relativePath) {
    return relativePath.startsWith('.git/objects/') ||
        relativePath.startsWith('.git/logs/') ||
        relativePath.startsWith('.git/lfs/');
  }

  /// status / branches / log / stash をまとめて取得して [GitViewState] を組む。
  Future<GitViewState> _load(String repoRoot) async {
    final repo = ref.read(gitRepositoryProvider);
    final status = await repo.status(repoRoot);
    final branches = await repo.branches(repoRoot);
    final commits = await repo.log(repoRoot, limit: _historyPageSize);
    final stashes = await repo.stashes(repoRoot);
    return GitViewState(
      repoRoot: repoRoot,
      status: status,
      branches: branches,
      graph: buildGitGraph(commits),
      hasMoreHistory: commits.length >= _historyPageSize,
      stashes: stashes,
    );
  }

  GitViewState? get _current => state.value;

  /// 操作を直列実行する共通処理。`runningOperation` 中は新規操作を弾く。
  /// 成功時はリポジトリ状態を再取得し、失敗時は通知を立てる。
  Future<void> _perform(
    GitOperation op,
    Future<void> Function(String repoRoot) action, {
    bool offerTerminalOnError = false,
  }) async {
    final current = _current;
    if (current == null || current.repoRoot.isEmpty || current.isBusy) {
      return;
    }
    final repoRoot = current.repoRoot;
    state = AsyncData(current.copyWith(runningOperation: op, notice: null));
    try {
      await action(repoRoot);
      final reloaded = await _load(repoRoot);
      state = AsyncData(reloaded);
    } on AppException catch (e) {
      state = AsyncData(
        (_current ?? current).copyWith(
          runningOperation: null,
          notice: GitNotice(
            kind: GitNoticeKind.error,
            message: _messageOf(e),
            offerTerminal: offerTerminalOnError,
          ),
        ),
      );
    }
  }

  // ---- 再読込 ------------------------------------------------------------

  /// リポジトリ状態を再取得する。
  Future<void> refresh() => _perform(GitOperation.refresh, (_) async {});

  /// 通知バーを閉じる。
  void dismissNotice() {
    final current = _current;
    if (current != null) {
      state = AsyncData(current.copyWith(notice: null));
    }
  }

  // ---- ステージング / コミット -------------------------------------------

  /// 指定ファイルを stage する。
  Future<void> stage(List<GitFileChange> changes) => _perform(
    GitOperation.stage,
    (repoRoot) => ref.read(gitRepositoryProvider).stage(repoRoot, [
      for (final c in changes) c.path,
    ]),
  );

  /// 指定ファイルを unstage する。
  Future<void> unstage(List<GitFileChange> changes) => _perform(
    GitOperation.stage,
    (repoRoot) => ref.read(gitRepositoryProvider).unstage(repoRoot, [
      for (final c in changes) c.path,
    ]),
  );

  /// 作業ツリーの全変更を stage する。
  Future<void> stageAll() {
    final unstaged = _current?.status?.unstaged ?? const [];
    return stage(unstaged);
  }

  /// 全 staged を unstage する。
  Future<void> unstageAll() {
    final staged = _current?.status?.staged ?? const [];
    return unstage(staged);
  }

  /// 指定ファイルの作業ツリー変更を破棄する。
  Future<void> discard(List<GitFileChange> changes) => _perform(
    GitOperation.discard,
    (repoRoot) => ref.read(gitRepositoryProvider).discard(repoRoot, changes),
  );

  /// staged の内容をコミットする。
  Future<void> commit(String message, {bool amend = false}) => _perform(
    GitOperation.commit,
    (repoRoot) =>
        ref.read(gitRepositoryProvider).commit(repoRoot, message, amend: amend),
  );

  // ---- リモート同期 ------------------------------------------------------

  /// リモートを fetch する。
  Future<void> fetch() => _perform(
    GitOperation.fetch,
    (repoRoot) => ref.read(gitRepositoryProvider).fetch(repoRoot),
    offerTerminalOnError: true,
  );

  /// upstream から pull する。
  Future<void> pull() => _perform(
    GitOperation.pull,
    (repoRoot) => ref.read(gitRepositoryProvider).pull(repoRoot),
    offerTerminalOnError: true,
  );

  /// upstream へ push する。
  Future<void> push({bool force = false}) => _perform(
    GitOperation.push,
    (repoRoot) => ref.read(gitRepositoryProvider).push(repoRoot, force: force),
    offerTerminalOnError: true,
  );

  // ---- ブランチ ----------------------------------------------------------

  /// ブランチを切り替える。
  Future<void> checkoutBranch(String name) => _perform(
    GitOperation.branch,
    (repoRoot) =>
        ref.read(gitRepositoryProvider).checkoutBranch(repoRoot, name),
  );

  /// ブランチを作成してチェックアウトする。
  Future<void> createBranch(String name) => _perform(
    GitOperation.branch,
    (repoRoot) => ref.read(gitRepositoryProvider).createBranch(repoRoot, name),
  );

  /// ブランチを現在ブランチへマージする。
  Future<void> mergeBranch(String name) => _perform(
    GitOperation.branch,
    (repoRoot) => ref.read(gitRepositoryProvider).mergeBranch(repoRoot, name),
  );

  /// ローカルブランチを削除する。
  Future<void> deleteBranch(String name) => _perform(
    GitOperation.branch,
    (repoRoot) => ref.read(gitRepositoryProvider).deleteBranch(repoRoot, name),
  );

  // ---- 履歴 --------------------------------------------------------------

  /// さらに古い履歴を追加で読み込む。
  Future<void> loadMoreHistory() async {
    final current = _current;
    if (current == null || current.isBusy || !current.hasMoreHistory) {
      return;
    }
    state = AsyncData(
      current.copyWith(runningOperation: GitOperation.loadMore),
    );
    try {
      final existing = [for (final r in current.graph) r.commit];
      final more = await ref
          .read(gitRepositoryProvider)
          .log(
            current.repoRoot,
            skip: existing.length,
            limit: _historyPageSize,
          );
      state = AsyncData(
        (_current ?? current).copyWith(
          graph: buildGitGraph([...existing, ...more]),
          hasMoreHistory: more.length >= _historyPageSize,
          runningOperation: null,
        ),
      );
    } on AppException catch (e) {
      state = AsyncData(
        (_current ?? current).copyWith(
          runningOperation: null,
          notice: GitNotice(kind: GitNoticeKind.error, message: _messageOf(e)),
        ),
      );
    }
  }

  /// 履歴のコミットを選択し、変更ファイル一覧を取得する。
  Future<void> selectCommit(String sha) async {
    final current = _current;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(selectedSha: sha, selectedCommitFiles: const []),
    );
    try {
      final files = await ref
          .read(gitRepositoryProvider)
          .commitFiles(current.repoRoot, sha);
      final latest = _current;
      if (latest != null && latest.selectedSha == sha) {
        state = AsyncData(latest.copyWith(selectedCommitFiles: files));
      }
    } on AppException {
      // 詳細取得失敗は選択を維持したまま無視する。
    }
  }

  /// コミット選択を解除する。
  void clearSelection() {
    final current = _current;
    if (current != null) {
      state = AsyncData(
        current.copyWith(selectedSha: null, selectedCommitFiles: const []),
      );
    }
  }

  // ---- stash -------------------------------------------------------------

  /// 作業ツリーの変更を stash に退避する。
  Future<void> stashSave({String? message}) => _perform(
    GitOperation.stash,
    (repoRoot) =>
        ref.read(gitRepositoryProvider).stashSave(repoRoot, message: message),
  );

  /// stash を作業ツリーへ適用する。
  Future<void> stashApply(int index, {required bool pop}) => _perform(
    GitOperation.stash,
    (repoRoot) =>
        ref.read(gitRepositoryProvider).stashApply(repoRoot, index, pop: pop),
  );

  /// stash を破棄する。
  Future<void> stashDrop(int index) => _perform(
    GitOperation.stash,
    (repoRoot) => ref.read(gitRepositoryProvider).stashDrop(repoRoot, index),
  );

  // ---- diff（状態を変えない読み取り）------------------------------------

  /// 作業ツリー上のファイルの diff を取得する。
  Future<GitDiff> workingFileDiff(
    String path, {
    required bool staged,
    bool untracked = false,
  }) {
    final repoRoot = _current?.repoRoot ?? '';
    return ref
        .read(gitRepositoryProvider)
        .diffWorkingFile(repoRoot, path, staged: staged, untracked: untracked);
  }

  /// コミット内のファイルの diff を取得する。
  Future<GitDiff> commitFileDiff(String sha, String path) {
    final repoRoot = _current?.repoRoot ?? '';
    return ref.read(gitRepositoryProvider).diffCommitFile(repoRoot, sha, path);
  }

  String _messageOf(AppException e) => switch (e) {
    GitNotFound() => 'git コマンドが見つかりません',
    GitCommandFailure(:final message) => message,
    _ => e.toString(),
  };
}

/// [path] が属する Git リポジトリのルートを返す Provider（ADR-0030）。
///
/// エクスプローラの「Git ビューを開く」ボタンの活性判定に使う。`family`
/// 引数（パス）単位でキャッシュされるため、描画のたびに `git` を起動しない。
@riverpod
Future<String?> gitRepositoryRoot(Ref ref, String path) {
  return ref.read(gitRepositoryProvider).repositoryRoot(path);
}
