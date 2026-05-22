# ADR-0052: メニューの key equivalent をフォーカス中ビューより優先する

- **Status**: Accepted
- **Date**: 2026-05-22

## Context

[ADR-0033] は、アプリの全ショートカットを macOS ネイティブメニューバー
（`PlatformMenuBar`）の key equivalent に一本化した。その根拠は
「ネイティブメニューの key equivalent はファーストレスポンダに関係なく
発火する。ターミナル（SwiftTerm のネイティブビュー）にフォーカスがあっても
効く」という前提だった（[ADR-0031]）。

しかし実際には **すべてのショートカットがキー操作で発火しない** という不具合が
あった。切り分けの結果:

- メニュー自体は正しくインストールされている（独自メニュー
  ファイル / 編集 / 表示 / ターミナル / Git / ペインが表示される）。
- メニュー項目には key equivalent のグリフ（例: パスをコピーの横に ⌘⇧C）が
  表示されている＝ `shortcut` は正しくセットされている。
- メニュー項目を **マウスでクリックすれば動作する**＝ `dispatchCommand`・
  フォーカス追跡・選択・実処理はすべて正常。
- それでも **キーを押すと何も起きない**（特定コマンドではなく全コマンド）。

### 根本原因（key equivalent の処理順）

macOS の command / control 付きキーイベントの処理順は次の通り
（Apple "Handling Key Events" / WWDC 2010 Session 145）:

```
NSApplication sendEvent:
  → キーウィンドウの performKeyEquivalent:（= ビュー階層が最初に処理）
  → （ビューが NO を返したら）メインメニューの performKeyEquivalent:
  → keyDown:（誰も処理しなければ）
```

つまり **キーウィンドウ内のビューがメインメニューより先に key equivalent を
処理する**。フォーカス中のビュー（Flutter ビュー、または SwiftTerm の
ターミナルビュー）が command 系キーを `performKeyEquivalent:` で消費して
`YES` を返すと、メインメニューの key equivalent には到達せず発火しない。

ADR-0033 の前提（「ファーストレスポンダに関係なく発火する」）は誤りで、
実際にはビューが先取りしていた。マウスクリックは key equivalent 経路を
通らないため動作し、グリフ表示は `NSMenuItem.keyEquivalent` がセットされて
いれば出る——観測された症状と完全に一致する。

[ADR-0031]: 0031-terminal-swiftterm-native-view.md
[ADR-0033]: 0033-customizable-keyboard-shortcuts.md
[ADR-0035]: 0035-reserve-text-editing-shortcuts.md

## Decision

`MainFlutterWindow`（`NSWindow`）で `performKeyEquivalent(with:)` を
オーバーライドし、**ビュー階層より先にメインメニューへ評価させる**。

```swift
override func performKeyEquivalent(with event: NSEvent) -> Bool {
  if NSApp.mainMenu?.performKeyEquivalent(with: event) == true {
    return true
  }
  return super.performKeyEquivalent(with: event)
}
```

- メニューが処理すれば `true` を返してビューへ渡さない。
- 処理しなければ `super` に委ね、従来どおりビュー（ターミナルの ⌘C / ⌘V
  など）が処理する。

これで ADR-0033 が意図した「メニューの key equivalent がフォーカスに
関係なく発火する」が実際に成立する。

## Consequences

- 全ショートカットが、エクスプローラ / ターミナル / Git いずれにフォーカスが
  あっても発火する。
- メニューに載るのは ⌘⇧C など修飾付きのアプリコマンドだけで、テキスト編集用に
  予約した ⌘C / ⌘V / ⌘X / ⌘A / ⌘Z（[ADR-0035]）はメニュー項目を持たない
  ため、テキストフィールド入力やターミナルのコピー＆ペースト（[ADR-0031] /
  [ADR-0035] のローカル keyDown モニタ）を奪わない。
- キーレコーダ表示中は `AppMenuBar` が全項目の `shortcut` を外す（[ADR-0033]）
  ので、`mainMenu.performKeyEquivalent` は false を返し、`super` 経由で
  レコーダがキーを受け取れる（録り込みは従来どおり）。
- ネイティブのみの最小修正で、Dart 側のショートカット機構（コマンドレジストリ /
  ディスパッチャ）には手を入れない。
