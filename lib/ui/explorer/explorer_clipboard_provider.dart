import 'package:hooks_riverpod/hooks_riverpod.dart';

/// エクスプローラ用の簡易クリップボード Notifier。
///
/// ユーザーが「コピー」したノードの絶対パスを保持し、「ペースト」時に
/// 参照する。OS の pasteboard とは無関係（アプリ内専用）。
/// アプリ再起動時はリセットする一時状態。
class ExplorerClipboardNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  /// 指定パスをクリップボードに保持する。
  void set(String? path) {
    state = path;
  }

  /// クリップボードを空にする。
  void clear() {
    state = null;
  }
}

final explorerClipboardProvider =
    NotifierProvider<ExplorerClipboardNotifier, String?>(
      ExplorerClipboardNotifier.new,
    );
