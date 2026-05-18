/// ノートパッド本文の永続化リポジトリ（ADR-0036）。
abstract interface class NotepadRepository {
  /// 永続化された本文を読み込む。
  ///
  /// ファイルが無い / JSON として不正 のいずれの場合も空文字を返す。
  Future<String> load();

  /// 本文を永続化する。
  Future<void> save(String content);
}
