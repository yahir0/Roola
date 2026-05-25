import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/task_notification/hook_stop_payload.dart';
import 'package:roola/data/task_notification/task_notification_receiver.dart';

/// 受理判定（トークン照合・タブ有効性・デデュープ）を検証する
/// （ADR-0057 / task 3.6）。
void main() {
  const valid = HookStopPayload(
    tabId: 'tab-1',
    token: 'token-abc',
    sessionId: 's1',
  );
  final t0 = DateTime(2026, 5, 25, 12);

  group('TaskNotificationReceiver.shouldNotify', () {
    test('トークン一致 + 有効タブなら通知する', () {
      final receiver = TaskNotificationReceiver();
      expect(
        receiver.shouldNotify(
          payload: valid,
          expectedToken: 'token-abc',
          isValidTab: true,
          now: t0,
        ),
        isTrue,
      );
    });

    test('トークン不一致は通知しない', () {
      final receiver = TaskNotificationReceiver();
      expect(
        receiver.shouldNotify(
          payload: valid,
          expectedToken: 'different-token',
          isValidTab: true,
          now: t0,
        ),
        isFalse,
      );
    });

    test('未知のタブ ID は通知しない', () {
      final receiver = TaskNotificationReceiver();
      expect(
        receiver.shouldNotify(
          payload: valid,
          expectedToken: 'token-abc',
          isValidTab: false,
          now: t0,
        ),
        isFalse,
      );
    });

    test('デデュープ窓内の連続発火は抑止する', () {
      final receiver = TaskNotificationReceiver(
        dedupeWindow: const Duration(seconds: 5),
      );
      bool fire(DateTime now) => receiver.shouldNotify(
        payload: valid,
        expectedToken: 'token-abc',
        isValidTab: true,
        now: now,
      );

      expect(fire(t0), isTrue);
      // 1 秒後（窓内）は抑止。
      expect(fire(t0.add(const Duration(seconds: 1))), isFalse);
      // 6 秒後（窓外）は再び通知。
      expect(fire(t0.add(const Duration(seconds: 6))), isTrue);
    });

    test('別セッションはデデュープ対象を分ける', () {
      final receiver = TaskNotificationReceiver();
      const other = HookStopPayload(
        tabId: 'tab-2',
        token: 'token-abc',
        sessionId: 's2',
      );

      expect(
        receiver.shouldNotify(
          payload: valid,
          expectedToken: 'token-abc',
          isValidTab: true,
          now: t0,
        ),
        isTrue,
      );
      // 同時刻でも別セッションなら通知する。
      expect(
        receiver.shouldNotify(
          payload: other,
          expectedToken: 'token-abc',
          isValidTab: true,
          now: t0,
        ),
        isTrue,
      );
    });
  });
}
