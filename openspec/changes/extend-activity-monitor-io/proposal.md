## Why

ADR-0039 で導入したトップバーのアクティビティモニタは CPU とメモリの 2 指標
のみで、ディスク I/O / ネットワーク I/O は明示的に Non-Goal として外していた。
実運用では「いまネットワークを誰が使っているか」「ディスクが暴れているか」を
知りたい場面が多く、現状ユーザーはアクティビティモニタ.app へ切り替える必要
が残っている。CPU / メモリと同じトップバー常駐の枠で I/O 系も見られるように
してアプリ内完結度を上げる。

設計判断は ADR-0048 に記録する。

## What Changes

- トップバーのアクティビティモニタを **4 連ゲージ** にする（左から CPU /
  メモリ / ディスク I/O / ネットワーク I/O）。
- ディスク / ネットワークのゲージは「アイコン＋ミニレベルバー＋現在のレート
  （人間可読、例 `12 MB/s`）」を表示する。
- レベルバーは **対数スケール** で `1 KB/s → 1 GB/s` を 0–100% にマップする。
  桁の広い I/O 量を 1 本のバーで直感的に見せる。
- 各ゲージをクリックすると、その指標の **上位プロセス一覧** をポップオーバー
  で表示する（CPU / メモリと同じ UX）。
- ディスク per-process は `proc_pid_rusage(RUSAGE_INFO_V2)` の累積 I/O バイト
  を 1 秒間隔で 2 回サンプリングして差分から rate を計算する。
- ネットワーク per-process は `nettop -P -L 2 -s 1 -x` を 1 回実行して 2 サン
  プルの差分から rate を計算する（per-process network I/O の Mach API は
  サンドボックス無しでは事実上 nettop 経由）。
- システム全体のレートは、ネイティブが返した **累積カウンタ**（disk read/
  write・network in/out）を Dart 側 ViewModel が前回 snapshot との差分と
  経過時間から計算する。ポーリング間隔は既存と同じ 1 秒。
- ネイティブ側は累積カウンタとレート計算用の差分を返すのみで、レート計算
  ロジックは Dart 側に集約する（テスト可能性）。
- l10n / ARB（JA / EN）にディスク・ネットワーク用のツールチップ・ポップオー
  バー見出し・列ラベルを追加する。

## Capabilities

### Modified Capabilities

- `activity-monitor`: ゲージ 2 連（CPU / メモリ）→ 4 連（CPU / メモリ /
  ディスク I/O / ネットワーク I/O）。ディスク・ネットワークは累積カウンタ
  からのレート表示（対数スケールバー＋人間可読レート）と、クリックで開く
  per-process 上位一覧ポップオーバーを持つ。

## Impact

- **UI**: `lib/ui/activity_monitor/activity_monitor_bar.dart` に Disk / Network
  ゲージを追加。`_ActivityGauge` をパーセント表示 / レート表示の両モードに
  拡張、`_LevelBar` を対数スケール対応に拡張。`activity_monitor_popover.dart`
  に Disk / Network 用のソートキーと列ラベルを追加。
- **data 層**: `system_metrics.dart` に累積カウンタ（diskReadBytes /
  diskWrittenBytes / networkInBytes / networkOutBytes）を追加。
  `process_metrics.dart` に I/O レート用フィールド（ioBytesPerSec）を追加。
  `ProcessSortKey` に `disk` / `network` を追加。`SystemMetricsRepository` に
  ソートキー別の `fetchProcesses(ProcessSortKey)` を追加（ネイティブ側を
  分岐）。
- **ViewModel**: `ActivityMonitorViewModel` の state を `SystemMetricsSnapshot`
  に拡張（累積カウンタ＋計算済みレート）。前回 snapshot を保持して差分から
  rate を計算する。
- **ネイティブ (macOS)**: `MainFlutterWindow.swift` の `SystemMetricsProvider`
  に `diskIOCounters()`（IOKit IOBlockStorageDriver 統計の合計）と
  `networkIOCounters()`（`getifaddrs` の `if_data` 合計、loopback 除外）を
  追加。`getSystemMetrics` の戻り値を累積カウンタ込みに拡張。`getTopProcesses`
  にソートキー引数を追加し、disk は `proc_pid_rusage` の 1 秒サンプリング、
  network は `nettop -P -L 2 -s 1 -x` のサブプロセス実行で per-process rate を
  返す。
- **ドキュメント**: `docs/adr/0048-activity-monitor-disk-network-io.md` を
  追加し、設計判断（IOKit / getifaddrs / nettop / proc_pid_rusage の採用理由・
  対数スケールの根拠・ポップオーバー取得の遅延許容）を記録する。
- **多言語化**: `lib/l10n/app_en.arb` / `app_ja.arb` に disk/network ツール
  チップ・popover タイトル・列ラベルを追加し `flutter gen-l10n` で再生成
  （ADR-0034）。
- **テスト**: `SystemMetricsRepository` のテストにディスク/ネットワークの
  パース検証を追加。ViewModel のレート計算ロジックのテストを追加。
- **App Sandbox**: Roola 自体は現状 App Sandbox 未使用（ADR-0039 と同じ前提）
  のため、`/usr/bin/nettop` のサブプロセス起動・IOKit 利用・getifaddrs はそ
  のまま動作する。将来サンドボックス化する場合は ADR-0039 と合わせて再検討
  する。
- **却下案・代替**: `iotop` は macOS に存在しない。`fs_usage` はイベント駆動
  でノイズが多く要 sudo。per-process network を libpcap で取るのは sudo 必要
  で重い。`nettop` は権限不要で nettop 自身が rate 計算してくれるためサンプル
  数 2・間隔 1 秒で必要十分。
