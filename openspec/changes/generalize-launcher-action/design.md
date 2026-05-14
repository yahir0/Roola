## Context

Roola のランチャーアイコン起動経路は現在 2 系統ある:

1. **永続エントリ起動** (`RunViewModel`): `LauncherEntry` (`repositoryPath` + `skillName`) を読んで `PtySkillRunner` を生成。`skillName` 空のフォールバックで Skill なしの素 `claude` も起動できる
2. **ad-hoc 起動** (`AdhocRunViewModel`): エクスプローラ右クリックから `AdhocRunArgs` を渡して起動。`AdhocRunKind` enum で `claudeCode` / `terminal` を分岐し、後者は `$SHELL` 直接起動

つまり「動作タイプを切り替える」ロジックは ad-hoc 側に既に部分的に存在し、データモデルも `kind: AdhocRunKind` という形で表現されている。一方で永続エントリ側は `skillName == ""` のフォールバック分岐で間接的に表現するに留まっている。

本 change は両者を `LauncherAction` sealed union に統合し、永続エントリ・ad-hoc のどちらからも同じ「動作タイプ」を選べる形にする。これにより:

- 永続エントリ画面（`EntryEditPage`）から「📂 開く」「⚡ コマンド」「🤖 Claude」を選べる
- ad-hoc 経路（エクスプローラ右クリック）から渡す引数も `LauncherAction` で統一
- runner も `LauncherAction` 1 つを引数に取るように汎用化

関連 ADR:

- ADR-0002（PTY ベースのターミナル統合）— 本 change の汎用化はこの基盤の上に乗る
- ADR-0008（スキル実行セッションを実行画面 widget から切り離して保持）— action 切替時の lifecycle は変えない
- ADR-0009（ad-hoc セッションを別 provider で扱う）— 維持（permanent と ad-hoc の provider 分離は残す）

## Goals / Non-Goals

**Goals:**

- `LauncherEntry` を「Claude Skill 専用」から「ターミナル動作 3 タイプ」へ拡張
- 永続エントリと ad-hoc 起動で「動作タイプ」を共通モデル（`LauncherAction`）で表現
- runner を `LauncherAction` 駆動の汎用 PTY runner に作り直し、`PtySkillRunner` の Claude 専用前提（`_buildArguments` の `/<name>` 自動付与）を `ClaudeSkillAction` のロジックに閉じ込める
- 旧 JSON スキーマ（`{repositoryPath, skillName}`）の自動 migration（read 時のみ）
- UI を SegmentedButton + progressive disclosure で書き直し、選択された動作のフィールドだけ表示

**Non-Goals:**

- 旧スキーマへの書き戻し / ダウングレードサポート
- 動作タイプの追加（SSH / Docker exec / WSL 等）— 将来別 change
- コマンド入力の補完・シンタックスハイライト・履歴
- 複数コマンドの順次実行 UI（`bash -lc` で `&&` を使う運用に倒す）
- 環境変数の個別指定 UI（`bash -lc` 経由で `FOO=bar npm run dev` と書く）
- 永続エントリと ad-hoc の provider 統合（ADR-0009 の分離は維持）

## Decisions

### Decision 1: `LauncherAction` を Freezed sealed union で表現する

```dart
@freezed
sealed class LauncherAction with _$LauncherAction {
  const factory LauncherAction.openHere() = OpenHereAction;

  const factory LauncherAction.runCommand({
    required String command,
    @Default(true) bool keepShellAfterExit,
  }) = RunCommandAction;

  const factory LauncherAction.claudeSkill({
    required String skillName,
  }) = ClaudeSkillAction;
}
```

- **採用理由**: Freezed の `sealed class` + `switch` パターンマッチで網羅性が型レベルで保証される。Dart 3 の `sealed` を使えば `switch (action)` の `default` を省略してもコンパイラが網羅性チェックする
- **代替案 1: enum + 個別フィールド**: 状態は単純だが「どのフィールドがどの enum 値で有効か」の対応が暗黙的になり、`RunCommand` の `command` を `ClaudeSkill` 用エントリに残してしまう等のバグを生む
- **代替案 2: 抽象クラス + サブクラス手書き**: Freezed の生成コード（`copyWith` / `==` / `hashCode` / `toJson`）が無くなる。永続化用 DTO を別に書く必要があるが、本プロジェクトは既に Freezed 多用なので統一する方が筋が良い

### Decision 2: 永続化スキーマの旧→新 migration は DTO 層で行う

`LauncherEntryDto.fromJson` で旧 key（`repositoryPath` / `skillName`）と新 key（`workingDirectory` / `action`）の両方を受理する:

```dart
factory LauncherEntryDto.fromJson(Map<String, dynamic> json) {
  if (json.containsKey('action')) {
    return _$LauncherEntryDtoFromJson(json);  // 新スキーマ
  }
  // 旧スキーマ migration
  final skillName = (json['skillName'] as String?)?.trim() ?? '';
  final action = skillName.isEmpty
      ? const LauncherActionDto.openHere()
      : LauncherActionDto.claudeSkill(skillName: skillName);
  return LauncherEntryDto(
    id: json['id'] as String,
    displayName: json['displayName'] as String,
    workingDirectory: json['repositoryPath'] as String,
    action: action,
    iconPath: json['iconPath'] as String?,
    createdAt: json['createdAt'] as String,
  );
}
```

- **採用理由**: read 時に 1 度新スキーマへ正規化することで、Entity 層は新スキーマだけを知っていればよい。書き戻し（`toJson`）は新スキーマ固定 = 1 度開いて保存すれば自動的に永続化ファイルが書き換わる
- **代替案: バージョン番号を JSON に持たせる**: 旧データに version フィールドが無いので結局 `containsKey('action')` の判定が必要。version を導入してもコードは複雑化するだけ
- **代替案: マイグレーションスクリプトを起動時に 1 度だけ実行**: ユーザーがエントリを開かなくても新スキーマに揃う利点はあるが、エラー時のロールバックが面倒。本アプリは 1 ユーザーで小規模なので「lazy migration on read」で十分

### Decision 3: `RunCommandAction.keepShellAfterExit=true` の実装は `; exec $SHELL -i` 後置

```dart
String _buildShellCommand(String userCommand, bool keep) {
  if (!keep) return userCommand;
  return '$userCommand; exec \$SHELL -i';
}
// 起動: $SHELL -lc "<上記>"
```

- **採用理由**: `exec` で現在のプロセスを login shell に置換するので、ユーザーから見ると「コマンド完了後にプロンプトが出てくる」体験になる。`;` を使うのはコマンド失敗時にもシェルが残るため（`&&` だと失敗時に Window が即閉じてしまう）
- **代替案: `bash --rcfile` で初期コマンドを仕込む**: macOS のデフォルト shell が zsh なのに bash 縛りになる。$SHELL を尊重する方が筋が良い
- **代替案: 別プロセスで command と shell を順次起動**: PTY を 2 回切り替える形になり実装複雑。1 プロセスで完結する `; exec` の方が安全

### Decision 4: `AdhocRunArgs.kind: AdhocRunKind` を `action: LauncherAction` に置換する

```dart
@freezed
abstract class AdhocRunArgs with _$AdhocRunArgs {
  const factory AdhocRunArgs({
    required String adhocId,
    required String workingDirectory,  // 旧 repositoryPath をリネーム
    required String displayName,
    required LauncherAction action,    // 旧 (skillName, kind) を統合
  }) = _AdhocRunArgs;
}
```

旧 `AdhocRunKind.claudeCode` + `skillName=""` → `ClaudeSkillAction(skillName: "")` ではなく `OpenHereAction` で `claude` を起動（Skill なし `claude`）にどう対応するか?

- 旧仕様: `claudeCode` + `skillName=""` → `claude` を素で起動（Claude 対話モード）
- 新仕様: `ClaudeSkillAction(skillName: "")` を許容するか? → **許容しない**。`ClaudeSkillAction` は必ず非空 `skillName` を要求し、「Claude を素で起動」は `RunCommandAction(command: 'claude')` で表現する
- これでエクスプローラ右クリックの「Claude Code を開く」は内部的に `RunCommandAction(command: 'claude')` として渡す（ユーザーから見える挙動は変わらない）

- **採用理由**: 「動作タイプ」の意味を 1 つに揃えるため、`ClaudeSkillAction` は必ず Skill 名を持つように制約する。`claude` を素で起動したい場合は `RunCommandAction` を使う。設計上の一貫性が増す
- **代替案: `ClaudeSkillAction(skillName: String?)` で nullable**: 「Skill 名なしの Claude」と「Skill 名ありの Claude」を 1 タイプで扱えるが、UI 側で「Skill 名空のとき何が起きるか」を改めて説明する必要が出る。`RunCommandAction(command: 'claude')` の方がユーザーから見て直感的

### Decision 5: `pty_skill_runner.dart` を `pty_terminal_runner.dart` にリネーム

ディレクトリも `lib/data/skill_runner/` → `lib/data/terminal_runner/` へ。capability 名（spec ファイルのディレクトリ名）は `skill-runner` のまま据え置く。

- **採用理由**: コード上のシンボル名は責務を反映すべき（汎用 PTY runner なので「terminal」が妥当）。一方で `openspec/specs/` のディレクトリ名はリポジトリの履歴トレーサビリティのために維持
- **代替案: capability 名も `terminal-runner` にリネーム**: openspec の archive 履歴と乖離する。renaming 自体に意味はないので避ける

### Decision 6: SegmentedButton で動作タイプを選ぶ

```
┌──────────────┬──────────────┬──────────────┐
│ 📂           │ ⚡           │ 🤖           │
│ 開くだけ     │ コマンド実行 │ Claude Skill │
│              │  (selected)  │              │
└──────────────┴──────────────┴──────────────┘
```

選択状態の下に該当フィールドだけが表示される（progressive disclosure）。

- **採用理由**: 3 択しかないので画面幅に収まる。Material 3 標準コンポーネントで実装が軽い。一目で全選択肢が見える
- **代替案: ラジオボタン縦リスト**: 説明文を各オプションに 1〜2 行付けやすいが、フォーム高さが増える。そもそも 3 択ならアイコン + ラベルで十分
- **代替案: DropdownButton**: 開かないと選択肢が分からないので 3 択には冗長

### Decision 7: バリデーションは action タイプ別に分岐

`EntryEditViewModel._validate` を:

```dart
bool _validate() {
  final errors = <String, String>{};
  if (state.displayName.trim().isEmpty) errors['displayName'] = '...';
  // workingDirectory は全タイプ共通で必須
  final dir = state.workingDirectory.trim();
  if (dir.isEmpty) errors['workingDirectory'] = '...';
  else if (!Directory(dir).existsSync()) errors['workingDirectory'] = '...';
  // action タイプ別
  switch (state.action) {
    case OpenHereAction():
      break;  // 追加バリデーション無し
    case RunCommandAction(command: final cmd):
      if (cmd.trim().isEmpty) errors['command'] = 'コマンドを入力してください';
    case ClaudeSkillAction(skillName: final name):
      if (name.trim().isEmpty) errors['skillName'] = 'Skill 名を入力してください';
  }
  state = state.copyWith(errors: errors);
  return errors.isEmpty;
}
```

`errors` のキーは action タイプを跨いで重複しない（`command` / `skillName` は別タイプにしか出ない）ので、タイプ切替時にエラーを明示的にクリアする必要は無い（次回バリデーションで自然に消える）。

## Risks / Trade-offs

- **[旧スキーマ migration の片方向性]** → 一度新スキーマで保存すると旧バージョンの Roola で読めなくなる。Roola は単一プロジェクトの単一 user のみが使う想定なので、ロールバックの必要は実質無い。CHANGELOG / migration コメントに「ダウングレード非対応」を明記して回避
- **[`pty_skill_runner.dart` リネームによる import 全件書き換え]** → 既存の import 約 6 ファイル分を一括置換。コンパイルエラーで漏れは検出可能
- **[capability 名 `skill-runner` のままだと spec の名前と中身がズレる]** → spec.md 冒頭に「（汎用 PTY runner。Claude Skill 起動はそのうちの 1 ケース）」と明記。次の大きな change で renaming を検討する余地は残す
- **[`RunCommandAction(command: 'claude')` で「Skill なし Claude」を表現する非自明さ]** → エクスプローラ右クリックメニューの「Claude Code を開く」項目は引き続きラベルで「Claude Code」と表示するため、ユーザーから見える文言は変わらない。内部表現の差異はコメントで説明
- **[`keepShellAfterExit=true` で `exec $SHELL -i` を後置する shell injection 懸念]** → ユーザー入力 `command` は double-quote で囲われた中に入るので `"; rm -rf /"` 等で抜け出される可能性はある。だがこれはローカル実行ツールなので「ユーザー自身が自分の環境で実行する任意コマンド」のセキュリティモデル（= 何でもできる）であり、サンドボックス対象外。proposal 上のリスクではなく仕様
- **[`AdhocRunArgs` の hashCode / `==` が `LauncherAction` を含む形に変わる]** → `Riverpod family` のキャッシュキーとして使われている。新旧で hash 値が変わるが、Riverpod は実行時の比較なので問題なし

## Migration Plan

### コード側（リファクタ順）

1. `LauncherAction` 新規追加（`lib/data/launcher_entry/launcher_action.dart` + freezed）
2. `LauncherEntry` 改修（`workingDirectory` / `action` フィールド）
3. `LauncherEntryDto` の旧→新 migration 実装 + 単体テスト
4. `pty_skill_runner.dart` を `pty_terminal_runner.dart` にリネーム + 汎用化（`fromAction` factory）
5. `RunViewModel` / `AdhocRunViewModel` を新 runner に置換
6. `AdhocRunArgs` のフィールド変更（`workingDirectory` / `action`）
7. エクスプローラ右クリック起動の呼び出し側を `RunCommandAction(command: 'claude')` または `OpenHereAction` で組み立てるよう修正
8. `EntryEditViewModel` 改修（state に `action`、validate 分岐）
9. `EntryEditPage` UI 改修（SegmentedButton + progressive disclosure）
10. ADR-0016 追加 / `CLAUDE.md` 更新

### ユーザー側

- アプリを起動すると既存の永続エントリが旧スキーマで読み込まれ、メモリ上で `ClaudeSkillAction` または `OpenHereAction` に変換される（既存の動作はそのまま継続）
- ユーザーがエントリを 1 度開いて「保存」を押した時点で、JSON が新スキーマで書き戻される
- 既存エントリを編集せずに使い続ける場合も、起動時の自動 read migration で実害なし
- 旧バージョンの Roola へのダウングレードは非対応（新スキーマの JSON は旧パーサーが受け付けない）

### ロールバック

新 change を revert する場合、永続化ファイルは旧スキーマのままなので問題なし（新スキーマで書き戻されたエントリは読み込み失敗となるが、`launcher_entry_repository_impl.dart` の既存エラーハンドリング = 「JSON が破損していたら空一覧扱い」でアプリは起動できる）。よってアプリは起動できるが、新スキーマで保存したエントリは消える。

## Open Questions

- **Q1: 「コマンド実行」の `keepShellAfterExit` のデフォルトは true / false どちらが妥当か?**
  - 現案 = true（one-shot 系コマンドの結果を確認できる体験を優先）
  - 代替: false（常駐コマンド `npm run dev` 等で末尾の `; exec $SHELL -i` は無意味）
  - **暫定判断**: true で固定し、ユーザーフィードバックで切り替えを検討
- **Q2: エクスプローラ右クリックの「Claude Code を開く」は今後も `claude` 素起動のままで良いか? それとも `claude-skill` 動作の選択 UI を出すか?**
  - 現案 = 既存挙動維持（`claude` 素起動）
  - 代替: 右クリックから「Skill を選んで起動」サブメニューを出す
  - **暫定判断**: 現案維持。Skill 起動はランチャー登録経由の方が体験として自然
- **Q3: `EntryEditPage` の動作タイプ切替時、編集中のフィールド値は破棄するか / 保持するか?**
  - 現案 = 保持（state 上に各タイプ用フィールドを持つ）。`action` を切り替えても `command` / `skillName` の入力履歴は残る
  - 代替: 切替時にクリア
  - **暫定判断**: 保持。ユーザーが間違えて切り替えた場合の救済になる。最終的に submit 時のバリデーションでアクティブなタイプのフィールドだけ評価される
