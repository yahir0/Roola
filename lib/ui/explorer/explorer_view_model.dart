import 'dart:io';

import 'package:claude_skills_launcher/data/repo_explorer/explorer_directory_loader.dart';
import 'package:claude_skills_launcher/data/repo_explorer/explorer_node.dart';
import 'package:claude_skills_launcher/data/repo_explorer/explorer_settings_repository_impl.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'explorer_view_model.freezed.dart';
part 'explorer_view_model.g.dart';

/// エクスプローラ画面の表示状態。
///
/// `root` は永続化されたルートディレクトリ。`currentPath` は現在表示中の
/// パス（root と同じか、その配下）。`children` は currentPath の直下の
/// ディレクトリ一覧（Skill 検知済みのものは `skillNames` が非空）。
@freezed
abstract class ExplorerState with _$ExplorerState {
  const factory ExplorerState({
    required String root,
    required String currentPath,
    required List<ExplorerDirectoryNode> children,
  }) = _ExplorerState;
}

/// エクスプローラの ViewModel。
///
/// ルートディレクトリは `explorerSettingsProvider` を購読して取得する。
/// `enter` / `goUp` でカレントパスを切り替え、その都度直下を再ロードする。
/// `changeRoot` ではルート自体を永続化したうえでカレントも合わせて更新する。
@riverpod
class ExplorerViewModel extends _$ExplorerViewModel {
  static const _loader = ExplorerDirectoryLoader();

  @override
  ExplorerState build() {
    final settings = ref.watch(explorerSettingsProvider).value;
    final root = settings?.rootPath ?? _defaultRoot();
    return ExplorerState(
      root: root,
      currentPath: root,
      children: _loader.load(root),
    );
  }

  void enter(String childPath) {
    state = state.copyWith(
      currentPath: childPath,
      children: _loader.load(childPath),
    );
  }

  void goUp() {
    if (state.currentPath == state.root) {
      return;
    }
    final parent = _parentOf(state.currentPath);
    state = state.copyWith(currentPath: parent, children: _loader.load(parent));
  }

  /// ルートを変更し、永続化する。
  Future<void> changeRoot(String newRoot) async {
    await ref.read(explorerSettingsProvider.notifier).setRootPath(newRoot);
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
