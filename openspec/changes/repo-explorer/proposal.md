## Why

`bootstrap-launcher-mvp` で MVP 範囲外として明示的に除外した「簡易エクスプローラ機能（impl.txt 10 / 11）」を実装する。

現状のホーム画面に並ぶアイコンは、設定画面で 1 件ずつ手動登録する必要がある。Skill を登録済みのリポジトリが複数ローカルに散在しているケースで、

- どこにどんな Skill があるかを GUI でブラウズできない
- 検知した Skill をワンタップで登録できない
- 登録せずにそのディレクトリで Claude Code を即起動できない

という体験ギャップがあり、impl.txt の主要要件として「簡単なエクスプローラ機能」「Skills 検知でクリック → 登録ダイアログ」「右クリックでそのディレクトリで Claude Code 起動」が挙がっていた。本 change でこの 3 機能を一体として実装する。

## What Changes

- 新ルート `/explorer` と画面を追加し、AppBar から切替できるようにする（ホーム / 設定 / エクスプローラ）。
- 起点ディレクトリを 1 件永続化し、次回起動時はその場所をルートに描画する。初回は macOS ホームディレクトリをデフォルトに、設定アイコンから別ディレクトリへ変更可能。
- ディレクトリツリー / リストを描画し、各フォルダで `.claude/skills/<name>/SKILL.md` を直下スキャンして検知バッジを付ける。
- フォルダの右クリックで以下のメニューを出す:
  1. **Skill を登録**: 検知時のみ表示。既存 `EntryEditPage` を「リポジトリパス + Skill 名」プリフィル状態で開く
  2. **Skill を即実行**: 検知時のみ。`LauncherEntry` を作らずに `/run/...` 系画面でセッションを 1 つ起動する
  3. **このディレクトリで Claude Code を開く**: Skill 引数なしで `claude` を PTY 上で起動し、`session-registry` に 1 件登録する（アイコン登録は行わない）
- `skill-runner` の `PtySkillRunner` に「Skill 名なし起動」を許容する（引数を空配列にし、`claude` だけで対話モード起動）。
- 「Skill 即実行」「Claude Code を開く」で生成されるセッションは、既存の chip 列にそのまま表示される。chip ラベルは「ディレクトリ名 / Skill 名」または「ディレクトリ名 (Claude)」形式。

## Capabilities

### New Capabilities

- `repo-explorer`: ローカルディレクトリのブラウズ、Skill 検知バッジ表示、右クリックメニュー（登録 / 即実行 / Claude 起動）、起点ディレクトリの永続化を担う。

### Modified Capabilities

- `skill-runner`: `PtySkillRunner` が空 Skill 名（または null）を許容し、引数なしで `claude` を起動する経路を追加する。
- `launcher-home`: chip 列のラベル生成が、`launcherEntriesProvider` に存在しない entry id（ad-hoc セッション）でも fallback できるよう拡張する。

## Impact

- **新規依存**: 既存のもので足りる想定（`dart:io`、`file_picker`、`path_provider`）。追加 pubspec 依存は無し。
- **永続化**: `appearanceSettings` と同じ要領で `repo_explorer_settings.json`（最後に開いたパス 1 件）を追加。マイグレーション不要。
- **`PtySkillRunner` のシグネチャ**: `skillName` を nullable に変更、または空文字許容に変更する。既存コード（RunViewModel 等）は影響を受けるが、新規パラメータ追加でない分修正は局所的。
- **テスト**: ディレクトリトラバーサル、Skill 検知バッジの表示分岐、右クリックメニューの選択経路、ad-hoc launch の引数構築の単体テストを追加。
- **非 goal**: ファイル中身プレビュー、ファイル操作（リネーム / 削除 / 移動）、ディレクトリ監視（`FileSystemEvent` watch）、ブックマーク複数保持、git clone ウィザード（要件 6 / 後続 change）、Spotlight 風アニメ（要件 9 / 後続 change）。
