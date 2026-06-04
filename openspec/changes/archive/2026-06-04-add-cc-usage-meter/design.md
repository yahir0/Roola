## Context

トップバーのアクティビティモニタ（ADR-0039）は CPU / メモリを `SystemMetricsRepository`
→ `ActivityMonitorViewModel`（Riverpod `Notifier`、1 秒ポーリング）→ `activity_monitor_bar`
の流れで表示し、クリックで `ActivityPopoverController`（排他制御）によるポップオーバーを
開く構成になっている。本 change はこの並びに「Claude Code 使用量メーター」を加える。

データソースは Claude Code がローカルに書き出す JSONL のみ。実構造は確認済みで、
`type: "assistant"` の行が `message.usage`（`input_tokens` / `output_tokens` /
`cache_creation_input_tokens` / `cache_read_input_tokens` ほか）と `message.model`、
top-level `timestamp`（UTC ISO8601）、`requestId`、`message.id` を持つ。ファイルは
`~/.claude/projects/<encoded-project-path>/<session-uuid>.jsonl` に配置される。

公式レートリミット残量は `/usage` 内部エンドポイント経由でしか得られず、機械可読な
公開 API が無い。第三者アプリが正確に取得する正攻法が現状存在しないため、本 change は
使用量（トークン・推定コスト）に範囲を限定する。

## Goals / Non-Goals

**Goals:**

- 当日（ローカルタイム）の Claude Code 消費トークンと推定コストを、CPU / メモリと並べて
  トップバーに表示する
- JSONL の追記を FSEvents で監視し、ほぼリアルタイムに更新する
- クリックでトークン種別別・推定コストの内訳をポップオーバー表示する
- ネットワーク・Claude Code 本体・外部 Skill に依存しない（ADR-0005）

**Non-Goals:**

- 公式レートリミット残量（5h / 週次 compute hours の %）の表示
- 厳密な請求額の算出（本機能の値はあくまで推定）
- Claude Code 以外の CLI / ツールの使用量集計
- 日次より長期の履歴ビュー・グラフ化（将来 change で別途検討）

## Decisions

### D1: データソースはローカル JSONL（ccusage 方式）

`~/.claude/projects/**/*.jsonl` を直接パースする。

- 理由: 公式 API 非依存・オフライン動作・自己完結（ADR-0005）。`ccusage` が同方式で
  実績がある。
- 代替案: OpenTelemetry メトリクス受信（`CLAUDE_CODE_ENABLE_TELEMETRY=1` + OTLP レシーバ）。
  → 却下。ユーザーに環境変数設定を強い、受信口の実装コストが重い。JSONL 方式の方が
  追加設定ゼロで Roola の自己完結方針に合う。

### D2: 集計範囲は「当日（ローカルタイム）」

top-level `timestamp`（UTC）をローカルタイムへ変換し、当日 0:00〜現在に入る行のみ合算する。

- 理由: CPU / メモリと同じく「今の状態」を示すメーターとして直感的。全期間合計は数値が
  大きくなり負荷計としての意味が薄い。
- 代替案: 直近 5 時間ローリング / セッション単位 / 全期間。→ 当日が最も実装が単純で
  ユーザーの「今日どれだけ使ったか」という関心に合致。集計範囲は将来拡張余地として
  リポジトリ層に閉じ込め、切替は後続 change で検討。

### D3: 重複排除は `message.id` + `requestId`

ストリーミング等で同一レスポンスの usage が複数行に出る可能性に備え、両者の組をキーに
集約後 1 件のみ算入する（ccusage と同じ排除キー）。

### D4: 推定コストはモデル別単価テーブルをコード内に定数で持つ

`input` / `output` / `cacheRead` / `cacheCreation` の単価をモデル別に保持し、トークン種別 ×
単価で算出する。未知モデルはコスト 0、トークンは集計に算入。

- 理由: 単価は外部取得すると自己完結方針に反し、オフラインで壊れる。リポジトリ内定数なら
  単体テスト可能でリンク切れも無い。
- トレードオフ: 単価改定や新モデル追加時にコード更新が要る。→ 単価表を 1 箇所に集約し、
  「推定」であることを UI に明示することで許容。

### D5: レイヤー配置

- `lib/data/cc_usage/`:
  - `cc_usage.dart`（Freezed: トークン種別別合計 + 推定コスト + 当日範囲）
  - `cc_usage_repository.dart`（JSONL 探索・パース・重複排除・集計・コスト算定）
  - `cc_usage_pricing.dart`（モデル別単価定数）
  - ファイル監視は既存の監視方式（ADR-0041）を再利用
- `lib/ui/activity_monitor/`:
  - `cc_usage_view_model.dart`（Riverpod `Notifier`。FSEvents 購読 + 初回フル集計、
    既存 `ActivityMonitorViewModel` のポーリングではなくイベント駆動で更新）
  - 既存 `activity_monitor_bar.dart` に要約セルを追加、`ActivityPopover` enum に
    `ccUsage` を追加して既存の排他ポップオーバー機構に乗せる

差し替え可能性の必要性が低いため、interface は作らない（CLAUDE.md 方針）。永続化を
伴わない表示専用集計なので DTO ⇄ モデル分離も行わない。

### D6: 更新方式はイベント駆動（ポーリングしない）

CPU / メモリは 1 秒ポーリングだが、使用量は JSONL 追記時のみ変化するため FSEvents
購読で再集計する。負荷を避けるため、変更通知は短いデバウンス（例: 300〜500ms）で束ねる。
全ファイル再走査が重い場合は当日分ファイル + 末尾差分読みに最適化余地を残す（初期実装は
当日に該当する mtime のファイルのみ走査で十分）。

ファイル監視は macOS（FSEvents）/ Windows（ReadDirectoryChangesW 等）の双方で動作する
よう、プラットフォーム差をリポジトリ層の内側に隠蔽し、ViewModel からは「変更通知ストリーム」
として OS 非依存に扱う（ADR-0058 の macOS + Windows 対応に従う。`~/.claude/projects` の
ホームディレクトリ解決もプラットフォーム非依存にする）。

## Risks / Trade-offs

- [JSONL フォーマットが将来変わる] → パースは防御的にし、欠損キー・破損行を握りつぶして
  スキップ。`usage` キーの有無で判定し、想定外でもクラッシュさせない。
- [大量・巨大 JSONL で初回集計が重い] → 当日 mtime のファイルに絞って走査。必要なら
  末尾からの差分読みに最適化（D6）。初回はバックグラウンドで集計し UI をブロックしない。
- [推定コストが実額とずれる] → UI に「推定」と明示。単価表は 1 箇所集約で更新容易に。
- [`~/.claude` が存在しない環境] → ゼロ表示のプレースホルダにフォールバック（エラーにしない）。
- [当日境界をまたぐ表示] → ローカルタイムの日付変更時に当日集計をリセット。日跨ぎの
  再計算はモニタ常駐中に検知する（タイマ or 次回イベント時に日付チェック）。

## Migration Plan

新規追加機能のみで既存挙動の破壊は無い。段階導入:

1. data 層（モデル / リポジトリ / 単価 / パーサ）を単体テスト付きで追加
2. ViewModel + トップバー要約セルを追加（フィーチャーフラグ不要、表示は常時 ON）
3. ポップオーバー内訳を追加
4. ADR-0060 を追記、`CLAUDE.md` の ADR 一覧を更新

ロールバックは UI 組み込み（手順 2-3）の revert で表示のみ除去でき、data 層は孤立しても無害。

## Open Questions

- トップバー要約は「合計トークン」「推定コスト」どちらを既定の主表示にするか（両方を
  ポップオーバーには出す。主表示は実装時に UI で確認して決める）
- 集計範囲を将来「5h ローリング」へ拡張する場合の切替 UI を持たせるか（本 change では
  当日固定。リポジトリ層に範囲パラメータを設けて拡張余地のみ確保）
