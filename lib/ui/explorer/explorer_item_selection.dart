import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'explorer_item_selection.g.dart';

/// エクスプローラの選択状態（Polaris の選択モデル / ADR-0038 D12）。
///
/// 複数選択（[paths]）と主選択（[primary]＝アンカー）を持つ。主選択は
/// 「最後に選んだ 1 件」で、UI 上で唯一フルアクセント色に点灯する行。
/// それ以外の選択行は控えめな塗りで示す。
@immutable
class ExplorerSelection {
  const ExplorerSelection({this.paths = const {}, this.primary});

  /// 選択中アイテムの絶対パス集合。
  final Set<String> paths;

  /// 主選択（アンカー）の絶対パス。選択が空なら null。
  final String? primary;

  /// 空の選択状態。
  static const ExplorerSelection empty = ExplorerSelection();

  bool get isEmpty => paths.isEmpty;

  bool get isNotEmpty => paths.isNotEmpty;

  int get length => paths.length;

  /// [path] が選択に含まれるか。
  bool contains(String path) => paths.contains(path);

  /// [path] が主選択（アンカー）か。
  bool isPrimary(String path) => primary == path;

  @override
  bool operator ==(Object other) =>
      other is ExplorerSelection &&
      setEquals(other.paths, paths) &&
      other.primary == primary;

  @override
  int get hashCode => Object.hash(Object.hashAllUnordered(paths), primary);
}

/// エクスプローラタブごとに選択状態を保持する Notifier
/// （`family(tabId)` / ADR-0027）。
///
/// 操作モデル（ADR-0021 / ADR-0038 D12）: シングルクリックで単一選択、
/// ⌘+クリックで選択へ加除（主選択はクリックした行へ移る）、ダブルクリックで
/// 遷移／オープン。
///
/// 永続化は不要。別ディレクトリへ navigate したタイミングでクリアする運用
/// （呼び出し側で [clear]）。タブを閉じたときは `Workspace.closeTab` から
/// 明示 invalidate される。
@riverpod
class ExplorerItemSelection extends _$ExplorerItemSelection {
  @override
  ExplorerSelection build(String tabId) => ExplorerSelection.empty;

  /// 単一選択。クリックした 1 件だけを選択し、主選択にする。
  void select(String path) =>
      state = ExplorerSelection(paths: {path}, primary: path);

  /// ⌘+クリック。選択へ加除する。追加した行を主選択にする。削除した行が
  /// 主選択だった場合は、残りの末尾を主選択へ繰り上げる。
  void toggle(String path) {
    final next = Set<String>.from(state.paths);
    if (next.remove(path)) {
      state = ExplorerSelection(
        paths: next,
        primary: next.isEmpty
            ? null
            : (state.primary == path ? next.last : state.primary),
      );
    } else {
      next.add(path);
      state = ExplorerSelection(paths: next, primary: path);
    }
  }

  /// 選択を解除する。
  void clear() => state = ExplorerSelection.empty;
}
