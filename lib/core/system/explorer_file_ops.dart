import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;

/// エクスプローラのファイル操作（新規作成・リネーム・移動・コピー）。
///
/// macOS / Windows 両対応。`File.rename` / `Directory.rename` / `dart:io` 再帰
/// コピーを使う薄いラッパー。失敗時は `FileSystemException` を素通しする
/// （UI 側で catch して SnackBar 表示）。
class ExplorerFileOps {
  const ExplorerFileOps();

  /// [parentPath] 直下に [name] のディレクトリを作る。
  Future<void> createDirectory(String parentPath, String name) async {
    final target = Directory(p.join(parentPath, name));
    if (target.existsSync()) {
      throw FileSystemException('既に存在します', target.path);
    }
    await target.create();
  }

  /// [parentPath] 直下に [name] の空ファイルを作る。
  Future<void> createFile(String parentPath, String name) async {
    final target = File(p.join(parentPath, name));
    if (target.existsSync() || Directory(target.path).existsSync()) {
      throw FileSystemException('既に存在します', target.path);
    }
    await target.create();
  }

  /// [oldPath] のエントリを同じ親の中で [newName] にリネームする。
  Future<void> rename(String oldPath, String newName) async {
    final normalizedOld = p.normalize(oldPath);
    final newPath = p.join(p.dirname(normalizedOld), newName);
    if (newPath == normalizedOld) {
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
  /// `dart:io` 再帰コピーで実装するため macOS / Windows 両対応。
  Future<void> copyInto(String sourcePath, String targetDir) async {
    final sep = p.separator;
    if (targetDir == sourcePath ||
        targetDir.startsWith('$sourcePath$sep')) {
      throw FileSystemException('自身またはその配下にはコピーできません', sourcePath);
    }
    final name = p.basename(sourcePath);
    final newPath = p.join(targetDir, name);
    if (FileSystemEntity.typeSync(newPath) != FileSystemEntityType.notFound) {
      throw FileSystemException('コピー先に同名の項目があります', newPath);
    }
    final type = FileSystemEntity.typeSync(sourcePath);
    if (type == FileSystemEntityType.notFound) {
      throw FileSystemException('対象が存在しません', sourcePath);
    }
    if (type == FileSystemEntityType.file) {
      await File(sourcePath).copy(newPath);
    } else {
      await _copyDirectoryRecursive(Directory(sourcePath), Directory(newPath));
    }
  }

  /// [sourcePath] を [targetDir] 直下へ移動する。
  Future<void> moveInto(String sourcePath, String targetDir) async {
    final sep = p.separator;
    if (targetDir == sourcePath ||
        targetDir.startsWith('$sourcePath$sep')) {
      throw FileSystemException('自身またはその配下には移動できません', sourcePath);
    }
    if (p.dirname(p.normalize(sourcePath)) == p.normalize(targetDir)) {
      return;
    }
    final name = p.basename(sourcePath);
    final newPath = p.join(targetDir, name);
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

  static Future<void> _copyDirectoryRecursive(
    Directory src,
    Directory dst,
  ) async {
    await dst.create(recursive: true);
    await for (final entity in src.list()) {
      final name = p.basename(entity.path);
      final dstPath = p.join(dst.path, name);
      if (entity is File) {
        await entity.copy(dstPath);
      } else if (entity is Directory) {
        await _copyDirectoryRecursive(entity, Directory(dstPath));
      }
    }
  }
}

final explorerFileOpsProvider = Provider<ExplorerFileOps>(
  (_) => const ExplorerFileOps(),
);
