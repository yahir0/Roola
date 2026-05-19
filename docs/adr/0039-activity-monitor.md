# ADR-0039: トップバーにアクティビティモニタを追加する

- **Status**: Accepted
- **Date**: 2026-05-19

## Context

Roola はシェル / 任意コマンド / Claude Skill を多数同時に起動するため、
「いま機械にどれだけ負荷がかかっているか」「重いのはどのプロセスか」を
アプリ内から把握したい場面がある。従来その手段はなく、ユーザーは macOS
標準のアクティビティモニタ.app へ切り替える必要があった。

トップバー（ADR-0038 D8）右端にはメモパッド・設定のアイコンが並ぶ。ここへ
CPU / メモリの負荷表示を常駐させ、クリックで上位プロセスを見られるように
する。

macOS のシステムメトリクス（CPU 使用率・メモリ使用量・プロセス一覧）は
Dart 標準ライブラリでは取れずネイティブ連携が要る。pub.dev を調査したが、
「システム全体のライブ CPU% / メモリ / 上位プロセス一覧」をまとめて返す
macOS 向けパッケージは存在しない（in-app 計測系はアプリ自身の FPS /
メモリのみ、device-info 系は CPU モデルや総 RAM など静的情報のみ）。

## Decision

**トップバー右端、メモパッド・設定アイコンの左にアクティビティモニタを
常設する。** 仕様・各決定の背景は
`openspec/changes/archive/<date>-add-activity-monitor/` を参照。

### D1. システム全体メトリクスはネイティブ Mach API で取得する

常時 1 秒ポーリングするシステム CPU% / メモリ使用率は、ネイティブ Swift で
macOS の Mach / sysctl API を直接呼ぶ。

- CPU: `host_statistics`(HOST_CPU_LOAD_INFO) の累積 tick（user/system/idle/
  nice）を 2 回分の差分から算出。差分方式のため前回 tick を保持する。
- メモリ: `host_statistics64`(HOST_VM_INFO64) ＋ `sysctl hw.memsize`。
  使用量は active + wired + compressed ページとする。

却下案: 毎秒 `top` / `ps` をサブプロセス起動して標準出力をパース —
1 秒ごとのプロセス起動はコストが高く、`top -l` は初回サンプルが不正確。

### D2. 上位プロセス一覧はクリック時に `ps` を実行して取得する

ポップオーバーを開いた瞬間にネイティブ側で `ps -Ao pid=,pcpu=,rss=,comm=`
を 1 回実行し、標準出力をパースして返す。並び替え（CPU 降順 / メモリ降順）
と上位 N 件への絞り込みは Dart 側で行う。プロセス一覧はクリック時のみ必要で
頻度が低く、サブプロセス 1 回起動のコストは許容範囲。per-process CPU% を
Mach API（`proc_pidinfo` の CPU 時間差分）で出すと状態保持が必要で実装が
重く、`ps` の `pcpu` 列で十分。

### D3. ネイティブ連携は単一の `MethodChannel` に集約する

`MainFlutterWindow.swift` に `roola/system/metrics` チャネルを 1 つ登録し、
`getSystemMetrics` / `getTopProcesses` の 2 メソッドを持たせる（既存
`roola/trash` と同じ素の `MethodChannel` パターン）。EventChannel の push は
使わず Dart 側のタイマー pull に統一し、ポーリング制御を Dart に集約する
（テストも容易）。CPU の tick 差分のためネイティブ側の `SystemMetricsProvider`
は状態を持ち、チャネルハンドラに captures させて常駐させる。

### D4. ネイティブ依存は data 層の 1 クラスに隔離する

- `data/activity_metrics/`: Freezed モデル（`SystemMetrics` /
  `ProcessMetrics`、表示専用のため DTO 分離なし）と、`MethodChannel` を
  叩く具象クラス `SystemMetricsRepository`。差し替え可能性のある箇所では
  ないため interface は作らない（CLAUDE.md）。テストは Riverpod の provider
  override で fake サブクラスに差し替える。
- `ui/activity_monitor/`: `Notifier` ベースの ViewModel（ポーリング）、
  ポップオーバー開閉状態、上位プロセス取得（`FutureProvider.autoDispose
  .family`）、トップバーのバー / ポップオーバーのウィジェット。
- Use Case 層は作らない（CLAUDE.md）。並び替え・件数制限は ViewModel に置く。

### D5. ポーリングは 1 秒間隔、ウィンドウ生存中のみ

`Timer.periodic` で 1 秒ごとに `getSystemMetrics` を pull する。負荷計の更新
頻度として一般的で、Mach API 取得は軽量なため常時稼働で問題ない。バーの値
更新はトゥイーンせず即時反映（ADR-0038 D7 の 0ms 方針）。取得失敗時は state
を直近の有効値に保ち、次回ポーリングで回復を試みる（一瞬ゼロへ落ちて
見えるのを防ぐ）。

### D6. ポップオーバーは body 側のレイヤーに描く

ミニバーをクリックすると、トップバー直下に上位プロセス一覧パネルを開く。
パネルはトップバー（`AppBar`）ではなくワークスペース body の `Stack` 直下に
置く `ActivityMonitorPopoverLayer` が描く（ノートパッド / ADR-0036 と同じ
構成）。外側クリックで閉じる透明バリアを body 内に敷くが、body はトップバーを
含まないためバリアがモニタを覆わず、ポップオーバーを開いたまま別モニタへ
切り替えられる。当初検討した `OverlayPortal` ＋ `CompositedTransformFollower`
はオーバーレイのバリアがトップバーを覆って切り替えクリックを奪うため却下。
パネルは Polaris の面（`bg` 地・1px `line` ボーダー・角丸 `radius`、影なし）。
同じモニタの再クリック・外側クリックで閉じ、CPU とメモリのポップオーバーは
排他とする。開閉状態は `activityPopoverProvider` で共有する。

## Why

アプリを離れずに負荷状況を把握できると、重いシェル / Skill を抱えたまま
作業を続ける際の判断材料になる。常時表示はミニバーで場所を取らず、詳細
（プロセス一覧）はクリック時のオンデマンドに分けることで、トップバーの
情報密度と取得コストの双方を抑える。

ライブのシステムメトリクスを返す pub パッケージが無いためネイティブ実装に
するが、これは依存禁止（ADR-0005 は外部 Skill / プラグインの話であり pub
とは無関係）ではなく、用途に合うものが無いことによる技術的判断である。

## Trade-offs

- **Mach API の Swift バインディングが冗長**: `host_statistics` 系は
  ボイラープレートが多い。実装を `SystemMetricsProvider` クラスに閉じ込め、
  `MainFlutterWindow` 本体はチャネル登録だけに留める。
- **CPU% の初回サンプルが不定**: 差分方式のため初回は前回値が無く 0% 付近に
  なる。1 秒後の 2 回目以降で正常化する。
- **`ps` 実行のわずかな遅延**: ポップオーバーを開いてからリスト確定まで
  数十 ms の空きが出うる。取得中は空のパネル枠を出す（スピナーは出さない /
  0ms 方針）。
- **App Sandbox 化した場合の制約**: 現状 Roola は App Sandbox 未使用。将来
  サンドボックス化する場合、子プロセス（`ps`）実行と Mach host port の権限を
  再検討する必要がある。
- **マルチウィンドウ（ADR-0012）で各プロセスが個別にポーリング**: 別プロセス
  起動方式のため各ウィンドウが独自のタイマーを持つ。メトリクスはシステム
  全体値なので重複取得しても表示は一致し、実害はない。

## References

- ADR-0038（Polaris デザインシステム — トップバー / トークン / 0ms 方針）
- ADR-0034（多言語化を gen-l10n で実装する）
- ADR-0012（マルチウィンドウは別プロセス起動）
- ADR-0005（外部 Skill / プラグインに依存しない自己完結方針 — pub とは無関係）
- `openspec/changes/add-activity-monitor/`（proposal / design / specs / tasks）
