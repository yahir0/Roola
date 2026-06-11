import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:roola/core/constants/terms.dart';
import 'package:roola/data/privacy/privacy_settings_repository_impl.dart';

/// 匿名利用統計の送信口（Aptabase / ADR-0065）。
///
/// `aptabase_flutter` SDK は依存競合（package_info_plus ^8 固定）のため使わず、
/// インジェスト API（`POST {host}/api/v0/events`）を dio で直接叩く。
/// プロトコル（ペイロード形式・セッション ID 仕様）は SDK ソースに合わせてある。
///
/// 送信条件はこのクラスに集約する。呼び出し側は無条件に [trackEvent] を
/// 呼んでよく、以下のいずれかに該当する場合は黙って no-op になる:
///
/// - App Key（dart-define `APTABASE_APP_KEY`）が未設定・不正（開発 / fork ビルド）
/// - 利用規約の現行版に未同意（同意モーダル表示前・規約改定後の再同意待ち）
/// - アナリティクス送信がオプトアウトされている
///
/// 送信はベストエフォート（オフラインバッファリングなし・失敗は握り潰す）。
/// 要件は規模感の把握なので欠落は許容する（ADR-0065 Trade-offs）。
///
/// プライバシー上の原則: イベント名と props にパス・コマンド・エントリ名等の
/// 自由文字列を入れないこと。props は開発者が列挙した離散値のみ。
class AnalyticsService {
  AnalyticsService({
    required String appKey,
    required bool Function() isAllowed,
    Dio? dio,
  }) : _appKey = appKey,
       _isAllowed = isAllowed,
       _dio = dio ?? Dio();

  /// ビルド時に dart-define で注入される App Key（ADR-0004 / docs/release.md）。
  static const appKeyFromEnvironment = String.fromEnvironment(
    'APTABASE_APP_KEY',
  );

  /// Aptabase ダッシュボードに表示される SDK 識別子。
  static const _sdkVersion = 'roola_dio@1';

  /// 最終送信からこの時間が経過したらセッション ID を作り直す（SDK と同仕様）。
  static const _sessionTimeout = Duration(hours: 1);

  /// App Key のリージョン部（`A-REG-0000000000` の `REG`）→ 送信先ホスト。
  /// セルフホストは未使用のため対応しない（必要になったら追加する）。
  static const _hosts = {
    'EU': 'https://eu.aptabase.com',
    'US': 'https://us.aptabase.com',
  };

  final String _appKey;
  final bool Function() _isAllowed;
  final Dio _dio;
  final _random = Random();

  String? _sessionId;
  DateTime _lastTouch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  bool _appLaunchTracked = false;

  /// App Key から導出した送信先。Key が空・形式不正なら null（= 全体 no-op）。
  late final Uri? _apiUrl = _resolveApiUrl();

  Uri? _resolveApiUrl() {
    final parts = _appKey.split('-');
    if (parts.length != 3) {
      return null;
    }
    final host = _hosts[parts[1]];
    if (host == null) {
      return null;
    }
    return Uri.parse('$host/api/v0/events');
  }

  /// イベントを 1 件送信する。送信条件を満たさない場合は何もしない。
  ///
  /// [props] は離散値（enum 名・真偽値・数値）のみを渡すこと。
  Future<void> trackEvent(String eventName, [Map<String, Object?>? props]) async {
    final apiUrl = _apiUrl;
    if (apiUrl == null || !_isAllowed()) {
      return;
    }
    try {
      final now = DateTime.now().toUtc();
      final payload = {
        'timestamp': now.toIso8601String(),
        'sessionId': _evalSessionId(now),
        'eventName': eventName,
        'systemProps': await _systemProps(),
        'props': props,
      };
      await _dio.postUri<void>(
        apiUrl,
        // インジェスト API はイベント JSON 配列を受け取る。バッファリングは
        // しないので常に 1 件配列。
        data: [payload],
        options: Options(
          headers: {
            'App-Key': _appKey,
            'Content-Type': 'application/json; charset=UTF-8',
            'User-Agent': _sdkVersion,
          },
        ),
      );
    } on Object {
      // ベストエフォート送信。オフライン・サーバーエラー等は握り潰す。
    }
  }

  /// `app_launched` を 1 起動につき 1 回だけ送信する。
  ///
  /// 同意モーダルの表示中など送信条件を満たさない間に呼ばれた場合は
  /// 「送信済み」にしない（同意確定後の呼び出しで改めて送信される）。
  Future<void> trackAppLaunchedOnce() async {
    if (_appLaunchTracked || _apiUrl == null || !_isAllowed()) {
      return;
    }
    _appLaunchTracked = true;
    await trackEvent('app_launched');
  }

  /// セッション ID（epoch 秒 + 乱数 8 桁）。最終送信から 1 時間で再生成する。
  String _evalSessionId(DateTime now) {
    final current = _sessionId;
    final sessionId = (current == null ||
            now.difference(_lastTouch) > _sessionTimeout)
        ? _newSessionId(now)
        : current;
    _sessionId = sessionId;
    _lastTouch = now;
    return sessionId;
  }

  String _newSessionId(DateTime now) {
    final epochInSeconds = now.millisecondsSinceEpoch ~/ 1000;
    final random = _random.nextInt(100000000).toString().padLeft(8, '0');
    return '$epochInSeconds$random';
  }

  Future<Map<String, Object?>> _systemProps() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return {
      'isDebug': kDebugMode,
      'osName': _osName(),
      'osVersion': _osVersion(),
      'locale': Platform.localeName,
      'appVersion': packageInfo.version,
      'appBuildNumber': packageInfo.buildNumber,
      'sdkVersion': _sdkVersion,
    };
  }

  String _osName() {
    if (Platform.isMacOS) {
      return 'macOS';
    }
    if (Platform.isWindows) {
      return 'Windows';
    }
    return Platform.operatingSystem;
  }

  /// `Platform.operatingSystemVersion` から数字版を抜き出す。
  ///
  /// device_info_plus を足さずに済ませるための簡易版。
  /// macOS: `Version 15.5 (Build 24F74)` → `15.5`
  /// Windows: `"Windows 10 Pro" 10.0 (Build 19043)` → `10.0.19043`
  String _osVersion() {
    final raw = Platform.operatingSystemVersion;
    final version = RegExp(r'(\d+(?:\.\d+)+)').firstMatch(raw)?.group(1);
    if (version == null) {
      return raw.length > 100 ? raw.substring(0, 100) : raw;
    }
    if (Platform.isWindows) {
      final build = RegExp(r'Build (\d+)').firstMatch(raw)?.group(1);
      if (build != null) {
        return '$version.$build';
      }
    }
    return version;
  }
}

/// `AnalyticsService` の Provider。アプリ生存期間で 1 インスタンス
/// （セッション ID と `app_launched` の送信済みフラグを保持する）。
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(
    appKey: AnalyticsService.appKeyFromEnvironment,
    isAllowed: () {
      final settings = ref.read(privacySettingsProvider).value;
      return settings != null &&
          (settings.acceptedTermsVersion ?? 0) >= currentTermsVersion &&
          settings.analyticsEnabled;
    },
  );
});
