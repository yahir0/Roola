import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola/core/git/worktree_scanner.dart';

/// `WorktreeScanner` の FS 判定（git プロセス不使用 / ADR-0067 design D4）。
void main() {
  const scanner = WorktreeScanner();
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('roola_wt_scan_');
  });

  tearDown(() async {
    if (root.existsSync()) {
      await root.delete(recursive: true);
    }
  });

  /// worktree 構造（`.git` ファイル + ポインタ先の HEAD）を作る。
  Directory makeWorktree(String name, {required String head}) {
    // 本体側の管理ディレクトリ `.git/worktrees/<name>`。
    final gitdir = Directory('${root.path}/main/.git/worktrees/$name')
      ..createSync(recursive: true);
    File('${gitdir.path}/HEAD').writeAsStringSync('$head\n');
    // worktree 側: `.git` はポインタファイル。
    final wt = Directory('${root.path}/$name')..createSync();
    File('${wt.path}/.git').writeAsStringSync('gitdir: ${gitdir.path}\n');
    return wt;
  }

  test('worktree ならブランチ名を返す', () {
    final wt = makeWorktree('feat-x', head: 'ref: refs/heads/feat/x');
    expect(scanner.scan(wt.path), 'feat/x');
  });

  test('detached HEAD なら短縮ハッシュを返す', () {
    final wt = makeWorktree(
      'detached',
      head: 'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0',
    );
    expect(scanner.scan(wt.path), 'a1b2c3d');
  });

  test('通常のリポジトリ（.git がディレクトリ）は null', () {
    final repo = Directory('${root.path}/repo/.git')
      ..createSync(recursive: true);
    expect(scanner.scan(Directory(repo.parent.path).path), isNull);
  });

  test('非リポジトリは null', () {
    final plain = Directory('${root.path}/plain')..createSync();
    expect(scanner.scan(plain.path), isNull);
  });

  test('gitdir ポインタが壊れていても落ちずに null', () {
    final wt = Directory('${root.path}/broken')..createSync();
    File('${wt.path}/.git').writeAsStringSync(
      'gitdir: ${root.path}/main/.git/worktrees/gone\n',
    );
    expect(scanner.scan(wt.path), isNull);
  });

  test('gitdir 形式でない .git ファイルは null', () {
    final wt = Directory('${root.path}/weird')..createSync();
    File('${wt.path}/.git').writeAsStringSync('not a pointer\n');
    expect(scanner.scan(wt.path), isNull);
  });
}
