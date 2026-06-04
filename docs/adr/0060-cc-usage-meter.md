# ADR-0060: アクティビティモニタに Claude Code 使用量メーターを追加する

- **Status**: Accepted
- **Date**: 2026-06-04

## Context

トップバーのアクティビティモニタ（ADR-0039）は CPU / メモリを可視化しているが、
Roola の中核ユースケースである Claude Code の「どれだけ使ったか」は見えない。
ユーザーは消費トークン量やコスト感を `ccusage` 等の別ツールで確認しており、
他のシステム指標と並べて Roola 内で把握できる状態が望ましい。

公式のレートリミット残量（5 時間枠・週次 compute hours の %）は Claude Code の
`/usage` が内部エンドポイント経由で表示しており、機械可読な公開 API が存在しない。
第三者アプリが正確に取得する正攻法が無く、内部エンドポイントの直叩きは脆く ToS 的
にもグレーである。

一方、Claude Code はセッションのやり取りをローカルの
`~/.claude/projects/<encoded-project-path>/<session-uuid>.jsonl` に追記しており、
各 assistant 行が `message.usage`（`input_tokens` / `output_tokens` /
`cache_creation_input_tokens` / `cache_read_input_tokens`）と `message.model`、
top-level `timestamp` を持つ。`ccusage` はこの JSONL を集計してトークン量・推定
コストを算出している。

## Decision

アクティビティモニタに **Claude Code 使用量メーター** を追加する。範囲は
**使用量（消費トークン・推定コスト）に限定**し、公式レートリミット残量は表示しない。

- **データソース**: `~/.claude/projects/**/*.jsonl` のみをパースする（`ccusage` と
  同方式）。ネットワーク・Claude Code 本体プロセス・外部 Skill に依存しない
  （ADR-0005 自己完結方針）。
- **集計範囲**: 当日（ローカルタイムの 0:00〜現在）。top-level `timestamp`（UTC）を
  ローカルタイムへ変換して当日分のみ合算する。集計範囲はリポジトリ層のパラメータと
  して保持し、将来「5h ローリング」等への拡張余地を残す。
- **重複排除**: ストリーミング等で同一レスポンスの usage が複数行に出る可能性に
  備え、`message.id` + `requestId` をキーに 1 回のみ算入する（`ccusage` と同じキー）。
- **推定コスト**: モデル別単価をコード内定数で保持し、トークン種別 × 単価で算出する。
  未知モデルはコスト 0 として扱い、トークン数は通常どおり集計する。値は「推定」で
  ある旨を UI に明示する。
- **更新方式**: CPU / メモリの 1 秒ポーリングと異なり、使用量は JSONL 追記時のみ
  変化するため、既存の `DirectoryWatcher`（ADR-0041）でイベント駆動更新する。
  デバウンスで連続変更を束ねる。
- **クロスプラットフォーム**: 監視は Dart の `Directory.watch`（macOS は FSEvents、
  Windows は ReadDirectoryChangesW）を使う `DirectoryWatcher` を再利用し、OS 差を
  リポジトリ層に隠蔽する。ホームディレクトリ解決は `HOME` / `USERPROFILE` 両対応
  （ADR-0058 の macOS + Windows 対応に従う）。
- **UI**: トップバーに当日の要約値を 1 つ表示し、クリックで既存のポップオーバー
  機構（ADR-0039）に乗せてトークン種別別・推定コストの内訳を展開する。
- **optional 化**: 使用量メーターは Claude 関連機能の 1 つなので、`claude` CLI が
  見つからない環境では `claudeAvailableProvider`（ADR-0022）に従ってメーターセル
  ごと非表示にする。非表示時は使用量 Provider も購読されず、ファイル監視も走らない。

差し替え可能性が低いため interface は作らない。永続化を伴わない表示専用集計のため
DTO ⇄ モデル分離も行わない（CLAUDE.md 方針）。

## Why

### 代替案 1: OpenTelemetry メトリクス受信

却下。`CLAUDE_CODE_ENABLE_TELEMETRY=1` + OTLP レシーバで公式メトリクスを受けられるが、
ユーザーに環境変数設定を強い、アプリ内に受信口（gRPC/HTTP）を実装する必要がある。
JSONL 方式は追加設定ゼロで動き、自己完結方針に合致する。

### 代替案 2: 公式レートリミット残量を表示する

却下。機械可読な公開 API が無く、内部エンドポイント依存は将来の変更で壊れ、ToS 的
にもグレー。今回は使用量メーターに限定し、レートリミット％は将来 API が公開された
段階で別 change として検討する。

### 採用理由（ローカル JSONL 集計）

- 公式 API 非依存・オフライン動作・追加設定ゼロ
- `ccusage` という実績ある同方式が存在する
- 既存資産（`DirectoryWatcher` / アクティビティモニタのポップオーバー機構）を再利用できる

## Trade-offs

- 推定コストは単価表に依存するため、単価改定・新モデル追加時にコード更新が要る。
  → 単価表を 1 箇所に集約し、「推定」である旨を UI に明示することで許容する。
- JSONL フォーマットが将来変わるとパースが壊れうる。→ 欠損キー・破損行を防御的に
  スキップし、クラッシュさせない。
- 集計範囲を当日に固定したため、長期履歴は見えない。→ リポジトリ層に範囲パラメータ
  を設け、後続 change で拡張する。
