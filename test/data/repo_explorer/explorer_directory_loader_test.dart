import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/repo_explorer/explorer_directory_loader.dart';
import 'package:roola/data/repo_explorer/explorer_node.dart';

void main() {
  late Directory tempDir;
  late ExplorerDirectoryLoader loader;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_loader_');
    loader = const ExplorerDirectoryLoader();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<void> seedSkill(String parent, String skillName) async {
    final dir = Directory('$parent/.claude/skills/$skillName');
    await dir.create(recursive: true);
    await File('${dir.path}/SKILL.md').writeAsString('# $skillName');
  }

  /// 各ノードから表示名を取り出すユーティリティ（sealed の switch 経由）。
  String nameOf(ExplorerNode n) => switch (n) {
    ExplorerDirectoryNode(:final name) => name,
    ExplorerFileNode(:final name) => name,
  };

  test('returns empty list for non-existent path', () {
    expect(loader.load('/path/does/not/exist'), isEmpty);
  });

  test('returns empty list for empty directory', () {
    expect(loader.load(tempDir.path), isEmpty);
  });

  test('lists child directories sorted by name (case-insensitive)', () async {
    await Directory('${tempDir.path}/zeta').create();
    await Directory('${tempDir.path}/Alpha').create();
    await Directory('${tempDir.path}/beta').create();

    final nodes = loader.load(tempDir.path);
    expect(nodes.map(nameOf).toList(), ['Alpha', 'beta', 'zeta']);
  });

  test(
    'includes files after directories, both sorted alphabetically',
    () async {
      await File('${tempDir.path}/zeta.txt').writeAsString('z');
      await File('${tempDir.path}/alpha.md').writeAsString('a');
      await Directory('${tempDir.path}/folder').create();

      final nodes = loader.load(tempDir.path);
      // ディレクトリが先、その後ファイル
      expect(nodes.map(nameOf).toList(), ['folder', 'alpha.md', 'zeta.txt']);
      expect(nodes[0], isA<ExplorerDirectoryNode>());
      expect(nodes[1], isA<ExplorerFileNode>());
      expect(nodes[2], isA<ExplorerFileNode>());
    },
  );

  test(
    'excludes common noise entries (.git, node_modules, .DS_Store, etc.)',
    () async {
      for (final name in ['.git', 'node_modules', '.dart_tool', 'build']) {
        await Directory('${tempDir.path}/$name').create();
      }
      await File('${tempDir.path}/.DS_Store').writeAsString('');
      await Directory('${tempDir.path}/src').create();
      await File('${tempDir.path}/README.md').writeAsString('# hi');

      final nodes = loader.load(tempDir.path);
      expect(nodes.map(nameOf).toList(), ['src', 'README.md']);
    },
  );

  test(
    'populates skillNames when .claude/skills/<x>/SKILL.md exists',
    () async {
      final repo = '${tempDir.path}/my-repo';
      await Directory(repo).create();
      await seedSkill(repo, 'alpha');
      await seedSkill(repo, 'bravo');

      final nodes = loader.load(tempDir.path);
      expect(nodes, hasLength(1));
      final first = nodes.first;
      expect(first, isA<ExplorerDirectoryNode>());
      first as ExplorerDirectoryNode;
      expect(first.name, 'my-repo');
      expect(first.skillNames, ['alpha', 'bravo']);
    },
  );

  test(
    'leaves skillNames empty for directories without .claude/skills',
    () async {
      await Directory('${tempDir.path}/regular').create();
      final nodes = loader.load(tempDir.path);
      final first = nodes.first as ExplorerDirectoryNode;
      expect(first.skillNames, isEmpty);
    },
  );
}
