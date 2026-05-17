# 作業引き継ぎメモ — ターミナルの SwiftTerm 移行

> このファイルはセッション間の作業引き継ぎ用。担当タスク（ターミナル移行）が
> 完了したら削除してよい。恒久的な設計記録は `docs/adr/` を参照。

最終更新: 2026-05-17

## これまでの経緯

- **Git ビュー機能（ADR-0030 / `GitTab`）** は実装完了し、PR #1 で `main` に
  マージ済み。
- ターミナルの不具合（日本語 IME・文字化け・スクロールバック・拡大崩れ）の
  調査の結果、描画を `xterm.dart` から **SwiftTerm（macOS ネイティブ NSView）**
  へ移行する判断をした。判断の全文は
  [`docs/adr/0031-terminal-swiftterm-native-view.md`](./adr/0031-terminal-swiftterm-native-view.md)。
  - ブランチ `docs/adr-0031-terminal` で push 済み（ADR-0031 ＋ `.gitignore`
    への `*.swp` 追加）。PR は作成待ち。

## 最初にやること

1. [`docs/adr/0031-terminal-swiftterm-native-view.md`](./adr/0031-terminal-swiftterm-native-view.md)
   を通読する。特に「実装の出発点（次セッションへの引き継ぎ）」節が作業指針。
2. [`docs/architecture.md`](./architecture.md) と `CLAUDE.md` の規約を確認する。

## 今回のゴール

ADR-0031 に従いターミナルを SwiftTerm へ移行する。

1. OpenSpec change `terminal-swiftterm` を起こす（proposal / design / tasks）。
   `/openspec-propose` を使ってよい。
2. 実装は **`AppKitView` スパイクから着手** する。SwiftTerm を `AppKitView` に
   1 枚出し、以下を実測する（ここが go/no-go チェックポイント）:
   - (a) タブに収まるか
   - (b) 日本語 IME が通るか
   - (c) 透過ウィンドウと合成が崩れないか
   - (d) タブ DnD オーバーレイと z-order が破綻しないか
3. スパイクが通れば本実装へ。役割分担は ADR-0031 の通り:
   - PTY は引き続き **Dart 側（`flutter_pty` / `PtyTerminalRunner`）が所有**
   - SwiftTerm は **レンダラ＋入力のみ**
   - `flutter_pty` / `SkillRunState` / `ActiveSessions` / 再 spawn は温存
   - View 層（`lib/ui/explorer/session_view.dart`）の `TerminalView`(xterm.dart)
     を `AppKitView` に置換、`TerminalRunner` interface から xterm.dart の
     `Terminal` を外す

## 独立した先行タスク（スパイク前にやってもよい）

`PtyTerminalRunner`（`lib/data/terminal_runner/pty_terminal_runner.dart`）が
PTY 出力を `utf8.decode` で **チャンク単位デコード** しており、マルチバイト
文字がチャンク境界をまたぐと文字化けする。streaming UTF-8 デコーダ化で直せる。
`xterm.dart` のままでも修正可能なので、移行前に潰してよい。

## ブランチ運用

- `main` への直コミットは避け、`feat/` `fix/` `docs/` `chore/` ブランチを切る。
- コミットは Conventional Commits（日本語サマリ可）。
- 完了時に `xterm` を `pubspec.yaml` から削除し、`docs/architecture.md` の
  ターミナル節を更新する。
