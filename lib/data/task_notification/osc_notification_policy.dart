import 'package:hooks_riverpod/hooks_riverpod.dart';

/// OSC 通知要求（ADR-0066）を「発射すべきか」判定する純粋ロジック。
///
/// MethodChannel や Riverpod から切り離してあり、フォーカス中サプレッション・
/// セッション単位のレート制限・ADR-0057 並走時の重複抑止用の OSC 受信実績
/// のみを扱う。ネイティブ通知の発射は呼び出し側の責務。
class OscNotificationPolicy {
  OscNotificationPolicy({this.minInterval = const Duration(seconds: 2)});

  /// 同一セッションの連続発火を抑止する最小間隔。エスケープシーケンス注入
  /// （OSC を大量に含むファイルの `cat` 等）による通知洪水を防ぐ
  /// （ADR-0066 Trade-offs）。
  final Duration minInterval;

  final Map<String, DateTime> _lastFired = {};
  final Set<String> _oscActiveSessions = {};

  /// 通知を発射すべきなら `true` を返し、レート制限用の最終発火時刻を更新する。
  ///
  /// 発射可否にかかわらず、当該セッションを「OSC 経路が機能している」として
  /// 記録する（[isOscActive]）。
  ///
  /// - [sessionId]: ad-hoc セッション id（`ROOLA_TAB_ID` と同じ id 空間）。
  /// - [isFocused]: 当該ペインがフォーカス中か。ユーザーが見ている画面からの
  ///   通知は出さない。
  bool shouldNotify({
    required String sessionId,
    required bool isFocused,
    required DateTime now,
  }) {
    _oscActiveSessions.add(sessionId);
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

  /// 当該セッションで OSC 通知要求を受信した実績があるか。
  ///
  /// ADR-0057（Stop フック → HTTP）経路との並走時、OSC が機能している
  /// セッションのフック通知を破棄して二重通知を防ぐ（design D5）。
  bool isOscActive(String sessionId) => _oscActiveSessions.contains(sessionId);

  /// セッション破棄時に記録を掃除する。
  void forgetSession(String sessionId) {
    _lastFired.remove(sessionId);
    _oscActiveSessions.remove(sessionId);
  }
}

/// アプリ全体で共有する [OscNotificationPolicy]。OSC 経路（コントローラ）と
/// ADR-0057 経路（HTTP 受信口の重複抑止）の両方から参照される。
final oscNotificationPolicyProvider = Provider<OscNotificationPolicy>(
  (ref) => OscNotificationPolicy(),
);
