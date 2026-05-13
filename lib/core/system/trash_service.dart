import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 指定パスを OS のゴミ箱に移動するサービス。
///
/// macOS では `FileManager.trashItem` を method channel 越しに呼ぶことで、
/// Finder の Cmd+Delete と同じ挙動になる（ゴミ箱から「戻す」も可能）。
/// `Process.run` で `mv ~/.Trash` するアプローチと違い、振り戻し情報や
/// Finder のアニメーション・通知センター連携も維持される。
class TrashService {
  const TrashService();

  static const _channel = MethodChannel('roola/trash');

  /// [path] のファイル / ディレクトリをゴミ箱へ移動する。
  /// 成功時は無例外で完了。失敗時は [PlatformException] を投げる。
  Future<void> moveToTrash(String path) async {
    await _channel.invokeMethod<void>('moveToTrash', {'path': path});
  }
}

final trashServiceProvider = Provider<TrashService>(
  (ref) => const TrashService(),
);
