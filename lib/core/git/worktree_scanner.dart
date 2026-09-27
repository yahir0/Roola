import 'dart:io';

/// ディレクトリが git worktree かを判定し、チェックアウト中のブランチ名を
/// 解決するスキャナ（ADR-0067 / design D4）。
///
/// エクスプローラのタイル描画ごとに呼ばれるため、**git プロセスは起動しない**。
/// 判定はファイルシステムの読み取りのみ:
///
/// 1. `<dir>/.git` が（ディレクトリではなく）**ファイル**なら worktree
/// 2. その中身 `gitdir: <本体の .git/worktrees/<name>>` を読む
/// 3. ポインタ先の `HEAD`（`ref: refs/heads/<branch>`）からブランチ名を得る
///
/// detached HEAD では HEAD にコミット SHA が直接入っているため、短縮ハッシュ
/// （7 桁）を返す。worktree でない・読めない・形式不明なら `null`。
class WorktreeScanner {
  const WorktreeScanner();

  /// [directoryPath] が worktree ならブランチ名（detached は短縮 SHA）を返す。
  String? scan(String directoryPath) {
    if (directoryPath.isEmpty) {
      return null;
    }
    final dotGit = File('$directoryPath/.git');
    try {
      // `.git` がディレクトリなら通常のリポジトリ、無ければ非 repo。
      if (!dotGit.existsSync()) {
        return null;
      }
      final content = dotGit.readAsStringSync().trim();
      if (!content.startsWith('gitdir:')) {
        return null;
      }
      var gitdir = content.substring('gitdir:'.length).trim();
      if (gitdir.isEmpty) {
        return null;
      }
      // 相対パス（`git worktree add` 既定は絶対だが repair 等で相対になり得る）。
      if (!_isAbsolute(gitdir)) {
        gitdir = '$directoryPath/$gitdir';
      }
      final headFile = File('$gitdir/HEAD');
      if (!headFile.existsSync()) {
        return null;
      }
      final head = headFile.readAsStringSync().trim();
      if (head.startsWith('ref: refs/heads/')) {
        return head.substring('ref: refs/heads/'.length);
      }
      // detached HEAD（SHA 直書き）。
      if (RegExp(r'^[0-9a-f]{40}$').hasMatch(head)) {
        return head.substring(0, 7);
      }
      return null;
    } on FileSystemException {
      // `.git` がディレクトリの場合の readAsStringSync 失敗もここに落ちる。
      return null;
    }
  }

  bool _isAbsolute(String path) =>
      path.startsWith('/') || RegExp(r'^[A-Za-z]:[/\\]').hasMatch(path);
}
