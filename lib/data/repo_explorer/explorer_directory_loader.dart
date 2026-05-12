import 'dart:io';

import 'package:claude_skills_launcher/core/skill/skill_scanner.dart';
import 'package:claude_skills_launcher/data/repo_explorer/explorer_node.dart';

/// 指定ディレクトリ直下の子ディレクトリを列挙し、各子で `.claude/skills/`
/// 直下を `SkillScanner` で再利用してスキャンする loader。
///
/// 再帰しない（深部は表示時に都度スキャン）。隠しディレクトリ（`.git` 等）
/// と一般的なツールキャッシュは除外する。
class ExplorerDirectoryLoader {
  const ExplorerDirectoryLoader({this.scanner = const SkillScanner()});

  final SkillScanner scanner;

  /// 表示対象から外す名前。Skill 検知用のドット始まり `.claude/skills/`
  /// を持つことのない一般的なノイズを除外する。
  static const _hiddenPrefixes = <String>{
    '.git',
    '.DS_Store',
    'node_modules',
    '.next',
    '.cache',
    '.idea',
    '.vscode',
    'build',
    '.dart_tool',
  };

  /// [parentPath] 直下を読み、子ディレクトリ一覧（名前昇順）を返す。
  /// パスが存在しない、ディレクトリでない、読めない場合は空リスト。
  List<ExplorerDirectoryNode> load(String parentPath) {
    final dir = Directory(parentPath);
    if (!dir.existsSync()) {
      return const [];
    }
    final List<ExplorerDirectoryNode> nodes;
    try {
      final entities = dir.listSync(followLinks: false);
      nodes = <ExplorerDirectoryNode>[];
      for (final entity in entities) {
        if (entity is! Directory) {
          continue;
        }
        final name = _basename(entity.path);
        if (_hiddenPrefixes.contains(name)) {
          continue;
        }
        nodes.add(
          ExplorerDirectoryNode(
            path: entity.path,
            name: name,
            skillNames: scanner.scan(entity.path),
          ),
        );
      }
    } on FileSystemException {
      return const [];
    }
    nodes.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return nodes;
  }

  String _basename(String path) {
    final segments = Uri.file(
      path,
    ).pathSegments.where((s) => s.isNotEmpty).toList();
    return segments.isEmpty ? path : segments.last;
  }
}
