import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:roola/data/repo_explorer/explorer_settings_repository_impl.dart';
import 'package:roola/data/skill_session/adhoc_run_args.dart';

part 'explorer_selection.freezed.dart';
part 'explorer_selection.g.dart';

/// エクスプローラ body に何を表示するかの状態。
///
/// - [ExplorerSelectionDirectory]: ディレクトリ一覧を描画
/// - [ExplorerSelectionEntrySession]: 永続エントリで起動したセッションの
///   PTY ターミナルを描画
/// - [ExplorerSelectionAdhocSession]: ad-hoc 起動セッションの PTY を描画
///
/// サイドバーの全タイル / AppBar の ⚡ popover / 右クリックの「Skill 即実行」
/// などが [ExplorerSelectionNotifier] を介してこの state を更新する。
@freezed
sealed class ExplorerSelection with _$ExplorerSelection {
  const factory ExplorerSelection.directory(String path) =
      ExplorerSelectionDirectory;

  /// 永続化された launcher entry のセッション。`sessionId == entryId`。
  const factory ExplorerSelection.entrySession(String entryId) =
      ExplorerSelectionEntrySession;

  /// ad-hoc セッション。`AdhocRunArgs` は family の引数として必要。
  const factory ExplorerSelection.adhocSession(AdhocRunArgs args) =
      ExplorerSelectionAdhocSession;
}

/// エクスプローラの現在 selection を保持する Notifier。`keepAlive: true`
/// のため、画面 widget が rebuild しても state は失われない。
///
/// 初期値はディレクトリビューで `rootPath`（未設定なら `$HOME`）を指す。
/// `rootPath` は ADR-0015 で「起動時の開始位置」のみを意味するように
/// なったので、selection は起動後に自由に書き換わる。
@Riverpod(keepAlive: true)
class ExplorerSelectionNotifier extends _$ExplorerSelectionNotifier {
  @override
  ExplorerSelection build() {
    final settings = ref.watch(explorerSettingsProvider).value;
    final start = settings?.rootPath ?? _defaultHome();
    return ExplorerSelection.directory(start);
  }

  /// ディレクトリビューに切替（パス指定）。`ExplorerViewModel.navigateTo` と
  /// 共に呼び出すこと。
  void selectDirectory(String path) {
    state = ExplorerSelection.directory(path);
  }

  /// 永続エントリのセッションビューに切替。`runViewModelProvider(entryId)`
  /// は呼び出し側で別途 read して PTY を起動させること。
  void selectEntrySession(String entryId) {
    state = ExplorerSelection.entrySession(entryId);
  }

  /// ad-hoc セッションビューに切替。`adhocRunViewModelProvider(args)` の
  /// 起動も呼び出し側で別途 read 推奨。
  void selectAdhocSession(AdhocRunArgs args) {
    state = ExplorerSelection.adhocSession(args);
  }

  static String _defaultHome() {
    final home = Platform.environment['HOME'];
    return (home != null && home.isNotEmpty) ? home : '/';
  }
}
