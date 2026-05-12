import 'dart:io';

import 'package:claude_skills_launcher/data/repo_explorer/explorer_directory_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late ExplorerDirectoryLoader loader;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cskl_loader_');
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
    expect(nodes.map((n) => n.name).toList(), ['Alpha', 'beta', 'zeta']);
  });

  test('excludes files (non-directory entities)', () async {
    await File('${tempDir.path}/note.txt').writeAsString('hi');
    await Directory('${tempDir.path}/folder').create();

    final nodes = loader.load(tempDir.path);
    expect(nodes.map((n) => n.name).toList(), ['folder']);
  });

  test(
    'excludes common noise directories (.git, node_modules, etc.)',
    () async {
      for (final name in ['.git', 'node_modules', '.dart_tool', 'build']) {
        await Directory('${tempDir.path}/$name').create();
      }
      await Directory('${tempDir.path}/src').create();

      final nodes = loader.load(tempDir.path);
      expect(nodes.map((n) => n.name).toList(), ['src']);
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
      expect(nodes.first.name, 'my-repo');
      expect(nodes.first.skillNames, ['alpha', 'bravo']);
    },
  );

  test(
    'leaves skillNames empty for directories without .claude/skills',
    () async {
      await Directory('${tempDir.path}/regular').create();
      final nodes = loader.load(tempDir.path);
      expect(nodes.first.skillNames, isEmpty);
    },
  );
}
