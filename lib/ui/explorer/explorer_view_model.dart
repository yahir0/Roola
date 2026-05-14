import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:roola/data/repo_explorer/explorer_directory_loader.dart';
import 'package:roola/data/repo_explorer/explorer_node.dart';
import 'package:roola/data/repo_explorer/explorer_settings_repository_impl.dart';

part 'explorer_view_model.freezed.dart';
part 'explorer_view_model.g.dart';

/// エクスプローラ画面の表示状態。
///
/// `root` は起動時の開始位置として永続化された絶対パス。ADR-0015 で
/// ceiling（上限）としての役割は撤去され、`currentPath` は root より
/// 上にも自由に navigate できる。`currentPath` は現在表示中の絶対パス。
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

/// エクスプローラの ViewModel。
///
/// ルートディレクトリは `explorerSettingsProvider` を購読して取得する。
/// `navigateTo` で任意の絶対パスに移動し、その都度直下を再ロードする。
/// `changeRoot` ではルート自体を永続化したうえでカレントも合わせて更新する。
///
/// マウスのサイドボタン（戻る / 進む）でブラウザのような履歴ナビゲーション
/// ができるよう、訪問パスを `_history` に保持し、`_historyCursor` で現在
/// 位置を指す。`navigateTo` は cursor 以降の forward 履歴を破棄して新しい
/// パスを末尾に積む。`goBack` / `goForward` は cursor を上下させるだけで
/// 履歴自体は変更しない。
@riverpod
class ExplorerViewModel extends _$ExplorerViewModel {
  static const _loader = ExplorerDirectoryLoader();

  final List<String> _history = [];
  int _historyCursor = -1;

  @override
  ExplorerState build() {
    final settings = ref.watch(explorerSettingsProvider).value;
    final root = settings?.rootPath ?? _defaultRoot();
    _history
      ..clear()
      ..add(root);
    _historyCursor = 0;
    return ExplorerState(
      root: root,
      currentPath: root,
      children: _loader.load(root),
    );
  }

  /// 任意の絶対パスへ移動する。存在しないパスは無視。
  /// パスバー入力 / お気に入りクリック / 子ディレクトリの enter / 親への
  /// `goUp` などすべてのユーザー起点ナビゲーションがここを通り、履歴に
  /// 積まれる。
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
    state = state.copyWith(currentPath: path, children: _loader.load(path));
  }

  /// 履歴を 1 つ戻る。先頭にいる場合は何もしない。
  /// マウスの戻るボタン（[MouseNavigationListener]）から呼ばれる。
  void goBack() {
    if (_historyCursor <= 0) {
      return;
    }
    _historyCursor--;
    final path = _history[_historyCursor];
    state = state.copyWith(currentPath: path, children: _loader.load(path));
  }

  /// 履歴を 1 つ進む。末尾にいる場合は何もしない。
  /// マウスの進むボタンから呼ばれる。
  void goForward() {
    if (_historyCursor >= _history.length - 1) {
      return;
    }
    _historyCursor++;
    final path = _history[_historyCursor];
    state = state.copyWith(currentPath: path, children: _loader.load(path));
  }

  bool get canGoBack => _historyCursor > 0;

  bool get canGoForward => _historyCursor < _history.length - 1;

  /// 親ディレクトリへ移動する（履歴にも積む）。AppBar の back 矢印 /
  /// `ExplorerParentDropTile` から呼ばれる。ADR-0015 で root ceiling は
  /// 廃止済みのため、root より上にも登れる。filesystem root (`/`) では
  /// `_parentOf` が `/` を返し、`navigateTo` の existsSync で no-op になる。
  void goUp() {
    final parent = _parentOf(state.currentPath);
    navigateTo(parent);
  }

  /// ルートを変更し、永続化する。履歴も新しいルートを起点に作り直す。
  Future<void> changeRoot(String newRoot) async {
    await ref.read(explorerSettingsProvider.notifier).setRootPath(newRoot);
    _history
      ..clear()
      ..add(newRoot);
    _historyCursor = 0;
    state = ExplorerState(
      root: newRoot,
      currentPath: newRoot,
      children: _loader.load(newRoot),
    );
  }

  /// テスト用の手動リフレッシュ。実機では使用しない。
  void refresh() {
    state = state.copyWith(children: _loader.load(state.currentPath));
  }

  static String _defaultRoot() {
    final home = Platform.environment['HOME'];
    return (home != null && home.isNotEmpty) ? home : '/';
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
