# ADR-0032: ターミナルで Shift+Enter を改行（LF）入力に割り当てる

- **Status**: Accepted
- **Date**: 2026-05-18

## Context

Roola のターミナルは SwiftTerm のネイティブビューで描画している（ADR-0031）。
Roola は設定済みの動作（素のシェル / 任意コマンド / Claude Code Skill）を
ワンクリック起動する汎用ターミナルランチャーで、Claude Code 等の TUI を
ターミナルタブで動かすのが主用途の 1 つ（ADR-0014 / ADR-0016）。

Claude Code の対話入力欄では複数行プロンプトを書きたい場面がある。しかし
通常の Enter は端末から CR（`\r`）が送られ、Claude Code はこれを「送信＝
行確定」として扱うため、入力途中で改行を挿入する手段が端末側になかった。

端末が Shift+Enter を通常の Enter と区別して別シーケンスを送れば、TUI 側は
それを改行の挿入として解釈できる。iTerm2 の Claude Code 用キーマップは
Shift+Enter に LF（`\n`）を割り当てており、これが事実上の慣例になっている。

## Decision

**ターミナルで Shift+Enter を押したとき LF（`\n` / 0x0a）を PTY に送る。**
通常の Enter は SwiftTerm 既定どおり CR（`\r`）＝行確定のまま変更しない。

実装は `RoolaTerminalView`（`macos/Runner/TerminalPlatformView.swift`）に
`NSEvent.addLocalMonitorForEvents(matching: .keyDown)` でローカル keyDown
モニタを張り、次の条件をすべて満たすイベントだけ横取りする:

- フォーカスが自分のターミナル（`window.firstResponder`）にある
- Kitty keyboard protocol が無効（`keyboardEnhancementFlags` が空）
- keyCode が Return（36）またはテンキー Enter（76）
- Shift が押されており、Ctrl / Cmd / Option を伴わない

条件を満たしたら LF をデータチャネルへ直送し、`keyDown` への伝播を止めて
SwiftTerm に CR を送らせない。それ以外のイベントは素通しする。

## Why

### なぜ LF（`\n`）を送るのか

Claude Code は LF を改行の挿入として解釈する。iTerm2 の Claude Code 用
Shift+Enter キーマップと同一の挙動であり、ユーザーの期待・既存ナレッジに
沿う。`\` + CR（バックスラッシュ継続）も検討したが、これはシェルの行継続
向けで TUI には効かない。主用途が TUI 入力であることを確認したうえで LF を
採用した。

### なぜローカルイベントモニタなのか

当初は SwiftTerm の `TerminalView` をサブクラス化し `keyDown(with:)` を
override する実装を試みたが、SwiftTerm の `keyDown` は `open` ではなく
`public` 止まりで、モジュール外のサブクラスからは override できない
（ビルドエラー `overriding non-open instance method outside of its
defining module` で確認）。

SwiftTerm 本体（SPM checkout）に手を入れれば override は可能だが、外部
依存の改変は自己完結方針（ADR-0005）と将来の更新追従の観点で避けたい。
`NSEvent` のローカル keyDown モニタなら SwiftTerm を無改変のまま、アプリ
側のグルーコード（`RoolaTerminalView`）に閉じて Shift+Enter を横取りできる。

### なぜ Kitty keyboard protocol 有効時は横取りしないのか

Kitty keyboard protocol が有効なときは SwiftTerm が修飾キー込みで Enter を
報告でき、TUI 側が Shift+Enter をネイティブに識別できる。この場合に本機構
が割り込むと二重処理になるため、横取りせず SwiftTerm 既定の処理に委ねる。

## Trade-offs

- **ローカルイベントモニタはアプリ全体の keyDown を受ける** — タブを複数
  開くと `RoolaTerminalView` ごとにモニタが張られる。各モニタは「フォーカス
  が自分のターミナルにあるとき」だけ反応する条件を持つため、実際に横取り
  するのはフォーカス中の 1 つだけ。モニタは `deinit` で `removeMonitor` する。
- **素のシェルでは「改行挿入」にはならない** — bash / zsh の readline は
  LF / CR の双方を accept-line に束ねるため、シェルプロンプトでは Shift+Enter
  でも行確定になる。本決定の主用途は TUI 入力であり許容する。シェルでの複数
  行入力は従来どおり `\` 継続等で行う。
- **Shift+Enter という割り当て自体は素直な拡張** — 端末では元々 Enter＝行
  確定であり、修飾キー付きで別挙動を足すのは OS 標準のテキスト入力慣習と
  衝突しない。

## References

- ADR-0005（外部 Skill / プラグインに依存しない自己完結方針）
- ADR-0014 / ADR-0016（Explorer メイン化 / 汎用ターミナルランチャー化）
- ADR-0031（ターミナル描画を SwiftTerm ネイティブビューへ移行）
- iTerm2 の Claude Code 用キーマップ（Shift+Enter → `\n`）
