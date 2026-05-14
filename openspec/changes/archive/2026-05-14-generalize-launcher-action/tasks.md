## 1. データモデル基盤

- [x] 1.1 `lib/data/launcher_entry/launcher_action.dart` を新規作成し、`LauncherAction` sealed union（`OpenHereAction` / `RunCommandAction(command, keepShellAfterExit=true)` / `ClaudeSkillAction(skillName)`）を Freezed で定義
- [x] 1.2 `LauncherAction` の JSON シリアライズ（`@Freezed(unionKey: 'type')` + `json_serializable`）を生成し、`type` 値を `openHere` / `runCommand` / `claudeSkill` に固定
- [x] 1.3 `lib/data/launcher_entry/launcher_entry.dart` を改修: `repositoryPath` → `workingDirectory` リネーム、`skillName` 削除、`action: LauncherAction` 追加
- [x] 1.4 `build_runner build` を実行して freezed / g.dart を再生成

## 2. 永続化スキーマ migration

- [x] 2.1 `lib/data/launcher_entry/launcher_entry_dto.dart` の `LauncherEntryDto` フィールドを新スキーマ（`workingDirectory` / `action`）に置換、`@JsonSerializable` を再生成
- [x] 2.2 `LauncherEntryDto.fromJson` に旧スキーマ判定ロジックを追加: `json.containsKey('action')` で新 / 旧を分岐し、旧スキーマは `repositoryPath` → `workingDirectory`、`skillName` 空 → `OpenHere`、非空 → `ClaudeSkill(skillName)` に変換
- [x] 2.3 `test/data/launcher_entry/launcher_entry_dto_test.dart` に migration テストを追加（旧スキーマ skillName 空 / 旧スキーマ skillName 非空 / 新スキーマそのまま / 不正 type 値の各ケース）
- [x] 2.4 不正な `action.type` 値を持つエントリは読み飛ばす分岐を `launcher_entry_repository_impl.dart` 側に実装し、ログ警告を出す
- [x] 2.5 旧スキーマファイルを `~/Library/Application Support/dev.tech.yahiro.Roola/launcher_entries.json` に手動配置 → アプリ起動 → 1 件編集して保存 → JSON が新スキーマで書き戻されることを目視確認（ユーザー確認済み）

## 3. PTY runner の汎用化

- [x] 3.1 `lib/data/skill_runner/` ディレクトリを `lib/data/terminal_runner/` にリネーム
- [x] 3.2 `pty_skill_runner.dart` を `pty_terminal_runner.dart` にリネーム、クラス名も `PtyTerminalRunner` へ変更
- [x] 3.3 `skill_runner.dart` / `skill_run_state.dart` も `terminal_runner.dart` / `terminal_run_state.dart` にリネーム（合わせて `SkillRunState` などのクラス名は内部互換のため一旦維持し、リネームは別 commit で）
- [x] 3.4 `PtyTerminalRunner` のコンストラクタ引数を `(workingDirectory, executable, arguments)` ベースに変更、`skillName == ""` フォールバック分岐を削除
- [x] 3.5 `PtyTerminalRunner.fromAction({required String workingDirectory, required LauncherAction action})` factory を追加し、3 つの `LauncherAction` から `(executable, arguments)` を組み立てる
  - `OpenHereAction` → `executable: $SHELL ?? '/bin/zsh'`, `arguments: const []`
  - `RunCommandAction` → `executable: $SHELL ?? '/bin/zsh'`, `arguments: ['-lc', _buildShellCommand(command, keepShellAfterExit)]`
  - `ClaudeSkillAction` → `executable: 'claude'`, `arguments: ['/<skillName>']`
- [x] 3.6 `_buildShellCommand` ヘルパー（`keepShellAfterExit=true` のとき末尾に `; exec $SHELL -i` を付与）を実装
- [x] 3.7 `_formatStartError` の "claude" hardcode を `executable` 引数を埋め込む形に変更
- [x] 3.8 既存の `import 'package:roola/data/skill_runner/...'` を全件 `terminal_runner/` に書き換え（rg で検索 → 一括 sed）
- [x] 3.9 `test/data/terminal_runner/pty_terminal_runner_test.dart` に `fromAction` の各タイプ起動テストを追加（テスト用 executable は `bash` でモック）

## 4. ad-hoc 起動側の調整

- [x] 4.1 `lib/data/skill_session/adhoc_run_args.dart` を改修: `repositoryPath` → `workingDirectory`、`skillName` / `kind` を削除、`action: LauncherAction` を追加。`AdhocRunKind` enum も削除
- [x] 4.2 `lib/ui/run/adhoc_run_view_model.dart` の switch を `PtyTerminalRunner.fromAction(workingDirectory: args.workingDirectory, action: args.action)` 1 行に置換
- [x] 4.3 `lib/ui/explorer/explorer_node_tile.dart` その他の右クリック起動呼び出しで `AdhocRunArgs` を組み立てている箇所を新フィールドで書き直す
- [x] 4.4 「Claude Code を開く」相当の右クリックメニューは `RunCommandAction(command: 'claude')` を渡すように変更（ユーザーから見える文言は変えない）
- [x] 4.5 「ターミナルで開く」相当は `OpenHereAction()` を渡すように変更

## 5. 永続エントリ起動側の調整

- [x] 5.1 `lib/ui/run/run_view_model.dart` で `PtySkillRunner` を直接呼んでいる箇所を `PtyTerminalRunner.fromAction(workingDirectory: entry.workingDirectory, action: entry.action)` に置換
- [x] 5.2 `lib/ui/explorer/launcher_actions.dart` の `launchLauncherEntry` 内で `AdhocRunArgs` を構築する際、`entry.action` を継承して渡すよう修正

## 6. 編集画面 UI（`EntryEditViewModel`）

- [x] 6.1 `EntryEditState` を改修: `repositoryPath` → `workingDirectory`、`skillName: String` → `action: LauncherAction`、各 action タイプの一時編集値を保持する `editedCommand: String` / `editedKeepShell: bool` / `editedSkillName: String` を追加
- [x] 6.2 `EntryEditViewModel.build` で既存エントリ読込時、`entry.action` を `state.action` に流し込み、各タイプ用の一時値も対応するフィールドに同期
- [x] 6.3 動作タイプ切替メソッド `setActionType(LauncherActionType)` を追加。タイプ切替時は state.action を新タイプ + 一時値で再構築、エラーマップは新タイプ用のキー以外を温存
- [x] 6.4 `setCommand(String)` / `setKeepShellAfterExit(bool)` / `setSkillName(String)` を追加し、editedXxx と state.action の対応フィールドを同時更新
- [x] 6.5 `_validate` を action タイプ別に分岐（`OpenHere` は追加チェック無し、`RunCommand.command` 必須、`ClaudeSkill.skillName` 必須）
- [x] 6.6 `submit` で `LauncherEntry(action: state.action, workingDirectory: ..., ...)` を組み立てるよう書き換え

## 7. 編集画面 UI（`EntryEditPage`）

- [x] 7.1 既存の Skill 名入力 `TextField`（`entry_edit_page.dart:122-155`）を一旦削除
- [x] 7.2 「動作」セクションを追加: `SegmentedButton<LauncherActionType>` で 📂 / ⚡ / 🤖 を選択
- [x] 7.3 選択された動作に応じた `_OpenHereSection` / `_RunCommandSection` / `_ClaudeSkillSection` を progressive disclosure で出し分け
- [x] 7.4 `_RunCommandSection`: 1 行コマンド入力 + 「コマンド終了後もターミナルを残す」チェックボックス + ヒント文
- [x] 7.5 `_ClaudeSkillSection`: 既存の Skill 名 TextField + `availableSkills` 候補プルダウンをそのまま移植
- [x] 7.6 `_OpenHereSection`: 説明文「ターミナルを開いてシェルプロンプトで停止します」のみ
- [x] 7.7 「リポジトリパス」ラベルを「作業ディレクトリ」に変更
- [x] 7.8 `useEffect` で repositoryPath を同期している箇所を workingDirectory に書き換え

## 8. テスト整備

- [x] 8.1 `test/data/launcher_entry/launcher_entry_test.dart` を新スキーマで書き直し、sealed union のパターンマッチを通すテストを追加（DTO テスト + repository_impl テストで sealed union round-trip をカバー）
- [x] 8.2 `test/data/launcher_entry/launcher_entry_dto_test.dart` の migration テスト（task 2.3）が動くことを確認
- [x] 8.3 `test/ui/settings/entry_edit_view_model_test.dart` を改修: タイプ切替時の state 遷移、タイプ別バリデーションを検証
- [x] 8.4 `test/ui/explorer/launcher_actions_test.dart` の `generateUniqueDisplayName` 8 ケースが引き続き通ることを確認、`AdhocRunArgs` 構築周りも新フィールドで通るよう調整
- [x] 8.5 `test/data/terminal_runner/pty_terminal_runner_test.dart` の `fromAction` 各タイプ起動テスト（task 3.9）が動くことを確認
- [x] 8.6 全テスト（既存 91 + 新規 19 = 110 ケース）がパスすることを `fvm flutter test` で確認

## 9. ドキュメント

- [x] 9.1 `docs/adr/0016-generalize-launcher-action.md` を新規作成: 「Skill ランチャー → 汎用ターミナルランチャーへの拡張」、決定背景・代替案・移行戦略を記録
- [x] 9.2 `docs/adr/README.md` の ADR インデックスに 0016 を追加
- [x] 9.3 `CLAUDE.md` 冒頭の「Mac 向けの Claude Code Skills ランチャーアプリ」記述を「Mac 向けの汎用ターミナルランチャー（Claude Skill 起動も含む）」相当に書き換え
- [x] 9.4 `CLAUDE.md` の「重要な設計判断（ADR）」セクションに ADR-0016 を追加
- [x] 9.5 `docs/architecture.md` でランチャー周りの責務記述があれば、新動作タイプを反映するよう更新

## 10. 動作確認 + 仕上げ

- [x] 10.1 `fvm flutter analyze` がクリーンであることを確認
- [x] 10.2 `fvm flutter test` で全テスト緑であることを確認（110/110 pass）
- [x] 10.3 `make FLUTTER="fvm flutter" DART="fvm dart" run` でアプリを起動し、3 タイプそれぞれのエントリを新規作成 → 起動 → 期待動作を目視確認（ユーザー確認済み）
  - 「📂 開くだけ」: zsh プロンプトが出る
  - 「⚡ コマンド」: `echo hello && ls` を登録 → 出力後シェルが残る
  - 「🤖 Claude Skill」: 既存エントリと同様に `claude /<name>` が起動
- [x] 10.4 旧スキーマで保存された既存エントリ（手元の永続化ファイル）を起動 → 旧挙動が維持されることを目視確認 → 1 件編集 → JSON が新スキーマに書き換わることを目視確認（ユーザー確認済み）
- [x] 10.5 OpenSpec change を archive: `openspec archive generalize-launcher-action`
