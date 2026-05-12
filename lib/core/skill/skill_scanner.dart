import 'dart:io';

/// リポジトリ配下から Claude Code Skills を発見するスキャナ。
///
/// 規約: `<repo>/.claude/skills/<skill-name>/SKILL.md` が存在するディレクトリを
/// Skill とみなし、ディレクトリ名のリストを返す。
class SkillScanner {
  const SkillScanner();

  /// [repositoryPath] 直下を走査し、見つかった Skill 名をアルファベット順に返す。
  ///
  /// パスが存在しない、`.claude/skills/` が無い場合は空リスト。
  List<String> scan(String repositoryPath) {
    if (repositoryPath.isEmpty) {
      return const [];
    }
    final skillsDir = Directory('$repositoryPath/.claude/skills');
    if (!skillsDir.existsSync()) {
      return const [];
    }
    final names = <String>[];
    for (final entity in skillsDir.listSync()) {
      if (entity is! Directory) {
        continue;
      }
      final skillFile = File('${entity.path}/SKILL.md');
      if (skillFile.existsSync()) {
        names.add(entity.uri.pathSegments.where((s) => s.isNotEmpty).last);
      }
    }
    names.sort();
    return names;
  }
}
