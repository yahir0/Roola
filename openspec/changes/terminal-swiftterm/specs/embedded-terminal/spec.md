## MODIFIED Requirements

### Requirement: ターミナル UI のレンダリング

システムはターミナルの描画・入力を **SwiftTerm（ネイティブ macOS NSView ベースのターミナルエミュレータ）** で行う SHALL。SwiftTerm は Flutter の `AppKitView` プラットフォームビューとして埋め込まれ、`xterm`（xterm.dart）の `TerminalView` は使用しない。PTY プロセスは引き続き Dart 側（`flutter_pty` / `PtyTerminalRunner`）が所有し、SwiftTerm はレンダラ＋入力に徹する。

#### Scenario: ターミナルタブの描画

- **WHEN** ユーザーがターミナルタブを開く
- **THEN** システムは `AppKitView` を介して SwiftTerm の NSView を描画し、PTY 出力（バイト列）を SwiftTerm に流して端末画面を表示する

#### Scenario: ユーザー入力の PTY への伝達

- **WHEN** ユーザーが SwiftTerm にフォーカスした状態でキー入力する
- **THEN** SwiftTerm が受け取った入力バイト列が Dart 側へ転送され、`PtyTerminalRunner.write` を経て PTY に書き込まれる

#### Scenario: 端末サイズの変更

- **WHEN** ターミナルタブ（ペイン本体）のサイズが変わる
- **THEN** SwiftTerm が新しい行・桁数を Dart 側へ転送し、`PtyTerminalRunner.resize` を経て PTY にサイズ変更が伝わる

#### Scenario: 日本語入力（IME）

- **WHEN** ユーザーが日本語を入力する
- **THEN** 変換中テキストが入力位置にインライン表示され、確定操作で 1 回で確定する（ネイティブ `NSTextInputClient` 経由）

#### Scenario: スクロールバックの保持

- **WHEN** ターミナルタブが非アクティブになり、再びアクティブに戻る
- **THEN** SwiftTerm の NSView は保持されており、過去の出力履歴（スクロールバック）がそのまま表示される

## ADDED Requirements

### Requirement: PTY 出力の streaming UTF-8 デコード

システムは PTY 出力のバイト列を streaming UTF-8 デコーダで処理し、マルチバイト文字がチャンク境界をまたいでも文字化けさせない SHALL。

#### Scenario: チャンク境界をまたぐマルチバイト文字

- **WHEN** PTY 出力の 1 チャンクの末尾でマルチバイト文字（日本語等）のバイト列が途切れ、続きが次のチャンクで届く
- **THEN** システムは前後のチャンクを跨いで正しく 1 文字にデコードし、`�`（置換文字）化させない

### Requirement: Dart ⇄ native ターミナルブリッジ

システムはタブ（PTY セッション）ごとに Dart と SwiftTerm の間にバイトブリッジを張る SHALL。ブリッジは `BasicMessageChannel` + `BinaryCodec` でバイト列を直送し、base64 等の追加エンコードを行わない。

#### Scenario: per-tab のチャネル

- **WHEN** ターミナルタブが生成される
- **THEN** システムは当該タブ固有のチャネル名で Dart と SwiftTerm NSView を 1:1 に配線する

#### Scenario: タブ破棄時の解放

- **WHEN** ユーザーがターミナルタブを閉じる
- **THEN** システムは `PtyTerminalRunner` を破棄するとともに、対応する SwiftTerm NSView とブリッジチャネルを解放する

### Requirement: ターミナルのテーマとフォント

システムはターミナルの配色とフォントを SwiftTerm に適用する SHALL。配色は 16 ANSI 色＋前景／背景／カーソル／選択色、フォントはバンドル済みの Sarasa Term J（ADR-0017）とする。

#### Scenario: 配色の適用

- **WHEN** SwiftTerm の NSView が初期化される
- **THEN** 既存テーマ定数の 16 ANSI 色・前景／背景／カーソル／選択色がネイティブの色として適用される

#### Scenario: フォント登録の失敗

- **WHEN** バンドル済み Sarasa Term J フォントの登録に失敗する
- **THEN** システムはクラッシュせず、デフォルトの等幅フォントにフォールバックして描画する

#### Scenario: 背景の透過

- **WHEN** ターミナルが描画される
- **THEN** SwiftTerm の背景は透過され、Flutter 側のアピアランス暗幕（フラットテーマ）が透けて見える

## REMOVED Requirements

### Requirement: xterm.Terminal インスタンスによる描画

**Reason**: 描画・入力を SwiftTerm（ネイティブ NSView）へ移行し、`xterm`（xterm.dart）パッケージ依存を削除する。`TerminalRunner` が `xterm.Terminal` インスタンスを保有し View が `TerminalView` でそれを描画する構造、および `Terminal.onOutput` / `onResize` を PTY へ配線する構造を廃止する。①③（日本語 IME）が Flutter のテキスト入力レイヤー由来で xterm.dart の fork でも回避できないため（ADR-0031）。

**Migration**: `TerminalRunner` interface から `Terminal get terminal` を削除し、byte stream（`output`）＋ `write` / `resize` に寄せる。`PtyTerminalRunner` から `Terminal` フィールドと配線を除去する。View 層（`session_view.dart`）の `TerminalView` を `AppKitView` ベースのターミナル面ウィジェットに置換する。スクロールバックの保持先は `xterm.Terminal` から SwiftTerm の NSView へ移る。`pubspec.yaml` から `xterm` を削除する。
