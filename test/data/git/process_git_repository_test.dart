import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:roola/core/exceptions/app_exception.dart';
import 'package:roola/data/git/git_diff.dart';
import 'package:roola/data/git/git_status.dart';
import 'package:roola/data/git/git_worktree.dart';
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
    await run(['config', 'core.autocrlf', 'false']);
    // グローバル設定のコミット署名（1Password 等）に依存しないようにする。
    await run(['config', 'commit.gpgsign', 'false']);
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
    // p.basename で区切り文字をプラットフォーム非依存に処理する。
    expect(root, endsWith(p.basename(repo.path)));
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

  group('worktree（ADR-0067）', () {
    test('worktreeSlug はスラッシュをハイフンに変換する', () {
      expect(worktreeSlug('feat/login-form'), 'feat-login-form');
      expect(worktreeSlug('main'), 'main');
    });

    test('resolveWorktreePath は兄弟ディレクトリ配下を返し衝突を回避する', () async {
      final container = worktreeContainerPath(repo.path);
      expect(p.basename(container), '${p.basename(repo.path)}.worktrees');
      expect(p.dirname(container), p.dirname(repo.path));

      final first = resolveWorktreePath(repo.path, 'feat/x');
      expect(first, p.join(container, 'feat-x'));

      // 同名フォルダが存在するとサフィックスで回避する。
      Directory(first).createSync(recursive: true);
      addTearDown(() => Directory(container).delete(recursive: true));
      expect(resolveWorktreePath(repo.path, 'feat/x'), p.join(container, 'feat-x-2'));
    });

    test('新規ブランチで worktree を作成・一覧・削除できる', () async {
      final path = resolveWorktreePath(repo.path, 'feat/wt');
      addTearDown(() {
        final container = Directory(worktreeContainerPath(repo.path));
        if (container.existsSync()) {
          container.deleteSync(recursive: true);
        }
      });
      await git.addWorktree(repo.path, path, newBranch: 'feat/wt');

      final list = await git.listWorktrees(repo.path);
      expect(list, hasLength(2));
      expect(list.first.isMain, isTrue);
      expect(list.first.branch, 'main');
      final wt = list.last;
      expect(wt.isMain, isFalse);
      expect(wt.branch, 'feat/wt');
      expect(Directory(wt.path).existsSync(), isTrue);

      await git.removeWorktree(repo.path, wt.path);
      expect(await git.listWorktrees(repo.path), hasLength(1));
      // ブランチは残る（worktree 削除はブランチを消さない）。
      final branches = await git.branches(repo.path);
      expect(branches.any((b) => b.name == 'feat/wt'), isTrue);
    });

    test('既存ブランチで worktree を作成できる', () async {
      await run(['branch', 'existing']);
      final path = resolveWorktreePath(repo.path, 'existing');
      addTearDown(
        () => Directory(worktreeContainerPath(repo.path)).delete(recursive: true),
      );
      await git.addWorktree(repo.path, path, existingBranch: 'existing');
      final list = await git.listWorktrees(repo.path);
      expect(list.last.branch, 'existing');
    });

    test('チェックアウト済みブランチの worktree 作成は失敗する', () async {
      final path = resolveWorktreePath(repo.path, 'main');
      await expectLater(
        git.addWorktree(repo.path, path, existingBranch: 'main'),
        throwsA(isA<AppException>()),
      );
    });

    test('リモート追跡で worktree を作成できる', () async {
      // bare リポジトリを origin として push し、リモートブランチを用意する。
      final remote = await Directory.systemTemp.createTemp('roola_git_remote_');
      addTearDown(() => remote.delete(recursive: true));
      addTearDown(() {
        final container = Directory(worktreeContainerPath(repo.path));
        if (container.existsSync()) {
          container.deleteSync(recursive: true);
        }
      });
      await Process.run('git', [
        'init',
        '--bare',
      ], workingDirectory: remote.path);
      await run(['remote', 'add', 'origin', remote.path]);
      await run(['push', 'origin', 'main']);
      await run(['branch', 'feat/remote-only']);
      await run(['push', 'origin', 'feat/remote-only']);
      await run(['branch', '-D', 'feat/remote-only']);
      await run(['fetch', 'origin']);

      final path = resolveWorktreePath(repo.path, 'feat/remote-only');
      await git.addWorktree(
        repo.path,
        path,
        trackRemote: 'origin/feat/remote-only',
      );
      final wt = (await git.listWorktrees(repo.path)).last;
      expect(wt.branch, 'feat/remote-only');

      final summary = await git.worktreeStatusSummary(wt.path);
      expect(summary.isDirty, isFalse);
      expect(summary.ahead, 0);
      expect(summary.behind, 0);
    });

    test('dirty な worktree の削除は失敗し force で消せる', () async {
      final path = resolveWorktreePath(repo.path, 'feat/dirty');
      addTearDown(() {
        final container = Directory(worktreeContainerPath(repo.path));
        if (container.existsSync()) {
          container.deleteSync(recursive: true);
        }
      });
      await git.addWorktree(repo.path, path, newBranch: 'feat/dirty');
      final wt = (await git.listWorktrees(repo.path)).last;
      File(p.join(wt.path, 'dirty.txt')).writeAsStringSync('x\n');

      expect((await git.worktreeStatusSummary(wt.path)).isDirty, isTrue);
      await expectLater(
        git.removeWorktree(repo.path, wt.path),
        throwsA(isA<AppException>()),
      );
      await git.removeWorktree(repo.path, wt.path, force: true);
      expect(await git.listWorktrees(repo.path), hasLength(1));
    });

    test('直接削除された worktree は prunable になり prune で消える', () async {
      final path = resolveWorktreePath(repo.path, 'feat/orphan');
      addTearDown(() {
        final container = Directory(worktreeContainerPath(repo.path));
        if (container.existsSync()) {
          container.deleteSync(recursive: true);
        }
      });
      await git.addWorktree(repo.path, path, newBranch: 'feat/orphan');
      final wt = (await git.listWorktrees(repo.path)).last;
      // Finder 等での直接削除を再現する。
      Directory(wt.path).deleteSync(recursive: true);

      final list = await git.listWorktrees(repo.path);
      expect(list.last.isPrunable, isTrue);

      await git.pruneWorktrees(repo.path);
      expect(await git.listWorktrees(repo.path), hasLength(1));
    });

    test('defaultBranch は origin/HEAD → main の順で解決する', () async {
      // origin 未設定ならローカル main にフォールバックする。
      expect(await git.defaultBranch(repo.path), 'main');
    });

    test('mergedBranches はマージ済みブランチを返す', () async {
      // main から分岐して 1 コミット進め、main へマージする。
      await run(['checkout', '-b', 'feat/merged']);
      writeFile('m.txt', 'merged\n');
      await run(['add', '.']);
      await run(['commit', '-m', 'merged work']);
      await run(['checkout', 'main']);
      await run(['merge', '--no-edit', 'feat/merged']);
      // 未マージのブランチも用意する。
      await run(['branch', 'feat/unmerged', 'HEAD~1']);
      writeFile('u.txt', 'x\n');

      final merged = await git.mergedBranches(repo.path, 'main');
      expect(merged, contains('feat/merged'));
      expect(merged, isNot(contains('main')));
    });
  });
}
