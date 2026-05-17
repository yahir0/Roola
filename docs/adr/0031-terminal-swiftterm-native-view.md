# ADR-0031: ターミナル描画を xterm.dart から SwiftTerm ネイティブビューへ移行する

- **Status**: Accepted（実装未着手。最初のスパイクが go/no-go チェックポイント）
- **Date**: 2026-05-17

## Context

ターミナルタブは現在 `xterm`（xterm.dart）4.0.0 パッケージの `TerminalView` で描画している。Roola は開発者向けツールでターミナル品質を最優先要件とするが、実使用で以下 5 つの不具合が報告された:

1. 日本語入力（変換中テキスト）が入力欄の 1 行下に表示される
2. 日本語がチャンク境界で文字化けする（`�` 化）
3. 句読点・丸などが 1 回のキー押下で確定しない
4. 拡大操作で表示がぐしゃぐしゃに崩れる
5. Claude Code の選択肢 UI 表示中にスクロールすると行が増殖する

切り分けの結果:

- **②は Roola 側のバグ** — `pty_terminal_runner.dart` が PTY 出力を `utf8.decode` でチャンク単位デコードしており、マルチバイト文字がチャンク境界をまたぐと壊れる
- **①③④⑤は `xterm` パッケージ側の制約・バグ** — IME 連携・スケール・スクロールバックの不具合。`xterm` 4.0.0 は事実上メンテが停滞しており、根治には fork が必要

Flutter のターミナルウィジェットを調査した結果、`xterm`（xterm.dart）以外に実用に耐える純 Flutter 製パッケージは存在しない（`termare_view` は discontinued、`terminal_library_flutter` は初期段階）。①③ の IME 問題は「Flutter のテキスト入力レイヤー」由来であり、Flutter ウィジェットである限り fork でも自作でも回避できない。根治には **Flutter の入力系を使わない＝ネイティブ or ブラウザの入力系を使う** 構成が要る。

## Decision

**ターミナルの描画・入力を SwiftTerm（ネイティブ macOS NSView ベースのターミナルエミュレータ）に置き換える。Flutter の `AppKitView` プラットフォームビューとして埋め込む。**

- PTY プロセスは **引き続き Dart 側（`flutter_pty` / `PtyTerminalRunner`）が所有** する。SwiftTerm はレンダラ＋入力に徹し、SwiftTerm 内蔵の `LocalProcessTerminalView`（PTY もネイティブで spawn する版）は使わない。ADR-0002（PTY は最初から Dart 側）の構成を維持し、`SkillRunState` / `ActiveSessions` / idle 判定 / 再 spawn（ADR-0028）を温存するため
- データ経路: PTY 出力（bytes）→ Flutter プラットフォームチャネル（binary codec）→ SwiftTerm `terminalView.feed(byteArray:)`。ユーザー入力・リサイズは SwiftTerm の `TerminalViewDelegate` → チャネル → Dart → `pty.write` / `pty.resize`
- `xterm` パッケージは依存から削除する

実装着手の最初のステップは **スパイク**（`AppKitView` に SwiftTerm を載せ、透過ウィンドウ＋タブ DnD と問題なく合成できるかを実測）とし、これを採否の最終チェックポイントとする。

## Why

### 代替案 A: xterm.dart を維持し fork パッチ

②を自前修正、④⑤を緩和、①③は xterm.dart を fork して IME 部分にパッチ。実装は最も軽いが、①③ は fork してもツギハギで、xterm.dart の VT パーサ/レンダラ品質が天井になる。メンテ停滞パッケージを自分で抱える。**品質最優先要件と矛盾するため却下。**

### 代替案 B: xterm.js を WebView に埋め込む

VSCode が使う `xterm.js` を WKWebView 内で動かす案。エンジン実績は最大で IME もブラウザ任せで確実。しかし調査の結果、**macOS にインライン WebView ウィジェットを埋め込める実用パッケージが存在しない**（`webview_flutter` は macOS 非対応、`flutter_inappwebview` の macOS 対応は `InAppBrowser`（別ウィンドウ）/ `HeadlessWebView` 止まりでインライン埋め込み不可）。結局 `WKWebView` をプラットフォームビューとして自前ホストするネイティブコードが要る。

「ネイティブコードを書く」のが B でも C でも前提になるなら、B は C に対し **JS ブリッジ層が 1 つ余分**・**WKWebView は NSView より重い（Web コンテンツプロセスを持つ）**・**バイト転送が文字列ベースで base64/WebSocket の工夫が要る**・**webview がキー入力を食うのでアプリショートカットの転送を JS で作り込む必要がある**。B の唯一の優位は xterm.js の累積実戦量だが、SwiftTerm も同一ユースケース（Mac アプリ内ターミナル）で production 実績が十分にある。**構造的に C より複雑なため却下。**

### 代替案 D: VT パーサ＋レンダラを Dart で完全自作

xterm.dart の再発明であり工数は数ヶ月。しかも①③ の IME 問題は Flutter の入力レイヤー由来なので、自作レンダラでも解決しない。**ROI 最悪のため却下。**

### C（SwiftTerm）を選んだ理由

- **①③ IME を根治** — ネイティブ `NSTextInputClient` を使う。SwiftTerm は CJK / 日本語入力を明示的に改善済み
- **②④⑤ も解決** — `feed(byteArray:)` がバイト列を受けて UTF-8 をチャンク跨ぎで正しく処理（②）、ネイティブのリフロー（④）・スクロールバック（⑤）
- **構造が B より 1 層シンプル** — JS ブリッジが不要。Dart ⇄ Swift をプラットフォームチャネルの binary codec で直送でき、base64 等のエンコードが要らない
- **NSView は WKWebView より軽量** — タブを多数開くランチャーに向く
- **アプリショートカットが自然に効く** — macOS のメニューバー key equivalent はファーストレスポンダに関係なく発火するため、ターミナルにフォーカスがあっても `NSMenu` 経由のショートカット（タブ切替・ウィンドウ操作）が効く。B（webview がキーを食う）より素直
- **実戦実績** — SwiftTerm は Secure ShellFish / La Terminal / CodeEdit 等の製品で使われ、現役メンテされている
- **`AppKitView` は Flutter 公式サポート** — macOS プラットフォームビューの正式機構

## Trade-offs

- **ネイティブ（Swift）コードを書く・保守する** — ただし SwiftTerm 自体は production 実績があり、グルーコード（NSView ファクトリ・delegate・チャネル）に閉じる。ADR-0005 の「外部 AI ツール / Skill に依存しない自己完結」には抵触しない（ネイティブライブラリはベンダリング可能で自己完結する）
- **`AppKitView` の hybrid composition は iOS の `UiKitView` ほど枯れていない** — Flutter 公式も「macOS ビュー埋め込みは重い処理、Flutter で代替できるなら避けよ」と注意。透過ウィンドウとの合成、プラットフォームビューの上に Flutter オーバーレイ（タブ DnD フィードバック等）を重ねる際の z-order に注意。**実装最初のスパイクでここを実測し、致命的なら再検討する**
- **macOS 専用に固定される** — Roola はもともと macOS 専用（ADR-0001）なので許容
- **`xterm` パッケージ依存を削除** — pub 依存は減るが、SwiftTerm を Xcode `Runner` の SPM 依存（またはベンダリング）として追加する
- **タブあたり 1 NSView** — マルチウィンドウ（ADR-0012、別プロセス起動）では各プロセスが自前の NSView 群を持つだけで問題ない

## 実装の出発点（次セッションへの引き継ぎ）

実装時は OpenSpec change `terminal-swiftterm` を起こして proposal / design / tasks を整理すること。要点:

- **役割分担**: `flutter_pty` / `PtyTerminalRunner`（PTY 所有・`output`/`write`/`resize`）・`SkillRunState`・idle 判定・`ActiveSessions`・ワークスペースタブ・再 spawn（ADR-0028）・ad-hoc provider は **再利用（ほぼ無傷）**。SwiftTerm はレンダラ＋入力のみ
- **作り直し**: View 層（`lib/ui/explorer/session_view.dart`）— `TerminalView`(xterm.dart) を `AppKitView` に置換。`TerminalRunner` interface から xterm.dart の `Terminal get terminal` を外し、byte stream（`output`）＋ `write` / `resize` に寄せる
- **新規（Swift）**: SwiftTerm の `TerminalView` を載せた `NSView` ＋ `NSViewFactory` 登録、`TerminalViewDelegate`（`send` / `sizeChanged` を Dart へ転送）、バイトブリッジ用チャネル（per-tab 配線）
- **新規（Dart）**: `AppKitView` ラッパ widget
- **ブリッジ**: `BasicMessageChannel` + `BinaryCodec` で `ByteData` を直送（base64 不要）。出力 Dart→native、入力・リサイズ native→Dart
- **テーマ / フォント**: 既存 `_terminalTheme` の 16 ANSI＋fg/bg/cursor を SwiftTerm の色 API にマップ。バンドル済み `SarasaTermJ.ttf`（ADR-0017）を app font 登録して `NSFont` を生成
- **フォーカス**: アプリショートカットは `NSMenu` の key equivalent 経由にすると、ターミナルにフォーカスがあっても効く
- **最初のタスク = スパイク**: `AppKitView` に SwiftTerm を 1 枚出し、(1) タブに収まるか (2) 日本語 IME が通るか (3) 透過ウィンドウと合成が崩れないか (4) タブ DnD オーバーレイと z-order が破綻しないか を 1〜2 日で実測。ここが go/no-go
- **別件だが先行可**: ②の文字化けは xterm.dart のままでも `pty_terminal_runner.dart` の streaming UTF-8 デコーダ化で直せる。移行前に潰しておいてもよい

移行完了時に `xterm` を `pubspec.yaml` から削除し、本 ADR を踏まえて `docs/architecture.md` のターミナル節を更新する。

## References

- ADR-0001（Flutter Desktop / macOS 専用）
- ADR-0002（PTY ベースのターミナル統合を最初から採用）— PTY は引き続き Dart 側
- ADR-0012（マルチウィンドウは別プロセス起動）
- ADR-0017（ターミナル描画フォントに Sarasa Term J を同梱）
- ADR-0026 / 0027 / 0028（ワークスペースタブ / per-tab 状態 / 永続化・再 spawn）
- [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm) — Miguel de Icaza、MIT
- [Flutter — Hosting native macOS views with Platform Views](https://docs.flutter.dev/platform-integration/macos/platform-views)
- [AppKitView class — Flutter API](https://api.flutter.dev/flutter/widgets/AppKitView-class.html)
