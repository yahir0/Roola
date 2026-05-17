import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:roola/data/git/git_commit.dart';

part 'git_graph_row.freezed.dart';

/// グラフ行内を縦に貫く 1 本の線分。行上端の [fromLane] から行下端の
/// [toLane] へ引かれる。同じ値なら垂直線、異なれば斜めの連結線。
@freezed
abstract class GitGraphRoute with _$GitGraphRoute {
  const factory GitGraphRoute({required int fromLane, required int toLane}) =
      _GitGraphRoute;
}

/// 履歴グラフの 1 行分の描画情報。
///
/// `git_graph_layout.dart` の `buildGitGraph` が `GitCommit` 列から計算する。
/// `CustomPainter`（`git_graph_painter.dart`）はこの行情報だけでグラフ列を
/// 描画できる。
@freezed
abstract class GitGraphRow with _$GitGraphRow {
  const factory GitGraphRow({
    /// この行のコミット。
    required GitCommit commit,

    /// コミットの丸印を打つレーン番号（0 始まり）。
    required int dotLane,

    /// この行を貫く線分群。
    required List<GitGraphRoute> routes,

    /// この行で使われるレーン数（描画幅の算出に使う）。
    required int laneCount,
  }) = _GitGraphRow;
}
