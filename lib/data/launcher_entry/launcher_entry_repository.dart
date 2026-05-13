import 'package:roola/data/launcher_entry/launcher_entry.dart';

/// ランチャーエントリの永続化を抽象化する Repository。
///
/// 実装は `LauncherEntryRepositoryImpl` がローカル JSON ファイルで提供する。
/// 将来 sqlite や Drift に差し替える場合も本 interface を介する。
abstract interface class LauncherEntryRepository {
  /// 保存済みエントリの一覧を作成日時昇順で返す。
  Future<List<LauncherEntry>> loadAll();

  /// エントリを新規追加する。同じ id が既にあれば [StateError] を投げる。
  Future<void> add(LauncherEntry entry);

  /// エントリを更新する。対象 id が見つからなければ [StateError] を投げる。
  Future<void> update(LauncherEntry entry);

  /// 指定 id のエントリを削除する。存在しなくても例外は投げない。
  Future<void> delete(String id);
}
