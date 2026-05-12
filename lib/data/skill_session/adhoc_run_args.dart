import 'package:freezed_annotation/freezed_annotation.dart';

part 'adhoc_run_args.freezed.dart';

/// ad-hoc セッション起動時に View 層と Notifier 層で取り回す引数。
///
/// Freezed で `==` / hashCode が成立するため、Riverpod family の比較や
/// `ActiveSessions._adhocArgs` の Map キーで安全に使える。
@freezed
abstract class AdhocRunArgs with _$AdhocRunArgs {
  const factory AdhocRunArgs({
    required String adhocId,
    required String repositoryPath,

    /// chip 列でのラベル。「ディレクトリ名 / Skill 名」または
    /// 「ディレクトリ名 (Claude)」など、呼び出し側が組み立てて渡す。
    required String displayName,

    /// 空文字なら Skill 指定なし（`claude` 単独起動）。
    @Default('') String skillName,
  }) = _AdhocRunArgs;
}
