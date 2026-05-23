# ADR-0054: コンテンツ面はベゼル付きディスプレイに統一し、内側はフラットにする

- **Status**: Accepted
- **Date**: 2026-05-24

## Context

設定画面（`lib/ui/settings/`）は Polaris 移行（ADR-0038）後もテーマの色は
当たっていたが、**画面の組み立てと部品が Material（M3）のまま**で「Flutter
らしさ」が残っていた。具体的には:

- 構造が `ListView` + `Divider(height: 32)` という Material 設定画面の定番形
- セクション見出しが `textTheme.titleMedium` + 太字で、`appearance_section`
  の全大文字ラベル（ADR-0038 D9）と語彙が割れていた
- 切替 UI が `SegmentedButton`（外枠 + セグメント間の仕切り線 + 薄塗りピル +
  チェックマークという M3 セグメンテッドコントロール特有の見た目）
- アイコンが `Icons.*`（汎用 Material アイコン。ADR-0038 D10 と相反）
- スライダーのツマミが Material 既定の丸ツマミ

これを Polaris へ作り替える過程で、ユーザーから「もう少しフラット／ジョナサン・
アイブ感を出したい」という方向が示された。これは ADR-0038 D1 が Polaris の思想
として明示する **ディーター・ラムス → ジョナサン・アイブの系譜（「より少なく、
しかしより良く」）** と一致する。検討用プレビューでなく実アプリを `flutter run`
で起動し、見ながら反復した（ADR-0038 の手法を踏襲）。

反復の中で「セクションごとに `well` パネルの箱で囲う」案は、Material 定番形は
脱却できるものの今度は「重い箱」として M3 感が残ることが分かり、却下した。一方
完全フラット（箱も枠もなし・余白だけ）案は軽くなる反面、Polaris が大事にする
**情報密度**と**トーン階層による計器の奥行き**（ADR-0038 D3/D6）から離れ、
かつ Explorer / Git の「計器ディスプレイパネル」（`well` + ベゼル）と温度差が
出てアプリ内で設定画面だけ浮く懸念があった。

## Decision

### D1. コンテンツ面は 1 枚の「計器ディスプレイパネル」(ベゼル) に嵌める

画面の本文エリア全体を、単一の [PolarisDisplayPanel]（`well` トーン・8px
インセット・R=4px・1px ベゼル）に嵌める。これは ADR-0038 D3/D6 の「計器
ディスプレイパネル」を、ファイル一覧（Explorer）だけでなく**コンテンツ面
一般の不変ルール**として一般化したもの。「コンテンツ面 ＝ ベゼルに嵌った
沈んだディスプレイ」という語彙を全画面で揃え、統一感を出す。

ベゼルの単位は **画面につき 1 枚**（コンテンツ面全体）であり、セクションごとに
箱を作らない。セクション単位の箱は Material 定番形か「重い箱」のどちらかに
読め、機能的な意味も持たないため。

### D2. ベゼルの内側レイアウトはフラットにする

ベゼルの内側は、面の塗りや枠で要素を囲わず、**余白と 1px ヘアライン**だけで
構成する（ADR-0038 D1 機能主義＝引き算、D3「トーン差と 1px ラインのみで面を
分ける」）。設定画面のような **preference フォームは「計器を読む面」ではなく
「操作する面」** なので、内側を計器パネルで階層化せずフラットに保つのが機能に
合う（読む面＝沈み込み、操作面＝フラット、という ADR-0038 D3 改訂の機能差の
考え方を踏襲）。

具体構成（`lib/ui/common/polaris_settings_panel.dart`）:

- `PolarisSettingsSection` — 箱なし。全大文字ラックラベル（`PolarisFieldLabel`）
  ＋補足＋内容を余白だけで積む
- `PolarisSectionDivider` — セクション間を 1px ヘアライン 1 本で区切る
- 余白は 4px グリッド（ADR-0038 D6）に厳密に乗せ、情報密度を保つ

### D3. 切替 UI は `SegmentedButton` をやめ `PolarisToggle` を自作する

M3 `SegmentedButton` の「外枠 + 仕切り線 + 薄塗りピル + チェックマーク」は計器
UI で浮くため、`PolarisToggle`（`lib/ui/common/polaris_toggle.dart`）に置換する。
外枠 1px のみ・セグメント間の仕切り線なし・R=4px とし、**選択は低透過（16%）の
淡いアクセント面 ＋ アクセント色の文字**で静かに示す（ADR-0038 D4 のアクセント
1 色・選択限定、D12 の「控えめな塗り」と整合）。当初はアクセントのベタ塗りに
したが、フラット指向には強すぎたため低透過へ落とした。

### D4. アイコンはモノライングリフ、スライダーは矩形フェーダに揃える

設定画面の `Icons.*`（info / keyboard / density / copy / check / 状態）を、
`CustomPaint` の自作モノライングリフ `PolarisGlyph`（`polaris_glyphs.dart`）へ
置換する（ADR-0038 D10 の徹底）。スライダーのツマミも Material 既定の丸ツマミ
から、機械加工 R の矩形フェーダキャップ（`theme.dart` の `_FaderThumbShape`）へ
差し替える。

### D5. secondary 画面はモーダルシェルとして重ね、戻る + タイトルのヘッダを廃止する

設定 / ランチャー管理 / キーバインド / エントリ編集は、これまで root navigator に
`.push()` され、`MacosWindowAppBar` が `canPop()` を見て **左に戻る山括弧 ＋
タイトル文字**を出していた。メイン画面のトップバー（信号灯 ＋ ROOLA ワードマーク
＋ 右アクション）と構造が別物で、戻るボタンもここでしか使われず浮いていた。

これらを `PolarisModalShell`（`lib/ui/common/polaris_modal_shell.dart`）へ統一する。
これらの画面は「ナビで深く潜った先」でなく「**ワークスペースに重ねる一時的な
モーダル文脈**」なので、`←戻る`でなく `✕閉じる`が実態に合う:

- ルートは `opaque: false`（`router.dart` の `_modalPage`）で push し、背後に
  ワークスペースを描かせる。
- シェルはスクリム（背後を薄暗く沈める・タップで閉じる）＋中央のベゼル付き
  ディスプレイ（D1 のベゼルそのもの）として出す。ヘッダは全大文字タイトル
  ＋ ✕、本文はハーラインで分ける。
- 閉じる手段は **✕ / スクリムタップ / Esc** の 3 つ（いずれも `maybePop`）。
- `MacosWindowAppBar` の戻る山括弧 + タイトルはこれらの画面から撤去する
  （メイン `WorkspacePage` と license 系は引き続き使用）。

これによりメイン画面のトップバーが常に見えたまま、secondary 画面が「閉じられる
パネル」として重なり、戻るボタン + ヘッダタイトルの不統一が解消される。

### D6. ランチャー管理 / エントリ編集の Material 部品を一掃する

これらの画面は Polaris の語彙から外れた Material 部品が残っていた。フォーム /
リスト系まで Polaris で揃える:

- **`ListTile`（3 行・40px leading）→ Polaris カスタム行**: 動作アイコン
  （`space7`=28px ベゼル）＋ 名前 ＋ 作業ディレクトリ（`mono`）の 2 行。動作種別は
  アイコンが運ぶため冗長なラベル行は出さない。フォルダ / 未分類見出しは固定高
  `space7`・縦中央寄せでサイドバー行と密度を揃える。
- **`SegmentedButton` → `PolarisToggle`（D3）**: エントリ編集の動作タイプ選択も
  他画面と同じトグルにする。
- **Material アイコン → モノライングリフ**: 動作種別は `prompt`（OpenHere）/
  `bolt`（RunCommand）/ `sparkle`（ClaudeSkill）。ほか `plus` / `dots` / `trash` /
  `folderPlus` / `grid`（空状態）/ `check`（保存）を `PolarisGlyph` に追加。
- **`Card` → Polaris パネル**、見出し → `PolarisFieldLabel`、`Divider` →
  ヘアライン、`CircularProgressIndicator` → 細い `LinearProgressIndicator`。
- **ドロップダウンの透過バグ修正**: `DropdownButtonFormField` のメニュー地は
  `canvasColor` を使うが、透過外観（ADR-0038 D14）で `canvasColor` が透明なため
  素通しになっていた。`dropdownColor` に不透明な `surface` トークンを明示する。

## Why

Polaris は思想（機能主義 / 引き算）が不変でビジュアルは導出物（ADR-0038 D1）。
「設定画面だけ例外的にフラット」とするより、「**全コンテンツ面はベゼル付き
ディスプレイ／その内側のレイアウトは面の機能（読む／操作する）で決める**」と
一段抽象化したルールに整理するほうが、思想からの導出として一貫し、後続画面でも
判断がブレない。ベゼルで全画面の語彙を揃えつつ、内側のフラットさで「より少なく」
を実践できる、という両立がこの決定の要。

## Trade-offs

- **設定画面（フラット内装）と Explorer / Git（計器パネルで密度高め）の温度差**:
  これはバグでなく「読む面／操作する面」の機能差の意図的な表現（D2）。ベゼルで
  外枠の語彙は揃うため、全体の一貫性は保てる。
- **`SegmentedButton` を捨て自作 `PolarisToggle` を保守する**: M3 の挙動
  （キーボード操作・アクセシビリティ等）を一部自前で持つ必要が出る。現状は
  単純な単一選択トグル用途に限定し、複雑化したら再検討する。
- **モノライングリフの自作コスト**: アイコンを増やすたび `CustomPaint` を書く。
  ADR-0038 D10 で受容済みのコスト。
- **モーダルの `opaque: false` で背後のワークスペースが描画され続ける**: 背後の
  ターミナル等は live のまま（見た目の利点はあるが描画コストは残る）。スクリムで
  操作はブロックする。
- **license 系画面（About ダイアログ経由）は従来の `MacosWindowAppBar` のまま**:
  システムの About フローから開く長文の法務テキストで、優先度が低く別フロー。
  必要なら後続でモーダルシェルへ寄せる。

## References

- ADR-0038: Polaris デザインシステムを採用する（本 ADR は D1/D3/D6 を一般化・具体化）
- ADR-0020: UI を Win10/11 風フラット実用テーマに転換する（ADR-0038 が Supersede）
- ADR-0010: Home / Explorer をタブ式 `StatefulShellRoute` で束ねる（secondary は root navigator に push）
- `lib/ui/common/polaris_display_panel.dart` / `polaris_settings_panel.dart` /
  `polaris_toggle.dart` / `polaris_glyphs.dart` / `polaris_modal_shell.dart`
- [Dieter Rams: 10 principles of good design](https://www.vitsoe.com/gb/about/good-design)
