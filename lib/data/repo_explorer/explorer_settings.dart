import 'package:freezed_annotation/freezed_annotation.dart';

part 'explorer_settings.freezed.dart';

/// エクスプローラのファイル/フォルダタイルの表示密度（ADR-0024）。
///
/// - [compact]: サイドバーと同等の縦幅。1 行表示、Skill subtitle と chip は省略
/// - [comfortable]: 従来の 3 行レイアウト。Skill subtitle / chip を含む
enum ExplorerListDensity {
  compact,
  comfortable,
}

/// エクスプローラ画面の永続化対象状態。
///
/// 最後に開いたルートパスと、ユーザーが登録したお気に入り（サイドバー
/// に表示する「よく使う場所」）、ファイルリストの表示密度を持つ。
@freezed
abstract class ExplorerSettings with _$ExplorerSettings {
  const factory ExplorerSettings({
    /// 最後に開いていたルートディレクトリの絶対パス。`null` なら未設定
    /// （ホームディレクトリで開く）。
    String? rootPath,

    /// サイドバーに並べるお気に入り。先頭から順に表示する。
    @Default(<ExplorerFavorite>[]) List<ExplorerFavorite> favorites,

    /// ファイル / フォルダのタイル表示密度（ADR-0024）。新規ユーザーには
    /// comfortable がデフォルト（Skill サブタイトル / チップを含む 3 要素レイアウト）。
    @Default(ExplorerListDensity.comfortable) ExplorerListDensity listDensity,
  }) = _ExplorerSettings;

  /// 既定値（未設定 + お気に入り空 + comfortable 密度）。
  factory ExplorerSettings.defaults() => const ExplorerSettings();
}

/// サイドバーに登録する 1 件のお気に入り。`id` は永続化時にユニーク
/// を保証するための識別子（uuid を想定）、`path` は対象の絶対パス、
/// `name` は表示名（既定では path の basename を採用するが、ユーザー
/// が編集できることを想定して別フィールドにしている）。
@freezed
abstract class ExplorerFavorite with _$ExplorerFavorite {
  const factory ExplorerFavorite({
    required String id,
    required String path,
    required String name,
  }) = _ExplorerFavorite;
}
