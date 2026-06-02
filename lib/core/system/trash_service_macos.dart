import 'package:flutter/services.dart';
import 'package:roola/core/system/trash_service.dart';

/// macOS 実装: `FileManager.trashItem` を MethodChannel 経由で呼ぶ。
///
/// Finder の Cmd+Delete と同じ挙動（ゴミ箱から「戻す」も可能）。
class TrashServiceMacos implements TrashService {
  const TrashServiceMacos();

  static const _channel = MethodChannel('roola/trash');

  @override
  Future<void> moveToTrash(String path) async {
    await _channel.invokeMethod<void>('moveToTrash', {'path': path});
  }
}
