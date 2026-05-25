import 'package:roola/data/task_notification/hook_stop_payload.dart';

/// 受信したフック通知を「発射すべきか」判定する純粋ロジック（ADR-0057）。
///
/// HttpServer や Riverpod から切り離してあり、トークン照合・タブ有効性・
/// 短時間デデュープのみを扱う。ネイティブ通知の発射は呼び出し側の責務。
class TaskNotificationReceiver {
  TaskNotificationReceiver({this.dedupeWindow = const Duration(seconds: 2)});

  /// 同一セッションの連続発火を抑止する時間窓。Stop フックは原則ターンに
  /// 1 回だが、`stop_hook_active` 絡みの多重 POST に備える。
  final Duration dedupeWindow;

  final Map<String, DateTime> _lastFired = {};

  /// 通知を発射すべきなら `true` を返し、デデュープ用の最終発火時刻を更新する。
  ///
  /// - [expectedToken]: 現在のアプリ起動のトークン。`payload.token` と一致必須。
  /// - [isValidTab]: `payload.tabId` が現在有効なセッションに存在するか。
  bool shouldNotify({
    required HookStopPayload payload,
    required String expectedToken,
    required bool isValidTab,
    required DateTime now,
  }) {
    if (payload.token != expectedToken) {
      return false;
    }
    if (!isValidTab) {
      return false;
    }
    final key = payload.sessionId ?? payload.tabId;
    final last = _lastFired[key];
    if (last != null && now.difference(last) < dedupeWindow) {
      return false;
    }
    _lastFired[key] = now;
    return true;
  }
}
