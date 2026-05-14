import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/launcher_entry/launcher_entry_dto.dart';

/// `LauncherEntryDto.fromJson` の旧→新スキーマ migration ガード。
///
/// 旧スキーマで保存された JSON（`repositoryPath` / `skillName` の 2 フィールド）
/// が、エントリ全件を壊さずに新スキーマ（`workingDirectory` / `action`）へ
/// 変換されることを担保する（ADR-0016）。
void main() {
  group('LauncherEntryDto.fromJson migration', () {
    test('新スキーマ（runCommand）はそのまま読み込める', () {
      final json = <String, dynamic>{
        'id': 'e1',
        'displayName': 'Dev Server',
        'workingDirectory': '/Users/me/projects/foo',
        'action': {
          'type': 'runCommand',
          'command': 'npm run dev',
          'keepShellAfterExit': true,
        },
        'iconPath': null,
        'createdAt': '2026-05-14T10:00:00.000',
      };

      final entity = LauncherEntryDto.fromJson(json).toEntity();

      expect(entity.id, 'e1');
      expect(entity.workingDirectory, '/Users/me/projects/foo');
      expect(entity.action, isA<RunCommandAction>());
      final action = entity.action as RunCommandAction;
      expect(action.command, 'npm run dev');
      expect(action.keepShellAfterExit, isTrue);
    });

    test('新スキーマ（openHere）はそのまま読み込める', () {
      final json = <String, dynamic>{
        'id': 'e2',
        'displayName': 'Project Foo',
        'workingDirectory': '/Users/me/projects/foo',
        'action': {'type': 'openHere'},
        'iconPath': '/Users/me/Library/Roola/icons/e2.png',
        'createdAt': '2026-05-14T10:00:00.000',
      };

      final entity = LauncherEntryDto.fromJson(json).toEntity();

      expect(entity.action, isA<OpenHereAction>());
      expect(entity.iconPath, '/Users/me/Library/Roola/icons/e2.png');
    });

    test('新スキーマ（claudeSkill）はそのまま読み込める', () {
      final json = <String, dynamic>{
        'id': 'e3',
        'displayName': 'Roola Skill',
        'workingDirectory': '/Users/me/projects/roola',
        'action': {'type': 'claudeSkill', 'skillName': 'flutter-architecture'},
        'iconPath': null,
        'createdAt': '2026-05-14T10:00:00.000',
      };

      final entity = LauncherEntryDto.fromJson(json).toEntity();

      expect(entity.action, isA<ClaudeSkillAction>());
      expect(
        (entity.action as ClaudeSkillAction).skillName,
        'flutter-architecture',
      );
    });

    test('旧スキーマで skillName が空文字 → OpenHereAction に変換される', () {
      // 旧 ホーム画面で「Skill 名なしで claude を開く」ために空文字保存していた
      // ケース。ADR-0016 では同等表現を OpenHere に倒す方針。
      final json = <String, dynamic>{
        'id': 'old-1',
        'displayName': '旧エントリ A',
        'repositoryPath': '/Users/me/projects/foo',
        'skillName': '',
        'iconPath': null,
        'createdAt': '2026-04-01T10:00:00.000',
      };

      final entity = LauncherEntryDto.fromJson(json).toEntity();

      expect(entity.id, 'old-1');
      expect(entity.workingDirectory, '/Users/me/projects/foo');
      expect(entity.action, const LauncherAction.openHere());
    });

    test('旧スキーマで skillName が空白のみ → OpenHereAction に変換される', () {
      // trim 後に空とみなす。空白だけの skillName が永続化されている可能性は
      // 低いが、防御的にカバーする。
      final json = <String, dynamic>{
        'id': 'old-2',
        'displayName': '旧エントリ B',
        'repositoryPath': '/Users/me/projects/foo',
        'skillName': '   ',
        'iconPath': null,
        'createdAt': '2026-04-01T10:00:00.000',
      };

      final entity = LauncherEntryDto.fromJson(json).toEntity();

      expect(entity.action, const LauncherAction.openHere());
    });

    test('旧スキーマで skillName が非空 → ClaudeSkillAction に変換される', () {
      final json = <String, dynamic>{
        'id': 'old-3',
        'displayName': '旧エントリ C',
        'repositoryPath': '/Users/me/projects/roola',
        'skillName': 'commit',
        'iconPath': '/path/to/icon.png',
        'createdAt': '2026-04-01T10:00:00.000',
      };

      final entity = LauncherEntryDto.fromJson(json).toEntity();

      expect(entity.workingDirectory, '/Users/me/projects/roola');
      expect(
        entity.action,
        const LauncherAction.claudeSkill(skillName: 'commit'),
      );
      expect(entity.iconPath, '/path/to/icon.png');
    });

    test('不正な action.type 値の JSON は例外を投げる（repository 側で skip 処理）', () {
      final json = <String, dynamic>{
        'id': 'broken-1',
        'displayName': '壊れたエントリ',
        'workingDirectory': '/tmp',
        'action': {'type': 'unknownActionType'},
        'iconPath': null,
        'createdAt': '2026-05-14T10:00:00.000',
      };

      // CheckedFromJsonException が投げられる。repository_impl 側の try/catch で
      // 当該エントリだけ読み飛ばし、残り全件は復元できる仕様。
      expect(() => LauncherEntryDto.fromJson(json).toEntity(), throwsA(anything));
    });

    test('toJson は常に新スキーマで書き出す（jsonEncode 経由）', () {
      // 旧スキーマで読み込んだエントリを toJson すると新スキーマになる
      // （= 1 度ファイルを書き戻せば全件 migration が完了する）。
      // production の `_saveAll` も `jsonEncode` 経由で書き出すため、ここでも
      // 同じ経路で確認する。`LauncherAction` は jsonEncode が自動的に
      // `.toJson()` を呼ぶので、最終出力では Map 形式になる。
      final entity = LauncherEntry(
        id: 'rt-1',
        displayName: 'roundtrip',
        workingDirectory: '/work',
        action: const LauncherAction.runCommand(command: 'echo hi'),
        createdAt: DateTime.parse('2026-05-14T10:00:00.000'),
      );

      final encoded = jsonEncode(LauncherEntryDto.fromEntity(entity).toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;

      expect(decoded['workingDirectory'], '/work');
      expect(decoded['action'], isA<Map<String, dynamic>>());
      expect((decoded['action'] as Map)['type'], 'runCommand');
      expect((decoded['action'] as Map)['command'], 'echo hi');
      expect((decoded['action'] as Map)['keepShellAfterExit'], true);
      // 旧フィールドは出さない
      expect(decoded.containsKey('repositoryPath'), isFalse);
      expect(decoded.containsKey('skillName'), isFalse);
    });

    test('round-trip: 旧スキーマ → 読み込み → 新スキーマで書き戻し → 同じ entity に復元できる', () {
      final oldJson = <String, dynamic>{
        'id': 'rt-2',
        'displayName': 'rt entry',
        'repositoryPath': '/work/rt',
        'skillName': 'my-skill',
        'iconPath': null,
        'createdAt': '2026-05-14T10:00:00.000',
      };

      // 旧スキーマで読み込み → DTO → entity
      final loaded = LauncherEntryDto.fromJson(oldJson).toEntity();

      // entity → DTO → 新スキーマ JSON 文字列
      final encoded = jsonEncode(LauncherEntryDto.fromEntity(loaded).toJson());

      // 新スキーマ JSON を再度読み込んでも同じ entity になる
      final reloaded = LauncherEntryDto.fromJson(
        jsonDecode(encoded) as Map<String, dynamic>,
      ).toEntity();

      expect(reloaded, loaded);
    });
  });
}
