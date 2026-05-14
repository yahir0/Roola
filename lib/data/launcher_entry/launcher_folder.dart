import 'package:freezed_annotation/freezed_annotation.dart';

part 'launcher_folder.freezed.dart';

/// ランチャーエントリをグループ化するフォルダ。
///
/// ネストは 1 階層のみ（フォルダの中にフォルダは作らない、ADR-0019）。
/// 永続化形式は `LauncherFolderDto` 経由で JSON に変換する。
@freezed
abstract class LauncherFolder with _$LauncherFolder {
  const factory LauncherFolder({
    /// 一意 ID（uuid v4）。
    required String id,

    /// ユーザーが付けたフォルダ名。
    required String name,

    /// フォルダ作成日時。同セクション内での並び順に使う。
    required DateTime createdAt,
  }) = _LauncherFolder;
}
