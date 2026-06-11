import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/constants/terms.dart';
import 'package:roola/data/analytics/analytics_service.dart';
import 'package:roola/data/privacy/privacy_settings_repository_impl.dart';
import 'package:roola/ui/consent/terms_consent_modal.dart';
import 'package:window_manager/window_manager.dart';

/// 利用規約の同意状態を照合し、必要なら同意モーダルを被せる Gate（ADR-0065）。
///
/// `MaterialApp.router` の builder チェーン（`app.dart`）に常駐させる。
/// 未同意、または同意済みバージョンが現行規約（[currentTermsVersion]）より
/// 古い場合、メイン UI の上に [TermsConsentModal] を重ねて操作を遮断する。
/// macOS には Windows インストーラのような同意シーンがないため、既存ユーザー
/// もアップデート後の初回起動でここを通る。
///
/// 同意済みのときは何も被せず、`app_launched` を 1 起動 1 回送信する
/// （同意モーダルで同意した直後も、Gate の再ビルドで同じ経路を通る）。
class TermsConsentGate extends ConsumerWidget {
  const TermsConsentGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(privacySettingsProvider).value;
    // 読み込み完了前はモーダルを出さない（同意済みユーザーの起動を
    // ちらつかせない）。読み込みは起動直後のローカルファイル 1 件で十分速く、
    // 完了までユーザー操作が間に合うことは実質ない。
    if (settings == null) {
      return child;
    }

    final needsConsent =
        (settings.acceptedTermsVersion ?? 0) < currentTermsVersion;
    if (!needsConsent) {
      // 送信条件（同意・オプトイン・App Key）の判定と 1 回制御は
      // AnalyticsService 側にあるため、ビルドのたびに呼んでも安全。
      unawaited(ref.read(analyticsServiceProvider).trackAppLaunchedOnce());
      return child;
    }

    return Stack(
      children: [
        child,
        const Positioned.fill(child: TermsConsentModal(onQuit: _quit)),
      ],
    );
  }

  /// 同意しない場合はアプリを終了する（規約第1条）。
  ///
  /// Windows で `windowManager.destroy()` を使わず `exit(0)` するのは
  /// `WindowCloseGuard` と同じ理由（FlutterEngineShutdown がメインスレッドを
  /// ブロックしてウィンドウが残るため）。
  static void _quit() {
    if (Platform.isWindows) {
      exit(0);
    } else {
      unawaited(windowManager.destroy());
    }
  }
}
