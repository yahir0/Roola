## 1. ネイティブ層（macOS）

- [x] 1.1 `macos/Runner/` にシステムメトリクス取得の Swift 実装を追加する
      （`host_statistics`(HOST_CPU_LOAD_INFO) の tick 差分で CPU 使用率、
      `host_statistics64`(HOST_VM_INFO64) ＋ `hw.memsize` でメモリ使用量 /
      総容量を算出）。CPU は前回 tick を保持して差分を取る。
- [x] 1.2 同 Swift 実装に上位プロセス取得を追加する（`ps -Aceo
      pid,pcpu,rss,comm` 相当を 1 回実行し、pid / 名前 / CPU% / RSS を
      パースしてリスト化）。
- [x] 1.3 `MainFlutterWindow.swift` に `MethodChannel('roola/system/metrics')`
      を登録し、`getSystemMetrics` / `getTopProcesses` の 2 メソッドを
      ハンドルする（既存 `roola/trash` と同じパターン）。
- [x] 1.4 `flutter run`（macOS）でネイティブ側が値を返すことを手元で確認する。

## 2. data 層（モデル・リポジトリ）

- [x] 2.1 `lib/data/activity_metrics/system_metrics.dart` に Freezed モデル
      `SystemMetrics`（cpuPercent / memoryUsedBytes / memoryTotalBytes、
      メモリ使用率の派生 getter）を定義する。
- [x] 2.2 `lib/data/activity_metrics/process_metrics.dart` に Freezed モデル
      `ProcessMetrics`（pid / name / cpuPercent / memoryBytes）を定義する。
- [x] 2.3 `lib/data/activity_metrics/system_metrics_repository.dart` に
      具象クラス `SystemMetricsRepository` を実装する
      （`MethodChannel('roola/system/metrics')` をラップし、
      `fetchSystemMetrics()` / `fetchTopProcesses()` を提供。interface は
      作らない）。Riverpod の `systemMetricsRepositoryProvider` を定義する。
- [x] 2.4 `build_runner` を実行して Freezed の生成コードを更新する。

## 3. UI 層（ViewModel）

- [x] 3.1 `lib/ui/activity_monitor/activity_monitor_view_model.dart` に
      `Notifier` ベースの ViewModel を実装する（`Timer.periodic` 1 秒で
      `fetchSystemMetrics` を pull、state を更新、`ref.onDispose` で
      タイマー破棄、取得失敗時は直近値を維持）。
- [x] 3.2 ポップオーバーの開閉状態（none / cpu / memory の排他）を扱う
      `Notifier` を実装する。
- [x] 3.3 プロセス一覧取得用の `AsyncNotifier`（または FutureProvider.family）
      を実装し、ソートキー（cpu / memory）に応じた降順並び替えと上位 N 件
      制限を行う。

## 4. UI 層（ウィジェット）

- [x] 4.1 `lib/ui/activity_monitor/` に CPU / メモリ共通のミニバー
      ウィジェット（アイコン＋レベルバー）を実装する。色・余白・角丸は
      `PolarisTokens` 経由、値変化は 0ms 即時反映。
- [x] 4.2 `activity_monitor_bar.dart` に CPU / メモリ 2 連のモニタを実装し、
      各モニタのクリックでポップオーバー開閉状態を切り替える。
- [x] 4.3 `activity_monitor_popover.dart` に上位プロセス一覧パネルを実装する
      （Polaris の面 — `bg` 地・1px `line` ボーダー・角丸 `radius`、
      各行にプロセス名・CPU%・メモリ MB、mono フォントで数値列を揃える）。
- [x] 4.4 `activity_monitor_popover_layer.dart` に body 側のポップオーバー
      レイヤーを実装する（透明バリアでの外側クリック / 同モニタ再クリック /
      排他切り替え。トップバーを覆わない body 内バリア方式）。

## 5. トップバーへの組み込み

- [x] 5.1 `lib/ui/workspace/workspace_page.dart` のトップバー `actions` の
      先頭（メモパッドアイコンの左）にアクティビティモニタを追加する。
- [x] 5.2 トップバー高 40px・4px グリッドの中でモニタ 2 連が破綻なく収まる
      ことを確認し、必要なら余白を調整する。

## 6. 多言語化（l10n）

- [x] 6.1 ツールチップ・ポップオーバー見出し・列ラベル等の文言を
      `lib/l10n/app_en.arb` / `app_ja.arb` に追加し、`flutter gen-l10n`
      で再生成する（ADR-0034）。

## 7. テスト

- [x] 7.1 `SystemMetricsRepository` のテストを書く（`MethodChannel` の
      モックハンドラでネイティブ応答を擬似し、モデルへの変換を検証）。
- [x] 7.2 ViewModel のテストを書く（fake リポジトリを provider override で
      注入し、ポーリング更新・取得失敗時の直近値維持・並び替えを検証）。
- [x] 7.3 ウィジェットテストを書く（モニタがメモパッド・設定の左に並ぶ、
      クリックでポップオーバーが開く、排他開閉、外側クリックで閉じる）。

## 8. ドキュメント

- [x] 8.1 `docs/adr/0039-activity-monitor.md` を追加する（ネイティブ連携
      方式・ポーリング間隔・レイヤー隔離・サンドボックス時の留意点）。
- [x] 8.2 `CLAUDE.md` の ADR 一覧に ADR-0039 を 1 行追記する。

## 9. 仕上げ

- [x] 9.1 `flutter analyze` をクリーンにする。
- [x] 9.2 `flutter test` が通ることを確認する。
- [x] 9.3 実機（macOS）で CPU / メモリのバー更新・ポップオーバーの一覧表示・
      並び替え・開閉挙動を目視確認する。
