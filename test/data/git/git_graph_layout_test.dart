import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/git/git_commit.dart';
import 'package:roola/data/git/git_graph_layout.dart';

/// 指定 sha・親で最小限の [GitCommit] を作る。
GitCommit _commit(String sha, List<String> parents) => GitCommit(
  sha: sha,
  parents: parents,
  subject: sha,
  authorName: 'tester',
  authorEmail: 't@example.com',
  date: DateTime(2026),
);

void main() {
  group('buildGitGraph', () {
    test('空のコミット列は空のグラフになる', () {
      expect(buildGitGraph(const []), isEmpty);
    });

    test('直線履歴は全行が同じレーンに乗る', () {
      final rows = buildGitGraph([
        _commit('c', ['b']),
        _commit('b', ['a']),
        _commit('a', const []),
      ]);

      expect(rows.length, 3);
      expect(rows.every((r) => r.dotLane == 0), isTrue);
      expect(rows.every((r) => r.laneCount == 1), isTrue);
      // 中間行は垂直の線分 1 本、root 行は線分なし。
      expect(rows[0].routes.single, isA<Object>());
      expect(rows[0].routes.single.fromLane, 0);
      expect(rows[0].routes.single.toLane, 0);
      expect(rows[2].routes, isEmpty);
    });

    test('分岐とマージで複数レーンになる', () {
      // m ──┬── b ──┐
      //     └── c ──┴── a
      final rows = buildGitGraph([
        _commit('m', ['b', 'c']),
        _commit('b', ['a']),
        _commit('c', ['a']),
        _commit('a', const []),
      ]);

      expect(rows.length, 4);

      // マージコミットは丸印から 2 本の線分が下りる。
      final mergeRow = rows.firstWhere((r) => r.commit.sha == 'm');
      expect(mergeRow.dotLane, 0);
      expect(mergeRow.routes.where((r) => r.fromLane == 0).length, 2);
      expect(mergeRow.laneCount, greaterThanOrEqualTo(2));

      // c は別レーン、a で再び 1 レーンに戻る。
      final cRow = rows.firstWhere((r) => r.commit.sha == 'c');
      expect(cRow.dotLane, greaterThan(0));
      final aRow = rows.firstWhere((r) => r.commit.sha == 'a');
      expect(aRow.routes, isEmpty);
    });
  });
}
