# ADR-0048: アクティビティモニタにディスク I/O とネットワーク I/O を追加する（不採用）

- **Status**: Rejected（最終的に不採用 / 2026-06-05）
- **Date**: 2026-05-21（提案） / 2026-06-05（不採用決定）

> **この ADR は提案されたが、最終的に採用しないことにした。** 実装（PR
> [#59](https://github.com/yahir0/Roola/pull/59)）はマージせず、コードは本リポジトリに
> 入っていない。ADR 番号を欠番にしないため、提案内容と不採用の経緯だけを記録として
> 残す（番号予約）。以降の本文は「当時こう設計しようとしていた」という履歴であり、
> 現行の実装方針ではない。不採用の理由は末尾「## 不採用の結末」を参照。

## Context

ADR-0039 で導入したトップバーのアクティビティモニタは CPU とメモリの 2 指標
のみで、ディスク I/O / ネットワーク I/O は明示的に Non-Goal として外していた。
実運用では「いまネットワークを誰が使っているか」「ディスクが暴れているか」を
知りたい場面が多く、ユーザーはアクティビティモニタ.app へ切り替える必要が
残っていた。CPU / メモリと同じトップバー常駐の枠で I/O 系も見られるように
する、という提案だった。

制約:

- macOS のシステム全体 I/O は Dart 標準では取得できず、ネイティブ連携が必須。
- pub.dev に「ライブのシステム I/O とプロセス別 I/O をまとめて返す macOS 向け
  パッケージ」は存在しない（ADR-0039 と同じ事情）。
- I/O 量は CPU% / メモリ% と違って値域が桁違いに広い（数 B/s ～ 数 GB/s）。
  単一の 0–100% スケールでは表現できない。
- per-process I/O を取得する macOS API は CPU/メモリのように単純ではなく、
  ディスクは `proc_pid_rusage`、ネットワークは `nettop` 経由が現実的。

## Decision（提案時の内容・不採用）

**アクティビティモニタを 4 連ゲージ化し、システム全体の I/O は累積カウンタ
から Dart 側でレート計算し、per-process はクリック時にネイティブで 1 秒
サンプリングして取得する** という設計を提案していた。以下は提案当時の検討
内容で、採用はしていない。

### D1. ディスク I/O は IOKit、ネットワーク I/O は getifaddrs で累積バイトを取る

- ディスク: `IOServiceGetMatchingServices("IOBlockStorageDriver")` で
  ブロックデバイスを列挙し、`IOBlockStorageDriverStatistics` 辞書の
  `Bytes (Read)` / `Bytes (Write)` を合計する。
- ネットワーク: `getifaddrs` で全インターフェイスを列挙し、`AF_LINK` の
  `if_data` から `ifi_ibytes` / `ifi_obytes` を合計する（ループバック除外）。

累積バイト数なのでネイティブは瞬間値を返すだけ。レート（B/s）は Dart 側
ViewModel が前回 snapshot との差分 ÷ 経過秒数で計算する想定だった。

### D2. per-process ディスクは proc_pid_rusage で 1 秒 2 サンプリング

`proc_listallpids` で全 PID を列挙し、各 PID に `proc_pid_rusage` を呼んで
`ri_diskio_bytesread + ri_diskio_byteswritten` を取り、1 秒間隔の差分から
per-second rate を算出する案。

### D3. per-process ネットワークは nettop -P -L 2 -s 1 のサブプロセス実行

`nettop -P -L 2 -s 1 -x -J bytes_in,bytes_out` を 1 回サブプロセス実行し、
2 サンプルの差分から per-second rate を出す案。`nettop` は macOS 標準で
sudo 不要。

### D4. レート計算は Dart 側 ViewModel に集約する

ネイティブは「ある瞬間の累積カウンタ」だけを返し、差分・レート計算は Dart 側
ViewModel に集約する案（状態管理の一貫性のため）。

### D5. レベルバーは対数スケール、レンジは 1 KB/s → 1 GB/s

I/O は桁が広いため `log10` で `1 KB/s` を 0%、`1 GB/s` を 100% にマップし、
readout は人間可読単位（`B/s` / `KB/s` / `MB/s` / `GB/s`）で表示する案。

### D6. ProcessSortKey に disk / network を追加し fetchProcesses で分岐

`ProcessSortKey { cpu, memory }` に `disk` / `network` を追加し、
`fetchProcesses(ProcessSortKey)` でネイティブ側の取得経路を切り分ける案。
`ProcessMetrics.ioBytesPerSec`（nullable）を追加し、ポップオーバーは
sortKey に応じて表示列を切り替える。

## Trade-offs（提案時に挙げていた懸念）

- `proc_pid_rusage` の全 PID 列挙が遅い可能性（500+ プロセスで 1 サンプリング
  50ms 超）。
- `nettop` 出力フォーマットの OS バージョン依存。
- 対数スケールが直感的でない可能性（数百 B/s でもバーが見える）。
- `proc_pid_rusage` の差分は短命プロセスを捕まえられない。
- App Sandbox 化した場合の IOKit / getifaddrs / nettop 起動の権限再検討。

## 不採用の結末

提案・実装（PR #59）まで進めたが、**最終的にこの機能は採用しないことにした。**
PR はマージせず、関連コード（ネイティブの I/O 取得経路・4 連ゲージ化・
`openspec/changes/extend-activity-monitor-io/` 一式）はリポジトリに入れていない。
アクティビティモニタは ADR-0039 のとおり CPU / メモリの 2 指標のままとする。

本 ADR は「ディスク / ネットワーク I/O 追加を検討し、いったん見送った」という
判断を残し、ADR 番号 0048 を欠番にしないために残す。将来 I/O 監視を再検討する
場合は、本 ADR の設計案（IOKit / getifaddrs / proc_pid_rusage / nettop の各経路）
を出発点にできる。

## References

- ADR-0039（トップバー常駐アクティビティモニタの基盤設計 — 本 ADR の前提・現行方針）
- ADR-0038（Polaris デザインシステム）
- Apple Docs: `libproc.h` / `proc_pid_rusage`
- macOS man: `nettop(1)`
- IOKit Programming Guide: IOBlockStorageDriver
