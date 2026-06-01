import 'package:flutter/services.dart';
import 'package:roola/core/system/update_checker.dart';

/// macOS 実装: Sparkle の `SPUStandardUpdater` を MethodChannel 経由で起動する。
///
/// バックグラウンドの自動更新はネイティブ側（`AppDelegate`）で完結。
/// 本クラスはメニューバーからの明示的な確認指示のトリガのみ担当する。
class UpdateCheckerMacos implements UpdateChecker {
  const UpdateCheckerMacos();

  static const _channel = MethodChannel('roola/updater');

  @override
  Future<void> checkForUpdates() async {
    await _channel.invokeMethod<void>('checkForUpdates');
  }
}
