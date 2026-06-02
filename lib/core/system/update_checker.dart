import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/system/update_checker_macos.dart';
import 'package:roola/core/system/update_checker_windows.dart';

/// アップデート確認を起動するサービス（ADR-0043）。
///
/// macOS は Sparkle（`SPUStandardUpdater`）経由、
/// Windows は WinSparkle（`win_sparkle_check_update_with_ui()`）経由で
/// いずれも MethodChannel `roola/updater` を通じてネイティブに委譲する。
abstract interface class UpdateChecker {
  /// アップデート確認を開始する。
  Future<void> checkForUpdates();
}

final updateCheckerProvider = Provider<UpdateChecker>((ref) {
  if (Platform.isMacOS) return const UpdateCheckerMacos();
  if (Platform.isWindows) return UpdateCheckerWindows();
  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
});
