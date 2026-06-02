import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/system/file_opener_macos.dart';
import 'package:roola/core/system/file_opener_windows.dart';

/// OS デフォルトアプリで指定パス（ファイル / ディレクトリ）を開くヘルパー。
abstract interface class FileOpener {
  Future<bool> open(String path);
  Future<bool> revealInFinder(String path);
}

final fileOpenerProvider = Provider<FileOpener>((ref) {
  if (Platform.isMacOS) return const FileOpenerMacos();
  if (Platform.isWindows) return const FileOpenerWindows();
  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
});
