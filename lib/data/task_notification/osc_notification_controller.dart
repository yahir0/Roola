import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/locale/app_locale.dart';
import 'package:roola/data/locale/locale_settings_repository_impl.dart';
import 'package:roola/data/skill_session/active_sessions.dart';
import 'package:roola/data/task_notification/osc_notification_policy.dart';
import 'package:roola/data/task_notification/task_notification_repository.dart';

/// OSC 通知要求（ADR-0066）の発射判断と実行。
///
/// ターミナルビュー（SwiftTerm / xterm.js）が解釈した OSC 9/777 を
/// [handleNotify] で受け、[OscNotificationPolicy] の判定を通った要求だけを
/// ネイティブ通知として発射する。
///
/// ADR-0057 の設定トグル（`TaskNotificationSettings.enabled`・既定 off）は
/// フック経路専用であり、本経路は参照しない。OSC 通知は設定ゼロで動くことが
/// 要件（spec: 設定ゼロ有効化）。無効化したいユーザーには OS の通知設定
/// （アプリ単位のオフ）がある。
class OscNotificationController {
  OscNotificationController(this._ref);

  final Ref _ref;

  /// 通知要求を処理する。
  ///
  /// - [sessionId]: ad-hoc セッション id（タブ名の解決と重複抑止のキー）。
  /// - [isFocused]: 当該ペインがフォーカス中か（呼び出し側の UI 層が判定して
  ///   渡す。data 層から UI のフォーカス状態へ依存しないため）。
  /// - [title]: OSC 777 のタイトル。OSC 9 は null（タブ名で補完する）。
  Future<void> handleNotify({
    required String sessionId,
    required bool isFocused,
    String? title,
    required String body,
  }) async {
    final policy = _ref.read(oscNotificationPolicyProvider);
    final fire = policy.shouldNotify(
      sessionId: sessionId,
      isFocused: isFocused,
      now: DateTime.now(),
    );
    if (!fire) {
      return;
    }

    final repository = _ref.read(taskNotificationRepositoryProvider);

    // 設定ゼロで動かすため、未決定なら初回発射時に通知許可を要求する
    // （ADR-0057 は設定画面の有効化を許可要求の起点にしていたが、本経路に
    // 有効化操作は存在しない）。拒否済みなら何もしない。
    switch (await repository.authorizationStatus()) {
      case NotificationAuthorizationStatus.notDetermined:
        final granted = await repository.requestAuthorization();
        if (!granted) return;
      case NotificationAuthorizationStatus.denied:
        return;
      case NotificationAuthorizationStatus.authorized:
        break;
    }

    final registry = _ref.read(activeSessionsProvider.notifier);
    final fallbackTitle =
        registry.labelFor(sessionId) ??
        registry.adhocArgsFor(sessionId)?.displayName ??
        (_ref.read(appLocaleProvider) == AppLocale.ja ? 'ターミナル' : 'Terminal');

    await repository.notify(
      title: (title == null || title.isEmpty) ? fallbackTitle : title,
      body: body,
      sessionId: sessionId,
    );
  }
}

/// OSC 通知コントローラの Provider。
final oscNotificationControllerProvider = Provider<OscNotificationController>(
  OscNotificationController.new,
);
