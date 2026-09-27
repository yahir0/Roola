import 'package:freezed_annotation/freezed_annotation.dart';

part 'explorer_node.freezed.dart';

/// エクスプローラに描画する 1 ノード。
///
/// ディレクトリとファイルの 2 case。クリック時の挙動が分かれる:
/// - ディレクトリはアプリ内でナビゲート
/// - ファイルは `FileOpener` 経由で OS デフォルトアプリで開く
@freezed
sealed class ExplorerNode with _$ExplorerNode {
  /// ディレクトリ。`skillNames` が空でなければ「Skill 検知済み」を示す。
  /// `worktreeBranch` が非 null なら git worktree（タイルにバッジ表示 /
  /// ADR-0067）。
  const factory ExplorerNode.directory({
    required String path,
    required String name,
    @Default(<String>[]) List<String> skillNames,
    String? worktreeBranch,
  }) = ExplorerDirectoryNode;

  /// ファイル。クリックで OS デフォルトアプリで開く。
  const factory ExplorerNode.file({
    required String path,
    required String name,
  }) = ExplorerFileNode;
}
