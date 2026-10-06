## Context

トップバーのアクティビティモニタ（ADR-0039）は CPU / メモリのミニバーと、
クリックで開く上位プロセス一覧だけを持つ常駐の簡易表示である。本 change は
これとは別に、ワークスペースのタブとして開く大型の「計器盤」を追加する。

現状の前提:

- ワークスペースは 3 ペインスロット × タブ群（ADR-0026）。タブ種別は
  `WorkspaceTab` の sealed union（explorer / terminal / git / notepad）で、
  per-tab 状態は `family(tabId)`（ADR-0027）。レイアウトは永続化しない
  （ADR-0042）。
- メトリクス取得は `roola/system/metrics` の `MethodChannel`
  （macOS: `SystemMetricsProvider`（Swift）、Windows: `roola_channels.cpp`）。
  CPU はネイティブ側が **前回 tick を保持して差分を返す** ステートフル実装で、
  呼び出し元が 1 つ（トップバーの 1 秒ポーリング）である前提になっている。
- ディスク / ネットワーク I/O は ADR-0048 で一度提案・実装したが、値を正しく
  取れず不採用にした。当時のコードはリポジトリに残っていない。
- Polaris（ADR-0038）は単一アクセント・アニメーション 0ms を MUST とする。
  本機能ではユーザーの判断でこれを適用しない（ADR を追加）。
- 見た目はデザインモックで合意済み。モックの HTML は `mock/meters.html`
  （ブラウザで開くと模擬データで動く）。

## Goals / Non-Goals

**Goals:**

- ワークスペースタブとして開く大型アクティビティモニタ（単一インスタンス）。
- LEVEL / TACHO（CLASSIC・DIGITAL・RACE）の 4 通りの描画を、モックの見た目と
  動きのまま Flutter で再現する。
- 針・バーを 60fps でなめらかに動かす（ばね＋ダンパ追従・PPM 風バリスティクス）。
- CPU（全体 / コア別）・メモリ・スワップ・ディスク I/O・ロードアベレージ・
  ネットワーク I/O（検証次第）を macOS と Windows で取得する。
- トップバーのモニタの挙動と精度に影響を与えない。

**Non-Goals:**

- プロセス一覧・プロセス操作（トップバーのポップオーバーが担う）。
- プロセス別の I/O（ADR-0048 で重いと判断した `nettop` / `proc_pid_rusage`
  経路は使わない）。
- 履歴グラフ（時系列チャート）。ピークホールド以上の履歴は持たない。
- 温度・ファン・GPU・バッテリー・ディスク空き容量（後続で追加可能な形にはする）。
- Roola で起動したセッション別の負荷集計（後続候補）。
- タブ配置やモードごとのレイアウトのカスタマイズ。

## Decisions

### D1. タブ種別 `WorkspaceTab.activity` を追加し、ワークスペースに 1 つだけ置く

`WorkspaceTab.activity({required String id})` を追加する。表示内容はシステム
全体の値で、2 つ開いても同じものが映るだけなので単一インスタンスにする。
`Workspace.openActivityTab()` は既存があればアクティブ化し、無ければ
**右上ペイン**（`PaneSlotId.topRight`、`openGitTab` と同じ）に追加する。
per-tab 状態は持たない（ViewModel はグローバル、D4）ので `_disposeTab` での
破棄は不要。レイアウトは永続化しないため DTO 変更もない（ADR-0042）。

代替案: 複数タブを許可し、タブごとに別モードで表示する — 需要が薄く、
ポーリングと状態の多重化を招くため却下。

### D2. 開き方は「+」メニュー・ポップオーバー・コマンドの 3 経路

- タブストリップ「+」メニューに「アクティビティモニタ」を追加（`_AddTabKind`）。
  このときは押したペインのスロットに追加する（既存があればそちらをアクティブ化）。
- トップバーのポップオーバー（CPU / メモリ）のフッタに「タブで開く」を追加。
- `CommandId.openActivityTab` を追加し、メニューバー（macOS ネイティブ /
  Windows トップメニュー）と設定のキー割り当て画面に載せる（ADR-0033）。
  コマンドレジストリは既定キーを必須とするため、空いている ⌘⇧A（Windows は
  Ctrl+Shift+A）を割り当てる（⌘A は ADR-0035 でテキスト編集用に予約済み）。

### D3. ネイティブは「累積カウンタのスナップショット」を返し、差分は Dart で計算する

`roola/system/metrics` に `getSystemSnapshot` を追加する。ネイティブ側は
**状態を持たず**、その時点の累積値だけを返す:

| キー | macOS | Windows |
|---|---|---|
| `cpuTicks`: コアごとの `[user, system, idle, nice]` 累積 tick | `host_processor_info(PROCESSOR_CPU_LOAD_INFO)` | `NtQuerySystemInformation(SystemProcessorPerformanceInformation)` |
| `memoryUsed` / `memoryTotal` | 既存と同じ（active + wired + compressed / `hw.memsize`） | 既存と同じ（`GlobalMemoryStatusEx`） |
| `swapUsed` / `swapTotal` | `sysctl vm.swapusage` | `GlobalMemoryStatusEx`（ページファイル − 物理） |
| `diskReadBytes` / `diskWriteBytes`（累積） | IOKit `IOBlockStorageDriver` の Statistics 合計 | PDH `\PhysicalDisk(_Total)\Disk Read/Write Bytes`（またはIOCTL_DISK_PERFORMANCE） |
| `netRxBytes` / `netTxBytes`（累積） | 検証後に決定（D8） | 検証後に決定（D8） |
| `loadAverage`: `[1m, 5m, 15m]` | `getloadavg` | なし（キーを返さない） |

Dart 側の ViewModel が前回スナップショットとの差分から CPU 使用率（全体・コア別）
と I/O レート（B/s）を算出する。取れない項目はキー自体を返さず、UI はその
メーターを出さない（Windows のロードアベレージなど）。

理由: 既存 `getSystemMetrics` の CPU 差分はネイティブ側に 1 つだけ前回値を持つ。
タブ（250ms）とトップバー（1 秒）が同じ経路を叩くと、互いの呼び出しが差分の
区間を横取りして両方の値が歪む。累積値だけを返せば呼び出し元ごとに独立して
差分を取れ、ネイティブ側も単純になる。既存 `getSystemMetrics` は変更しない。

代替案: 既存メソッドに項目を足し、ポーリング元を 1 本に統合する — トップバーの
間隔と精度に影響が出るため却下。

### D4. ViewModel はグローバルな autoDispose Notifier、表示中だけ 250ms でポーリング

`ActivityDashboardViewModel`（`Notifier`、autoDispose）を
`lib/ui/activity_dashboard/` に置く。タブ body が `ref.watch` している間だけ
生存し、`Timer.periodic(250ms)` で `getSystemSnapshot` を pull する。

ペインの非アクティブタブは `IndexedStack` で mount されたまま残る（`pane_widget`）
ため、mount の有無ではポーリングを止められない。タブ body は
`workspaceProvider.select` で「自タブが所属スロットのアクティブタブか」を監視し、
アクティブな間だけ ViewModel を `ref.watch` する。非アクティブになると watch が
外れて autoDispose でタイマーごと破棄され、再アクティブ化で作り直される（前回
スナップショットが無いので最初の 250ms は差分が出ず、CPU と I/O のメーターは
0 から立ち上がる）。Ticker は `IndexedStack` が非表示子の `TickerMode` を切るため
自動で止まる。

state（Freezed、表示専用のため DTO 分離なし）は「最新のサンプル値」のみを持つ:
CPU 全体 / コア別（0–1）、メモリ / スワップ使用率と容量、ディスク / ネットワークの
B/s、ロードアベレージ、項目ごとの取得可否。前回スナップショットは ViewModel の
フィールドに保持する。取得失敗時は直近値を維持する（ADR-0039 D5 と同じ）。

250ms の理由: 1 秒だと数値の変化が段差として見え、補間しても「遅れて追う」感じが
強い。250ms なら補間との組み合わせで針が実機らしく追従する。取得は Mach /
Win32 の軽量 API だけなので負荷は小さい。

### D5. アニメーションはウィジェット側の Ticker で、サンプル間を物理モデルで補間する

ViewModel は 250ms ごとの「目標値」だけを出し、なめらかな動きは描画側で作る。
メーター群を包む `MeterAnimator`（`useSingleTickerProvider` 相当の Ticker を
持つ `HookWidget`）が毎フレーム dt を計算し、各チャンネルの表示値を更新して
`CustomPainter` に渡す。

- **針・円弧（TACHO 全スタイル）**: ばね＋ダンパ（k = 90、減衰比 0.7）。
  少しだけ行き過ぎて戻る。dt は 1/240 秒に刻んで積分し、フレーム落ちでも安定させる。
- **LEVEL のバー**: 上昇は時定数 50ms の指数追従、下降は毎秒 60% ぶんの直線減衰
  （PPM 風）。**ピークホールド** は 1.5 秒保持してから毎秒 35% で落下。
  RACE のセグメントも同じピーク処理を使う。
- **オープニング演出**: TACHO に切り替えた直後・スタイル変更直後の 0.55 秒は
  目標値を 1.0（フルスケール）にし、その後実値に戻す。
- `MediaQuery.disableAnimations` が真のときは補間せず目標値へ即時スナップする。

物理モデルは純粋関数（`SpringState step(SpringState, double target, double dt)`
など）として `lib/ui/activity_dashboard/meter_physics.dart` に置き、ユニットテスト
で挙動を固定する。

代替案: `AnimationController` + `Tween` で 250ms ごとにトゥイーン — 目標値が
途中で変わるたびにカーブが途切れ、針の慣性が表現できないため却下。

### D6. 描画は全て `CustomPainter`、モードごとに 1 つずつ

- `LevelMeterPainter`: 1 グループ（CPU / MEMORY / NETWORK / DISK / LOAD）ぶんの
  目盛り＋縦 LED チャンネル群。40 セグメント、緑（〜70%）/ 琥珀（〜90%）/
  赤の 3 帯、消灯セグメントは同色 9% 不透明度、点灯は発光（`MaskFilter.blur`）。
  I/O は 1 KB/s〜1 GB/s の対数目盛り、LOAD はコア数を満点とする。
- `ClassicDialPainter` / `DigitalDialPainter`: 270° スイープの円形メーター。
  CPU / メモリは 0–10（×10 %）目盛り、I/O は対数目盛り、LOAD はコア数満点。
  レッドゾーンは 85% 以上（I/O は 84%、LOAD は 80%）。DIGITAL は VFD オレンジ
  （#FF8A1F）のセグメント円弧で、消灯セグメントもうっすら描き、通過した目盛りと
  数字だけ点灯させる。
- `RaceClusterPainter`: Track Mode 風クラスタを 1 枚で描く。中央に右肩上がりの
  CPU バーグラフ（0–4 を全幅の 18% に詰めた非線形目盛り、7 から橙・8.5 から赤）、
  左にメモリ / スワップの横バー、右にロードアベレージ・時刻と I/O のブロック
  ゲージ、下に大きな CPU 数値、中央の円の縁取りと左右へ
  伸びる水平線。最小幅 720px を下回る場合は横スクロールにする。
- シフトライト（RACE のみ）: 12 灯、50% から点き始め、95% 超で全灯 70ms 点滅。
- 全コア表示: LEVEL は CPU グループをコア数ぶんのチャンネルに、CLASSIC /
  DIGITAL はコア別の小メーターのグリッドを追加、RACE はコア別の小さな右肩上がり
  バーグラフのグリッドを追加する。

色は本機能専用のトークンクラス `ActivityMeterPalette`（`ThemeExtension`）に
まとめる（LED 3 色・VFD オレンジ・レッドゾーン・文字盤・目盛り色など）。Polaris の
`PolarisTokens` には入れない。コンポーネントへの直書きは避け、このパレット経由に
することで Polaris の「ハードコード禁止」の精神は保つ。タブ外枠（ヘッダ・
ツールバー・ベゼル）は Polaris のまま。

### D7. 表示設定は永続化し、DTO を分離する

表示モード（`level` / `tacho`）、TACHO スタイル（`classic` / `digital` / `race`）、
全コア表示（bool）を `ActivityDashboardSettings`（Freezed）として保存する。
永続化を伴うので DTO（json_serializable）を分離する（CLAUDE.md の規約）。保存先・
Repository は既存 `AppearanceSettings` と同じパターン（interface + impl、
`core/storage`）に揃える。既定値は LEVEL / CLASSIC / 全コア表示オフ。

### D8. ネットワーク I/O は実装の最初に検証し、結果で採否を決める

ADR-0048 で値を正しく取れなかった原因の記録がないため、タスクの先頭で検証を行う:

1. macOS: `getifaddrs` の `AF_LINK` / `if_data`（`ifi_ibytes` / `ifi_obytes`）と、
   `sysctl(NET_RT_IFLIST2)` の `if_data64` を比較する。`if_data` は 32bit で
   4GB でラップアラウンドするため、差分がマイナスや巨大値になるのが原因の候補。
   `if_data64` を使い、ループバック（`lo0`）と仮想 IF（`utun*` / `awdl*` /
   `bridge*` 等）の扱いを決める。
2. Windows: `GetIfTable2` の `InOctets` / `OutOctets`（64bit）で、
   物理 / 仮想アダプタのフィルタを決める。
3. 大きめのファイルのダウンロード・アップロード中に、OS 標準のモニタ
   （アクティビティモニタ.app / タスクマネージャ）と値が桁レベルで一致するか確認する。

一致すればネットワークを表示項目に含める。一致しなければネットワークの
メーター・キーを本 change から外し、原因を ADR に追記する。カウンタが減った
（ラップ・IF 消滅）区間はレート 0 として扱う（D3 の差分計算で共通処理）。

**検証結果（macOS 26 / 2026-09-29）: 採用**

- `getifaddrs`（`if_data`・32bit）と `sysctl(NET_RT_IFLIST2)`（`if_data64`）は
  **同じ値** を返し、どちらも **32bit で一周した値** だった（en0 受信: 取得値
  3,029,959,680 に対し `netstat -ib` は 20,209,830,563 ≒ 4×2³² + 取得値）。
  さらに値は **1 KiB 単位に丸められて** いる。サードパーティのプロセスには
  加工済みのカウンタが渡され、`netstat` だけが生の値を得ていると考えられる。
- 250ms〜0.7 秒間隔の差分を **インターフェイスごとに 2³² を法として** 取ると、
  `netstat -ib` から求めたレートと丸め誤差の範囲で一致した。
- VPN 利用中は同じ通信がトンネル（`utun*`）と物理 IF（`en0`）の両方に載るため、
  合計には **`en*` だけ** を使う（`lo0` / `utun*` / `awdl*` / `llw*` / `bridge*` /
  `gif*` / `stf*` / `anpi*` / `ap*` は除外）。
- ADR-0048 で値が正しく取れなかったのは、合計値の差分（一周で負になる）と
  VPN の二重計上が原因だった可能性が高い。
- 実装: ネイティブは `en*` の IF ごとに `{name, rx, tx}` を返し、Dart 側で IF ごとに
  2³² 剰余の差分を取ってから合計する。前回に無い IF は差分 0 とする。

### D9. 書体はコンデンス数字書体とラベル書体を同梱する

モックの数値は Barlow Condensed、ラベルは Chakra Petch（いずれも SIL OFL）。
計器らしさの大半は書体に依るため、両書体を `assets/fonts/` に同梱し、ライセンス
全文を `assets/licenses/` に追加して `LicenseRegistry` へ登録する（ADR-0040）。
容量は各数百 KB 程度で、Sarasa Term J（ADR-0017）に比べ小さい。使用はこの
タブの描画に限る。

## Risks / Trade-offs

- [CustomPainter を毎フレーム再描画する CPU 負荷] → 再描画はタブ表示中のみ。
  メーター群ごとに `RepaintBoundary` を分け、`shouldRepaint` は表示値が変わった
  ときだけ真にする。発光（blur）は点灯セグメントに限定する。プロファイルで
  1 フレーム 4ms を超えるなら、LED の消灯面をキャッシュした `Picture` に分ける。
- [自身の描画負荷が CPU メーターに乗る（観測者効果）] → 上記の軽量化で抑える。
  完全には避けられないことを ADR に明記する。
- [コア別 CPU の Windows 実装が `NtQuerySystemInformation`（半公開 API）に依存]
  → 取得失敗時はコア別キーを返さず、全コア表示トグルを無効化する。代替に PDH
  `\Processor(*)\% Processor Time` を検討できる。
- [ディスク I/O の IOKit 列挙が外付けディスクの着脱で変わる] → 毎回列挙して
  合計し、合計が減った区間はレート 0 とする（D8 と同じ処理）。
- [Polaris 適用除外がアプリ全体に広がる] → ADR と `docs/design-system.md` に
  「アクティビティタブの内側のみ」と範囲を明記し、`ActivityMeterPalette` を
  他所から参照しない。
- [ネットワークが結局取れない] → D8 の手順で早期に判定し、取れなければ外して
  他の項目だけで出荷する。

## Migration Plan

新規機能の追加のみ。既存データの移行はない。表示設定は新規キーで保存し、未保存
なら既定値を使う。ロールバックはタブ種別・コマンド・ネイティブメソッドの削除で
完結する（トップバーの経路には触れない）。

## Open Questions

- ネットワーク I/O を含めるか（D8 の検証結果で決定）。
- RACE の左下 UPTIME（起動からの経過時間）の取得方法: macOS は
  `sysctl kern.boottime`、Windows は `GetTickCount64`。スナップショットに含めるか、
  表示を省くか（実装時に判断。モックでは固定文字列）。
- DIGITAL / CLASSIC の小メーター群を狭いペインでどう折り返すか（モックは
  グリッドの自動折り返し。実機のペイン幅で確認して調整する）。
