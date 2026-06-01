import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/system/trash_service_macos.dart';
import 'package:roola/core/system/trash_service_windows.dart';

/// 指定パスを OS のゴミ箱に移動するサービス。
abstract interface class TrashService {
  Future<void> moveToTrash(String path);
}

final trashServiceProvider = Provider<TrashService>((ref) {
  if (Platform.isMacOS) return const TrashServiceMacos();
  if (Platform.isWindows) return const TrashServiceWindows();
  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
});
