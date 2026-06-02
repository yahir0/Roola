## ADDED Requirements

### Requirement: Windows でのみ xterm.js WebView2 ターミナルレンダラが使われる
`TerminalSurface` は `Platform.isWindows` のときのみ xterm.js を埋め込んだ WebView2 ビューを使用する SHALL。macOS は引き続き SwiftTerm（`AppKitView`）を使用し、本 change で変更を加えない SHALL。

#### Scenario: Windows でターミナルが表示される
- **WHEN** Windows でターミナルタブを開く
- **THEN** xterm.js WebView2 ビューに PTY 出力が描画され、シェルのプロンプトが表示される

#### Scenario: macOS でのターミナル実装が変わらない
- **WHEN** macOS でターミナルタブを開く
- **THEN** SwiftTerm（AppKitView）が使われ、本 change 以前と同じ動作をする

### Requirement: キーボード入力が PTY に転送される
Windows の xterm.js WebView2 ビューで入力したキーストロークは、xterm.js の `onData` コールバック → JS メッセージ → `TerminalRunner.write` の経路で PTY に送信される SHALL。

#### Scenario: テキスト入力がターミナルに反映される
- **WHEN** Windows でターミナルにフォーカスがある状態で文字を入力する
- **THEN** 入力した文字がターミナル画面に表示され PTY に送信される

#### Scenario: Ctrl+C が PTY に送信される
- **WHEN** Windows でターミナルで `Ctrl+C` を押す
- **THEN** `0x03`（SIGINT 相当）が PTY に書き込まれる

### Requirement: 端末サイズ変更が PTY に反映される
ウィンドウリサイズまたはペイン分割比率変更時、xterm.js の `term.resize(cols, rows)` が呼ばれ `TerminalRunner.resize` にも通知される SHALL。

#### Scenario: リサイズが PTY に伝わる
- **WHEN** Windows でターミナルペインのサイズを変更する
- **THEN** PTY の cols/rows が更新される

### Requirement: SarasaTermJ フォントで描画される
Windows の xterm.js ターミナルは SarasaTermJ-Regular フォントを使用して描画する SHALL。

#### Scenario: 日本語が正しく表示される
- **WHEN** Windows のターミナルに日本語文字列が出力される
- **THEN** SarasaTermJ フォントで文字化けなく表示される

### Requirement: xterm.js はローカルにベンダリングされる
xterm.js の JS/CSS ファイルは `assets/js/xterm/` に配置し CDN を参照しない SHALL。WebView2 は外部 URL へのナビゲーションをブロックする SHALL。

#### Scenario: ネットワーク不要でターミナルが起動する
- **WHEN** Windows でネットワーク接続なしにターミナルタブを開く
- **THEN** xterm.js ターミナルが正常に表示される

### Requirement: PTY 所有・セッション管理は変更しない
`flutter_pty` / `PtyTerminalRunner`・`TerminalRunner` interface・`SkillRunState`・`ActiveSessions`・idle 判定・ワークスペースタブは既存のまま変更しない SHALL。xterm.js レンダラは View 層のみ影響する SHALL。

#### Scenario: Windows でターミナルタブを複数開ける
- **WHEN** Windows でターミナルタブを複数開く
- **THEN** 各タブが独立した PTY セッションを持ち、互いに干渉しない
