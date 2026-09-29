## Why

トップバーのアクティビティモニタ（ADR-0039）は常駐の簡易表示で、CPU / メモリの
ミニバーと上位プロセス一覧しか持たない。重い Skill やビルドを走らせながら負荷の
推移を腰を据えて眺めたい場面では情報量も視認性も足りず、ユーザーは OS 標準の
アクティビティモニタへ切り替えている。ワークスペースのタブとして開ける大型の
「計器盤」を用意し、ひと目で負荷が読める見た目で CPU / メモリ / I/O をまとめて
表示できるようにする。

## What Changes

- ワークスペースに新しいタブ種別 **アクティビティタブ**（`WorkspaceTab.activity`）
  を追加する。システム全体を表示するためワークスペースに同時に 1 つだけとし、
  既に開いていればそのタブをアクティブにする。
- アクティビティタブの開き方を 3 つ用意する: タブストリップの「+」メニュー、
  トップバーのアクティビティモニタのポップオーバー内「タブで開く」、
  コマンドレジストリ（ADR-0033）の新コマンド `openActivityTab`（メニューバー・
  ショートカット割り当て対象）。
- 表示モードを 2 つ持つ。
  - **LEVEL**: 放送用レベルゲージ風の縦 LED バー（40 セグメント・緑/琥珀/赤の
    3 帯・ピークホールド・PPM 風の減衰）
  - **TACHO**: 3 スタイルから選択
    - **CLASSIC**: 針のタコメータ
    - **DIGITAL**: オレンジ蛍光表示管（VFD）風のセグメント円弧
    - **RACE**: GR86 / BRZ の Track Mode 風クラスタ（右肩上がりの CPU バー
      グラフ＋左右パネル＋シフトライト）
- 表示項目:
  - CPU 使用率（既定は全体 1 本。「全コア表示」トグルでコア別を追加表示）
  - メモリ使用率・スワップ使用量
  - ディスク I/O（読み / 書き B/s）
  - ロードアベレージ（1 / 5 / 15 分。macOS のみ）
  - ネットワーク I/O（受信 / 送信 B/s）— **条件付き**。以前の試行（ADR-0048）で
    値を正しく取れなかった経緯があるため、実装の最初に取得方法を検証し、
    正しく取れない場合は本 change から外す
- アクティビティタブを表示している間だけ 250ms 間隔でポーリングし、描画は
  毎フレーム補間してメーターをなめらかに動かす。トップバーは従来どおり 1 秒。
- **このタブに限り Polaris の規定（単一アクセント・アニメーション 0ms）を適用
  しない**。多色の計器色・発光表現・なめらかな針の動き・オープニング演出
  （表示直後に一度フルスケールまで振って戻る）を許可する。
- 表示モード・TACHO スタイル・全コア表示の選択は永続化し、次回も同じ表示で開く。
- ADR を 2 件追加する（アクティビティタブの追加 / このタブにおける Polaris 規定の
  適用除外）。

## Capabilities

### New Capabilities

- `activity-dashboard`: ワークスペースタブとして開く大型アクティビティモニタ。
  タブの開き方と単一インスタンス性、表示項目、LEVEL / TACHO（CLASSIC・DIGITAL・
  RACE）の表示モード、全コア表示、ポーリングと描画の挙動、表示設定の永続化。

### Modified Capabilities

<!-- 既存 activity-monitor（トップバー）の要件は変えない。ポップオーバーへの
     「タブで開く」導線の追加は activity-dashboard 側の要件として扱う。 -->

## Impact

- **ワークスペース**: `lib/data/workspace/workspace_tab.dart` に
  `WorkspaceTab.activity` を追加。`workspace_provider.dart` に
  `openActivityTab`、`pane_widget.dart` / `pane_tab_strip.dart` に表示・アイコン・
  「+」メニュー項目を追加。
- **コマンド**: `lib/data/keybindings/command_id.dart` に `openActivityTab`、
  メニューバー（macOS / Windows）と l10n に項目を追加。
- **data 層**: `lib/data/activity_metrics/` に拡張スナップショットのモデルと
  取得メソッドを追加。表示設定の永続化（DTO 分離あり）を追加。
- **UI 層**: 新規ディレクトリ `lib/ui/activity_dashboard/` に ViewModel と
  メーター描画（`CustomPainter`）一式。
- **ネイティブ**: `macos/Runner/MainFlutterWindow.swift` と
  `windows/runner/roola_channels.cpp` の `roola/system/metrics` に拡張メソッドを
  追加（コア別 CPU・スワップ・ディスク I/O・ロードアベレージ・ネットワーク）。
- **フォント**: 数値表示用のコンデンス書体を同梱する可能性がある（design で判断）。
- **ドキュメント**: ADR 2 件、`docs/design-system.md` に適用除外の注記、
  CLAUDE.md の主要 ADR 一覧を更新。
- 外部 pub パッケージの追加はない（描画は Flutter 標準の `CustomPainter`）。
