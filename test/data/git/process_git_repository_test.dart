import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/git/git_diff.dart';
import 'package:roola/data/git/git_status.dart';
import 'package:roola/data/git/process_git_repository.dart';

/// `ProcessGitRepository` の実 CLI 経路を、一時ディレクトリに作った実リポジトリ
/// で検証する（ADR-0030 / tasks 8.1）。`git` が PATH 上に必要。
void main() {
  late Directory repo;
  const git = ProcessGitRepository();

  /// テスト用に `git` を直接実行する（作者・コミッタを固定）。
  Future<void> run(List<String> args) async {
    final result = await Process.run(
      'git',
      args,
      workingDirectory: repo.path,
      environment: const {
        'GIT_AUTHOR_NAME': 'tester',
        'GIT_AUTHOR_EMAIL': 'tester@example.com',
        'GIT_COMMITTER_NAME': 'tester',
        'GIT_COMMITTER_EMAIL': 'tester@example.com',
      },
    );
    if (result.exitCode != 0) {
      fail('git ${args.join(' ')} failed: ${result.stderr}');
    }
  }

  void writeFile(String name, String content) {
    File('${repo.path}/$name').writeAsStringSync(content);
  }

  setUp(() async {
    repo = await Directory.systemTemp.createTemp('roola_git_repo_');
    await run(['init', '-b', 'main']);
    await run(['config', 'user.name', 'tester']);
    await run(['config', 'user.email', 'tester@example.com']);
    writeFile('a.txt', 'hello\n');
    await run(['add', '.']);
    await run(['commit', '-m', 'first commit']);
  });

  tearDown(() async {
    if (repo.existsSync()) {
      await repo.delete(recursive: true);
    }
  });

  test('isGitAvailable は true を返す', () async {
    expect(await git.isGitAvailable(), isTrue);
  });

  test('repositoryRoot はリポジトリルートを返す', () async {
    final root = await git.repositoryRoot(repo.path);
    expect(root, isNotNull);
    // macOS の一時ディレクトリは /private シンボリックリンク経由になり得る。
    expect(root, endsWith(repo.path.split('/').last));
  });

  test('repositoryRoot は Git 管理外で null を返す', () async {
    final outside = await Directory.systemTemp.createTemp('roola_no_git_');
    addTearDown(() => outside.delete(recursive: true));
    expect(await git.repositoryRoot(outside.path), isNull);
  });

  test('status はクリーンな作業ツリーを返す', () async {
    final status = await git.status(repo.path);
    expect(status.branch, 'main');
    expect(status.isClean, isTrue);
  });

  test('status は変更・stage を反映する', () async {
    writeFile('a.txt', 'hello\nworld\n');
    writeFile('b.txt', 'new file\n');

    var status = await git.status(repo.path);
    expect(status.unstaged.any((c) => c.path == 'a.txt'), isTrue);
    expect(
      status.unstaged.any(
        (c) => c.path == 'b.txt' && c.type == GitChangeType.untracked,
      ),
      isTrue,
    );

    await git.stage(repo.path, ['a.txt']);
    status = await git.status(repo.path);
    expect(status.staged.any((c) => c.path == 'a.txt'), isTrue);

    await git.unstage(repo.path, ['a.txt']);
    status = await git.status(repo.path);
    expect(status.staged, isEmpty);
  });

  test('commit と log が往復する', () async {
    writeFile('a.txt', 'changed\n');
    await git.stage(repo.path, ['a.txt']);
    await git.commit(repo.path, 'second commit');

    final commits = await git.log(repo.path);
    expect(commits.length, 2);
    expect(commits.first.subject, 'second commit');
    expect(commits.first.parents.length, 1);
    expect(commits.last.subject, 'first commit');
  });

  test('discard は作業ツリーの変更を破棄する', () async {
    writeFile('a.txt', 'dirty\n');
    final dirty = await git.status(repo.path);
    await git.discard(repo.path, dirty.unstaged);
    expect((await git.status(repo.path)).isClean, isTrue);
    expect(File('${repo.path}/a.txt').readAsStringSync(), 'hello\n');
  });

  test('ブランチの作成・一覧・切替', () async {
    await git.createBranch(repo.path, 'feature');
    var branches = await git.branches(repo.path);
    expect(branches.any((b) => b.name == 'feature' && b.isCurrent), isTrue);

    await git.checkoutBranch(repo.path, 'main');
    branches = await git.branches(repo.path);
    expect(branches.firstWhere((b) => b.name == 'main').isCurrent, isTrue);
  });

  test('diff は変更行を返す', () async {
    writeFile('a.txt', 'hello\nextra\n');
    final diff = await git.diffWorkingFile(repo.path, 'a.txt', staged: false);
    expect(diff.isBinary, isFalse);
    expect(diff.lines, isNotEmpty);
  });

  test('未追跡ファイルの diff は全行を追加として返す', () async {
    writeFile('new.md', '# title\nbody\n');
    final diff = await git.diffWorkingFile(
      repo.path,
      'new.md',
      staged: false,
      untracked: true,
    );
    expect(diff.isBinary, isFalse);
    expect(diff.hasNoChanges, isFalse);
    final additions = diff.lines.where(
      (l) => l.kind == GitDiffLineKind.addition,
    );
    expect(additions.map((l) => l.text), containsAll(['# title', 'body']));
  });

  test('commitFiles は変更ファイルを返す', () async {
    writeFile('a.txt', 'v2\n');
    await git.stage(repo.path, ['a.txt']);
    await git.commit(repo.path, 'second');
    final head = (await git.log(repo.path)).first;
    final files = await git.commitFiles(repo.path, head.sha);
    expect(files.any((f) => f.path == 'a.txt'), isTrue);
  });

  test('stash の退避・一覧・適用', () async {
    writeFile('a.txt', 'stash me\n');
    await git.stashSave(repo.path, message: 'wip');

    final stashes = await git.stashes(repo.path);
    expect(stashes, isNotEmpty);
    expect((await git.status(repo.path)).isClean, isTrue);

    await git.stashApply(repo.path, stashes.first.index, pop: true);
    expect((await git.status(repo.path)).isClean, isFalse);
  });
}
