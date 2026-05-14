## Why

Roola のランチャーアイコンは現状 **「リポジトリパス + Claude Skill 名」固定の 2 フィールド** で、`claude /<skill>` を起動することしかできない。一方で実際に欲しい体験は「ターミナルのお気に入り」に近く、

- 特定ディレクトリで素のシェルを開きたい（e.g. プロジェクトに毎日入る）
- 特定ディレクトリで毎回叩く決まったコマンドを実行したい（e.g. `npm run dev`、`docker compose up`、`make test`）
- Claude Skill を起動したい（既存）

の 3 種類が並列にあり、Skill 専用前提では他 2 種を表現できない。`pty_skill_runner.dart:184-198` には既に `skillName == ""` で「素の `claude` を開く」フォールバックがあるが、これも Claude 限定で「任意コマンド」には届かない。

Roola を Claude 専用ツールではなく **汎用ターミナルランチャー** として位置付け直し、Claude Skill はその中の 1 種として扱う。

## What Changes

- **BREAKING**（永続化スキーマ）: `LauncherEntry` の `repositoryPath` / `skillName` 2 フィールドを `workingDirectory` / `action: LauncherAction` に置換する。`LauncherAction` は sealed union で 3 タイプ:
  - `OpenHereAction`: `workingDirectory` で `$SHELL` を起動
  - `RunCommandAction(command, keepShellAfterExit)`: `workingDirectory` で `$SHELL -lc "<command>"` を起動。`keepShellAfterExit=true` のときは末尾に `; exec $SHELL -i` を付与してコマンド終了後にシェルを残す
  - `ClaudeSkillAction(skillName)`: 既存の `claude /<skillName>` 経路を維持（`.claude/skills/` 候補プルダウンも継続）
- 旧スキーマ JSON（`{repositoryPath, skillName}`）は `LauncherEntryDto.fromJson` で読み込み時に新スキーマへ自動 migrate。`skillName` 空 → `OpenHereAction`、非空 → `ClaudeSkillAction`。書き戻しは新スキーマのみ
- `data/skill_runner/pty_skill_runner.dart` を `data/terminal_runner/pty_terminal_runner.dart` に rename し、`(workingDirectory, executable, arguments)` を引数に取る汎用 runner に作り変える。`LauncherAction` から `(executable, arguments)` を組み立てる factory（`PtyTerminalRunner.fromAction`）を追加。`skillName == ""` フォールバック分岐は削除（`OpenHereAction` で表現される）
- `lib/ui/settings/entry_edit_page.dart` を改修:
  - 共通フィールド（アイコン / 表示名 / 作業ディレクトリ）は常時表示
  - `SegmentedButton` で「📂 開く」「⚡ コマンド」「🤖 Claude」を選択
  - 選択された動作のフィールドのみ progressive disclosure で表示
- `EntryEditViewModel` に `LauncherAction` 用の state / バリデーションを追加。タイプごとのバリデーション（`RunCommand` の `command` は必須・トリム後 1 文字以上、`ClaudeSkill` の `skillName` は既存ルール継続）
- `lib/ui/explorer/launcher_actions.dart` の `launchLauncherEntry` は引き続き「同 entry の永続セッションが無ければ起動 / あれば連番 ad-hoc」のロジックを保つが、`AdhocRunArgs` も `skillName: String` ではなく `action: LauncherAction` を持つように変更
- ADR を 1 件追加: 「ADR-0016: ランチャーを Claude Skill 専用から汎用ターミナルランチャーへ」

## Capabilities

### Modified Capabilities

- `launcher-config`: エントリの動作フィールドを「Skill 名 1 つ」から「`LauncherAction` 3 タイプの sealed union」に拡張。永続化・追加・編集・削除・アイコンの既存要件は維持しつつ、入力フォームと永続化スキーマが新フォーマットになる
- `skill-runner`: 「PTY 上で `claude` を起動する」専用要件から、「PTY 上で `LauncherAction` に応じた任意プロセスを起動する」汎用要件に拡張。Claude Skill 起動はそのうちの 1 ケース。capability 名はリポジトリ慣習を尊重して `skill-runner` のまま据え置く（spec 内記述が「ターミナル runner」になる）

## Impact

- **コード**:
  - `lib/data/launcher_entry/`: `launcher_entry.dart` / `launcher_entry_dto.dart` / `launcher_entries_provider.dart` 改修、`launcher_action.dart`（新規 sealed union）追加
  - `lib/data/skill_runner/` → `lib/data/terminal_runner/` へリネーム、`pty_skill_runner.dart` → `pty_terminal_runner.dart`、`skill_runner.dart` → `terminal_runner.dart`、`skill_run_state.dart` → `terminal_run_state.dart`
  - `lib/data/skill_session/adhoc_run_args.dart`: `skillName` → `action: LauncherAction`
  - `lib/ui/settings/entry_edit_page.dart` / `entry_edit_view_model.dart`: 動作セグメント追加・progressive disclosure
  - `lib/ui/explorer/launcher_actions.dart`: AdhocRunArgs 構築の置換
  - `lib/ui/run/run_view_model.dart` / `adhoc_run_view_model.dart`: runner 構築を `PtyTerminalRunner.fromAction` 経由に
- **永続化スキーマ**: 自動 migration あり（旧 → 新片方向、ロールバック非対応）。アプリを 1 回起動 → エントリを開いて保存すれば全エントリが新フォーマットに書き直される
- **テスト**:
  - 既存 91 ケースのうち launcher_entry / pty_skill_runner / entry_edit_view_model / launcher_actions 周りは構造変更で要修正
  - 新規追加: `launcher_action.dart` テスト（sealed pattern matching）、DTO migration テスト、`PtyTerminalRunner.fromAction` の各タイプ起動テスト、`EntryEditViewModel` のタイプ切替・バリデーションテスト
- **依存パッケージ**: 追加なし（freezed の sealed union と既存 flutter_pty で完結）
- **ドキュメント**:
  - `CLAUDE.md` の「Claude Code Skills ランチャーアプリ」記述を「ターミナルランチャー（Claude Skill 起動も含む）」に更新
  - `docs/adr/0016-generalize-launcher-action.md` 新規追加
- **非 goal**:
  - 旧スキーマへの書き戻し / ダウングレードサポート
  - 複数コマンドの順次実行 UI（`&&` で 1 行に書く運用）
  - コマンド入力の補完・シンタックスハイライト
  - 動作タイプ追加（SSH 接続・Docker exec 等）— 将来別 change で
