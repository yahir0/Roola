## Why

ターミナルで長尺出力を範囲選択しようとして左クリックを押したままカーソルを
ビュー上端より上に動かしても、Roola のターミナル（SwiftTerm ベース /
ADR-0031）は **バッファを自動スクロールしない**。Terminal.app / iTerm2 /
`NSTextView` などの macOS 標準は同じ場面で連続的にスクロールしながら選択を
伸ばす。ユーザー期待を裏切る挙動になっており、選択は可視範囲の最上行で
止まる（下端方向のドラッグも同様）。

調査の結果、SwiftTerm の `Sources/SwiftTerm/Mac/MacTerminalView.swift` には
autoscroll 用の `autoScrollDelta` フィールドと `scrollingTimerElapsed`
コールバックがあるものの、**それを定期実行する `Timer.scheduledTimer(...)`
がどこにもない**（grep 確認済み）。コールバックは未到達で値はセット毎に
捨てられている。設計判断と詳細な検討経緯は ADR-0047 に記録した。

上流 SwiftTerm 側の修正 PR は別途検討（Roola リポジトリ Issue #56 で追跡）
する一方、Roola 側で先に直す。

## What Changes

- `macos/Runner/TerminalPlatformView.swift` に `SwiftTerm.TerminalView` の
  サブクラス `RoolaTerminalRenderingView` を追加する。
- サブクラスは `mouseDown` / `mouseDragged` / `mouseUp` を override し、
  ドラッグ中だけ `Timer`（〜40ms 周期）を起動。各 tick で `event.locationInWindow`
  を view-local 座標に変換し、`bounds` 外なら距離に応じた行数で
  `scrollUp(lines:)` / `scrollDown(lines:)` を呼んだ後、同じ `NSEvent` を
  `super.mouseDragged(with:)` に再投入して SwiftTerm 内部の
  `selection.dragExtend(bufferPosition:)` 経由で選択範囲を伸ばす。
- マウスレポーティング有効時（TUI 等）は autoscroll を発動しない。
- `RoolaTerminalView` の `terminal` プロパティの型を `TerminalView` から
  `RoolaTerminalRenderingView` に差し替える（既存の delegate / テーマ /
  チャネル配線はそのまま互換）。
- 設計判断は ADR-0047 に記録済み。

## Capabilities

### Modified Capabilities

- `terminal-rendering`（SwiftTerm 描画層）: 選択ドラッグ中、カーソルが
  ビュー外に出るとバッファが自動スクロールし、選択範囲が新たに見えた行
  まで伸びる挙動を追加する。

### New Capabilities

<!-- 新規 capability は無し。`terminal-rendering` の既存挙動の補強。 -->

## Impact

- **macOS ネイティブ**: `macos/Runner/TerminalPlatformView.swift` に
  約 80〜100 行の Swift 追加。SwiftTerm への変更や上流 fork は無し。
- **Dart 側**: 影響なし。`TerminalSurface` / `TerminalChannel` などの
  Dart 側コードは無変更。
- **ビルド**: 追加依存なし。
- **テスト**: native 単体テストは設けない（ネイティブイベント駆動でテスト
  困難）。ADR と本 change の動作確認シナリオでカバーする。
