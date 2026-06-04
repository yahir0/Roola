## Why

トップバーのアクティビティモニタ（ADR-0039）は CPU / メモリは可視化しているが、
Roola の中核ユースケースである Claude Code の「どれだけ使ったか」は見えない。
ユーザーは消費トークン量やコスト感を別ツール（`ccusage` 等）に頼って確認しており、
Roola 内で他のシステム指標と並べて把握できる状態が望ましい。

公式のレートリミット残量（5h 枠・週次 compute hours の %）は機械可読な公開 API が
存在せず第三者アプリが正確に取得する正攻法が無いため、**今回は「使用量メーター」
（消費トークン・推定コスト）に範囲を限定する**。データは Claude Code がローカルに
書き出す `~/.claude/projects/**/*.jsonl` のみを参照し、外部サービスへ問い合わせない
（自己完結方針 ADR-0005 に準拠）。

## What Changes

- アクティビティモニタに **Claude Code 使用量メーター** を追加する
  - 集計対象: 当日（ローカルタイム）の消費トークン（input / output / cacheRead /
    cacheCreation）と、それに基づく**推定**コスト（$）
  - データソース: `~/.claude/projects/**/*.jsonl` の各行 `usage` を集計する
    （`ccusage` と同方式。Claude Code 本体やネットワークには依存しない）
  - 更新: FSEvents で JSONL の追記を監視し、ほぼリアルタイムに表示を更新する
    （ADR-0041 の監視方式を踏襲）
- トップバーには要約値（例: 当日の合計トークン / 推定コスト）を 1 つ表示し、
  クリックで既存ポップオーバー機構（ADR-0039）を使って内訳（トークン種別・
  モデル別など）を展開する
- 公式レートリミット残量は **本 change のスコープ外**。表示しない（将来 change で
  別途検討する旨を design に残す）
- 設計判断として ADR-0060 を追加する

## Capabilities

### New Capabilities

- `cc-usage-meter`: ローカル JSONL から Claude Code の使用量（トークン・推定コスト）を
  集計し、アクティビティモニタにリアルタイム表示する機能。集計ロジック・ファイル監視・
  トップバー要約表示・ポップオーバー内訳・推定コスト算定・データ欠如時の挙動を扱う。

### Modified Capabilities

<!-- なし（既存 spec は openspec/specs/ に promote 運用していないため変更対象なし） -->

## Impact

- **新規コード（data 層）**: `lib/data/cc_usage/` に JSONL パーサ / 集計リポジトリ /
  使用量モデル（Freezed）/ ファイル監視を追加
- **新規コード（ui 層）**: `lib/ui/activity_monitor/` に使用量メーターの表示・
  ViewModel（Riverpod `Notifier`）・ポップオーバー内訳を追加
- **既存コード**: `activity_monitor_bar.dart` / `activity_monitor_popover*.dart` に
  メーターと内訳の組み込み。`ActivityPopover` enum に項目追加の可能性
- **依存**: 既存の Freezed / Riverpod / Hooks の範囲。ファイル監視は Explorer / Git
  ビューで使用中の監視方式（ADR-0041）を再利用。新規外部依存は最小化する
- **ドキュメント**: ADR-0060 追加、`CLAUDE.md` の ADR 一覧に追記
- **非対象**: レートリミット％の取得、コストの厳密値（あくまで推定）、Claude Code
  以外の CLI の使用量
