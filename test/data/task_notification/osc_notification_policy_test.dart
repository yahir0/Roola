import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/task_notification/osc_notification_policy.dart';

/// `OscNotificationPolicy` のフォーカス中サプレッション・レート制限・
/// OSC 受信実績（ADR-0057 並走時の重複抑止）を検証する。
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

  group('isOscActive（ADR-0057 並走時の重複抑止）', () {
    test('要求を受けたセッションは発射可否にかかわらず OSC 実績ありになる', () {
      final policy = OscNotificationPolicy();

      // フォーカス中で破棄されるケースでも実績は記録される。
      policy.shouldNotify(sessionId: 's1', isFocused: true, now: base);

      expect(policy.isOscActive('s1'), isTrue);
      expect(policy.isOscActive('s2'), isFalse);
    });

    test('forgetSession で実績とレート制限の記録が消える', () {
      final policy = OscNotificationPolicy();
      policy.shouldNotify(sessionId: 's1', isFocused: false, now: base);

      policy.forgetSession('s1');

      expect(policy.isOscActive('s1'), isFalse);
      // レート制限の記録も消えるため、直後でも発射できる。
      final fire = policy.shouldNotify(
        sessionId: 's1',
        isFocused: false,
        now: base.add(const Duration(milliseconds: 1)),
      );
      expect(fire, isTrue);
    });
  });
}
