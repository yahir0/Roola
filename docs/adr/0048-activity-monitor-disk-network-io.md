# ADR-0048: アクティビティモニタにディスク I/O とネットワーク I/O を追加する

- **Status**: Accepted
- **Date**: 2026-05-21

## Context

ADR-0039 で導入したトップバーのアクティビティモニタは CPU とメモリの 2 指標
のみで、ディスク I/O / ネットワーク I/O は明示的に Non-Goal として外していた。
実運用では「いまネットワークを誰が使っているか」「ディスクが暴れているか」を
知りたい場面が多く、ユーザーはアクティビティモニタ.app へ切り替える必要が
残っていた。CPU / メモリと同じトップバー常駐の枠で I/O 系も見られるように
する。

制約:

- macOS のシステム全体 I/O は Dart 標準では取得できず、ネイティブ連携が必須。
- pub.dev に「ライブのシステム I/O とプロセス別 I/O をまとめて返す macOS 向け
  パッケージ」は存在しない（ADR-0039 と同じ事情）。
- I/O 量は CPU% / メモリ% と違って値域が桁違いに広い（数 B/s ～ 数 GB/s）。
  単一の 0–100% スケールでは表現できない。
- per-process I/O を取得する macOS API は CPU/メモリのように単純ではなく、
  ディスクは `proc_pid_rusage`、ネットワークは `nettop` 経由が現実的。

## Decision

**アクティビティモニタを 4 連ゲージ化し、システム全体の I/O は累積カウンタ
から Dart 側でレート計算し、per-process はクリック時にネイティブで 1 秒
サンプリングして取得する。** 仕様は
`openspec/changes/extend-activity-monitor-io/` を参照。

### D1. ディスク I/O は IOKit、ネットワーク I/O は getifaddrs で累積バイトを取る

- ディスク: `IOServiceGetMatchingServices("IOBlockStorageDriver")` で
  ブロックデバイスを列挙し、`IOBlockStorageDriverStatistics` 辞書の
  `Bytes (Read)` / `Bytes (Write)` を合計する。複数ディスク・APFS コンテナ
  でも全部足し合わせる。
- ネットワーク: `getifaddrs` で全インターフェイスを列挙し、`AF_LINK` の
  `if_data` 構造体から `ifi_ibytes` / `ifi_obytes` を合計する。`lo` 始まりの
  ループバックは除外する（自分宛て通信を二重計上しないため）。

これらは累積バイト数なので、ネイティブ側はその瞬間の値を返すだけ。レート
（B/s）は Dart 側 ViewModel が前回 snapshot との差分 ÷ 経過秒数で計算する。

却下案: 毎秒 `iostat` / `netstat` をサブプロセス起動してパース — プロセス
起動コストが高く、出力フォーマットが OS バージョンに依存して壊れやすい。

### D2. per-process ディスクは proc_pid_rusage で 1 秒 2 サンプリング

`proc_listallpids` で全 PID を列挙し、各 PID に
`proc_pid_rusage(pid, RUSAGE_INFO_V2)` を呼んで
`ri_diskio_bytesread + ri_diskio_byteswritten` を取る。1 秒スリープして再度
取り、差分から per-second rate を算出する。

`proc_pid_rusage` はカーネル提供 API でサブプロセス起動なし。1 サンプリング
は数百プロセスでも数 ms オーダー。1 秒待ちはポップオーバーを開いてからの
体感遅延として許容範囲（ADR-0039 D6「取得中は空の枠を出す」と一致）。

却下案: `iotop`（macOS には存在しない）、`fs_usage`（要 sudo・ノイズ多）。

### D3. per-process ネットワークは nettop -P -L 2 -s 1 のサブプロセス実行

`nettop -P -L 2 -s 1 -x -J bytes_in,bytes_out` を 1 回サブプロセス実行する。

- `-P`: per-process 集計
- `-L 2 -s 1`: 1 秒間隔の 2 サンプル
- `-x`: バイト表示（人間可読化しない）
- `-J bytes_in,bytes_out`: 列を限定（出力パースを安定化）

2 サンプル目の bytes 値から 1 サンプル目を引いて per-second rate を出す。
`nettop` は macOS 標準ツールで権限不要・sudo 不要。プロセス起動 1 回のコスト
はポップオーバー開時のみで頻度が低く許容範囲。

却下案:

- per-process network 用 Mach / sysctl API — 標準には存在しない。
- libpcap ベース — 要 sudo・実装重・本来用途と乖離。

### D4. レート計算は Dart 側 ViewModel に集約する

ネイティブ側は「ある瞬間の累積カウンタ」だけを返し、差分・レート計算は Dart
側 ViewModel に集約する。

- ViewModel が前回 snapshot を保持し、新値到着時に
  `delta / elapsedSeconds` を計算して state（`SystemMetricsSnapshot`）に
  持たせる。
- 初回ポーリングは前回値が無いためレートは 0（CPU 使用率と同じ挙動）。
- 累積カウンタが減少した場合（OS の wrap-around / 異常値）は 0 として扱う。
- テストではネイティブを呼ばずに「累積カウンタの 2 サンプル → 期待レート」
  のロジックだけを検証できる。

却下案: ネイティブで前回値を保持して rate を返す — CPU の tick 差分は既存で
ネイティブ持ちだが、disk/network まで広げると状態が分散する。Dart 側に集約
した方が状態管理が一貫する。

### D5. レベルバーは対数スケール、レンジは 1 KB/s → 1 GB/s

I/O 量は 0 から GB/s まで桁が広く、線形スケールの 100 MB/s 固定では普段の
KB/s オーダーが見えない。対数スケール `log10` で `1 KB/s` を 0%、`1 GB/s` を
100% にマップする。Wi-Fi の数百 KB/s も SSD の数百 MB/s も同じバーで直感的に
見せる。

レート readout は人間可読単位（`B/s` / `KB/s` / `MB/s` / `GB/s`）で 1 行表示。
`< 10` は B/s、`< 10 KB/s` は小数 1 桁、それ以上は整数 2–3 桁（例:
`512 B/s` / `1.2 KB/s` / `12 MB/s` / `1.2 GB/s`）。

却下案: 直近の最大値を 100% とする自動スケール — 反応的だが絶対値の感覚が
掴めず、静かなときにもバーが動いて誤解を招く。

### D6. ProcessSortKey に disk / network を追加し fetchProcesses で分岐

既存 `ProcessSortKey { cpu, memory }` に `disk` / `network` を追加する。
`SystemMetricsRepository.fetchProcesses(ProcessSortKey)` がソートキーを受け
取って ネイティブ側で経路を切り分ける（CPU/memory は既存 `ps` 経路、disk は
`proc_pid_rusage` サンプリング、network は `nettop`）。

`ProcessMetrics` に `ioBytesPerSec`（nullable）を追加。disk / network ソート
時のみネイティブが値を埋め、ポップオーバーは sortKey に応じて表示列を切り
替える（CPU/Memory: CPU% + Mem MB 2 列 / Disk/Network: I/O レート 1 列）。

## Trade-offs

- **`proc_pid_rusage` の全 PID 列挙が遅い可能性**: 500+ プロセスで 1 サン
  プリング 50ms 超になる可能性がある。実測で問題が出たら CPU% 上位 N プロセス
  に絞るか、待ち時間を短くする等で調整する。
- **`nettop` 出力フォーマットの OS バージョン依存**: `-J` で列を限定して
  ある程度安定化するが、メジャーバージョン更新時には目視確認が必要。出力が
  空のときはエラーにせず空一覧で返す。
- **対数スケールが直感的でない可能性**: 数百 B/s でもバーが 30% 程度見える
  ため「動いてる感」が強く出る。実機で違和感があれば下限を 10 KB/s に上げる。
- **per-process I/O の計測精度**: `proc_pid_rusage` の差分は短命プロセスを
  捕まえられない。`ioBytesPerSec = 0` のプロセスは表示から除外する。
- **App Sandbox 化した場合の制約**: 現状未使用（ADR-0039 と同じ）。サンド
  ボックス化する場合は IOKit / getifaddrs / nettop 起動の権限を再検討する。
- **マルチウィンドウでの重複サンプリング**: ADR-0039 と同じ。`nettop` 起動
  もウィンドウごとに走るが、表示は一致するので実害なし。

## References

- ADR-0039（トップバー常駐アクティビティモニタの基盤設計）
- ADR-0038（Polaris デザインシステム — トップバー / トークン / 0ms 方針）
- ADR-0034（多言語化を gen-l10n で実装する）
- ADR-0005（外部 Skill / プラグインに依存しない自己完結方針 — pub とは無関係）
- Apple Docs: `libproc.h` / `proc_pid_rusage`
- macOS man: `nettop(1)`
- IOKit Programming Guide: IOBlockStorageDriver
- `openspec/changes/extend-activity-monitor-io/`（proposal / design / specs /
  tasks）
