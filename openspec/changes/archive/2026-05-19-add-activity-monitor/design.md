## Context

Roola はトップバー（macOS タイトルバー統合の自前バー / ADR-0038 D8）の右端に
メモパッド・設定のアイコンを並べている。ここへ CPU / メモリのアクティビティ
モニタを追加する。

制約:

- macOS のシステムメトリクス（CPU 使用率・メモリ使用量・プロセス一覧）は
  Dart 標準ライブラリでは取得できず、ネイティブ連携が必須。
- pub.dev を調査したが、「システム全体のライブ CPU% ／ メモリ ／ 上位
  プロセス一覧」をまとめて返す macOS 向けパッケージはない（in-app 計測系は
  アプリ自身の FPS / メモリのみ、device-info 系は CPU モデルや総 RAM など
  静的なハード情報のみ）。pub の追加に制約はないが、用途に合うものがない
  ため Flutter 標準 `MethodChannel` ＋ ネイティブ標準 API で実装する。
- ADR-0038（Polaris）に準拠。色・余白・角丸は `PolarisTokens` 経由、
  アニメーションは 0ms。
- 既存のネイティブ連携は `roola/trash`（`MainFlutterWindow.swift` /
  `core/system/trash_service.dart`）と `roola/terminal/*`
  （`TerminalPlatformView.swift` / `data/terminal_runner/terminal_channel.dart`）。
  本 change は前者のシンプルな `MethodChannel` パターンを踏襲する。

## Goals / Non-Goals

**Goals:**

- トップバー常駐で CPU / メモリのシステム全体負荷をミニバーで可視化する。
- クリックで上位プロセス一覧（名前・CPU%・メモリ MB）をポップオーバー表示。
- ネイティブ依存を 1 つの薄いクラスに隔離し、ViewModel をテスト可能に保つ。
- Polaris に厳密準拠した見た目。

**Non-Goals:**

- Windows / Linux 対応（ADR-0001 で macOS 専用。将来は OS 分岐で別実装）。
- プロセスの kill・優先度変更などの操作機能（表示のみ）。
- ディスク I/O・ネットワーク・GPU など CPU / メモリ以外の指標。
- 履歴グラフ・スパークライン（現在値のバー表示のみ）。
- メトリクスの永続化（常に揮発・起動ごとに取得）。

## Decisions

### D1. システム全体メトリクスはネイティブ Mach API で取得する

常時 1 秒ポーリングする「システム CPU% / メモリ使用率」は、ネイティブ Swift
側で macOS の Mach / sysctl API を直接呼んで取得する。

- CPU: `host_statistics(HOST_CPU_LOAD_INFO)` の累積 tick（user/system/idle/
  nice）を 2 回分の差分から使用率を算出する。
- メモリ: `host_statistics64(HOST_VM_INFO64)` の `vm_statistics64` と
  `sysctlbyname("hw.memsize")` の総容量から使用率を算出する。

**代替案: 毎秒 `top` / `ps` をサブプロセス起動して標準出力をパース** —
1 秒ごとのプロセス起動はコストが高く、`top -l` は初回サンプルが不正確。
常時ポーリング経路では却下。

### D2. 上位プロセス一覧はクリック時に `ps` をサブプロセス実行して取得する

ポップオーバーを開いた瞬間にネイティブ側で `ps -Aceo pid,pcpu,rss,comm`
（相当）を 1 回実行し、標準出力をパースして返す。並び替え（CPU 降順 /
メモリ降順）と件数制限（上位 N 件）は Dart 側で行う。

- プロセス一覧はクリック時のみ必要で頻度が低く、サブプロセス 1 回起動の
  コストは許容範囲。
- per-process CPU% を Mach API（`proc_pidinfo` の CPU 時間差分）で出すと
  2 サンプル間の状態保持が必要で実装が重い。`ps` の `pcpu` 列で十分。

**代替案: Mach API でプロセス列挙** — 実装が重く、得られる精度に見合わ
ない。却下。

### D3. ネイティブ連携は単一の `MethodChannel` に集約する

`MainFlutterWindow.swift` に `roola/system/metrics` チャネルを 1 つ登録し、
2 メソッドを持たせる:

- `getSystemMetrics` → `{ cpu: Double(0–100), memoryUsed: Int(bytes),
  memoryTotal: Int(bytes) }`
- `getTopProcesses` → 引数なし、`[{ pid: Int, name: String,
  cpu: Double, memoryBytes: Int }]` を返す（並び替え前の生リスト）。

`roola/trash` と同じ素の `MethodChannel` パターン。EventChannel による
push は使わず、Dart 側のタイマー pull に統一する（ポーリング制御を
Dart 側に集約でき、テストも容易）。

### D4. レイヤー構成 — ネイティブ依存は data 層の 1 クラスに隔離する

- `data/activity_metrics/`:
  - `system_metrics.dart` / `process_metrics.dart` — Freezed のイミュータブル
    モデル（表示専用の状態クラスのため DTO 分離はしない）。
  - `system_metrics_repository.dart` — `MethodChannel('roola/system/metrics')`
    を叩く具象クラス。CLAUDE.md の方針どおり interface は作らない（差し替え
    可能性のある箇所ではない）。テストでは Riverpod の provider override で
    fake サブクラスに差し替える。
- `ui/activity_monitor/`:
  - `activity_monitor_view_model.dart` — `Notifier` ベースの ViewModel。
    `Timer.periodic`（1 秒）で `getSystemMetrics` を pull し state を更新。
    `ref.onDispose` でタイマーを破棄。
  - `activity_monitor_bar.dart` — トップバーに置くミニバー 2 連
    （CPU / メモリ）。
  - `activity_monitor_popover.dart` — 上位プロセス一覧のポップオーバー本体。
- Use Case 層は作らない（CLAUDE.md）。並び替え・件数制限のロジックは
  ViewModel に置く。

### D5. ポーリングは 1 秒間隔、ウィンドウ生存中のみ

`Timer.periodic` で 1 秒ごとに `getSystemMetrics` を呼ぶ。負荷計の更新頻度
として一般的で、Mach API 取得は軽量なため常時稼働でも問題ない。バーの値
更新はトゥイーンせず即時反映（ADR-0038 D7 の 0ms 方針）。ViewModel が
`keepAlive` で常駐し、トップバーが存在する限りポーリングする。

### D6. ポップオーバーは body 側のレイヤーに描く

ミニバーをクリックすると、トップバー直下にプロセス一覧パネルを開く。
パネルはトップバー（`AppBar`）ではなく、ワークスペース body の `Stack`
直下に置く `ActivityMonitorPopoverLayer` が描く。ノートパッド（ADR-0036）
と同じ構成。モニタ（`ActivityMonitorBar`）とパネルは別の場所に描かれるが、
開閉状態は `activityPopoverProvider` で共有する。

外側クリックで閉じる透明バリアを body 内に敷く。body はトップバーを含まない
ためバリアがモニタを覆わず、ポップオーバーを開いたまま別モニタをクリック
して切り替えられる（バリアで先に閉じてしまわない）。

当初は `OverlayPortal` ＋ `CompositedTransformFollower` でクリック元へ
アンカーする案だったが、オーバーレイのバリアがトップバー全体を覆い別モニタ
への切り替えクリックを奪う。body レイヤー方式ならバリアの及ぶ範囲が body に
限られ、この問題が構造的に起きない。

パネルは Polaris の面（`bg` 地・1px `line` ボーダー・角丸 `radius`、影なし）。
同じモニタの再クリックまたは外側クリックで閉じる。CPU と メモリの
ポップオーバーは排他（一方を開くと他方は閉じる）。

### D7. 設計判断を ADR-0039 として記録する

ネイティブ連携方式（D1〜D3）・ポーリング間隔（D5）・レイヤー隔離（D4）を
`docs/adr/0039-activity-monitor.md` に 1 件記録する（CLAUDE.md のワーク
フロー 2）。

## Risks / Trade-offs

- **[Mach API の Swift バインディングが冗長]** → `host_statistics` 系は
  Swift から呼ぶとボイラープレートが多い。実装を `SystemMetricsProvider`
  相当の 1 ファイルに閉じ込め、`MainFlutterWindow.swift` 本体は薄く保つ。
- **[CPU% の初回サンプルが不定]** → 差分方式のため初回ポーリングは前回値が
  なく 0% 付近になる。1 秒後の 2 回目以降で正常化する。初回のブレは UI 上
  許容する（ローディング表示でごまかさない）。
- **[`ps` 実行のわずかな遅延]** → ポップオーバーを開いてからリスト確定まで
  数十 ms の空きが出うる。取得中は空のパネル枠を出し、結果到着で即埋める
  （スピナーは出さない / 0ms 方針）。
- **[サンドボックス化した場合の `ps` 実行可否]** → 現状 Roola は App
  Sandbox を有効化していない。将来サンドボックス化する場合、子プロセス
  実行と Mach host port の権限を再検討する必要がある。ADR-0039 に明記する。
- **[マルチウィンドウ（ADR-0012）で各プロセスが個別にポーリング]** →
  別プロセス起動方式のため各ウィンドウが独自にタイマーを持つ。メトリクスは
  システム全体値なので重複取得しても表示は一致し、実害はない。
