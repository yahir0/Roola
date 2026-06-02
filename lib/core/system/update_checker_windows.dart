import 'package:flutter/services.dart';
import 'package:roola/core/system/update_checker.dart';

/// Windows 実装: WinSparkle の手動チェック UI を MethodChannel 経由で起動する。
///
/// バックグラウンドの自動チェックはネイティブ側（`main.cpp` の
/// `win_sparkle_init()`）で完結。本クラスはメニューバー「アップデートを確認…」
/// からの手動トリガのみを担当する（macOS の `UpdateCheckerMacos` と同パターン）。
///
/// WinSparkle が未統合のビルド（`ROOLA_WINSPARKLE` 未定義）では
/// ネイティブ側が no-op で返すため Dart 側にエラーは出ない。
class UpdateCheckerWindows implements UpdateChecker {
  static const _channel = MethodChannel('roola/updater');

  @override
  Future<void> checkForUpdates() async {
    await _channel.invokeMethod<void>('checkForUpdates');
  }
}
