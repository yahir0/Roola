## Context

ADR-0039 でトップバーのアクティビティモニタ（CPU / メモリ）を導入したが、
明示的に Non-Goal としていたディスク I/O / ネットワーク I/O を今回追加する。
既存実装の枠組み（1 秒ポーリング・MethodChannel・Polaris ゲージ・上位プロセス
ポップオーバー）はそのまま再利用し、データソースと表示モードを 4 指標に拡張
する。

制約:

- macOS のシステム全体 I/O メトリクスは Dart 標準では取れず、ネイティブ連携
  が必須（ADR-0039 と同じ事情）。
- pub.dev に「ライブのシステム I/O とプロセス別 I/O をまとめて返す macOS 向け
  パッケージ」は存在しない。ADR-0039 で確認済み。
- I/O 量は CPU% / メモリ% と違って値域が桁違いに広い（数 B/s ～ 数 GB/s）。
  単一の 0–100% スケールでは表現できない。
- per-process ディスク I/O は `proc_pid_rusage(RUSAGE_INFO_V2)` で取れるが、
  累積バイトのため rate にするには 2 サンプル必要。
- per-process ネットワーク I/O は Mach API では取れず、`nettop` がほぼ唯一の
  権限不要手段。
- Polaris の 0ms 即時方針（ADR-0038 D7）と CPU / メモリの既存挙動と整合。

## Goals / Non-Goals

**Goals:**

- 4 連ゲージ（CPU / メモリ / ディスク / ネットワーク）。
- ディスク・ネットワークはシステム全体レートをミニバーで可視化し、現在値を
  人間可読の単位（B/s, KB/s, MB/s, GB/s）で表示する。
- クリックで上位プロセス一覧（per-process I/O rate）を表示する。
- 既存 CPU / メモリの挙動を変えない（追加だけ）。

**Non-Goals:**

- 履歴グラフ・スパークライン（現在値のバー表示のみ。ADR-0039 と同じ方針）。
- メトリクスの永続化。
- per-process I/O の継続バックグラウンド計測（ポップオーバーが開かれた瞬間に
  サンプリングする方式に統一）。
- Windows / Linux 対応。
- I/O の Read/Write・In/Out の分離表示（合計のみ。将来必要なら追加）。

## Decisions

### D1. ディスク I/O は IOKit、ネットワーク I/O は getifaddrs を使う

**システム全体の累積カウンタ:**

- ディスク I/O: IOKit の `IOServiceGetMatchingServices("IOBlockStorageDriver")`
  で各ブロックデバイスを列挙し、`IOBlockStorageDriverStatistics` の
  `Bytes (Read)` / `Bytes (Write)` を合計する。物理ディスクごとのカウンタを
  すべて足し合わせるため、複数ディスク・APFS のコンテナ構成にも対応する。
- ネットワーク I/O: `getifaddrs` で全インターフェイスを列挙し、`AF_LINK` の
  `if_data` 構造体から `ifi_ibytes` / `ifi_obytes` を合計する。`lo` 始まりの
  ループバックは除外する（自分宛て通信を合算しないため）。

これらは累積バイト数（system boot 以降の総量）なので、Dart 側 ViewModel が
前回 snapshot との差分と経過秒数から rate（B/s）を計算する。

**代替案: `iostat` / `netstat` のサブプロセス実行** —
1 秒ごとのプロセス起動はコストが高く、出力フォーマットが OS バージョン依存
で壊れやすい。常時ポーリング経路では却下。

### D2. per-process ディスクは proc_pid_rusage で 1 秒 2 サンプル

ポップオーバーを開いた瞬間、ネイティブ側で `proc_listallpids` で全 PID を列挙
し、各 PID に対して `proc_pid_rusage(pid, RUSAGE_INFO_V2)` を呼び
`ri_diskio_bytesread + ri_diskio_byteswritten` を取る。1 秒スリープして再度
取り、差分から per-second rate を出す。

`proc_pid_rusage` はカーネルが提供する API でサブプロセス起動なし。1 回の
列挙は数百プロセスでも数 ms オーダー。サンプリングの 1 秒待ちはポップオーバー
を開いてからの体感遅延として許容範囲（ADR-0039 D6 で「取得中は空の枠を出す」
方針と一致）。

**代替案: `iotop`（macOS には存在しない） / `fs_usage`（要 sudo・ノイズ多）** —
いずれも採用不可。

### D3. per-process ネットワークは nettop -P -L 2 -s 1

`nettop -P -L 2 -s 1 -x -J bytes_in,bytes_out` を 1 回サブプロセス実行する。
`-P` で per-process 集計、`-L 2 -s 1` で 1 秒間隔の 2 サンプル、`-x` でバイト
表示、`-J` で必要列のみ。2 サンプル目の bytes_in / bytes_out から 1 サンプル
目を引いて per-second rate を出す（nettop の bytes 列はシステム boot からの
累積）。

`nettop` は macOS 標準ツールで権限不要（sudo 不要）。プロセス起動 1 回・出力
パースのコストは ポップオーバー開時のみで頻度が低いため許容範囲。

**代替案: per-process network 用の Mach / sysctl API** — 標準的に存在しない。
libpcap ベースは sudo 必要で重く却下。

### D4. レート計算は Dart 側 ViewModel に集約する

ネイティブ側が返すのは「ある瞬間の累積カウンタ」のみ。「前回値との差分／
経過秒数」のレート計算は Dart 側 ViewModel が担う。テスト時にネイティブを
呼ばずに rate 計算ロジックだけを検証できる。

ViewModel は state を `SystemMetricsSnapshot`（累積カウンタ＋現在レート）に
拡張する。前回 snapshot を保持し、新しい値が来たら delta / elapsedSeconds で
rate を計算する。初回ポーリングは前回値が無いため rate は 0（CPU 使用率と
同じ挙動）。

**代替案: ネイティブ側で前回値を保持して rate を返す** — ネイティブが状態を
持つほど多くはなく（CPU の tick 差分は既存）、Dart 側に集約する方が一貫性が
高い。

### D5. レベルバーは対数スケール、レンジは 1 KB/s → 1 GB/s

I/O 量は 0 から GB/s まで桁が広く、線形スケールの 100 MB/s 固定では普段の
KB/s オーダーが見えない。対数スケール（`log10`）で `1 KB/s` を 0%、`1 GB/s`
を 100% にマップすることで、Wi-Fi 上の数百 KB/s も SSD 上の数百 MB/s も同じ
バーで直感的に見せる。1 KB/s 未満は 0%、1 GB/s 超は 100% にクランプする。

レート表示の文字列は人間可読単位で `<10` は B/s、`<10 KB/s` は小数 1 桁、それ
以上は 2 桁固定（例: `512 B/s` / `1.2 KB/s` / `12 MB/s`）。

**代替案: 直近の最大値を 100% とする自動スケール** — ローカルでアクティブな
状況に合わせて反応的になる一方、絶対値の感覚が掴めず、静かな時にもバーが
動いて誤解を招く。却下。

### D6. ProcessSortKey に disk / network を追加し fetchProcesses で分岐

既存の `ProcessSortKey { cpu, memory }` に `disk` / `network` を追加する。
`SystemMetricsRepository.fetchProcesses(ProcessSortKey)` がソートキーを受け取り、
ネイティブ側に渡して disk / network のときは I/O プロセス取得経路を実行する。
CPU / メモリは既存 `ps` 経路を使う（変更なし）。

`ProcessMetrics` に I/O レート用フィールド `ioBytesPerSec`（nullable）を追加
する。ソートキーが disk / network のときのみネイティブが値を埋め、それ以外
では null。ポップオーバー側はソートキーに応じて表示列を切り替える
（cpu/memory: CPU% + Mem MB / disk/network: ioBytesPerSec を人間可読で 1 列）。

`activityTopProcessesProvider(ProcessSortKey)` の family は既存のまま、CPU と
メモリは降順キーで分岐する箇所に disk / network を追加する。

### D7. Polaris 準拠 — 4 連でも 40px トップバーに収める

`_ActivityGauge` の幅は CPU/Mem では `アイコン + bar(32px) + readout(32px)`
で約 88px。4 連で約 350px。トップバーには十分収まる。レート readout は数値
+ 単位で桁揺れしうるため、現状の 32px から拡げる（実装時に微調整）。アイコン
は Material Symbols から: ディスク `Icons.storage`、ネットワーク
`Icons.wifi_tethering` か `Icons.swap_vert` を採用候補（実装時に決定）。

## Risks / Trade-offs

- **`proc_pid_rusage` で全 PID 列挙が遅い可能性**: プロセス数が 500+ になる
  環境では 1 サンプリングが 50ms 超になるかもしれない。実測で問題が出たら
  CPU% 上位 N プロセスに絞る、または 1 秒待ちを短くする等で調整する。
- **`nettop` 出力フォーマットの OS バージョン依存**: 列ヘッダがズレると
  パースが壊れる。列を `-J bytes_in,bytes_out` で限定し、テスト時に擬似出力で
  カバーする。出力が空のときはエラーにせず空一覧で返す。
- **対数スケールが直感的でない場合がある**: 数百 B/s でもバーが 30% 程度
  見えるため「動いてる感」が強く出るかもしれない。実機確認で違和感があれば
  下限を 10 KB/s に上げる等を検討する。
- **per-process I/O の計測精度**: `proc_pid_rusage` の差分は短命プロセスを
  捕まえられない。`ioBytesPerSec` が 0 のプロセスは表示から除外する。
- **マルチウィンドウでの重複サンプリング**: ADR-0039 と同じ。表示は一致する
  ので実害なし。`nettop` の重複起動も同様。

## Migration / Rollout

- 既存の CPU / メモリゲージは挙動を変えず、新規 2 連を追加するだけ。
- `SystemMetrics` モデルにフィールドを追加するため Freezed 再生成
  （`build_runner`）が必要。
- 既存テストは `SystemMetrics.zero` 等の差分のみ最小限の修正で済む。

## Open Questions

- ディスク・ネットワークのレート readout 幅。実装時に実機で確認して、桁揺れ
  の最大値（例: `999 MB/s`）に合わせて `_readoutWidth` を拡げる。
- ネットワークのループバック除外条件。`lo` 始まりだけで十分か、より明示的に
  `IFF_LOOPBACK` フラグで判定するか。実装時に確認。

## References

- ADR-0039: トップバー常駐アクティビティモニタの基盤設計
- ADR-0038: Polaris デザインシステム（4px グリッド・0ms 方針）
- ADR-0034: 多言語化（gen-l10n / ARB）
- ADR-0005: 外部依存に関する方針（pub とは無関係、本件のネイティブ採用は
  「用途に合うパッケージがない」技術判断）
- Apple Docs: `libproc.h` / `proc_pid_rusage`
- macOS man: `nettop(1)`
- IOKit Programming Guide: IOBlockStorageDriver
