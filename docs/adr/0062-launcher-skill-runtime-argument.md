# ADR-0062: ランチャーの Claude Skill に実行時引数（プロンプト）を渡せるようにする

- **Status**: Accepted
- **Date**: 2026-06-05

## Context

ランチャーに登録した Claude Code Skill 動作（`ClaudeSkillAction`）は、これまで
`claude /<skillName>` を起動するだけで、起動のたびに変わる入力（ログ・文字起こし
など）を渡せなかった。ユーザーから「登録時に『引数を渡すか』を設定でき、引数を
渡すタイプのスキルは実行時に引数を求めてほしい。引数はログや文字起こしなど大量の
文字数になりうるので、大量の文字数を受け取れるようにしたい」という要望が出た。

「大量の文字数」をどう届けるかが論点になった。候補と各々の難点:

1. **コマンドライン引数** `claude /skill "<本文>"`: スキル無改修・`$ARGUMENTS` で
   本文を直接受け取れる。ただし OS のコマンドライン長制限がある（macOS は
   ARG_MAX ≈ 1MB、Windows は約 32KB）。
2. **一時ファイル（パスを渡す）** `claude /skill <path>`: 文字数無制限・文字コード
   完全無傷。ただし **スキル側が「渡されたパスのファイルを読む」実装に変わる**
   ＝スキルの改修が必要。
3. **起動後に PTY へ貼り付け**: スキル無改修・インライン本文・長さ制限なし。ただし
   「起動完了の検知」「bracketed paste / 送信」のタイミング制御が必要で実装が複雑・
   バージョン差で不安定になりうる。

ユーザーとの対話で確定した前提:

- 「**文字コードの影響を受けたくない**」。
- 「**既存のスキルには一切手を入れない**」（= 案 2 は不可）。
- 「そもそも OS のコマンドラインを溢れるテキストは、**普通にターミナルでスキルを
  手動実行しても同じ問題**に当たる。ならば**ターミナルの制限を下回る限り引数方式で
  良い**」。

この最後の指摘が決め手になった。ランチャー起動は「人がターミナルで
`claude /skill <本文>` と打つ」のと同じ経路であり、その長さ制限はスキルを手動
実行しても等しく当たる本質的な制約である。過剰実装（一時ファイル / PTY 注入）を
避け、ターミナルと同じ挙動・同じ上限を受け入れるのが妥当と判断した。

## Decision

### D1. `ClaudeSkillAction` に `requiresArgument`（bool・既定 false）を追加する

スキル登録/編集フォーム（`_ClaudeSkillSection`）に「実行時に引数を求める」トグルを
追加し、`ClaudeSkillAction(skillName, requiresArgument)` として永続化する。既定
false なので既存エントリ・既存の生成箇所は無改修で移行できる（JSON は
`requiresArgument` キー欠落時に false へフォールバック）。

### D2. 実行時に複数行・文字数無制限の入力ダイアログで引数を受け取る

`requiresArgument: true` のエントリをランチャーから起動したとき、起動前に
`showPolarisMultilinePrompt`（Polaris の複数行ダイアログ）を出す。

- 入力は **trim しない**（先頭/末尾の改行・空白も意味を持つ本文をそのまま渡す）。
- 文字数の上限は設けない。高さ固定＋スクロールで長文（ログ/文字起こし）を扱える。
- **取消（null）なら起動しない**。空文字での確定は許可（引数なしで実行）。

入力値は永続化エントリには保存せず、実行時専用の `AdhocRunArgs.skillArgument` として
取り回す（RUNNING からの再起動でも同じ引数を再利用できる）。

### D3. 引数は `claude` への単一 positional `/skill <本文>` として渡す

`PtyTerminalRunner.fromAction(..., skillArgument)` が `claude` へ渡す引数を
`/skill <本文>` の **1 個の引数**として組み立てる（skillName と本文を半角空白で
連結）。本文に空白・改行が含まれても 1 引数のまま claude に届く。

- **macOS**: 既存の `exec "$@"` 配列形式の最後の argv 要素を `/skill <本文>` にする
  だけ。**argv 配列なのでシェルを通さず、エスケープも文字コードの変質もない**
  （ユーザーの「文字コードの影響を受けたくない」要件を満たす）。
- **Windows**: claude は npm の `.cmd` シム経由でしか起動できず、シェル
  （cmd / PowerShell）のコマンド文字列に埋め込まざるを得ない。`/skill <本文>` を
  claude への 1 引数としてシェルごとにクォートする:
  - **PowerShell / pwsh（既定）**: シングルクォート囲み（`'` → `''` のみエスケープ）。
    `$` / バッククォート / `%` / `!` / 改行をリテラル化でき最も安全。
  - **cmd**: ダブルクォート囲み（`"` → `""`）の best-effort。`%` 展開等は完全には
    無害化できないため、長文/特殊文字を確実に渡したい場合は PowerShell を推奨。
- 引数なし（`skillArgument` が null / 空）のときは従来どおり素の `claude /skill`。

### D4. 長さ制限は「ターミナルと同じ」を受け入れ、専用ガードは設けない

OS のコマンドライン長を超えた場合は `Pty.start` が起動時エラー（`E2BIG` 等）を投げ、
既存の `SkillRunState.failed(message)` 経路でターミナルタブにエラーが表示される。
これは「同じ本文をターミナルで手動実行したときと同じ失敗」であり、専用の事前
バリデーションや一時ファイルへのフォールバックは追加しない（Context の最終合意）。

## Why

- ユーザーの 3 つの前提（文字コード無傷・スキル無改修・ターミナル相当の上限で可）を
  すべて満たす最小の実装が「コマンドライン引数（単一 argv / シェル別クォート）」
  だった。一時ファイル（案 2）はスキル改修が要り前提に反し、PTY 注入（案 3）は
  ターミナル相当を超える堅牢性のために実装複雑性・不安定性を抱え込むため、要望の
  範囲に対して過剰だった。
- macOS は argv 配列でエスケープ・文字コードの問題が原理的に発生しない。Windows
  だけはシェル経由が避けられないが、既定の PowerShell をシングルクォートで囲むこと
  で実用上の安全性を確保した。

## Trade-offs

- **Windows の上限が macOS より小さい（約 32KB）**: 巨大すぎる本文は Windows で
  起動失敗しうる。ただしこれは手動ターミナル実行と同じ制約で、想定どおりの挙動
  （D4）。それを超える要件が出たら一時ファイル方式（スキル改修込み）を再検討する。
- **Windows / cmd のクォートは best-effort**: `%` 展開等の cmd 固有の癖は完全には
  防げない。既定は PowerShell なので大半のユーザーは安全な経路に乗る。
- **`AdhocRunArgs.skillArgument` に長文がメモリ保持される**: セッション存続中は本文を
  保持する（再起動での再利用のため）。永続化はしない。
- **`requiresArgument` を runtime の引数本文と混同しない設計**: フラグ（永続化）と
  本文（実行時の `skillArgument`）を分離した。エントリに本文は保存しない。

## References

- ADR-0016: ランチャーを Claude Skill 専用から汎用ターミナルランチャーへ
  （`LauncherAction` sealed union・`ClaudeSkillAction` の導入）
- ADR-0058: Windows 対応（claude を cmd / PowerShell 経由で起動する経緯）
- `lib/data/launcher_entry/launcher_action.dart`（`requiresArgument`）
- `lib/data/skill_session/adhoc_run_args.dart`（`skillArgument`）
- `lib/data/terminal_runner/pty_terminal_runner.dart`（argv 連結・シェル別クォート）
- `lib/ui/explorer/launcher_actions.dart`（起動前プロンプト）
- `lib/ui/common/polaris_dialog.dart`（`showPolarisMultilinePrompt`）
