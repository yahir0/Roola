import 'package:roola/data/workspace/workspace_layout.dart';

/// ワークスペースレイアウトの永続化リポジトリ（ADR-0028）。
abstract interface class WorkspaceRepository {
  /// 永続化されたレイアウトを読み込む。
  ///
  /// ファイルが無い / JSON として不正 / 全スロットが空 のいずれの場合も
  /// `null` を返す。呼び出し側は `null` を既定 3 ペイン seed のトリガにする。
  Future<WorkspaceLayout?> load();

  /// レイアウトを永続化する。複数ウィンドウからの書き込みは last-write-wins。
  Future<void> save(WorkspaceLayout layout);
}
