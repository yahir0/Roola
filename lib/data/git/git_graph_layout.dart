import 'package:roola/data/git/git_commit.dart';
import 'package:roola/data/git/git_graph_row.dart';

/// コミット列（新しい順）から履歴グラフ各行のレーン配置を計算する純粋関数
/// （ADR-0030 / design D5）。
///
/// アルゴリズムは「アクティブレーン」方式。`lanes[i]` は、そのレーンが次に
/// 出会うことを期待しているコミット SHA を保持する（`null` は空きレーン）。
/// 各コミット行で:
///
/// 1. そのコミット SHA を期待しているレーンを探す（無ければ空きレーンを取る）。
///    そこに丸印（[GitGraphRow.dotLane]）を打つ。
/// 2. コミットの親をレーンへ割り当て、丸印から下へ伸びる線分を引く。第 1 親は
///    可能ならコミットと同じレーンを引き継ぐ。
/// 3. コミットレーン以外の継続中レーンは、次の行へ向かう線分として通す。
///
/// レーン交差の最小化など高度な最適化は行わない（ADR-0030 / design O3）。
List<GitGraphRow> buildGitGraph(List<GitCommit> commits) {
  final rows = <GitGraphRow>[];
  // 各レーンが次に期待する SHA。null は空き。
  var lanes = <String?>[];

  int allocateLane(List<String?> ls) {
    final free = ls.indexOf(null);
    if (free != -1) {
      return free;
    }
    ls.add(null);
    return ls.length - 1;
  }

  for (final commit in commits) {
    var dotLane = lanes.indexOf(commit.sha);
    if (dotLane == -1) {
      dotLane = allocateLane(lanes);
    }
    lanes[dotLane] = commit.sha;

    // 次の行のレーン状態を構築する。コミットレーンはいったん空ける。
    final next = List<String?>.from(lanes);
    next[dotLane] = null;
    final routes = <GitGraphRoute>[];

    // 親をレーンへ割り当て、丸印から下への線分を引く。
    for (var p = 0; p < commit.parents.length; p++) {
      final parent = commit.parents[p];
      var target = next.indexOf(parent);
      if (target == -1) {
        // 第 1 親は可能ならコミットレーンをそのまま引き継ぐ。
        if (p == 0 && next[dotLane] == null) {
          target = dotLane;
        } else {
          target = allocateLane(next);
        }
        next[target] = parent;
      }
      routes.add(GitGraphRoute(fromLane: dotLane, toLane: target));
    }

    // コミットレーン以外の継続レーンを次の行へ通す。
    for (var l = 0; l < lanes.length; l++) {
      if (l == dotLane) {
        continue;
      }
      final sha = lanes[l];
      if (sha == null) {
        continue;
      }
      final to = next.indexOf(sha);
      if (to != -1) {
        routes.add(GitGraphRoute(fromLane: l, toLane: to));
      }
    }

    var laneCount = dotLane + 1;
    if (lanes.length > laneCount) {
      laneCount = lanes.length;
    }
    if (next.length > laneCount) {
      laneCount = next.length;
    }
    for (final r in routes) {
      if (r.fromLane + 1 > laneCount) {
        laneCount = r.fromLane + 1;
      }
      if (r.toLane + 1 > laneCount) {
        laneCount = r.toLane + 1;
      }
    }

    rows.add(
      GitGraphRow(
        commit: commit,
        dotLane: dotLane,
        routes: routes,
        laneCount: laneCount,
      ),
    );

    // 末尾の空きレーンを刈り取って次の行へ。
    while (next.isNotEmpty && next.last == null) {
      next.removeLast();
    }
    lanes = next;
  }

  return rows;
}
