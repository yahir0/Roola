import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/task_notification/notification_environment.dart';

/// `notificationEnvironment` が OSC 通知用の `TERM_PROGRAM` /
/// `TERM_PROGRAM_VERSION` のみを注入することを検証する（ADR-0066）。
void main() {
  group('notificationEnvironment', () {
    test('TERM_PROGRAM / TERM_PROGRAM_VERSION を注入する', () {
      final env = notificationEnvironment();

      expect(env['TERM_PROGRAM'], oscTermProgram);
      expect(env['TERM_PROGRAM_VERSION'], oscTermProgramVersion);
    });

    test('注入するのは 2 変数のみ（フック用識別子は注入しない）', () {
      final env = notificationEnvironment();

      expect(env.containsKey('ROOLA_TAB_ID'), isFalse);
      expect(env.containsKey('ROOLA_NOTIFY_TOKEN'), isFalse);
      expect(env.length, 2);
    });
  });
}
