import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'explorer_item_selection.g.dart';

/// エクスプローラタブごとに「いま選択中の 1 アイテム」の絶対パスを保持する
/// Notifier（`family(tabId)` / ADR-0027）。
///
/// 操作モデル（ADR-0021）: シングルクリックで選択（このパスをセット）、
/// ダブルクリックで遷移／オープン、選択中に `C` キー連打で選択パスを
/// クリップボードへコピー。
///
/// 永続化は不要。別ディレクトリへ navigate したタイミングでクリアする運用
/// （呼び出し側で `clear` または `select(null)`）。タブを閉じたときは
/// `Workspace.closeTab` から明示 invalidate される。
@riverpod
class ExplorerItemSelection extends _$ExplorerItemSelection {
  @override
  String? build(String tabId) => null;

  /// 指定パスを選択状態にする。null 渡しで選択解除。
  void select(String? path) => state = path;

  /// 同じパスがすでに選択されているなら解除、違うなら新規選択。
  void toggle(String path) => state = state == path ? null : path;

  void clear() => state = null;
}
