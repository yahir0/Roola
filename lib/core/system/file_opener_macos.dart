import 'dart:io';

import 'package:roola/core/system/file_opener.dart';

/// macOS 実装: `open` コマンドを `Process.run` 経由で呼び出す。
class FileOpenerMacos implements FileOpener {
  const FileOpenerMacos();

  @override
  Future<bool> open(String path) async {
    try {
      final result = await Process.run('open', [path]);
      return result.exitCode == 0;
    } on ProcessException {
      return false;
    }
  }

  @override
  Future<bool> revealInFinder(String path) async {
    try {
      final result = await Process.run('open', ['-R', path]);
      return result.exitCode == 0;
    } on ProcessException {
      return false;
    }
  }
}
