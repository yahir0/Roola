import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/task_notification/notification_environment.dart';

/// `notificationEnvironment` が Claude Code セッションにのみ識別子を注入し、
/// 他アクションでは注入しない（`null`）ことを検証する（ADR-0057 / task 2.3）。
void main() {
  group('notificationEnvironment', () {
    test('ClaudeSkillAction では ROOLA_TAB_ID / ROOLA_NOTIFY_TOKEN を注入する', () {
      final env = notificationEnvironment(
        action: const LauncherAction.claudeSkill(skillName: 'review'),
        tabId: 'tab-1',
        token: 'token-abc',
      );

      expect(env, isNotNull);
      expect(env!['ROOLA_TAB_ID'], 'tab-1');
      expect(env['ROOLA_NOTIFY_TOKEN'], 'token-abc');
      expect(env.length, 2);
    });

    test('OpenHereAction では注入しない', () {
      final env = notificationEnvironment(
        action: const LauncherAction.openHere(),
        tabId: 'tab-1',
        token: 'token-abc',
      );

      expect(env, isNull);
    });

    test('RunCommandAction では注入しない', () {
      final env = notificationEnvironment(
        action: const LauncherAction.runCommand(command: 'npm run dev'),
        tabId: 'tab-1',
        token: 'token-abc',
      );

      expect(env, isNull);
    });
  });
}
