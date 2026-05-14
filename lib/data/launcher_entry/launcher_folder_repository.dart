import 'package:roola/data/launcher_entry/launcher_folder.dart';

/// ランチャーフォルダの永続化を抽象化する Repository。
///
/// 実装は `LauncherFolderRepositoryImpl` がローカル JSON ファイルで提供する。
/// JSON ファイル自体は `LauncherEntryRepository` と共有する（同じ
/// `launcher_entries.json`）が、各 repository は「自分の領分のキー」だけを
/// 上書きする lazy merge 方式で書き戻すため、相互干渉しない（ADR-0019）。
abstract interface class LauncherFolderRepository {
  /// 保存済みフォルダ一覧を作成日時昇順で返す。
  Future<List<LauncherFolder>> loadAll();

  /// フォルダを新規追加する。同じ id が既にあれば [StateError] を投げる。
  Future<void> add(LauncherFolder folder);

  /// フォルダを更新する（名前変更想定）。対象 id が見つからなければ
  /// [StateError] を投げる。
  Future<void> update(LauncherFolder folder);

  /// 指定 id のフォルダを削除する。存在しなくても例外は投げない。
  /// 中身のエントリの folderId を null に戻す副作用がある。
  Future<void> delete(String id);
}
