# ADR-0020: UI を Win10/11 風フラット実用テーマに転換する

- **Status**: Superseded by ADR-0038
- **Date**: 2026-05-14

> **Superseded**: 本 ADR の Win10/11 風フラットテーマは ADR-0038（Polaris
> デザインシステム）により全面置換された。ライト/ダーク 2 テーマ・Material
> `ColorScheme` ベースの構成は廃止され、ダーク専用の `PolarisTokens` ベースへ
> 移行している。角丸 2px・elevation 0・ink ripple 抑制という方向性は Polaris に
> 引き継がれているが、本 ADR の記述は歴史的経緯としてのみ参照すること。

## Context

これまでの Roola は Flutter Material 3 のデフォルトに、ロゴ由来の gunmetal + sky-blue パレットを乗せた
構成だった。Material 3 のデフォルトは丸み（角丸 12-16px）・soft shadow・ripple アニメーション・余白の
広いコントロールが特徴で、いわゆる「Flutter らしい柔らかい UI」になる。

ユーザーから「Flutter らしさが強すぎる。Win10 のブラウザや Win7 / XP、昔のオンラインゲームのような
**実用的で柔らかさのない UI** にしたい」というフィードバックが入った。

## Decision

**Win10/11 のシステムコントロールに近い、フラットで実用的なテーマに転換する。**

### 採用する Visual ルール

| 要素 | 旧（Material 3 デフォルト） | 新（Win11 フラット） |
|---|---|---|
| 角丸 | 12-16px | **2px**（[`AppTheme._radius`]） |
| 立体感 | drop shadow / elevation 1-3 | **elevation 0**、区切りは 1px ボーダー |
| クリック反応 | ink ripple アニメ | **NoSplash**、背景色トーン変化のみ |
| ホバー | overlay 8-12% | **`surfaceContainerHigh` 60%** の薄いハイライト |
| 密度 | standard / adaptive | **`VisualDensity.compact`** |
| Light テーマ背景 | seed 由来の薄ブルーティント | **#F3F3F3 ニュートラル**（Win11 セルフ準拠） |
| Dark テーマ背景 | gunmetal（ロゴ由来）* | gunmetal を維持 |
| アクセント色 | ロゴブルー | ロゴブルー（変更なし） |

*Dark テーマは透過背景前提なので、ロゴパレットを維持する。Light だけがニュートラルグレーに移行。

### 角丸 2px を選んだ理由

- 完全な 0px だとドット交差や描画エッジでジャギーが目立つ
- 2px なら Win11 のボタン・カードと同等で、フラット感を維持しつつ角の描画品質が安定する
- 2px は **`AppTheme._radius`** 定数として一元管理し、各 component theme + ハードコード箇所
  すべてをそこに合わせる

### Light パレット刷新

旧 Light は `ColorScheme.fromSeed(_logoBlue)` の結果をそのまま使っていたため、surface 全体が
うっすらブルーに染まる Material 3 らしい見た目だった。これを Win11 のニュートラルグレー
（`#F3F3F3` 背景 / `#FAFAFA` surface / `#E2E2E2` container high など）に置換。Dark テーマは
ロゴ由来 gunmetal をそのまま維持して、透過 backdrop（壁紙）と馴染ませる。

アクセント色（primary）は両テーマで `_logoBlue` を維持し、選択 / focus / cursor 等の機能色として
ブランド色を残す。

### コンポーネント別 shape 上書き

`ThemeData` 段階で以下すべてに 2px 角を適用:

- `cardTheme`, `dialogTheme`, `popupMenuTheme`, `menuTheme`, `dropdownMenuTheme`, `tooltipTheme`
- `filledButtonTheme`, `elevatedButtonTheme`, `outlinedButtonTheme`, `textButtonTheme`
- `segmentedButtonTheme`, `chipTheme`
- `inputDecorationTheme`（OutlineInputBorder）

ハードコードされていた `BorderRadius.circular(6 / 8 / 12)` は全箇所 2px に置換（`appearance_section`,
`explorer_sidebar`, `explorer_path_bar`, `launcher_management_page`, `entry_edit_page`）。

### Ink ripple 抑制

`ThemeData.splashFactory = NoSplash.splashFactory` で `InkWell` の ripple アニメーションを全廃。
クリック反応は背景色トーンの瞬間切替のみで、Win10 のような静的応答にする。`highlightColor` も
透明にして長押しの濃い overlay も消す。

## Why

「Flutter らしさ」の正体は、Material 3 のデフォルトが持つ次の要素:

1. 強めの角丸（12-16px）でカード・ボタンに「柔らかい・親しみやすい」印象を与える
2. surfaceTint と elevation で「浮いている」感を出す
3. ink ripple で操作に「弾力」を持たせる
4. 余白の広いコントロールで余裕を持たせる

これらは「人間優しいモバイル UI」としては正しいが、Roola は **ターミナルランチャー = 開発ツール**
であり、ユーザーが期待するのは「即応的・密度の高い・装飾の少ない」UI。Win10/11 のシステム
コントロールはちょうどこの帯にいる（Win7/XP よりさらに削った現代版）。

### 代替案 1: Win7/XP クラシック（ベベル付き）

ベベル（inset/outset）の 3D 表現、グラデーション、深いグレー + 青アクセント。RuneScape / 旧
Diablo / 旧 Windows のような風合い。実装に CustomPaint や複雑な BoxDecoration の手書きが必要で
高コスト。Flutter 標準ウィジェットとの噛み合わせも悪い。

却下: 表現としては魅力的だが、現実的な工数と Flutter エコシステムとの相性が悪い。

### 代替案 2: Terminal / Tool 型高密度モノスペース

全 UI を Sarasa Term J で描き、グレースケール中心、ASCII 風セパレータ。VS Code preferences や
htop に近い。Roola のアイデンティティ（ターミナルランチャー）とは整合するが、エントリ管理や
設定画面のような「読みやすさが必要な GUI」が読みにくくなりかねない。

却下: 一貫した「ツール感」は出るが、可読性とのトレードオフがきつい。

### 代替案 3: Material 3 のままハードコード Tweak

現状の Material 3 を残したまま、各所で `borderRadius: 2` を指定して回る。Theme 一元管理の利点
が失われ、新規 widget で角丸 12px が混ざるリスクが残る。

却下: 一貫性が保てない。

## Trade-offs

- **Material 3 のリッチな表現（surface tint / elevation overlay）が消える**: 階層感を出すには
  背景色トーン差・ボーダー線で表現することになり、要素数が多い画面では情報密度が上がる代わりに
  視覚的にフラットになる。
- **Ripple がない違和感**: モバイル UI に慣れたユーザーには「クリックが効いたか分かりにくい」と
  感じる可能性。ホバー時の背景色変化と、クリック時の即時遷移で代替する。
- **新しいウィジェット追加時に角丸を意識する必要**: ハードコード箇所は ADR の表に従って 2px、
  あるいは theme が拾える widget を使う運用。lint で縛れない部分なのでレビュー時に注意。
- **Light テーマのブランド感が薄れる**: ロゴ由来の青ティントは Light では消える。primary 色だけ
  ブランド色を維持して、surface 全体は中立。Dark テーマでだけ gunmetal の「Roola らしさ」が残る。

## References

- [Windows 11 Fluent Design](https://learn.microsoft.com/en-us/windows/apps/design/)
- [Material 3 デフォルトとの違い](https://m3.material.io/) — 比較用
- ADR-0017 / ADR-0019（既存の UI 関連 ADR）
