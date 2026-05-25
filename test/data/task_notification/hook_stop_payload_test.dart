import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/task_notification/hook_stop_payload.dart';

/// Stop フックの POST ボディのパースを検証する（ADR-0057 / task 3.6）。
void main() {
  group('HookStopPayload.tryParse', () {
    test('必須フィールドが揃った JSON をパースする', () {
      final payload = HookStopPayload.tryParse(
        '{"tab_id":"tab-1","token":"tok","session_id":"s1","cwd":"/work"}',
      );

      expect(payload, isNotNull);
      expect(payload!.tabId, 'tab-1');
      expect(payload.token, 'tok');
      expect(payload.sessionId, 's1');
      expect(payload.cwd, '/work');
    });

    test('session_id / cwd は省略可能（null になる）', () {
      final payload = HookStopPayload.tryParse('{"tab_id":"t","token":"k"}');

      expect(payload, isNotNull);
      expect(payload!.sessionId, isNull);
      expect(payload.cwd, isNull);
    });

    test('tab_id が欠けると null', () {
      expect(HookStopPayload.tryParse('{"token":"k"}'), isNull);
    });

    test('token が空文字だと null', () {
      expect(HookStopPayload.tryParse('{"tab_id":"t","token":""}'), isNull);
    });

    test('不正な JSON は null', () {
      expect(HookStopPayload.tryParse('not json'), isNull);
    });

    test('JSON 配列など Map でないものは null', () {
      expect(HookStopPayload.tryParse('[1,2,3]'), isNull);
    });
  });
}
