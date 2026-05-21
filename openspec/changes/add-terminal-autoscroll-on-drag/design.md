## Context

ターミナル描画は SwiftTerm の `TerminalView`（NSView）を Flutter の
`AppKitView` プラットフォームビューとしてホストしている（ADR-0031）。
Dart 側は `TerminalSurface` で view ホストとフォーカス橋渡しを担い、
ネイティブ側は `RoolaTerminalView`（NSView コンテナ）が SwiftTerm の
`TerminalView` を 1 枚抱えてチャネル配線する。

設計判断と却下した代替案（SwiftTerm 上流 PR / フォーク / Flutter 側で
全上書き）は ADR-0047 を参照。本ドキュメントは実装方針の詳細。

制約:

- SwiftTerm の `selection` プロパティは `internal`。サブクラスから直接
  触れない。
- SwiftTerm の `mouseDown` / `mouseDragged` / `mouseUp` は `open override`
  でサブクラスから override 可能。
- SwiftTerm `scrollUp(lines:)` / `scrollDown(lines:)` は `public`。
- マウスレポーティング有効時の挙動を壊さない（TUI で `vim` がマウスを
  握っているような場面）。

## Goals / Non-Goals

**Goals:**

- ドラッグ中にカーソルがビュー上端より上 / 下端より下に出たら、距離に
  応じた速度で連続的にスクロールする。
- スクロールに合わせて選択範囲を伸ばす（新たに表示された行までを含む）。
- カーソルがビュー外で静止していてもスクロールが続く（`Timer` 駆動）。
- 通常のドラッグ（ビュー内）には一切影響しない。
- マウスレポーティング有効時は本機能を発動しない。

**Non-Goals:**

- SwiftTerm 自体の autoscroll を直す（ADR-0047 代替案 1・2 で却下）。
- 修飾キーや感度のユーザー設定（要望が出てから検討）。
- iOS / iPadOS の Roola（そもそも対応外）。
- スクロール時のスムーズアニメーション（SwiftTerm の `scrollUp` は離散
  行スクロールでスムーズスクロールを持たない。一致させる）。

## Decisions

### Decision 1: `TerminalView` のサブクラスで autoscroll を持つ

`macos/Runner/TerminalPlatformView.swift` の同一ファイル内に
`RoolaTerminalRenderingView: SwiftTerm.TerminalView` を追加する。
`RoolaTerminalView`（既存の NSView コンテナ）の `terminal` フィールドの
型を新クラスに差し替える。

別ファイルに切り出さない（〜100 行なら本ファイル内で見通し良い、
ADR-0032 の keyMonitor / `installKeyMonitor` と同じくターミナル動作補強の
集積場所）。

### Decision 2: `mouseDown` で `Timer.scheduledTimer` を起動・`mouseUp` で停止

`mouseDown(with:)` を override し、`super` を呼んだ後にタイマーが未起動
なら起動する。`mouseUp(with:)` で `invalidate()` してから `super` を呼ぶ。

タイマー周期は **40ms**（25fps 相当）。SwiftTerm 上流の半完成コードが
持つ周期は不明（コメントに `withTimeInterval` の値が無い）。Terminal.app
の体感に近い 25–30Hz を採用する。重すぎず・遅すぎない感覚値。

### Decision 3: 各 tick で `event.locationInWindow` を保持・再評価する

`mouseDragged(with:)` を override し、`super` を呼んだ後に
最後のドラッグイベント (`lastDragEvent: NSEvent?`) を更新する。
タイマー tick は `lastDragEvent` を参照して現在のカーソル相対位置を判定。

カーソルが view-local 座標で:

- `point.y > bounds.height` → 上にはみ出し（macOS 座標系は y 上向き）。
  `scrollUp(lines:)` を呼ぶ。
- `point.y < 0` → 下にはみ出し。`scrollDown(lines:)` を呼ぶ。
- 範囲内 → 何もしない（範囲内ドラッグは super.mouseDragged が SwiftTerm
  既定処理で扱う）。

### Decision 4: スクロール後に `super.mouseDragged(with: lastDragEvent)` を再投入

`selection` は internal で直接触れない。代わりに同じ `NSEvent` を
`super.mouseDragged(with:)` に再投入することで、SwiftTerm の
`calculateMouseHit` が「同じウィンドウ座標 × 新しい yDisp = 新しい buffer
行」を計算し、内部の `selection.dragExtend(bufferPosition:)` が呼ばれて
選択範囲が伸びる。

`super.mouseDragged` 内で `autoScrollDelta` が再計算されるが、Roola 側で
使わないので無視。SwiftTerm 上流側の値が暴れる懸念はない（タイマー駆動の
側で計算した velocity しか参照しない）。

### Decision 5: 速度計算は単純なステップ関数

`tick` ごとに以下を計算:

```swift
let distance = max(point.y - bounds.height, -point.y)  // bounds 外の距離
let lines = min(max(1, Int(distance / 20.0)), 5)       // 20px ごとに +1 行、上限 5 行/tick
```

距離 0–20px なら 1 行/tick、20–40px なら 2 行/tick、... 100px+ なら 5 行/tick
（40ms × 5行 = 125 行/秒）。実用範囲。SwiftTerm の `calcScrollingVelocity`
（指数関数気味）と完全一致はしないが、十分自然。

### Decision 6: マウスレポーティング有効時は autoscroll しない

`terminal.getTerminal().mouseMode.sendButtonTracking()` が true、もしくは
`terminal.getTerminal().mouseMode != .off` のとき、tick で early-return。
TUI（vim / less 等）がマウスを内部用途で握っているケースで Roola が勝手に
スクロールしないようにする。SwiftTerm 既定の挙動と整合。

### Decision 7: ネイティブテストは書かない

`NSEvent` を fabricate して `mouseDragged` を再現するテストは macOS の
ランタイムイベントループに依存し、再現性が低い。本 change は ADR-0047 の
判断と動作確認シナリオで品質を担保する。SwiftTerm の API 変更に弱い箇所
だが、Roola のテスト基盤を膨らませる方が割が悪い。

## Architecture Sketch

```swift
// macos/Runner/TerminalPlatformView.swift（同一ファイル内）

final class RoolaTerminalRenderingView: TerminalView {
    private var autoScrollTimer: Timer?
    private var lastDragEvent: NSEvent?

    open override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        startAutoScrollTimerIfNeeded()
    }

    open override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        lastDragEvent = event
    }

    open override func mouseUp(with event: NSEvent) {
        stopAutoScrollTimer()
        super.mouseUp(with: event)
    }

    private func startAutoScrollTimerIfNeeded() { /* ... */ }
    private func stopAutoScrollTimer() { /* ... */ }
    private func tickAutoScroll() {
        guard let event = lastDragEvent else { return }
        let mouseMode = getTerminal().mouseMode
        if mouseMode != .off && mouseMode.sendButtonTracking() { return }

        let point = convert(event.locationInWindow, from: nil)
        let dyOver: CGFloat
        let direction: ScrollDirection  // .up / .down / .none

        if point.y > bounds.height {
            dyOver = point.y - bounds.height
            direction = .up
        } else if point.y < 0 {
            dyOver = -point.y
            direction = .down
        } else {
            return
        }

        let lines = min(max(1, Int(dyOver / 20.0)), 5)
        switch direction {
        case .up:   scrollUp(lines: lines)
        case .down: scrollDown(lines: lines)
        }
        super.mouseDragged(with: event)  // selection.dragExtend を間接発火
    }
}
```

`RoolaTerminalView` の差し替え:

```swift
private let terminal: RoolaTerminalRenderingView  // was: TerminalView
// init:
terminal = RoolaTerminalRenderingView(frame: .zero)
```

その他は無変更（delegate / theme / channel / keyMonitor）。

## Risks / Trade-offs

- **`super.mouseDragged(with: event)` 再投入の脆さ**: SwiftTerm 上流が
  この関数の実装を変えると我々の前提（`calculateMouseHit` → `dragExtend`）
  が崩れる可能性。SwiftTerm を bump するたびに動作確認が必要。
- **mouseMode の判定が SwiftTerm の internal API 寄り**:
  `terminal.getTerminal().mouseMode` は public だが将来の SwiftTerm で
  リネームされる可能性。bump 時に追従する。
- **タイマー精度**: `Timer.scheduledTimer` は run loop 依存で厳密に 40ms
  保証はしない。実用上問題なし（数 ms ジッタしても体感に影響なし）。
- **マウス位置取得**: `lastDragEvent` の `locationInWindow` を使うと
  `mouseDragged` 発火時のウィンドウ座標になる。ウィンドウ自身が動くと
  ズレるが、ドラッグ中にウィンドウを移動するのは現実的でない。問題視
  しない。

## Open Questions

- スクロール速度の上限 5 行/tick（125 行/秒）は妥当か？ → 動作確認で
  「速すぎ / 遅すぎ」が出れば調整する。
- 上流 SwiftTerm に PR を出すべきか → 上流には既に [SwiftTerm#309]
  （メンテナ自身が 2023-06 に立てた同等 issue・約 3 年 OPEN）が存在する
  ので新規 issue 化は不要。PR を投げる価値はあるが、マージまでの時間軸が
  読めない（[Issue #56] でフォロー）。本 change はあくまで Roola 側の
  workaround。

[Issue #56]: https://github.com/yahir0/Roola/issues/56
[SwiftTerm#309]: https://github.com/migueldeicaza/SwiftTerm/issues/309
