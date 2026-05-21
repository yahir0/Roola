import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Sparkle ベースの手動アップデート確認を起動するサービス（ADR-0043）。
///
/// バックグラウンドの自動更新はネイティブ側（`AppDelegate` の
/// `SPUStandardUpdaterController`）で完結している。本クラスはメニューバー
/// 「Roola > アップデートを確認…」など Flutter 側からの明示的な指示で
/// Sparkle の UI を起動するためのトリガに限定する。
///
/// 結果ダイアログ・ダウンロード・再起動などのフローはすべて Sparkle 側に
/// あるため、Dart 側は呼び出すだけで追加の状態は持たない。
class SparkleUpdater {
  const SparkleUpdater();

  static const _channel = MethodChannel('roola/updater');

  /// 手動でアップデートチェックを開始する。Sparkle のチェック UI が出る。
  /// SUFeedURL / SUPublicEDKey が未設定（ローカルビルド等）の場合は
  /// ネイティブ側で no-op。
  Future<void> checkForUpdates() async {
    await _channel.invokeMethod<void>('checkForUpdates');
  }
}

final sparkleUpdaterProvider = Provider<SparkleUpdater>(
  (ref) => const SparkleUpdater(),
);
