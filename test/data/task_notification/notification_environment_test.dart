import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/task_notification/notification_environment.dart';

/// `notificationEnvironment` が全アクションに `TERM_PROGRAM` を注入し
/// （ADR-0066）、Claude Code セッションにのみ ADR-0057 並走用の識別子を
/// 加えることを検証する。
void main() {
  group('notificationEnvironment', () {
    test('全アクションで TERM_PROGRAM / TERM_PROGRAM_VERSION を注入する', () {
      for (final action in const [
        LauncherAction.openHere(),
        LauncherAction.runCommand(command: 'npm run dev'),
        LauncherAction.claudeSkill(skillName: 'review'),
      ]) {
        final env = notificationEnvironment(
          action: action,
          tabId: 'tab-1',
          token: 'token-abc',
        );

        expect(env['TERM_PROGRAM'], oscTermProgram, reason: '$action');
        expect(
          env['TERM_PROGRAM_VERSION'],
          oscTermProgramVersion,
          reason: '$action',
        );
      }
    });

    test('ClaudeSkillAction では ROOLA_TAB_ID / ROOLA_NOTIFY_TOKEN も注入する', () {
      final env = notificationEnvironment(
        action: const LauncherAction.claudeSkill(skillName: 'review'),
        tabId: 'tab-1',
        token: 'token-abc',
      );

      expect(env['ROOLA_TAB_ID'], 'tab-1');
      expect(env['ROOLA_NOTIFY_TOKEN'], 'token-abc');
      expect(env.length, 4);
    });

    test('OpenHereAction では ADR-0057 用の識別子は注入しない', () {
      final env = notificationEnvironment(
        action: const LauncherAction.openHere(),
        tabId: 'tab-1',
        token: 'token-abc',
      );

      expect(env.containsKey('ROOLA_TAB_ID'), isFalse);
      expect(env.containsKey('ROOLA_NOTIFY_TOKEN'), isFalse);
      expect(env.length, 2);
    });

    test('RunCommandAction では ADR-0057 用の識別子は注入しない', () {
      final env = notificationEnvironment(
        action: const LauncherAction.runCommand(command: 'npm run dev'),
        tabId: 'tab-1',
        token: 'token-abc',
      );

      expect(env.containsKey('ROOLA_TAB_ID'), isFalse);
      expect(env.length, 2);
    });
  });
}
