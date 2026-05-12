import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';

/// OS デフォルトアプリで指定パス（ファイル / ディレクトリ）を開くヘルパー。
///
/// macOS 専用。`open` コマンドを `Process.run` 経由で呼び出す。テストで
/// 差し替えやすいよう `Provider` 経由で注入する。
class FileOpener {
  const FileOpener();

  /// [path] を `open` で開く。終了コード 0 なら true、それ以外（コマンド
  /// 不在や非 0 終了）は false。
  Future<bool> open(String path) async {
    try {
      final result = await Process.run('open', [path]);
      return result.exitCode == 0;
    } on ProcessException {
      return false;
    }
  }

  /// `open -R <path>` で Finder を起動し、対象を選択状態で開く。
  Future<bool> revealInFinder(String path) async {
    try {
      final result = await Process.run('open', ['-R', path]);
      return result.exitCode == 0;
    } on ProcessException {
      return false;
    }
  }
}

/// アプリ全体で共有する [FileOpener] の Provider。テスト時は
/// `overrideWithValue` で fake 実装に差し替える。
final fileOpenerProvider = Provider<FileOpener>((ref) => const FileOpener());
