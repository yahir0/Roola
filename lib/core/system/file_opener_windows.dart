import 'dart:io';

import 'package:roola/core/system/file_opener.dart';

/// Windows 実装: `explorer.exe` を `Process.run` 経由で呼び出す。
class FileOpenerWindows implements FileOpener {
  const FileOpenerWindows();

  @override
  Future<bool> open(String path) async {
    try {
      final result = await Process.run('explorer.exe', [path]);
      // explorer.exe returns 1 when opening a file (by design), treat as success
      return result.exitCode == 0 || result.exitCode == 1;
    } on ProcessException {
      return false;
    }
  }

  @override
  Future<bool> revealInFinder(String path) async {
    try {
      // /select, highlights the file in Explorer
      final result = await Process.run('explorer.exe', ['/select,', path]);
      return result.exitCode == 0 || result.exitCode == 1;
    } on ProcessException {
      return false;
    }
  }
}
