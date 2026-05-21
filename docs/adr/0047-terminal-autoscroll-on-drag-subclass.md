# ADR-0047: ターミナル選択ドラッグ中の自動スクロールを `TerminalView` のサブクラスで補う

- **Status**: Accepted
- **Date**: 2026-05-21

## Context

Roola のターミナルは SwiftTerm のネイティブ `TerminalView` をホストする
（[ADR-0031]）。ターミナル内で長尺の出力を範囲選択しようとして、左クリック
を押したままカーソルをビュー上端より上 / 下端より下に持っていっても、
**バッファが自動スクロールしない**。Terminal.app・iTerm2・`NSTextView`
など macOS の標準的なテキストコントロールはこの場面でビュー外にカーソルが
出るとスクロールしながら選択を伸ばすので、ユーザー期待を裏切る挙動になる
（[Issue #56]）。

[ADR-0031]: 0031-terminal-swiftterm-native-view.md
[Issue #56]: https://github.com/yahir0/Roola/issues/56

### 根本原因（SwiftTerm 内部の半完成 autoscroll）

`Sources/SwiftTerm/Mac/MacTerminalView.swift` には autoscroll 用の状態と
コールバックが存在するが、**それを定期実行する `Timer` がどこにも
スケジュールされていない**。

```swift
private var autoScrollDelta = 0

// scrollUp を呼ぶコールバック。ただし誰も呼び出さない。
private func scrollingTimerElapsed (source: Timer) {
    if autoScrollDelta == 0 { return }
    if autoScrollDelta < 0 { scrollUp(lines: autoScrollDelta * -1) }
    else { scrollUp(lines: autoScrollDelta) }
}

open override func mouseDragged(with event: NSEvent) {
    ...
    autoScrollDelta = 0
    let screenRow = hit.row - displayBuffer.yDisp
    if selection.active {
        if screenRow <= 0 { autoScrollDelta = calc... * -1 }
        else if screenRow >= rows { autoScrollDelta = calc... }
    }
}
```

`mouseDragged` のたびに `autoScrollDelta` が再計算されるが、`mouseDragged`
自体はマウスが動いた瞬間しか発火しないため、ビュー外でカーソルを静止すると
スクロールしない。

## Decision

Roola 側で `SwiftTerm.TerminalView` の **薄いサブクラス**
`RoolaTerminalRenderingView` を `macos/Runner/TerminalPlatformView.swift` 内に
追加し、選択ドラッグ中の autoscroll を自前で動かす。

- `mouseDown` / `mouseDragged` / `mouseUp` を override
- ドラッグ開始時に `Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true)`
  を起動し、`mouseUp` で `invalidate`
- 各 tick で `event.locationInWindow` を view-local 座標へ変換し、`bounds`
  外なら距離に応じた行数を計算して `scrollUp(lines:)` / `scrollDown(lines:)`
  を呼ぶ
- スクロール後に同じ `NSEvent` を `super.mouseDragged(with:)` に再投入する
  ことで、SwiftTerm 内部の `selection.dragExtend(bufferPosition:)` を介して
  選択範囲を新たに見えた行まで伸ばす
- マウスレポーティング有効（`terminal.mouseMode.sendButtonTracking()`）の
  ときは autoscroll しない（SwiftTerm 側の挙動を温存）
- 通常のドラッグ（ビュー内）には一切影響しない（タイマーは tick で out-of-bounds
  判定が偽なら何もしない）

`selection` プロパティ自体は SwiftTerm 内部で `internal` のためサブクラス
から直接触れない。`super.mouseDragged(with:)` に同じ `NSEvent` を再投入する
ことで、`calculateMouseHit` が「同じウィンドウ座標 → 新しい buffer 行」を
返す性質を利用して間接的に選択範囲を伸ばす。

`RoolaTerminalView` の `terminal` プロパティの型を `TerminalView` から
`RoolaTerminalRenderingView` に差し替える（既存の delegate 設定 / テーマ
適用 / チャネル配線はすべて互換）。

## Why

- **すぐ直る**: Roola のリポジトリ内で完結する。SwiftTerm 上流 PR
  （[Issue #56] でも触れた）を待たずに体験を改善できる
- **副作用が小さい**: subclass + override のみ。SwiftTerm 内部に手を入れない
  ので、SwiftTerm のバージョンアップ追従が容易（上流が autoscroll を実装
  したらサブクラスを撤去するだけ）
- **`selection` private を回避する素直な手筋**: 同じ `NSEvent` の再投入で
  `super.mouseDragged` の既存ロジックに「新しい buffer 行」を計算させ、
  内部 `selection.dragExtend` を発火させる。サブクラスから internal API に
  リフレクションで突っ込む等の脆い手段を取らない
- **マウスレポーティング温存**: TUI（vim / less 等）でマウスを「内部用途」
  に握っているターミナルでは autoscroll を発動しない。SwiftTerm 既存の
  分岐に合わせる

## 代替案

### 代替案 1: SwiftTerm 上流に PR を出して `Timer` を仕込む

- 全 SwiftTerm 利用者が直る
- マージ / リリース待ちで Roola の体験はその間も悪いまま
- 上流が「半完成」を放置している理由（メンテナの方針 / iOS 側との整合）が
  不明で、PR が通るかが読めない
- 上流 issue / PR は別途立てて長期で追う（[Issue #56]）。本 ADR の Roola
  側 patch は **そのうえで** 残しても良し、上流が直ったら撤去しても良し

### 代替案 2: SwiftTerm をフォークして直接修正する

- 直接根本治療できる
- メンテ負担が増える（SwiftTerm 本体のアップデートに追従し続ける必要）
- 数行の機能のためにフォーク管理は割に合わない。却下

### 代替案 3: Flutter 側の `RawKeyboardListener` + `MouseRegion` で全部上書きする

- ターミナル領域に Flutter のマウスイベント layer を被せ、Flutter 側で
  スクロールを駆動する案
- ターミナルはネイティブビュー（platform view）でホストされており、Flutter
  layer はその下に重なるため、マウスイベントの取り合いになる。`hit test`
  の調停が複雑化する
- 既存の SwiftTerm のマウス選択ロジックを Flutter から再現する必要がある。
  バグの温床。却下

### 代替案 4: スクロールはせず「選択範囲を超えた行も `scrollUp` 不要でコピー」

- ユーザーは結局スクロールしたい場合がある（途中まで見たい）
- UX として中途半端。却下

## Trade-offs

- **`super.mouseDragged` の再呼び出し**: 同じ `NSEvent` を 2 回以上 super
  に投げることで、SwiftTerm 内部状態が想定外に進む可能性は理論上ある。
  実際には `selection.dragExtend` は冪等で、`autoScrollDelta` の再計算も
  問題なし。それでも将来 SwiftTerm の `mouseDragged` 実装が変わるとここが
  fragile になる。実害が出れば Subclass 側で `selection` を Mirror 経由で
  叩く / 上流 PR を加速する等の対策に切り替える
- **`autoScrollDelta` を再利用しない**: SwiftTerm 内部の `autoScrollDelta`
  は private なので参照しない。サブクラスでカーソル位置から速度を独自に
  計算する。SwiftTerm 内部の `calcScrollingVelocity` と完全に同じ式には
  ならないが、似た「距離が遠いほど速い」挙動を再現する
- **`Timer` のオーバーヘッド**: 40ms 周期で `tick` が走るのはドラッグ中のみ
  （`mouseDown` で起動・`mouseUp` で停止）。常時負荷ではない
- **SwiftTerm が将来直したら撤去対象**: Subclass 自体は最小なので、上流が
  実装したら気付いた時点で消せばよい。`Status` を Deprecated にして
  ADR を残す方針

## References

- [Issue #56]（Roola）— ターミナルでドラッグ選択中にビューの外へ出ても
  自動スクロールしない
- ADR-0031（ターミナル描画を SwiftTerm ネイティブビューへ移行する）
- ADR-0032（Shift+Enter で LF 入力 — `NSEvent` のローカルモニタで横取り
  する例。本 ADR の subclass 戦略とは違うが、SwiftTerm の挙動を周辺で
  補強する同種のパターン）
- ADR-0037（ターミナルのプラットフォームビューと Flutter フォーカスを
  橋渡しする）
- SwiftTerm: `Sources/SwiftTerm/Mac/MacTerminalView.swift`（`autoScrollDelta`
  / `scrollingTimerElapsed` の半完成箇所）
