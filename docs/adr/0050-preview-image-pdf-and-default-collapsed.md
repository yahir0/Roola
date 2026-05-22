# ADR-0050: プレビューに画像 / PDF を追加し、既定非表示 + 選択追従の自動開閉にする

- **Status**: Accepted
- **Date**: 2026-05-22
- **Amends**: [ADR-0046]（スコープとデフォルト可視状態の 2 点を変更）

## Context

[ADR-0046] で Explorer タブに読み取り専用ファイルプレビューパネルを追加した。
その時点では次の 2 つを決めていた。

1. **スコープはテキスト系ファイルのみ**。画像 / PDF / バイナリは非対象
2. **パネルのデフォルトは表示**（起動直後から右ペインが開いている）

運用してみて、この 2 点に見直しの要望が出た。

- 画像や PDF も「ちょっと中身を見たい」対象であり、テキスト限定では
  QuickLook 的な使い勝手の核が欠ける。Finder の Column View / スペースキー
  プレビューは画像 / PDF を当然のように表示する
- 起動直後からプレビューが開いていると、ディレクトリ一覧の横幅が常に削られる。
  「まずファイル一覧を広く見て、必要なときだけプレビューを開く」流れの方が
  Explorer 主体（[ADR-0014]）の UI に合う

[ADR-0046]: 0046-explorer-file-preview-pane.md
[ADR-0014]: 0014-explorer-first-ui.md

## Decision

### 1. 画像 / PDF をプレビュー対象に追加する

- `FilePreviewContent` の sealed union に `FilePreviewImage` / `FilePreviewPdf`
  を追加（いずれもパスのみ保持）
- `FilePreviewRepository.load` は **拡張子** で画像 / PDF を判定し、内容を
  読まずにパスだけを返す（テキスト用のサイズ制限・バイナリ判定は適用しない）。
  デコード / レンダリングは UI 層に委ねる
  - 画像: `png` / `jpg` / `jpeg` / `gif` / `webp` / `bmp` / `wbmp`
  - PDF: `pdf`
- 描画（UI 層 `file_preview_pane.dart`）
  - 画像: `Image.file` を `InteractiveViewer`（パン / ズーム）に載せ、地の
    中央に contain。デコード失敗は `errorBuilder` でエラー placeholder
  - PDF: **pdfrx** の `PdfViewer.file`（スクロール / ズーム / テキスト選択は
    pdfrx 既定）。読み込み失敗は `errorBannerBuilder` でエラー placeholder
- **編集機能は持たない**方針（[ADR-0046]）は維持。pdfrx は閲覧用途のみ使う

ADR-0046 が「フル機能エディタを内包しない」「`flutter_code_editor` は採らない」
としたのは、**編集 UI を抱え込まないため**であって、閲覧フォーマットを
テキストに縛る趣旨ではない。画像 / PDF の閲覧追加はこの思想と矛盾しない。

### 2. 起動時の既定をパネル非表示にする

- `FilePreviewLayout.initial` を `visible: false` に変更（split 比率 0.6 は維持）
- 表示状態 / 横幅は引き続き per-tab の in-memory（永続化しない /
  [ADR-0042] と整合）

### 3. 主選択の内容に応じてパネルを自動開閉する

ワンクリック（主選択）の対象に応じてプレビューパネルを自動で開閉する。

- **プレビュー可能（text / image / pdf）を選択 → 自動で開く**
- **それ以外（ディレクトリ / バイナリ / 大きすぎ / 読み込み失敗 / 非選択）
  → 自動で閉じる**

判定は `FilePreviewContent.isPreviewable`（text / image / pdf のみ true）で行う。
`ExplorerTabBody` が `filePreviewViewModelProvider(tabId)` を `ref.listen` し、
解決した内容で `FilePreviewLayoutNotifier.setVisible` を呼ぶ。`ref.listen` に
よりパネル非表示時も内容 provider が生き続けるため、閉じた状態からの自動
オープンが効く。ローディング中は据え置き（直前の表示状態を保ってちらつきを
防ぐ）。

- **ヘッダの手動トグルボタンは撤去する**（[ADR-0046] で追加したもの）。
  パネルの開閉は選択に完全追従する。自動開閉を入れた結果、手動トグルは
  「次のクリックで上書きされる一時的な状態」になり、「押しても定着しない」
  分かりにくいボタンになるため。コントロールを減らす方が Polaris の機能主義
  ・QuickLook 的な軽量プレビューの狙い（[ADR-0046]）に合う
- バイナリ / 大きすぎ / 失敗を選択するとパネルは閉じるため、これらの
  placeholder（[ADR-0046]）は通常ユーザーの目に触れない。ただし
  `_PreviewBody` の sealed switch は網羅性のため全ケースを引き続き描画分岐
  として保持する（読込中→確定の瞬間に一瞬挟まる可能性があるだけ）

## なぜ pdfrx か

- macOS デスクトップを正式サポートし、PDFium XCFramework を CocoaPods 経由で
  リンクするため、追加のネイティブ設定が不要（min macOS 13.0 の本プロジェクト
  要件を満たす）
- スクロール / ズーム / テキスト選択が既定で揃っており、読み取り専用
  プレビューにそのまま使える
- pub.dev で活発にメンテされている（採用時 2.4.1）

代替案は「## 代替案」を参照。

## Why

- **QuickLook 的な体験の核を満たす**: テキストに限らず画像 / PDF も
  「開かずに中身を見る」をワンクリックで実現する
- **データ層は軽いまま**: 画像 / PDF は内容を読まずパスを渡すだけ。重い
  デコードは UI 層（`Image.file` / pdfrx）に委ね、Repository は拡張子判定の
  分岐が増えるのみ
- **Explorer 主体の UI に合わせる**: 既定で一覧を広く使い、プレビューは
  オンデマンドで開く。常時表示の押し付けをやめる

## 代替案

### 代替案 1: PDF も対象外のまま、画像だけ追加する

- 画像は Flutter 標準（`Image.file`）で新規依存ゼロなのでコストが低い
- PDF は「中身を見たい」需要が高い代表格。ここを外すと QuickLook 的体験が
  片手落ち。ネイティブ依存 1 つの追加で得られる価値が大きいので採用しない

### 代替案 2: PDF レンダリングを `pdfrx_coregraphics`（Apple ネイティブ）にする

- PDFium バイナリを同梱せずアプリサイズが小さい
- 実験的（experimental）扱いで pdfrx 本体ほど枯れていない。閲覧用途の
  安定性を優先し、本流の pdfrx（PDFium）を採用。将来サイズが問題になれば
  切り替えを検討

### 代替案 3: macOS ネイティブ PDFKit を platform view で出す

- OS の QuickLook に最も近い描画
- platform view と Flutter フォーカス / ヒットテストの調停が複雑
  （[ADR-0037] と同種の難しさ）。pdfrx はページを Flutter ウィジェットとして
  描くためこの問題を避けられる。却下

### 代替案 4: 起動時デフォルトは「表示」のまま据え置く

- 既存挙動を変えない安心感
- 一覧が常に狭まるという実利用上の不満が出発点なので、据え置きでは要望に
  応えられない。却下

### 代替案 5: 手動トグルを残す / 「追従 ON/OFF」マスタースイッチに変える

- トグルを残せば「一覧を広く保ったままファイルを選択しておく」操作ができる。
  あるいはトグルを「自動追従の ON/OFF」を定着させるマスタースイッチに役割
  変更すれば、「押しても定着しない」問題は解消できる
- いずれもコントロールが 1 つ増え、QuickLook 的な軽量さから離れる。選択追従
  だけで開閉ニーズはほぼ満たせると判断し、撤去（完全自動）を採用。将来
  「一覧を広く固定したい」要望が強ければマスタースイッチ案を再検討する

[ADR-0037]: 0037-terminal-platform-view-focus-bridge.md
[ADR-0042]: 0042-discard-workspace-on-exit.md

## Trade-offs

- **ネイティブ依存が 1 つ増える**: pdfrx（PDFium）。CocoaPods 経由で
  XCFramework がリンクされ、アプリサイズが増える。バージョン追従も必要
- **画像のメモリ**: `Image.file` は全体をデコードする。極端に大きい画像で
  メモリを食う可能性があるが、`errorBuilder` で失敗は受け止める。実害が
  出れば `cacheWidth` 等でデコード解像度を抑える
- **画像キャッシュの陳腐化**: `Image.file`（`FileImage`）のデコード結果は
  Flutter の `ImageCache` に **パス（と scale）単位** で保持される。そのため
  同じパスのまま中身だけが差し替わった画像は、`reload()`（パネル右上の
  リフレッシュ）で provider を `invalidateSelf` しても古いキャッシュが返り
  続けて反映されない。対策として `reload()` は再 build の前に主選択が画像で
  あれば `FileImage(File(path)).evict()` で該当エントリをキャッシュから追い
  出す。なお FSEvents（[ADR-0041]）はディレクトリ一覧の再読込のみで、
  プレビューは選択追従のため、外部での画像差し替えはリフレッシュ操作で
  反映させる（自動追従が必要になれば mtime をキャッシュキーへ織り込む拡張を
  検討する）

[ADR-0041]: 0041-realtime-fs-watch.md
- **既定変更の周知**: これまで起動時に開いていたパネルが閉じた状態になる。
  プレビューは previewable なファイルをクリックすれば開くので導線は自然だが、
  画像 / テキスト / PDF を一度も選ばないユーザーはプレビュー機能の存在に
  気付きにくい
- **対象外クリックのフィードバックが無い**: トグル撤去により、バイナリ等の
  非対応ファイルをクリックしても「プレビュー不可」placeholder を能動的に
  開く手段が無くなる（パネルは閉じるだけ）。「ちょっと覗く」用途では許容と
  判断。明示フィードバックが必要になれば代替案 5 のマスタースイッチや
  ステータス表示を検討する

## References

- ADR-0046（読み取り専用ファイルプレビューパネル。本 ADR はそのスコープと
  デフォルト可視状態を変更する）
- pdfrx 2.4.1（PDF レンダリング。`pdfrxFlutterInitialize()` を `main` で
  1 度呼ぶ）
- `lib/data/file_preview/file_preview_content.dart`（`FilePreviewImage` /
  `FilePreviewPdf`）
- `lib/ui/explorer/file_preview/file_preview_pane.dart`（`_ImageBody` /
  `_PdfBody`）
- `lib/ui/explorer/file_preview/file_preview_layout_provider.dart`
  （`FilePreviewLayout.initial` を非表示に）
