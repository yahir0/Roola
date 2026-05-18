## Why

Roola のターミナルタブは現在 `xterm`（xterm.dart）4.0.0 の `TerminalView` で描画している。Roola は開発者向けツールでターミナル品質を最優先要件とするが、実使用で 5 つの不具合が報告された:

1. 日本語入力（変換中テキスト）が入力欄の 1 行下に表示される
2. 日本語がチャンク境界で文字化けする（`�` 化）
3. 句読点・丸などが 1 回のキー押下で確定しない
4. 拡大操作で表示が崩れる
5. Claude Code の選択肢 UI 表示中にスクロールすると行が増殖する

切り分けの結果、②は Roola 側のバグ（`pty_terminal_runner.dart` が PTY 出力を `utf8.decode` でチャンク単位デコードしており、マルチバイト文字がチャンク境界をまたぐと壊れる）、①③④⑤は `xterm` パッケージ側の制約・バグで、①③ の IME 問題は Flutter のテキスト入力レイヤー由来のため fork でも自作レンダラでも回避できない。

ADR-0031 は、根治には Flutter の入力系を使わない構成が必要と判断し、ターミナルの描画・入力を **SwiftTerm（ネイティブ macOS NSView ベースのターミナルエミュレータ）** に置き換え、Flutter の `AppKitView` プラットフォームビューとして埋め込むことを決めた。本 change はその実装計画である。

## What Changes

- **スパイク先行**: 実装の最初のタスクとして `AppKitView` に SwiftTerm を 1 枚載せ、(a) タブに収まるか (b) 日本語 IME が通るか (c) 透過ウィンドウと合成が崩れないか (d) タブ DnD オーバーレイと z-order が破綻しないか を実測する。これを移行採否の **go/no-go チェックポイント** とする（ADR-0031 / ADR-0026 のタブ DnD・ADR-0020 の透過テーマと整合）
- **②文字化けの先行修正**: `PtyTerminalRunner` の `utf8.decode` チャンク単位デコードを streaming UTF-8 デコーダ（`Utf8Decoder` の chunked conversion）に置き換える。`xterm` のままでも修正でき、移行と独立に先行マージしてよい
- **`TerminalRunner` interface の作り直し**: `xterm` の `Terminal get terminal` を interface から外し、byte stream（`output`）＋ `write` / `resize` に寄せる。レンダラ非依存にすることで将来のレンダラ差し替え余地も残す（ADR-0031 参考節）
- **ネイティブ（Swift）コードの新規追加**: SwiftTerm の `TerminalView` を載せた `NSView` ＋ `NSViewFactory` 登録、`TerminalViewDelegate`（`send` / `sizeChanged` を Dart へ転送）、per-tab のバイトブリッジチャネル
- **Dart 側ラッパ widget の新規追加**: `AppKitView` をホストし、per-tab チャネルを native と配線するターミナル面ウィジェット
- **View 層の置換**: `lib/ui/explorer/session_view.dart` の `TerminalView`(xterm.dart) を新ラッパ widget に置換。既存の `_terminalTheme` / `_terminalStyle`（16 ANSI ＋ fg/bg/cursor、バンドル済み `SarasaTermJ.ttf`）を SwiftTerm の色・フォント API にマップする
- **`xterm` パッケージ依存の削除**: `pubspec.yaml` から `xterm` を外し、SwiftTerm を Xcode `Runner` の SPM 依存（またはベンダリング）として追加する
- PTY プロセスは引き続き Dart 側（`flutter_pty` / `PtyTerminalRunner`）が所有する。`SkillRunState` / idle 判定 / `ActiveSessions` / ワークスペースタブ / 再 spawn（ADR-0028）/ ad-hoc provider は再利用（ほぼ無傷）。SwiftTerm はレンダラ＋入力に徹し、SwiftTerm 内蔵の `LocalProcessTerminalView` は使わない

## Capabilities

### Modified Capabilities

- `embedded-terminal`: ターミナルの描画・入力レイヤーを `xterm` の `TerminalView`（Flutter ウィジェット）から SwiftTerm の `AppKitView`（ネイティブ NSView）に置き換える。PTY 所有・状態管理は変更しない

## Impact

- **新規コード（Swift）**: `macos/Runner/` 配下に SwiftTerm ホスト NSView・`NSViewFactory`・`TerminalViewDelegate`・チャネル配線
- **新規コード（Dart）**: `AppKitView` をホストするターミナル面ウィジェット（`lib/ui/explorer/` 配下）、native ⇄ Dart のブリッジ
- **既存コード変更**:
  - `lib/data/terminal_runner/terminal_runner.dart`（`Terminal get terminal` を削除、byte stream 中心の interface へ）
  - `lib/data/terminal_runner/pty_terminal_runner.dart`（`Terminal` 依存の除去、streaming UTF-8 デコーダ化、`terminal.write` / `onOutput` / `onResize` 配線の撤去）
  - `lib/ui/explorer/session_view.dart`（`TerminalView` → 新ラッパ widget、テーマ/フォントの受け渡し方式変更）
- **依存変更**: `pubspec.yaml` から `xterm` を削除。Xcode `Runner` に SwiftTerm（SPM）を追加
- **ブリッジ**: `BasicMessageChannel` + `BinaryCodec` で `ByteData` を直送（出力 Dart→native、入力・リサイズ native→Dart。base64 不要）
- **テスト**: `TerminalRunner` / `PtyTerminalRunner` のテストを byte stream ベースへ更新。streaming UTF-8 デコーダの境界またぎテストを追加。`AppKitView` を含む View はネイティブ依存のためウィジェットテストの範囲を見直す
- **ドキュメント**: ADR-0031 は作成済み。移行完了時に `docs/architecture.md` のターミナル節を更新する
- **プラットフォーム**: macOS 専用に固定される（ADR-0001 で元々 macOS 専用のため許容）
