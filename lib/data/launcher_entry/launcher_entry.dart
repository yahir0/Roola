import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';

part 'launcher_entry.freezed.dart';

/// ランチャーに並ぶ 1 エントリ。
///
/// 永続化形式は `LauncherEntryDto` 経由で JSON に変換する。
/// 表示用の派生値（アイコン画像の絶対パスなど）は ViewModel 側で計算する。
///
/// `action` は sealed union で「起動時にやること」を表現する。動作タイプの
/// 詳細は [LauncherAction] を参照。旧スキーマ (`repositoryPath` /
/// `skillName` の 2 フィールド) は `LauncherEntryDto.fromJson` で読み込み時に
/// 自動 migrate される（ADR-0016）。
@freezed
abstract class LauncherEntry with _$LauncherEntry {
  const factory LauncherEntry({
    /// 一意 ID（uuid v4）。
    required String id,

    /// ユーザーが付けた表示名。
    required String displayName,

    /// PTY を起動する作業ディレクトリの絶対パス。
    required String workingDirectory,

    /// 起動時にやること。タイプ別の追加フィールドはここに含まれる。
    required LauncherAction action,

    /// アイコン画像のローカル絶対パス。未設定なら null（既定アイコンを使う）。
    String? iconPath,

    /// エントリ作成日時。
    required DateTime createdAt,
  }) = _LauncherEntry;
}
