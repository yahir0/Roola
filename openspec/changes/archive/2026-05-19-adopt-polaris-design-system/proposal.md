# adopt-polaris-design-system

## Why

Roola は現在 Flutter Material 3 のデフォルトに ADR-0020 の Win10/11 風フラットテーマを乗せた構成だが、ユーザーから「Flutter（Material Design）のモバイル感・Android 感を完全に排除したい」「ADR-0020 の Win11 フラットでも Flutter らしすぎる」という要望があり、ユーザーとの長い対話（検討用プレビューを 17 回反復）を経て、独自のデザインシステムへ全面転換する方針が固まった。

新しいデザインシステムは **Polaris** と名付ける。思想は **機能主義（functionalism）** — ディーター・ラムス → ジョナサン・アイブの系譜で、装飾を排し、機能・精密さ・情報密度で形を決める。「Polaris＝移動の導きの星」はアプリ名 Roola（移動呪文ルーラ）と呼応する。**思想が不変、ビジュアルは思想からの導出物**（機能が優先ならビジュアルは差し替え可）という位置づけで、名前自体がその構造（不動の基準星）を表す。

## What Changes

> **前提（方針）**: 今回定めた Polaris は、あくまで**視覚層のデザイン方針**
> である。その適用にあたり、Roola の**既存レイアウト**（画面構成・タブ/ペイン/
> サイドバーの配置・ナビゲーション構造・各画面内のウィジェット配置）は**一切
> 変更しない**。下記の変更はすべて、既存の構造の上で視覚スタイルを差し替える
> ものである。

- **BREAKING**: `lib/app/theme.dart` の `AppTheme` / `LogoTheme` を、Polaris のデザイントークン（`PolarisTokens` ThemeExtension）ベースへ全面置換する。色・角丸・密度・フォント・コンポーネントテーマがすべて変わる。
- **BREAKING**: ライト/ダークの 2 テーマ構成をやめ、**ダーク専用**にする。
- 地を「グラファイト 2 トーン階層」（`well`＝沈んだ計器ディスプレイ ＜ `bg`＝筐体の枠）にし、影を使わずトーン差と 1px ラインだけで面を分ける。
- アクセントを単一色運用（同時併用なし）にし、選択・現在地・フォルダに限定使用する。アクセント色はゴールド `#D0A341`（デフォルト）とアイスブルー `#48C9DE` をユーザー設定で切替可能とする。
- 信号色（green=新規 / amber=変更 / red=コンフリクト）を Git 状態表示で意味専用に使う。
- 角を機械加工 R=4px に統一（`PolarisTokens.radius` の単一トークンで統制）、全寸法を 4px グリッドに乗せる、アニメーションを 0ms にする。
- macOS タイトルバーを隠し、自前トップバーに統合する（`window_manager`）。
- アイコンを幾何学モノラインの自作描画にする。状態表示を「ベゼルに嵌った表示灯」型インジケーターにする。
- ファイル一覧の選択モデルを「主選択 1 つだけフルアクセント点灯 ＋ 複数選択は控えめな塗り」にする。
- 設計判断として **ADR-0038** を新規追加し、**ADR-0020 を `Superseded` にする**。
- 検討用プレビュー `lib/dev/cockpit_preview.dart` は実装反映後に破棄する。
- 背景の「外観」機能を Polaris と整合させ、**透過 / 不透明の 2 モード**に整理する（Polaris と相反する 単色 / 画像 / グラデーションを廃止 / ADR-0038 D14）。

## Capabilities

### New Capabilities
- `polaris-design-system`: Polaris デザインシステムの要件 — デザイントークン（`PolarisTokens`）、テーマ構成（ダーク専用・グラファイト 2 トーン・単一アクセント〔ゴールド／アイスブルー切替〕・信号色）、視覚ルール（R=4px・4px グリッド・アニメーション 0ms・モノラインアイコン・表示灯インジケーター）、ウィンドウ統合（タイトルバー非表示）、タイポグラフィ方針を規定する。

### Modified Capabilities
<!-- なし。Polaris は既存 spec の要件変更でなく新規 capability。ADR-0020 は OpenSpec spec ではなく ADR なので、ここではなく ADR-0038 で Superseded にする。 -->

## Impact

- **テーマ基盤**: `lib/app/theme.dart`（全面書き換え）。`AppTheme.light()/dark()` / `LogoTheme` の API が変わるため、これらを参照する全箇所に影響。
- **UI コンポーネント**: `lib/ui/` 配下全般 — explorer 系（`explorer_node_tile.dart` / `explorer_sidebar.dart` / `explorer_path_bar.dart` 等）、workspace 系、git 系、settings 系、common 系。ハードコードされた色・角丸・余白を Polaris トークン参照へ置換。
- **ウィンドウ**: macOS タイトルバー統合（`window_manager` の利用拡張）。`lib/app/` の起動系・`macos/` 側設定に影響しうる。
- **ドキュメント**: `docs/adr/0038-*.md` 新規、`docs/adr/0020-*.md` を Superseded 化、`docs/architecture.md` / `CLAUDE.md` のテーマ関連記述の更新。
- **依存**: 既存依存（`window_manager` 等）の範囲内。新規パッケージ追加は想定しない（フォントは macOS 同梱の SF Pro / SF Mono、日本語は Hiragino フォールバック）。
- **設計リファレンス**: `lib/dev/cockpit_preview.dart`（第 17 稿）が Polaris の最終形を示す実動プレビュー。実装はこれを基準にする。
