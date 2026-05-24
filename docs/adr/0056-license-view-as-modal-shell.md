# ADR-0056: ライセンス表示をモーダルシェル化し、ウィンドウヘッダの戻るボタンを廃止する

- **Status**: Accepted
- **Date**: 2026-05-24

## Context

OSS ライセンス画面（ADR-0040）は、設定 / ランチャー管理が `PolarisModalShell`
のモーダル化（ADR-0054）へ移行した後も、唯一 `MacosWindowAppBar` を使った
2 画面（一覧 / 詳細）の push 構成のまま残っていた。ADR-0054 はこれを「優先度の
低い別フロー」として後続タスクに先送りしていた。

この積み残しが次の歪みを生んでいた:

1. **戻るボタンが `MacosWindowAppBar` に居座り続けていた。** ライセンス一覧 /
   詳細だけが `Navigator.push` で重なるため、`MacosWindowAppBar` は
   `Navigator.canPop()` を見て back シェブロンを出していた。Roola で push して
   重なる他のモーダル（設定 / キーバインド / ランチャー管理 / エントリ編集）は
   すべて `PolarisModalShell` 側が閉じる導線を持つので、この back ボタンの
   利用者はライセンス画面 **だけ** だった。

2. **見た目が他のモーダルと揃わない。** ライセンスだけ `Scaffold` +
   `MacosWindowAppBar` で、スクリム + 中央ベゼルパネルという Polaris の
   モーダル体裁（ADR-0054）から外れていた。

ライセンス画面をモーダルシェルへ寄せれば、`MacosWindowAppBar` の back ボタンの
最後の利用者が消え、ヘッダの戻る導線そのものを廃止できる。

## Decision

### D1. ライセンス一覧を `PolarisModalShell` のモーダルにする

設定 / ランチャー管理と同じく `LicensesRoute`（`/licenses`）を `_modalPage`
（`opaque: false` / 遷移アニメ 0）で push し、中身を `PolarisModalShell` で
スクリム + ベゼルパネルとして出す（`router.dart`）。About ダイアログの
「ライセンスを表示」ボタンは、ダイアログを pop した後に `rootNavigatorKey`
の context でこのルートを push する（pop 直後の defunct な context を避ける。
`app_menu_bar` のメニュー起動と同じ作法）。

### D2. 一覧 → 詳細はモーダル 1 枚の中で内部 state で行き来する

従来は詳細を別ページとして `Navigator.push` していたが、モーダルを 2 枚
重ねるとスクリムが二重になり重い。代わりに `LicenseBrowserPage`（HookWidget）
が選択中パッケージを `useState` で保持し、一覧と詳細をシェルの `child` として
差し替える。詳細表示中はシェルのタイトルをパッケージ名に切替える。

`PackageLicenseDetailPage`（`Scaffold` + `MacosWindowAppBar` 前提の独立ページ）
は廃止し、本体（段落リスト）を一覧ファイル内の body widget として取り込む。

### D3. `PolarisModalShell` に階層用の戻る導線を持たせる

`PolarisModalShell` に optional な `onBack` を追加する。非 null のとき:

- タイトル左に戻る山括弧（一覧の trailing と同じ `PolarisChevron` を左右反転）
  を出す。
- **Esc を「閉じる」ではなく `onBack` に割り当てる**（詳細 → 一覧 → 閉じる、と
  一段ずつ戻る）。
- **✕ ボタンとスクリムのタップは常にモーダル全体を閉じる**（一段戻るのでは
  ない）。一覧では `onBack` が null なので Esc も閉じる。

これにより、戻る導線をウィンドウヘッダではなくモーダルパネル内に閉じ込められる
（信号灯との衝突が原理的に起きない）。

### D4. `MacosWindowAppBar` の back ボタンを廃止する

D1〜D3 で `MacosWindowAppBar` の back ボタンの最後の利用者（ライセンス画面）が
消えるため、`Navigator.canPop()` 連動の back シェブロンと `navBack` ツールチップ
配線を `MacosWindowAppBar` から削除する。leading は信号灯ぶんの幅を確保する
空 spacer のみに戻す。`navBack`（l10n）は `PolarisModalShell` の戻るツールチップ
として引き続き使う。

## Consequences

- ライセンス画面が設定 / ランチャー管理と同じ体裁になり、開閉操作（✕ / スクリム
  / Esc）も統一される。一覧 → 詳細 → 一覧の行き来はモーダル内で完結する。
- `MacosWindowAppBar` から push 連動の戻る導線が消え、ワークスペースのトップバー
  専用の単純な widget になった。信号灯との衝突を気にする箇所が 1 つ減る。
- `PackageLicenseDetailPage` と、その push に使っていた `InstantMaterialRoute`
  （ADR-0038 D7）は利用者が無くなったため削除した。Polaris の遷移即時化は
  `_modalPage`（遷移アニメ 0）が担う。
- `PolarisModalShell` がモーダル内の浅い階層ナビ（一覧 ↔ 詳細）を扱えるように
  なった。今後同種の「一覧から詳細へ潜るモーダル」を作る際に再利用できる。

## References

- ADR-0038: Polaris デザインシステムを採用する（D7: 遷移の即時化）
- ADR-0040: About ダイアログと OSS ライセンス画面を提供する
- ADR-0054: コンテンツ面はベゼル付きディスプレイに統一し、内側はフラットにする
  （設定 / ランチャー管理のモーダルシェル化。本 ADR はその積み残しの follow-through）
