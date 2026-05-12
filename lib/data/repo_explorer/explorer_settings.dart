import 'package:freezed_annotation/freezed_annotation.dart';

part 'explorer_settings.freezed.dart';

/// エクスプローラ画面の永続化対象状態。
///
/// 最後に開いたルートパスと、ユーザーが登録したお気に入り（サイドバー
/// に表示する「よく使う場所」）を持つ。
@freezed
abstract class ExplorerSettings with _$ExplorerSettings {
  const factory ExplorerSettings({
    /// 最後に開いていたルートディレクトリの絶対パス。`null` なら未設定
    /// （ホームディレクトリで開く）。
    String? rootPath,

    /// サイドバーに並べるお気に入り。先頭から順に表示する。
    @Default(<ExplorerFavorite>[]) List<ExplorerFavorite> favorites,
  }) = _ExplorerSettings;

  /// 既定値（未設定 + お気に入り空）。
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
