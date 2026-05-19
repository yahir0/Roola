# 実装タスク: adopt-polaris-design-system

> 視覚リファレンスは `lib/dev/cockpit_preview.dart`（第 17 稿）。判断理由は
> `design.md`、要件は `specs/polaris-design-system/spec.md` を参照。
> 各タスク完了後に `flutter analyze` を通すこと。
>
> **重要な前提: Polaris は視覚層の方針であり、適用にあたり Roola の既存
> レイアウト（画面構成・タブ/ペイン/サイドバーの配置・ナビゲーション構造・
> 各画面内のウィジェット配置）は一切変更しない。** 下記タスクはすべて、既存
> 構造の上での視覚スタイルの差し替えに限る。

## 1. 設計記録（ADR・ドキュメント）

- [x] 1.1 `docs/adr/0038-polaris-design-system.md` を作成し、Polaris の思想
      （機能主義）・トークン構成・主要な決定（D1〜D13）とその理由を記録する
- [x] 1.2 `docs/adr/0020-*.md` の Status を `Superseded by ADR-0038` に更新する
- [x] 1.3 `docs/architecture.md` と `CLAUDE.md` のテーマ・規約サマリの記述を
      Polaris（ダーク専用・トークン構成）に合わせて更新する

## 2. デザイントークン基盤

- [x] 2.1 `PolarisTokens`（`ThemeExtension`）を定義する — 色（`well` / `bg` /
      `topEdge` / `surface` / `surfaceHi` / `line` / `text` / `textDim` /
      `textFaint` / `accent` / 信号色）、角丸 `radius`（2px）、グリッド単位
      （4px）、テキストスタイル群
- [x] 2.2 Git「変更」状態の信号色を、アクセントのゴールド `#D0A341` と明確に
      区別できる色に確定し、`PolarisTokens` の信号色（新規 / 変更 /
      コンフリクト）として定義する
- [x] 2.3 `lib/app/theme.dart` をダーク専用の `ThemeData` ビルダーへ全面置換
      する — `NoSplash`、ボタン等の `animationDuration: Duration.zero`、
      ページ遷移を即時化する `PageTransitionsBuilder`、各 component theme を
      R=2px・elevation 0 に
- [x] 2.4 `LogoTheme` を廃止（または `PolarisTokens` へ吸収）し、参照している
      全箇所を `PolarisTokens` 参照へ置換する
- [x] 2.5 オーバースクロールのグロー・慣性・バウンスを排除する `ScrollBehavior`
      （`ClampingScrollPhysics`）を定義し、`MaterialApp` へ適用する

## 3. 共通 UI 部品

- [x] 3.1 フォルダ／ファイル等の型アイコンを `CustomPaint` の幾何学モノライン
      として実装し、共通ウィジェット化する
- [x] 3.2 「ベゼルに嵌った表示灯」型の状態インジケーター（同心円のリング＋
      コア）を共通ウィジェット化する
- [x] 3.3 「計器ディスプレイパネル」（筐体からインセット＋R=2px＋1px ボーダー＋
      `well` トーン）の共通ラッパを用意する

## 4. ウィンドウ統合

- [x] 4.1 `window_manager` で macOS タイトルバーを非表示化する
      （`TitleBarStyle.hidden`）— `main.dart` で既に適用済み
- [x] 4.2 自前トップバーを `DragToMoveArea` 化し、信号機ボタン用の左端領域を
      確保する — `MacosWindowAppBar` で既に適用済み（80px 確保）

## 5. コンポーネント移行（`lib/ui/` 配下）

- [x] 5.1 explorer 系（`explorer_node_tile` / `explorer_sidebar` /
      `explorer_path_bar` / `explorer_tab_body` 等）を `PolarisTokens` 参照へ
      移行し、選択モデル（主選択のみフルアクセント点灯＋複数選択は控えめな
      塗り）を適用する — `ExplorerSelection` で複数選択（⌘+クリック）対応・
      モノラインアイコン・主選択 2px バーを実装
- [x] 5.2 workspace 系（`workspace_page` / `pane_widget` / `pane_tab_strip` /
      `workspace_split` 等）を移行する — ハードコード色なし。トークン化された
      `ColorScheme` 経由で Polaris 配色を適用
- [x] 5.3 git 系（`git_tab` / `git_changes_section` / `git_history_section` /
      `git_diff_view` 等）を移行し、Git 信号色を適用する — `gitChangeColor` /
      diff 配色 / グラフレーン / ref チップをトークン化
- [x] 5.4 launchers 系・run 系を移行する — ハードコード色なし。トークン経由で適用
- [x] 5.5 notepad 系を移行する — フローティングパネルの elevation/角丸を Polaris に
- [x] 5.6 settings 系を移行する。ライト/ダーク切替の UI が存在すれば撤去する
      （ダーク専用化）— 切替 UI は元から存在せず。外観プリセット色を Polaris に更新
- [x] 5.7 common 系（`macos_window_app_bar` / 各 dialog / アイコン類等）を
      移行する — `session_state_icon` を信号色トークン化
- [x] 5.8 app 系（`app` / `router` / `app_menu_bar` 等）の色・画面遷移表現を
      移行する — 画面遷移は `_InstantPageTransitionsBuilder` で即時化済み

## 6. 仕上げ・検証

- [x] 6.1 ハードコードされた色（`Color(0x...)`）・`BorderRadius`・余白の
      マジックナンバーを `lib/` 全体で洗い出し、残りを `PolarisTokens` 参照へ
      解消する — 残存は `theme.dart`（トークン定義）と外観プリセット色
      （色を選ばせる「データ」）のみ。角丸の非 2px 値（4 / 8）を修正
- [x] 6.2 ファイル一覧のタイル密度切替（ADR-0024）と、プレビューの DENSE/ULTRA
      の関係を整理し、密度の扱いを確定する — 製品は ADR-0024 の compact /
      comfortable を維持。プレビューの DENSE/ULTRA・PERM 列は検証用トグルで
      あり製品機能には採用しない（プレビュー破棄と同時に廃棄）
- [x] 6.3 `flutter analyze` と `dart format` をパスさせる
- [x] 6.4 既存のウィジェット/ユニットテストを Polaris に合わせて更新し、
      テストを実行してパスさせる — `git_tab_test` のテストハーネスに Polaris
      テーマを注入。全 233 件パス
- [x] 6.5 検討用プレビュー `lib/dev/cockpit_preview.dart` を破棄する
- [ ] 6.6 実機（macOS）で起動し、第 17 稿プレビューと見比べて視覚を確認する
      — GUI 実機確認のためユーザーによる実施が必要

## 7. 実装後のデザイン詰め（archive 前の継続作業）

> 1〜6 の実装完了後、実機で見ながら視覚を詰める中で確定した改定。本 change は
> まだ archive しない（デザインを継続的に詰めるため）。下記は完了済みだが、
> 「2px」等の旧記述がタスク 2.1 / 3.3 / 5.1 / 6.1 の文面に残っている点に注意
> （最終値は spec.md / design.md / ADR-0038 を正とする）。

- [x] 7.1 アクセントをゴールド固定からユーザー切替式へ（ゴールド既定 ＋
      アイスブルー `#48C9DE`）。`PolarisAccent` enum・`appearance` 設定・
      `AppTheme.polaris(accent:)` を追加。ADR-0038 D4 を改定
- [x] 7.2 ダイアログの「Flutter 感」を排除。`PolarisDialog`（ヘッダ帯＋1px 継ぎ目
      ＋本文＋アクション帯）を新設し、全 `AlertDialog` を撤去。確認/入力は
      `showPolarisConfirm` / `showPolarisPrompt` に統一
- [x] 7.3 テキストウェイトを w600 から w500（medium）へ。小サイズ＋太字の
      「丸文字感」を解消。ADR-0038 D9 を改定
- [x] 7.4 角丸を R=2px から R=4px へ。2px が大パネルで直角に見えたため。
      `BorderRadius.circular(2)` のハードコードを全廃し `PolarisTokens.radius`
      に集約。ADR-0038 D6 を改定
- [x] 7.6 外観機能（背景）を Polaris と整合させる。Polaris と相反する 単色 /
      画像 / グラデーションモードを廃止し、`opaque` / `transparent` の 2 択へ
      整理。`_AppearanceLayer` が常に不透明グラファイトの基底層を敷くよう修正
      （ターミナル・設定画面が透明な穴になる不具合を解消）、透過は UI 全体を
      `Opacity` で一括半透明合成する。ADR-0038 D14 を追加
- [ ] 7.5 デザインの継続的な詰め（実機で見ながら調整）。完了し満足したら
      本 change を `/opsx:archive` でアーカイブする
