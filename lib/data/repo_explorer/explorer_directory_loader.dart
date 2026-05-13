import 'dart:io';

import 'package:roola/core/skill/skill_scanner.dart';
import 'package:roola/data/repo_explorer/explorer_node.dart';

/// 指定ディレクトリ直下のディレクトリ・ファイルを列挙し、各ディレクトリで
/// `.claude/skills/` 直下を `SkillScanner` で再利用してスキャンする loader。
///
/// 再帰しない（深部は表示時に都度スキャン）。well-known なノイズ
/// （`.git` / `.DS_Store` / `node_modules` 等）は除外する。
/// ディレクトリ → ファイルの順、各ブロック内は名前昇順（大文字小文字無視）。
class ExplorerDirectoryLoader {
  const ExplorerDirectoryLoader({this.scanner = const SkillScanner()});

  final SkillScanner scanner;

  /// 表示対象から外す名前。ドット始まりでも `.claude` のような
  /// Skill 検知対象は出したいので、明示的なブロックリスト方式を取る。
  static const _hiddenNames = <String>{
    '.git',
    '.DS_Store',
    '.localized',
    'node_modules',
    '.next',
    '.cache',
    '.idea',
    '.vscode',
    'build',
    '.dart_tool',
  };

  /// [parentPath] 直下を読み、ノード一覧を返す。
  /// パスが存在しない、ディレクトリでない、読めない場合は空リスト。
  List<ExplorerNode> load(String parentPath) {
    final dir = Directory(parentPath);
    if (!dir.existsSync()) {
      return const [];
    }
    final dirs = <ExplorerDirectoryNode>[];
    final files = <ExplorerFileNode>[];
    try {
      final entities = dir.listSync(followLinks: false);
      for (final entity in entities) {
        final name = _basename(entity.path);
        if (_hiddenNames.contains(name)) {
          continue;
        }
        if (entity is Directory) {
          dirs.add(
            ExplorerDirectoryNode(
              path: entity.path,
              name: name,
              skillNames: scanner.scan(entity.path),
            ),
          );
        } else if (entity is File) {
          files.add(ExplorerFileNode(path: entity.path, name: name));
        }
        // Link 等はスキップ。followLinks: false としているのでまずここに来ない。
      }
    } on FileSystemException {
      return const [];
    }
    int byName(ExplorerNode a, ExplorerNode b) {
      final an = switch (a) {
        ExplorerDirectoryNode(:final name) => name,
        ExplorerFileNode(:final name) => name,
      };
      final bn = switch (b) {
        ExplorerDirectoryNode(:final name) => name,
        ExplorerFileNode(:final name) => name,
      };
      return an.toLowerCase().compareTo(bn.toLowerCase());
    }

    dirs.sort(byName);
    files.sort(byName);
    return [...dirs, ...files];
  }

  String _basename(String path) {
    final segments = Uri.file(
      path,
    ).pathSegments.where((s) => s.isNotEmpty).toList();
    return segments.isEmpty ? path : segments.last;
  }
}
