import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola/core/skill/skill_scanner.dart';

void main() {
  late Directory tempDir;
  const scanner = SkillScanner();

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_scanner_');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<void> createSkill(String name, {bool withSkillMd = true}) async {
    final dir = Directory('${tempDir.path}/.claude/skills/$name');
    await dir.create(recursive: true);
    if (withSkillMd) {
      await File('${dir.path}/SKILL.md').writeAsString('# $name');
    }
  }

  test('returns empty list when repository path is empty', () {
    expect(scanner.scan(''), isEmpty);
  });

  test('returns empty list when path does not exist', () {
    expect(scanner.scan('/no/such/path'), isEmpty);
  });

  test('returns empty list when .claude/skills is missing', () {
    expect(scanner.scan(tempDir.path), isEmpty);
  });

  test('lists skill directories that contain SKILL.md', () async {
    await createSkill('alpha');
    await createSkill('beta');
    final result = scanner.scan(tempDir.path);
    expect(result, ['alpha', 'beta']);
  });

  test('excludes directories without SKILL.md', () async {
    await createSkill('valid');
    await createSkill('no-skill-md', withSkillMd: false);
    final result = scanner.scan(tempDir.path);
    expect(result, ['valid']);
  });

  test('sorts results alphabetically', () async {
    await createSkill('zeta');
    await createSkill('alpha');
    await createSkill('mid');
    final result = scanner.scan(tempDir.path);
    expect(result, ['alpha', 'mid', 'zeta']);
  });
}
