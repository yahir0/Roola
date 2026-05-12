import 'package:freezed_annotation/freezed_annotation.dart';

part 'explorer_node.freezed.dart';

/// エクスプローラに描画する 1 ノード。
///
/// 現在はディレクトリのみ。ファイルプレビュー機能を入れる際に sealed の
/// 別 case を追加する。
@freezed
sealed class ExplorerNode with _$ExplorerNode {
  /// ディレクトリ。`skillNames` が空でなければ「Skill 検知済み」を示す。
  const factory ExplorerNode.directory({
    required String path,
    required String name,
    @Default(<String>[]) List<String> skillNames,
  }) = ExplorerDirectoryNode;
}
