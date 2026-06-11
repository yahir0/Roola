import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/locale/app_locale.dart';
import 'package:roola/data/locale/locale_settings_repository_impl.dart';
import 'package:roola/data/skill_session/active_sessions.dart';
import 'package:roola/data/task_notification/hook_stop_payload.dart';
import 'package:roola/data/task_notification/notify_token.dart';
import 'package:roola/data/task_notification/osc_notification_policy.dart';
import 'package:roola/data/task_notification/task_notification_receiver.dart';
import 'package:roola/data/task_notification/task_notification_repository.dart';
import 'package:roola/data/task_notification/task_notification_settings_repository_impl.dart';

/// Stop フックからの POST を受ける、127.0.0.1 限定のローカル HTTP 受信口
/// （ADR-0057）。`build()` が返す値は確定したポート番号で、設定画面が
/// スニペットに埋め込んで表示する。
///
/// 受理判定（トークン照合・タブ有効性・デデュープ）は純粋ロジックの
/// [TaskNotificationReceiver] に委譲する。本 Notifier は HttpServer の生存と、
/// 照合成功時の通知発射の結線のみを担う。
class TaskNotificationServerNotifier extends AsyncNotifier<int> {
  /// フォールバック先の既定ポート（ユーザー指定なし & 競合なし時に使う）。
  static const int defaultPort = 51763;

  final TaskNotificationReceiver _receiver = TaskNotificationReceiver();

  @override
  Future<int> build() async {
    // preferredPort が変わったときだけ再 bind する。
    final preferredPort = ref.watch(
      taskNotificationSettingsProvider.select((s) => s.value?.preferredPort),
    );
    final server = await _bind(preferredPort ?? defaultPort);
    ref.onDispose(() {
      unawaited(server.close(force: true));
    });
    unawaited(_serve(server));
    return server.port;
  }

  Future<HttpServer> _bind(int port) async {
    try {
      return await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    } on SocketException {
      // ポート競合時は OS 任せの空きポート（0）へフォールバックする。
      return HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    }
  }

  Future<void> _serve(HttpServer server) async {
    await for (final request in server) {
      unawaited(_handle(request));
    }
  }

  Future<void> _handle(HttpRequest request) async {
    try {
      if (request.method != 'POST' || request.uri.path != '/hook/stop') {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }
      final body = await utf8.decoder.bind(request).join();
      // フック側の curl を待たせないよう、判定より先に 200 を返して閉じる。
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();

      final payload = HookStopPayload.tryParse(body);
      if (payload == null) {
        return;
      }
      _maybeNotify(payload);
    } on Object {
      try {
        await request.response.close();
      } on Object {
        // 既に閉じている場合は無視する。
      }
    }
  }

  /// 照合・設定確認のうえ、条件を満たせば通知を発射する。
  void _maybeNotify(HookStopPayload payload) {
    // OSC 経路（ADR-0066）が機能しているセッションはフック経路を破棄し、
    // 並走期間中の二重通知を防ぐ（osc-task-notification design D5）。
    if (ref.read(oscNotificationPolicyProvider).isOscActive(payload.tabId)) {
      return;
    }

    final sessions = ref.read(activeSessionsProvider);
    final expectedToken = ref.read(notifyTokenProvider);
    final shouldNotify = _receiver.shouldNotify(
      payload: payload,
      expectedToken: expectedToken,
      isValidTab: sessions.containsKey(payload.tabId),
      now: DateTime.now(),
    );
    if (!shouldNotify) {
      return;
    }

    // 機能が無効なら発射しない（許可未取得時はネイティブ側が握り潰す）。
    final settings = ref.read(taskNotificationSettingsProvider).value;
    if (settings?.enabled != true) {
      return;
    }

    final registry = ref.read(activeSessionsProvider.notifier);
    final name =
        registry.labelFor(payload.tabId) ??
        registry.adhocArgsFor(payload.tabId)?.displayName ??
        payload.cwd ??
        payload.tabId;

    final isJa = ref.read(appLocaleProvider) == AppLocale.ja;
    final title = isJa ? 'Claude Code が完了しました' : 'Claude Code finished';
    final bodyText = isJa ? '$name のタスクが完了しました' : 'Task completed — $name';

    unawaited(
      ref
          .read(taskNotificationRepositoryProvider)
          // sessionId で通知クリック→ペインフォーカス復帰（ADR-0066）に
          // 相乗りする。フック経路の tabId は ad-hoc セッション id と同じ。
          .notify(title: title, body: bodyText, sessionId: payload.tabId),
    );
  }
}

/// 受信口の Provider。`build()` で待受を開始し、確定ポートを返す。
/// keepAlive 相当（アプリ生存中は破棄しない）にするため、起動時に
/// `App` から watch して常駐させる。
final taskNotificationServerProvider =
    AsyncNotifierProvider<TaskNotificationServerNotifier, int>(
      TaskNotificationServerNotifier.new,
    );
