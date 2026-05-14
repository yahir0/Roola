import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';

part 'adhoc_run_args.freezed.dart';

/// ad-hoc セッション起動時に View 層と Notifier 層で取り回す引数。
///
/// Freezed で `==` / hashCode が成立するため、Riverpod family の比較や
/// `ActiveSessions._adhocArgs` の Map キーで安全に使える。
///
/// 旧バージョンでは `kind: AdhocRunKind { claudeCode, terminal }` で
/// 動作を分岐していたが、本 change（ADR-0016）で `LauncherAction` に統合
/// した。エクスプローラ右クリックの「Claude Code を開く」は
/// `RunCommandAction(command: 'claude')`、「ターミナルで開く」は
/// `OpenHereAction()` を渡す。
@freezed
abstract class AdhocRunArgs with _$AdhocRunArgs {
  const factory AdhocRunArgs({
    required String adhocId,
    required String workingDirectory,

    /// chip 列でのラベル。「ディレクトリ名 / Skill 名」または
    /// 「ディレクトリ名 (Claude)」など、呼び出し側が組み立てて渡す。
    required String displayName,

    /// 起動時にやること（[LauncherAction] の sealed union を再利用）。
    required LauncherAction action,
  }) = _AdhocRunArgs;
}
