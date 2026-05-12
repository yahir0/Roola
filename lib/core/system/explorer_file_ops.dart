import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';

/// エクスプローラのファイル操作（新規作成・リネーム・移動）。
///
/// macOS のローカル FS 前提。`File.rename` / `Directory.rename`
/// を直接呼ぶ薄いラッパー。失敗時は `FileSystemException` を素通しする
/// （UI 側で catch して SnackBar 表示）。
class ExplorerFileOps {
  const ExplorerFileOps();

  /// [parentPath] 直下に [name] のディレクトリを作る。
  /// 既存パスにヒットする場合は `FileSystemException` を投げる。
  Future<void> createDirectory(String parentPath, String name) async {
    final target = Directory(_join(parentPath, name));
    if (target.existsSync()) {
      throw FileSystemException('既に存在します', target.path);
    }
    await target.create();
  }

  /// [parentPath] 直下に [name] の空ファイルを作る。
  /// 既存パスにヒットする場合は `FileSystemException` を投げる。
  Future<void> createFile(String parentPath, String name) async {
    final target = File(_join(parentPath, name));
    if (target.existsSync() || Directory(target.path).existsSync()) {
      throw FileSystemException('既に存在します', target.path);
    }
    await target.create();
  }

  /// [oldPath] のエントリ（ファイル or ディレクトリ）を、同じ親の中で
  /// [newName] にリネームする。
  Future<void> rename(String oldPath, String newName) async {
    final newPath = _join(_parentOf(oldPath), newName);
    if (newPath == oldPath) {
      return;
    }
    if (FileSystemEntity.typeSync(newPath) != FileSystemEntityType.notFound) {
      throw FileSystemException('既に存在します', newPath);
    }
    final type = FileSystemEntity.typeSync(oldPath);
    if (type == FileSystemEntityType.directory) {
      await Directory(oldPath).rename(newPath);
    } else if (type == FileSystemEntityType.file) {
      await File(oldPath).rename(newPath);
    } else {
      throw FileSystemException('対象が存在しません', oldPath);
    }
  }

  /// [sourcePath] を [targetDir] 直下にコピーする。ディレクトリは再帰。
  /// macOS の `cp -R` を `Process.run` 経由で呼び出す（dart:io 単体だと
  /// ディレクトリの再帰コピーが提供されないため）。自身・自身の子孫への
  /// コピーや、コピー先に同名がある場合は弾く。
  Future<void> copyInto(String sourcePath, String targetDir) async {
    if (targetDir == sourcePath || targetDir.startsWith('$sourcePath/')) {
      throw FileSystemException('自身またはその配下にはコピーできません', sourcePath);
    }
    final name = _basename(sourcePath);
    final newPath = _join(targetDir, name);
    if (FileSystemEntity.typeSync(newPath) != FileSystemEntityType.notFound) {
      throw FileSystemException('コピー先に同名の項目があります', newPath);
    }
    if (FileSystemEntity.typeSync(sourcePath) ==
        FileSystemEntityType.notFound) {
      throw FileSystemException('対象が存在しません', sourcePath);
    }
    final result = await Process.run('cp', ['-R', sourcePath, newPath]);
    if (result.exitCode != 0) {
      throw FileSystemException('cp が異常終了しました: ${result.stderr}', sourcePath);
    }
  }

  /// [sourcePath] を [targetDir] 直下へ移動する。同一ボリュームなら
  /// `rename` で原子的に処理される。クロスボリュームは `rename` が失敗
  /// するため呼び出し側でエラー表示する。
  ///
  /// 自身・自身の子孫への移動、同一親内ノーオペ移動は弾く。
  Future<void> moveInto(String sourcePath, String targetDir) async {
    if (targetDir == sourcePath || targetDir.startsWith('$sourcePath/')) {
      throw FileSystemException('自身またはその配下には移動できません', sourcePath);
    }
    if (_parentOf(sourcePath) == targetDir) {
      // 同一親に対する移動は no-op。
      return;
    }
    final name = _basename(sourcePath);
    final newPath = _join(targetDir, name);
    if (FileSystemEntity.typeSync(newPath) != FileSystemEntityType.notFound) {
      throw FileSystemException('移動先に同名の項目があります', newPath);
    }
    final type = FileSystemEntity.typeSync(sourcePath);
    if (type == FileSystemEntityType.directory) {
      await Directory(sourcePath).rename(newPath);
    } else if (type == FileSystemEntityType.file) {
      await File(sourcePath).rename(newPath);
    } else {
      throw FileSystemException('対象が存在しません', sourcePath);
    }
  }

  static String _join(String parent, String name) {
    final cleanedParent = parent.endsWith('/') && parent.length > 1
        ? parent.substring(0, parent.length - 1)
        : parent;
    return '$cleanedParent/$name';
  }

  static String _parentOf(String path) {
    final normalized = path.endsWith('/') && path.length > 1
        ? path.substring(0, path.length - 1)
        : path;
    final lastSlash = normalized.lastIndexOf('/');
    if (lastSlash <= 0) {
      return '/';
    }
    return normalized.substring(0, lastSlash);
  }

  static String _basename(String path) {
    final normalized = path.endsWith('/') && path.length > 1
        ? path.substring(0, path.length - 1)
        : path;
    final segments = normalized.split('/').where((s) => s.isNotEmpty).toList();
    return segments.isEmpty ? normalized : segments.last;
  }
}

final explorerFileOpsProvider = Provider<ExplorerFileOps>(
  (_) => const ExplorerFileOps(),
);
