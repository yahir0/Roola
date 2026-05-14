import 'package:hooks_riverpod/hooks_riverpod.dart';

/// ディレクトリビュー内で「いま選択中の 1 アイテム」の絶対パスを保持する Notifier。
///
/// 操作モデル変更（ADR-0021）に伴い導入: シングルクリックで選択（このパスを
/// セット）、ダブルクリックで遷移／オープン、選択中に `C` キー連打で
/// 選択パスをクリップボードへコピー。
///
/// 永続化は不要。ディレクトリビューを離れた / 別ディレクトリに navigate した
/// タイミングでクリアする運用（呼び出し側で `clear` または `select(null)`）。
class ExplorerItemSelectionNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  /// 指定パスを選択状態にする。null 渡しで選択解除。
  void select(String? path) => state = path;

  /// 同じパスがすでに選択されているなら解除、違うなら新規選択。
  /// （シングルクリック反復で選択トグルしたいときに使うが、現状は
  /// 単純 select のみで運用）
  void toggle(String path) => state = state == path ? null : path;

  void clear() => state = null;
}

final explorerItemSelectionProvider =
    NotifierProvider<ExplorerItemSelectionNotifier, String?>(
      ExplorerItemSelectionNotifier.new,
    );
