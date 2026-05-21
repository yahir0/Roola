## 1. ネイティブ層（macOS）

- [ ] 1.1 `SystemMetricsProvider` に `diskIOCounters()` を実装する
      （IOKit `IOServiceGetMatchingServices("IOBlockStorageDriver")` で
      ブロックデバイスを列挙し、`IOBlockStorageDriverStatistics` の
      `Bytes (Read)` / `Bytes (Write)` を合計する）。
- [ ] 1.2 `SystemMetricsProvider` に `networkIOCounters()` を実装する
      （`getifaddrs` で全インターフェイスを列挙、`AF_LINK` の `if_data` から
      `ifi_ibytes` / `ifi_obytes` を合計、`lo` 始まりのループバックは除外）。
- [ ] 1.3 `getSystemMetrics` の戻り値に `diskReadBytes` / `diskWrittenBytes` /
      `networkInBytes` / `networkOutBytes` を追加する。
- [ ] 1.4 `SystemMetricsProvider` に `diskTopProcesses()` を実装する
      （`proc_listallpids` で全 PID を列挙、各 PID に
      `proc_pid_rusage(pid, RUSAGE_INFO_V2)` を呼んで I/O バイトを取り、
      1 秒スリープして再取得、差分から per-second rate を算出。
      `ri_diskio_bytesread + ri_diskio_byteswritten` の合計を扱う）。
- [ ] 1.5 `SystemMetricsProvider` に `networkTopProcesses()` を実装する
      （`/usr/bin/nettop -P -L 2 -s 1 -x -J bytes_in,bytes_out` をサブプロセス
      実行、2 サンプル目と 1 サンプル目の差分から per-second rate を算出）。
- [ ] 1.6 `getTopProcesses` ハンドラを `sortKey: String`（`"cpu"` /
      `"memory"` / `"disk"` / `"network"`）引数付きにして分岐する。
      cpu/memory は既存の `processes()` 経路、disk は `diskTopProcesses()`、
      network は `networkTopProcesses()`。後者 2 つはレスポンスに
      `ioBytesPerSec` 列を含める。
- [ ] 1.7 `flutter run`（macOS）で各メソッドが値を返すことを手元で確認する。

## 2. data 層（モデル・リポジトリ）

- [ ] 2.1 `lib/data/activity_metrics/system_metrics.dart` に累積カウンタ
      （`diskReadBytes` / `diskWrittenBytes` / `networkInBytes` /
      `networkOutBytes`）を追加する。
- [ ] 2.2 `lib/data/activity_metrics/system_metrics_snapshot.dart` を新設し、
      累積カウンタ＋計算済みレート（`diskBytesPerSec` / `networkBytesPerSec`）
      ＋メタ情報（取得時刻）を保持する Freezed モデルを定義する。
      ViewModel の state 型として使う。
- [ ] 2.3 `lib/data/activity_metrics/process_metrics.dart` に
      `ioBytesPerSec`（`int?`）を追加する。CPU/Memory ソートでは null、
      Disk/Network ソートではネイティブが埋める。
- [ ] 2.4 `ProcessSortKey` に `disk` / `network` を追加する。
- [ ] 2.5 `SystemMetricsRepository.fetchSystemMetrics()` を累積カウンタ込みに
      拡張する。
- [ ] 2.6 `SystemMetricsRepository.fetchProcesses(ProcessSortKey)` を追加し、
      ネイティブ `getTopProcesses` にソートキーを渡してレスポンスを
      `ProcessMetrics` のリストへ変換する。
- [ ] 2.7 `build_runner` を実行して Freezed の生成コードを更新する。

## 3. UI 層（ViewModel）

- [ ] 3.1 `ActivityMonitorViewModel` の state 型を `SystemMetrics` から
      `SystemMetricsSnapshot` に変更する。前回 snapshot を保持し、新しい値が
      来たら delta / elapsedSeconds で disk/network rate を計算する。
- [ ] 3.2 ポップオーバー開閉用 `ActivityPopover` enum に `disk` / `network`
      を追加する。
- [ ] 3.3 `activityTopProcessesProvider(ProcessSortKey)` の family を維持し、
      `fetchProcesses(sortKey)` を呼び出す形に置き換える（並び替えは disk /
      network は ioBytesPerSec 降順、cpu / memory は既存どおり）。

## 4. UI 層（ウィジェット）

- [ ] 4.1 `_ActivityGauge` をパーセント表示 / レート表示の両モードに対応させる
      （`displayMode: GaugeDisplayMode`）。レートモードでは readout に人間
      可読単位を出す。
- [ ] 4.2 `_LevelBar` を対数スケール対応にする（`scale: GaugeScale`、
      `linear` は現状の 0–1 そのまま、`logBytesPerSec` は `1 KB/s → 1 GB/s`
      を `log10` でマップ）。
- [ ] 4.3 `ActivityMonitorBar` に Disk / Network のゲージボタンを追加し、
      4 連レイアウトに変更する。トップバー 40px 内に収まることを確認する。
- [ ] 4.4 ディスク・ネットワーク用のアイコン候補（例: `Icons.storage` /
      `Icons.swap_vert`）を実機で確認して決定する。
- [ ] 4.5 `ActivityMonitorPopover` で sortKey が disk / network のとき、列
      ヘッダを「I/O」1 列にし、各行の数値を人間可読レートで表示する。
- [ ] 4.6 ポップオーバーの幅・列幅が、最大値（例: `999 MB/s`）でも桁揺れ
      しないよう調整する。

## 5. ヘルパー / 共通

- [ ] 5.1 人間可読バイト/秒文字列のフォーマット関数
      `formatBytesPerSec(int)` を `lib/ui/activity_monitor/` または
      `lib/core/format/` に追加する（`512 B/s` / `1.2 KB/s` / `12 MB/s` /
      `1.2 GB/s`）。

## 6. 多言語化（l10n）

- [ ] 6.1 `lib/l10n/app_en.arb` / `app_ja.arb` に Disk / Network 用のツール
      チップ・ポップオーバー見出し・列ラベルを追加する。
      （`activityMonitorDiskTooltip` / `activityMonitorNetworkTooltip` /
      `activityMonitorDiskPopoverTitle` / `activityMonitorNetworkPopoverTitle`
      / `activityMonitorColumnIo`）
- [ ] 6.2 `flutter gen-l10n` で再生成する（ADR-0034）。

## 7. テスト

- [ ] 7.1 `SystemMetricsRepository` のテストに、ディスク / ネットワークの
      累積カウンタが `SystemMetrics` に正しくマッピングされることの検証を
      追加する。
- [ ] 7.2 `SystemMetricsRepository.fetchProcesses(disk / network)` で
      `ioBytesPerSec` を含む `ProcessMetrics` リストが返ることを検証する。
- [ ] 7.3 `ActivityMonitorViewModel` の rate 計算ロジックのテストを追加する
      （初回は 0、2 回目以降は delta / elapsedSeconds、累積カウンタが減った
      場合は 0 として扱う等のエッジケース）。
- [ ] 7.4 ウィジェットテストに、Disk / Network ゲージが追加され、クリックで
      対応するポップオーバーが開くこと、別モニタへの排他切替が動くことを
      追加する。
- [ ] 7.5 `formatBytesPerSec` のユニットテストを追加する。

## 8. ドキュメント

- [ ] 8.1 `docs/adr/0048-activity-monitor-disk-network-io.md` を追加する
      （ネイティブ取得方式・per-process サンプリング戦略・対数スケールの
      根拠・レート計算の Dart 集約方針）。
- [ ] 8.2 `CLAUDE.md` の ADR 一覧に ADR-0048 を 1 行追記する。
- [ ] 8.3 `docs/adr/README.md` に ADR-0048 を追加する。

## 9. 仕上げ

- [ ] 9.1 `fvm dart analyze` をクリーンにする。
- [ ] 9.2 `fvm dart format` を実行する。
- [ ] 9.3 `fvm flutter test` が通ることを確認する。
- [ ] 9.4 実機（macOS）で 4 つのゲージのバー更新・各ポップオーバーの一覧
      表示・排他開閉挙動を目視確認する。
