import 'package:hooks_riverpod/hooks_riverpod.dart';

/// OSC 通知要求（ADR-0066）を「発射すべきか」判定する純粋ロジック。
///
/// MethodChannel や Riverpod から切り離してあり、フォーカス中サプレッションと
/// セッション単位のレート制限のみを扱う。ネイティブ通知の発射は呼び出し側の
/// 責務。
class OscNotificationPolicy {
  OscNotificationPolicy({this.minInterval = const Duration(seconds: 2)});

  /// 同一セッションの連続発火を抑止する最小間隔。エスケープシーケンス注入
  /// （OSC を大量に含むファイルの `cat` 等）による通知洪水を防ぐ
  /// （ADR-0066 Trade-offs）。
  final Duration minInterval;

  final Map<String, DateTime> _lastFired = {};

  /// 通知を発射すべきなら `true` を返し、レート制限用の最終発火時刻を更新する。
  ///
  /// - [sessionId]: ad-hoc セッション id。
  /// - [isFocused]: 当該ペインがフォーカス中か。ユーザーが見ている画面からの
  ///   通知は出さない。
  bool shouldNotify({
    required String sessionId,
    required bool isFocused,
    required DateTime now,
  }) {
    if (isFocused) {
      return false;
    }
    final last = _lastFired[sessionId];
    if (last != null && now.difference(last) < minInterval) {
      return false;
    }
    _lastFired[sessionId] = now;
    return true;
  }

  /// セッション破棄時にレート制限の記録を掃除する。
  void forgetSession(String sessionId) {
    _lastFired.remove(sessionId);
  }
}

/// アプリ全体で共有する [OscNotificationPolicy]。
final oscNotificationPolicyProvider = Provider<OscNotificationPolicy>(
  (ref) => OscNotificationPolicy(),
);
