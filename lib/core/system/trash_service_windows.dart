import 'package:flutter/services.dart';
import 'package:roola/core/system/trash_service.dart';

/// Windows 実装: Win32 `SHFileOperationW`（FOF_ALLOWUNDO）を
/// MethodChannel 経由で呼ぶ。ゴミ箱から「元に戻す」が可能。
class TrashServiceWindows implements TrashService {
  const TrashServiceWindows();

  static const _channel = MethodChannel('roola/trash');

  @override
  Future<void> moveToTrash(String path) async {
    await _channel.invokeMethod<void>('moveToTrash', {'path': path});
  }
}
