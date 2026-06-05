import 'package:freezed_annotation/freezed_annotation.dart';

part 'launcher_action.freezed.dart';
part 'launcher_action.g.dart';

/// ランチャー 1 エントリの「起動時にやること」を表す sealed union。
///
/// PTY runner は本 union を解釈して `(executable, arguments)` を組み立てる。
/// 永続化スキーマ上は `type` フィールドで分岐する（`openHere` / `runCommand` /
/// `claudeSkill`）。
@Freezed(unionKey: 'type', fromJson: true, toJson: true)
sealed class LauncherAction with _$LauncherAction {
  /// 作業ディレクトリで `$SHELL` を起動するだけの素のターミナル。
  /// `SHELL` 環境変数が無い環境では PTY runner 側で `/bin/zsh` にフォールバック。
  @FreezedUnionValue('openHere')
  const factory LauncherAction.openHere() = OpenHereAction;

  /// 作業ディレクトリで `$SHELL -lc "<command>"` として任意コマンドを実行する。
  ///
  /// `keepShellAfterExit` が true（既定）のとき、`<command>` の末尾に
  /// `; exec $SHELL -i` を後置し、コマンド完了後にログインシェルがそのまま
  /// 立ち上がる。one-shot 系コマンドの結果を確認できる体験のための既定値。
  /// 常駐コマンド（`npm run dev` 等）では false でも結果は同じ
  /// （プロセスが終わらないので後置が発火しない）。
  @FreezedUnionValue('runCommand')
  const factory LauncherAction.runCommand({
    required String command,
    @Default(true) bool keepShellAfterExit,
  }) = RunCommandAction;

  /// `claude /<skillName>` を起動して Claude Code Skill を呼び出す。
  ///
  /// `skillName` は必ず非空（バリデーションで保証される）。素の `claude`
  /// 起動が必要な場合は `RunCommandAction(command: 'claude')` で表現する
  /// （ADR-0016 / design.md Decision 4 を参照）。
  ///
  /// `requiresArgument` が true のとき、ランチャー起動時に複数行テキストの
  /// 入力ダイアログを出し、入力値を `claude /<skillName> <入力>` の単一引数
  /// として渡す（ADR-0062）。引数本文は永続化エントリには保存せず、実行時に
  /// [AdhocRunArgs.skillArgument] として一時的に取り回す。
  @FreezedUnionValue('claudeSkill')
  const factory LauncherAction.claudeSkill({
    required String skillName,
    @Default(false) bool requiresArgument,
  }) = ClaudeSkillAction;

  factory LauncherAction.fromJson(Map<String, dynamic> json) =>
      _$LauncherActionFromJson(json);
}

/// `LauncherAction` のタイプ識別子。UI のセグメント選択や
/// `EntryEditViewModel` の state 管理で使う。永続化スキーマには出ない
/// （永続化は sealed union 自体の `type` フィールド経由）。
enum LauncherActionType { openHere, runCommand, claudeSkill }

/// `LauncherAction` から対応する [LauncherActionType] を取り出すヘルパー。
LauncherActionType launcherActionTypeOf(LauncherAction action) =>
    switch (action) {
      OpenHereAction() => LauncherActionType.openHere,
      RunCommandAction() => LauncherActionType.runCommand,
      ClaudeSkillAction() => LauncherActionType.claudeSkill,
    };
