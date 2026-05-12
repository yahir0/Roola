import 'package:freezed_annotation/freezed_annotation.dart';

part 'launcher_entry.freezed.dart';

/// ランチャー画面に並ぶ 1 エントリ。
///
/// 永続化形式は `LauncherEntryDto` 経由で JSON に変換する。
/// 表示用の派生値（アイコン画像の絶対パスなど）は ViewModel 側で計算する。
@freezed
abstract class LauncherEntry with _$LauncherEntry {
  const factory LauncherEntry({
    /// 一意 ID（uuid v4）。
    required String id,

    /// ユーザーが付けた表示名。
    required String displayName,

    /// 起動対象のローカルリポジトリ絶対パス。
    required String repositoryPath,

    /// 実行する Skill 名（`claude` プロセスに渡す）。
    required String skillName,

    /// アイコン画像のローカル絶対パス。未設定なら null（既定アイコンを使う）。
    String? iconPath,

    /// エントリ作成日時。
    required DateTime createdAt,
  }) = _LauncherEntry;
}
