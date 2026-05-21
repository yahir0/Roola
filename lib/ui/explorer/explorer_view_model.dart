import 'dart:async';
import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:roola/data/fs_watcher/directory_watcher.dart';
import 'package:roola/data/repo_explorer/explorer_directory_loader.dart';
import 'package:roola/data/repo_explorer/explorer_node.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:roola/ui/workspace/workspace_seed.dart';

part 'explorer_view_model.freezed.dart';
part 'explorer_view_model.g.dart';

/// エクスプローラタブ 1 つ分の表示状態。
///
/// `root` はタブ生成時の開始位置。`currentPath` は現在表示中の絶対パス。
/// `children` は currentPath 直下のディレクトリ + ファイル（ディレクトリ
/// が先、各ブロック内は名前順）。
@freezed
abstract class ExplorerState with _$ExplorerState {
  const factory ExplorerState({
    required String root,
    required String currentPath,
    required List<ExplorerNode> children,
  }) = _ExplorerState;
}

/// エクスプローラタブの ViewModel（`family(tabId)` / ADR-0027）。
///
/// 初期パスは `workspaceProvider` のタブ状態から `ref.read` で 1 度だけ取得
/// する（watch しない＝起動ディレクトリ変更で全タブがリセットされない）。
/// `navigateTo` で任意の絶対パスに移動し、その都度直下を再ロードして
/// `workspaceProvider.updateTabPath` でカレントパスを永続化用に反映する。
///
/// マウスのサイドボタン（戻る / 進む）でブラウザのような履歴ナビゲーション
/// ができるよう、訪問パスを `_history` に保持し、`_historyCursor` で現在
/// 位置を指す。`navigateTo` は cursor 以降の forward 履歴を破棄して新しい
/// パスを末尾に積む。`goBack` / `goForward` は cursor を上下させるだけで
/// 履歴自体は変更しない。
///
/// `keepAlive` のため、タブを別ペインへ DnD 移動しても履歴は保持される。
/// 破棄はタブを閉じたときに `Workspace.closeTab` から明示 invalidate する。
@Riverpod(keepAlive: true)
class ExplorerViewModel extends _$ExplorerViewModel {
  static const _loader = ExplorerDirectoryLoader();
  static const _watcher = DirectoryWatcher();

  final List<String> _history = [];
  int _historyCursor = -1;
  StreamSubscription<void>? _watchSub;

  @override
  ExplorerState build(String tabId) {
    final tab = ref.read(workspaceProvider.notifier).tabById(tabId);
    final start = (tab is ExplorerTab)
        ? tab.currentPath
        : defaultWorkspaceHome();
    _history
      ..clear()
      ..add(start);
    _historyCursor = 0;
    ref.onDispose(() {
      _watchSub?.cancel();
      _watchSub = null;
    });
    _startWatch(start);
    return ExplorerState(
      root: start,
      currentPath: start,
      children: _loader.load(start),
    );
  }

  /// 任意の絶対パスへ移動する。存在しないパスは無視。
  /// パスバー入力 / お気に入りクリック / 子ディレクトリの enter / 親への
  /// `goUp` などすべてのユーザー起点ナビゲーションがここを通り、履歴に
  /// 積まれる。カレントパスは `workspaceProvider` にも反映する（永続化用）。
  void navigateTo(String path) {
    if (!Directory(path).existsSync()) {
      return;
    }
    if (state.currentPath == path) {
      return;
    }
    // 現在位置より forward 側の履歴は破棄して、新しいパスを末尾に追加。
    if (_historyCursor < _history.length - 1) {
      _history.removeRange(_historyCursor + 1, _history.length);
    }
    _history.add(path);
    _historyCursor = _history.length - 1;
    _applyPath(path);
  }

  /// 履歴を 1 つ戻る。先頭にいる場合は何もしない。
  void goBack() {
    if (_historyCursor <= 0) {
      return;
    }
    _historyCursor--;
    _applyPath(_history[_historyCursor]);
  }

  /// 履歴を 1 つ進む。末尾にいる場合は何もしない。
  void goForward() {
    if (_historyCursor >= _history.length - 1) {
      return;
    }
    _historyCursor++;
    _applyPath(_history[_historyCursor]);
  }

  bool get canGoBack => _historyCursor > 0;

  bool get canGoForward => _historyCursor < _history.length - 1;

  /// 親ディレクトリへ移動する（履歴にも積む）。filesystem root (`/`) では
  /// `_parentOf` が `/` を返し、`navigateTo` の existsSync で no-op になる。
  void goUp() {
    navigateTo(_parentOf(state.currentPath));
  }

  /// テスト用の手動リフレッシュ。実機では使用しない。
  void refresh() {
    state = state.copyWith(children: _loader.load(state.currentPath));
  }

  /// state と `workspaceProvider` のタブパスを path に揃える共通処理。
  /// 監視先も新しいパス直下に貼り直す（ADR-0041）。
  void _applyPath(String path) {
    state = state.copyWith(currentPath: path, children: _loader.load(path));
    ref.read(workspaceProvider.notifier).updateTabPath(tabId, path);
    _startWatch(path);
  }

  /// `path` 直下を監視し、外部からの変更（Finder / CLI など）に追随する。
  /// 既存の購読は破棄してから新規に貼り直す。
  void _startWatch(String path) {
    _watchSub?.cancel();
    _watchSub = _watcher.watch(path).listen((_) {
      if (state.currentPath == path) {
        state = state.copyWith(children: _loader.load(path));
      }
    });
  }

  static String _parentOf(String path) {
    final normalized = path.endsWith('/') && path.length > 1
        ? path.substring(0, path.length - 1)
        : path;
    final lastSlash = normalized.lastIndexOf('/');
    if (lastSlash <= 0) {
      return '/';
    }
    return normalized.substring(0, lastSlash);
  }
}
