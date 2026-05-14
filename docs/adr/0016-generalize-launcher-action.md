# ADR-0016: ランチャーを Claude Skill 専用から汎用ターミナルランチャーへ

- **Status**: Accepted
- **Date**: 2026-05-14

## Context

Roola のランチャーアイコンは元々「リポジトリパス + Claude Skill 名」の 2 フィールド固定で、`claude /<skill>` を起動することしか出来なかった。一方で実際に欲しい体験は「ターミナルのお気に入り」に近い:

- 特定ディレクトリで素のシェルを開きたい（毎日入るプロジェクト）
- 特定ディレクトリで毎回叩く決まったコマンドを実行したい（`npm run dev`、`docker compose up`、`make test`）
- Claude Skill を起動したい（既存ユースケース）

`pty_skill_runner.dart` には既に `skillName == ''` のフォールバックで「素の `claude` を開く」分岐があり、ad-hoc 側にも `AdhocRunKind { claudeCode, terminal }` という enum 分岐が存在していた。動作タイプを切り替えたい欲求は局所的に芽生えていたが、データモデル上は表現できていなかった。

ADR-0014（Explorer をメイン UI に格上げ）で Roola の主要機能はエクスプローラに移っており、ランチャーは「サブ機能」となった。であれば Claude 専用に縛り続ける理由が薄く、汎用ランチャーへの拡張時期。

## Decision

`LauncherEntry` の動作フィールドを **3 タイプの sealed union（`LauncherAction`）** に置き換え、永続エントリ・ad-hoc 起動・runner 構築を全てこの union 経由に統一する。

```dart
sealed class LauncherAction {
  factory LauncherAction.openHere() = OpenHereAction;
  factory LauncherAction.runCommand({
    required String command,
    bool keepShellAfterExit = true,
  }) = RunCommandAction;
  factory LauncherAction.claudeSkill({required String skillName}) =
      ClaudeSkillAction;
}
```

主要な決定:

- **永続化スキーマ変更**: `repositoryPath` / `skillName` 2 フィールド → `workingDirectory` / `action` 2 フィールド。読み込み時に旧スキーマを自動 migrate（lazy migration on read）。書き戻しは新スキーマ固定
- **PTY runner の汎用化**: `pty_skill_runner.dart` を `pty_terminal_runner.dart` にリネームし、`(workingDirectory, executable, arguments)` を引数とする汎用 runner に。`PtyTerminalRunner.fromAction` factory が `LauncherAction` から `(executable, arguments)` を組み立てる
- **「素の `claude` 起動」の表現**: 旧コードで `skillName: ''` が担っていた「Skill 名なしで `claude` を開く」は、新モデルでは `RunCommandAction(command: 'claude')` で表現する。`ClaudeSkillAction` は必ず非空 `skillName` を要求し、概念の一貫性を保つ
- **AdhocRunArgs の統合**: `AdhocRunKind` enum を削除し、`action: LauncherAction` で永続エントリと共通モデル化
- **編集画面 UI**: `SegmentedButton<LauncherActionType>` で 3 タイル横並び（📂 / ⚡ / 🤖）、選択された動作のフィールドのみ progressive disclosure で表示
- **タイプ切替時の値保持**: `EntryEditState` に `editedCommand` / `editedKeepShellAfterExit` / `editedSkillName` の一時編集値を持たせ、ユーザーがタイプを切り替えても値が消えないようにする
- **`keepShellAfterExit`**: `RunCommandAction` のフラグ。true（既定）のとき `$SHELL -lc "<cmd>; exec $SHELL -i"` として起動し、コマンド完了後にログインシェルが立ち上がる。one-shot コマンドの結果を確認できる体験を優先

## Why

### 代替案 1: enum + 個別フィールド（`type` + `command` + `skillName`）

却下。状態は単純だが「どのフィールドがどの enum 値で有効か」の対応が暗黙的になり、`RunCommand` 用のエントリに `skillName` が残るような不整合バグを生む。Freezed sealed union なら型レベルで網羅性チェックできる。

### 代替案 2: Claude Skill を独立タイプにせず `RunCommandAction` に内包

却下。Skill 名候補プルダウン（`.claude/skills/` スキャン）や「Claude Code とは何か」の説明 UI を出す導線が消える。Roola の出自（Claude Skills ランチャー）も保持したい。

### 代替案 3: 動作タイプ追加時にスキーマバージョンを上げる

却下（過剰）。バージョンフィールドを永続化する利点は小さく、`json.containsKey('action')` 判定で旧→新移行は十分判別可能。

### 代替案 4: 「Skill 名なしの Claude」を `ClaudeSkillAction(skillName: String?)` で nullable

却下。「Skill 名空のとき何が起きるか」を改めて UI で説明する必要が出る。`RunCommandAction(command: 'claude')` の方がユーザーから見て直感的（「claude というコマンドを実行する」）。

### 採用理由

- ユーザーの期待（「ターミナルのお気に入り」）と内部モデルが一致する
- 動作タイプが増えても sealed union と SegmentedButton にタイル追加するだけで拡張可能
- 既存の Claude Skill 起動はそのまま維持される（旧エントリの自動 migration あり）
- runner 構築・ad-hoc 起動・永続エントリ起動すべての経路で同じモデルを通せる

## Trade-offs

### 旧スキーマへの書き戻し非対応

新スキーマで保存したエントリは旧バージョンの Roola で読めない。Roola は単一プロジェクトの単一 user 用なので実害は無いが、CHANGELOG とコメントで明記する。永続化ファイルが破損して読めない場合の挙動（空一覧扱い）は既存の防御処理で吸収される。

### `keepShellAfterExit=true` の shell injection 懸念

`$SHELL -lc "<userCommand>; exec $SHELL -i"` の中に user 入力 `command` が double-quote 込みで入る。`"; rm -rf /` 等で抜け出される可能性は理論上ある。だが Roola はローカルで「ユーザー自身が自分の環境で実行する任意コマンド」を扱うツールなので、そのセキュリティモデル上「何でもできる」のは仕様。サンドボックス対象外。

### `pty_skill_runner.dart` のリネームによる import 全件書き換え

既存の import 約 6 ファイル分を一括 sed 置換。コンパイルエラーで漏れは検出可能なので低リスク。

### capability 名 `skill-runner` の据え置き

OpenSpec の spec ディレクトリ名は `skill-runner` のまま据え置く（archive 履歴とのトレーサビリティ尊重）。コード上のシンボル名は責務に合わせて `terminal_runner` / `PtyTerminalRunner` にリネーム済み。spec.md 冒頭で「（汎用 PTY runner。Claude Skill 起動はそのうちの 1 ケース）」と明記。

### `SkillRunState` クラス名の温存

段階的リネームの方針として、`SkillRunState` などの内部クラス名は本 change では維持する（`SkillRunner` interface のみ `TerminalRunner` にリネーム）。次の大きな change で揃えて renaming する余地を残す。

### Roola のアイデンティティが「Claude Skills ランチャー」から「汎用ターミナルランチャー」へ

CLAUDE.md / README.md など対外的な説明文も書き直す必要があるが、影響範囲は限定的。Claude Skill 起動は引き続きコア体験として残るので、ユーザーから見える文言は「Claude Skill も起動できる汎用ターミナルランチャー」へのアップデートになる。

## References

- ADR-0002: PTY ベースのターミナル統合（本 change の汎用化はこの基盤の上に乗る）
- ADR-0008: スキル実行セッションを実行画面 widget から切り離して保持（action 切替時の lifecycle は変えない）
- ADR-0009: ad-hoc セッションを別 provider で扱う（永続 / ad-hoc の provider 分離は維持）
- ADR-0014: Explorer をメイン UI に格上げ、Skills ランチャーをサブ機能へ降格
