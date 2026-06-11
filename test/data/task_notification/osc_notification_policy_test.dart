import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/task_notification/osc_notification_policy.dart';

/// `OscNotificationPolicy` のフォーカス中サプレッションとレート制限を検証する。
void main() {
  final base = DateTime(2026, 6, 11, 12);

  group('shouldNotify', () {
    test('非フォーカスのセッションからの初回要求は発射する', () {
      final policy = OscNotificationPolicy();

      final fire = policy.shouldNotify(
        sessionId: 's1',
        isFocused: false,
        now: base,
      );

      expect(fire, isTrue);
    });

    test('フォーカス中のセッションからの要求は破棄する', () {
      final policy = OscNotificationPolicy();

      final fire = policy.shouldNotify(
        sessionId: 's1',
        isFocused: true,
        now: base,
      );

      expect(fire, isFalse);
    });

    test('最小間隔内の連続要求はレート制限する（cat 洪水対策）', () {
      final policy = OscNotificationPolicy();

      var fired = 0;
      // OSC を 100 個含むファイルの cat 相当: ほぼ同時刻に 100 要求。
      for (var i = 0; i < 100; i++) {
        if (policy.shouldNotify(
          sessionId: 's1',
          isFocused: false,
          now: base.add(Duration(milliseconds: i)),
        )) {
          fired++;
        }
      }

      expect(fired, 1);
    });

    test('最小間隔を過ぎれば再び発射する', () {
      final policy = OscNotificationPolicy();

      policy.shouldNotify(sessionId: 's1', isFocused: false, now: base);
      final fire = policy.shouldNotify(
        sessionId: 's1',
        isFocused: false,
        now: base.add(const Duration(seconds: 3)),
      );

      expect(fire, isTrue);
    });

    test('レート制限はセッション単位で独立している', () {
      final policy = OscNotificationPolicy();

      policy.shouldNotify(sessionId: 's1', isFocused: false, now: base);
      final fire = policy.shouldNotify(
        sessionId: 's2',
        isFocused: false,
        now: base,
      );

      expect(fire, isTrue);
    });
  });

  group('forgetSession', () {
    test('レート制限の記録が消え、直後でも発射できる', () {
      final policy = OscNotificationPolicy();
      policy.shouldNotify(sessionId: 's1', isFocused: false, now: base);

      policy.forgetSession('s1');

      final fire = policy.shouldNotify(
        sessionId: 's1',
        isFocused: false,
        now: base.add(const Duration(milliseconds: 1)),
      );
      expect(fire, isTrue);
    });
  });
}
