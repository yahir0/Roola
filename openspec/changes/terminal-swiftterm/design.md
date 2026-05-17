## Context

Roola のターミナルタブは `xterm`（xterm.dart）の `TerminalView` で描画している。`PtyTerminalRunner`（`data/terminal_runner/`）が `flutter_pty` で PTY を起動し、PTY 出力を `Terminal` に書き込み、`Terminal.onOutput` / `onResize` を PTY に配線している。View 層（`ui/explorer/session_view.dart`）は `runner.terminal` を `TerminalView` に渡すだけで描画が完結する設計（ADR-0008 の「Terminal を View から切り離す」方針）。

ADR-0031 は、報告された 5 つのターミナル不具合のうち①③（日本語 IME）が Flutter のテキスト入力レイヤー由来で fork でも自作でも回避できないと結論し、描画・入力を SwiftTerm（ネイティブ macOS NSView）へ移行し `AppKitView` で埋め込むことを決めた。本 change はその実装設計である。代替案 B（xterm.js + WebView）/ D（レンダラ自作）の比較、および将来 Windows 対応時の判断は ADR-0031 に記録済みで、ここでは繰り返さない。

## Goals / Non-Goals

**Goals:**

- ターミナルの描画・入力を SwiftTerm に置き換え、①③④⑤を根治、②も解消する
- PTY 所有・状態管理（`PtyTerminalRunner` / `SkillRunState` / idle 判定 / `ActiveSessions` / 再 spawn）を温存し、変更を描画・入力レイヤーに閉じる
- `TerminalRunner` interface をレンダラ非依存（byte stream 中心）にし、View 層から `xterm` への依存を除去する
- 既存のテーマ・フォント（16 ANSI ＋ fg/bg/cursor、`SarasaTermJ.ttf`）の見た目を維持する

**Non-Goals:**

- PTY 実装の差し替え（`flutter_pty` を継続使用。ADR-0002）
- SwiftTerm 内蔵の `LocalProcessTerminalView`（PTY をネイティブで spawn する版）の採用 — PTY は Dart 側所有を維持
- 代替案 B（xterm.js）の足場づくり — 将来 Windows 対応が要件化した時点で別途判断（ADR-0031 参考節）
- ターミナルの新機能追加（検索 UI・リンク化・URL 検出など）。本 change は等価移行に徹する
- マルチウィンドウ（ADR-0012）の構成変更 — 各プロセスが自前の NSView 群を持つだけで影響なし

## Decisions

### D1: 実装はスパイクから着手し、これを採否の go/no-go とする

最初のタスクは `AppKitView` に SwiftTerm を 1 枚載せるスパイクとし、以下 4 点を実測する:

- (a) タブ（ペイン本体）に正しく収まり、リサイズに追従するか
- (b) 日本語 IME（変換中テキストのインライン表示・確定）が通るか
- (c) 透過ウィンドウ（ADR-0020 のフラットテーマ・`_AppearanceLayer` の暗幕）と合成が崩れないか
- (d) タブ DnD オーバーレイ（ADR-0026）と z-order が破綻しないか — プラットフォームビューの上に Flutter オーバーレイを重ねられるか

`AppKitView` の hybrid composition は iOS の `UiKitView` ほど枯れておらず、Flutter 公式も注意を促している（ADR-0031 Trade-offs）。(c)(d) が致命的に破綻する場合は ADR-0031 自体の再検討に戻す。スパイクは捨てコードでよく、本実装に流用しない前提で素早く回す。

### D2: PTY は Dart 側所有のまま、SwiftTerm はレンダラ＋入力のみ

`PtyTerminalRunner` が `flutter_pty` で PTY を所有する構成（ADR-0002）を維持する。SwiftTerm の `LocalProcessTerminalView` は使わない。理由は ADR-0028 の再 spawn・`SkillRunState` の idle 判定・`ActiveSessions` レジストリが Dart 側の PTY 所有を前提にしているため。SwiftTerm に渡すのは「描画すべきバイト列」と、SwiftTerm から受け取るのは「ユーザー入力バイト列」と「サイズ変更」のみ。

データ経路:

- 出力: `Pty.output`（bytes）→ `PtyTerminalRunner.output`（Stream）→ Dart 側ブリッジ → チャネル → native `terminalView.feed(byteArray:)`
- 入力: SwiftTerm `TerminalViewDelegate.send` → チャネル → Dart → `PtyTerminalRunner.write` → `pty.write`
- リサイズ: SwiftTerm `TerminalViewDelegate.sizeChanged` → チャネル → Dart → `PtyTerminalRunner.resize` → `pty.resize`

### D3: `TerminalRunner` interface を byte stream 中心に作り直す

現 interface は `Terminal get terminal`（xterm.dart 型）を公開し、View はそれを `TerminalView` に渡す。これを廃止し、interface から `xterm` 型を完全に除去する:

- 削除: `Terminal get terminal`
- 維持: `output`（`Stream<Uint8List>`）・`write(Uint8List)`・`resize({cols, rows})`・`start` / `cancel` / `dispose` / `state` / `currentState`
- `PtyTerminalRunner` から `Terminal` フィールド・`terminal.onOutput` / `onResize` 配線・`terminal.write` 呼び出しを削除する

これにより `output` Stream が描画の唯一の供給源になる。`output` は既に `StreamController.broadcast` で実装済み（start 前 subscribe のレース対策コメントあり）なので、ブリッジ側はこれを subscribe して native に流すだけでよい。

**スクロールバックの所在**: 現状は `Terminal` インスタンスがスクロールバックを保持し、`TerminalRunner` の生存期間 = `Terminal` の生存期間だった。移行後はスクロールバックを **SwiftTerm（NSView）側が保持** する。NSView の生存期間管理（タブ非アクティブ時の保持・タブ破棄時の解放）は D5 で扱う。

### D4: ブリッジは per-tab の `BasicMessageChannel` + `BinaryCodec`

タブ（= PTY セッション）ごとに一意な channel 名（`roola/terminal/<tabId>`）で `BasicMessageChannel<ByteData>`（`BinaryCodec`）を張る。

- **採用理由**: `MethodChannel` は引数を standard codec でエンコードするためバイト列に余分なラップが乗る。`BasicMessageChannel` + `BinaryCodec` なら `ByteData` を直送でき、base64 等のエンコードが不要（ADR-0031）
- 出力（Dart→native）と入力・リサイズ（native→Dart）を 1 チャネルに相乗りさせる場合、リサイズはバイト列でなく小さな構造のため、リサイズ専用に別途軽量チャネル（`MethodChannel`）を併用するか、先頭 1 バイトのタグで多重化するかを実装時に決める（Open Question O1）
- per-tab にするのは、1 つの `AppKitView` インスタンス（= 1 NSView）と 1 つの `PtyTerminalRunner` を 1:1 で結ぶため。`AppKitView` の `creationParams` に `tabId` を渡し、native ファクトリがその id でチャネルを開く

### D5: `AppKitView` のライフサイクルと per-tab 状態

ワークスペースは per-tab 状態を `family(tabId)` でルートスコープに保持する（ADR-0027）。ターミナルタブが非アクティブ（同ペインの別タブに切替）になっても PTY セッションと出力は保持される（既存仕様）。

- SwiftTerm の NSView はスクロールバックを持つため、タブ非アクティブ時も **NSView インスタンスを破棄しない**ことが望ましい。`AppKitView` を含む Flutter サブツリーが dispose されると native view も解放されうるため、タブ本体を `Offstage` や `IndexedStack` 的に保持するか、native 側で id 単位に NSView をキャッシュ（プール）して `AppKitView` 再生成時に再アタッチするかを実装時に決める（Open Question O2）
- タブ破棄時（× で閉じる）は `PtyTerminalRunner.dispose` と合わせて native NSView・チャネルを解放する
- 再 spawn（ADR-0028、再起動時）は PTY を新規 start するだけで、NSView は新規生成・空スクロールバックで始まる（既存の「出力履歴は引き継がない」仕様どおり）

### D6: テーマ・フォントの SwiftTerm へのマッピング

現 `session_view.dart` の `_terminalTheme`（`TerminalTheme`: 16 ANSI + foreground/background/cursor/selection）と `_terminalStyle`（`SarasaTermJ`）を SwiftTerm の API に移す。

- 色: SwiftTerm の `TerminalView` は ANSI パレット・デフォルト前景/背景・カーソル色を設定できる。現 16 色 + fg/bg/cursor/selection の `Color` 値をネイティブの色型（`NSColor` / SwiftTerm の `Color`）にマップする。値は ADR-0031 / `session_view.dart` の定数をそのまま使う
- 背景透過: 現状 `backgroundOpacity: 0` で `_AppearanceLayer` の暗幕を透かしている。SwiftTerm 側の背景を透明にし、Flutter 側の暗幕を見せる構成を維持する（D1 スパイクの (c) で実測する論点）
- フォント: バンドル済み `SarasaTermJ.ttf`（ADR-0017、`pubspec.yaml` の Flutter assets）を native 側でも参照する必要がある。アプリバンドルにフォントを同梱し、`CTFontManagerRegisterFontsForURL` 等で登録して `NSFont` を生成する。Flutter assets のフォントは native から直接は読めないため、`macos/Runner/` のリソースとしても同梱するか、Flutter assets のパスを解決して登録するかを実装時に決める（Open Question O3）

### D7: アプリショートカットは `NSMenu` の key equivalent 経由

macOS のメニューバー key equivalent はファーストレスポンダに関係なく発火するため、ターミナル（NSView）にフォーカスがあってもタブ切替・ウィンドウ操作のショートカットが効く（ADR-0031）。既存のショートカットが Flutter 側の `Shortcuts` / `Actions` で実装されている場合、SwiftTerm にフォーカスがあるとキーイベントが Flutter に届かず効かなくなる恐れがある。移行で効かなくなるショートカットを洗い出し、必要なものは `NSMenu`（macOS ネイティブメニュー、ADR の macos-menu-and-multiwindow change で導入済み）の key equivalent に寄せる。

## Risks / Trade-offs

- **[スパイク (c)(d) で `AppKitView` 合成が破綻] → 緩和**: D1 のスパイクを最初に回し、致命的なら ADR-0031 に差し戻す。本実装の前にここで止める
- **[ネイティブ Swift コードの保守コスト] → 受容**: SwiftTerm 自体は production 実績がありメンテ継続中。Roola が書くのはグルーコード（ファクトリ・delegate・チャネル）に閉じる。ADR-0005 の自己完結方針には抵触しない（SPM 依存はベンダリング可能）
- **[スクロールバックの所在が NSView へ移る] → 緩和**: D5 で NSView の生存期間を設計。タブ非アクティブで NSView が破棄されると履歴が消えるため、保持戦略を Open Question O2 で確定させる
- **[SarasaTermJ を native から参照できない] → 緩和**: D6 / O3。フォント登録に失敗した場合は SwiftTerm のデフォルト等幅フォントにフォールバックし、クラッシュさせない
- **[ウィジェットテストが native 依存で書けない] → 緩和**: `AppKitView` を含む View はウィジェットテスト対象から外し、`TerminalRunner` / `PtyTerminalRunner` / ブリッジの Dart 側ロジックをユニットテストでカバーする。native コードの動作確認は実機（macOS）で行う
- **[②文字化け修正の先行マージ] → 設計どおり**: streaming UTF-8 デコーダ化は `xterm` のままで成立するため、移行と独立に先行マージしてよい（リスクではなく進め方の選択肢）
- **[マルチウィンドウへの影響] → なし**: ADR-0012 は別プロセス起動。各プロセスが自前の NSView 群を持つだけ

## Migration Plan

- ②の streaming UTF-8 デコーダ化を先行で別コミット（必要なら別 PR）として入れてよい
- `TerminalRunner` interface の作り直し → `PtyTerminalRunner` の `Terminal` 依存除去 → ブリッジ → native → View 置換、の順で進める。interface 変更時点で一時的にビルドが壊れるため、interface・実装・View・テストは同一 PR にまとめる
- `xterm` 依存の削除は最後（View 置換完了後）。`pubspec.yaml` から外し、import 残りがないことを `flutter analyze` で確認する
- 移行完了時に `docs/architecture.md` のターミナル節を ADR-0031 を踏まえて更新する
- ロールバック: 移行は単一 PR の revert で戻せる（②の先行修正は独立して残してよい）

## Open Questions

- **O1**: 出力（Dart→native, bytes）とリサイズ（native→Dart, 構造）を 1 チャネルに多重化するか、リサイズ用に別チャネルを併用するか。スパイク中に実装感を見て決める
- **O2**: タブ非アクティブ時に NSView インスタンスを破棄しない保持戦略 — Flutter サブツリー側で保持（`IndexedStack` 等）するか、native 側で id 単位に NSView をプールするか。SwiftTerm のスクロールバック保持と直結する論点
- **O3**: バンドル済み `SarasaTermJ.ttf` を native から参照する方法 — `macos/Runner/` リソースとして二重同梱するか、Flutter assets のパス解決で登録するか
- **O4**: スパイクで `AppKitView` のリサイズ追従・IME に問題が出た場合の SwiftTerm 側の設定・パッチ範囲（SwiftTerm の更新追従コスト）
