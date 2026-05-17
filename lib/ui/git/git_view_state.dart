import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:roola/data/git/git_branch.dart';
import 'package:roola/data/git/git_graph_row.dart';
import 'package:roola/data/git/git_stash_entry.dart';
import 'package:roola/data/git/git_status.dart';

part 'git_view_state.freezed.dart';

/// `GitViewModel` で進行中の Git 操作の種別。
///
/// `null` でない間は当該タブの操作ボタンを無効化し、多重実行を防ぐ
/// （ADR-0030 / design D4）。
enum GitOperation {
  refresh,
  stage,
  commit,
  discard,
  fetch,
  pull,
  push,
  branch,
  stash,
  loadMore,
}

/// 通知バーに出すメッセージの種別。
enum GitNoticeKind { info, error }

/// Git ビュー上部の通知バーに表示するメッセージ。
@freezed
abstract class GitNotice with _$GitNotice {
  const factory GitNotice({
    required GitNoticeKind kind,
    required String message,

    /// `true` のとき「ターミナルで開く」導線を併記する（同期失敗時など）。
    @Default(false) bool offerTerminal,
  }) = _GitNotice;
}

/// Git ビュータブ 1 つ分の表示状態（ADR-0030 / design D4）。
@freezed
abstract class GitViewState with _$GitViewState {
  const factory GitViewState({
    /// 対象リポジトリのルート絶対パス。
    required String repoRoot,

    /// `git` コマンドが利用できない、または GitTab が解決できない。
    @Default(false) bool gitMissing,

    /// 作業ツリーの状態。初回ロード前は `null`。
    GitStatus? status,

    /// ローカル・リモート追跡ブランチ一覧。
    @Default(<GitBranch>[]) List<GitBranch> branches,

    /// 履歴グラフの行。
    @Default(<GitGraphRow>[]) List<GitGraphRow> graph,

    /// さらに古い履歴を取得できる可能性があるか。
    @Default(true) bool hasMoreHistory,

    /// stash 一覧。
    @Default(<GitStashEntry>[]) List<GitStashEntry> stashes,

    /// 履歴で選択中のコミット SHA。
    String? selectedSha,

    /// 選択中コミットの変更ファイル一覧。
    @Default(<GitFileChange>[]) List<GitFileChange> selectedCommitFiles,

    /// 進行中の Git 操作。`null` なら操作可能。
    GitOperation? runningOperation,

    /// 通知バーに出すメッセージ。
    GitNotice? notice,
  }) = _GitViewState;

  const GitViewState._();

  /// 何らかの Git 操作が進行中か。
  bool get isBusy => runningOperation != null;

  /// 現在ブランチ名（detached / コミット 0 件では `null`）。
  String? get branch => status?.branch;

  /// upstream に対する先行コミット数。
  int get ahead => status?.ahead ?? 0;

  /// upstream に対する遅れコミット数。
  int get behind => status?.behind ?? 0;
}
