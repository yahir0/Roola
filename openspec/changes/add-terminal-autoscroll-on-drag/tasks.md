## 1. ネイティブ実装

- [ ] 1.1 `macos/Runner/TerminalPlatformView.swift` に `SwiftTerm.TerminalView`
      のサブクラス `RoolaTerminalRenderingView` を追加する。
      - `private var autoScrollTimer: Timer?`
      - `private var lastDragEvent: NSEvent?`
      - `mouseDown(with:)` を override し、`super` を呼んだ後にタイマーが
        未起動なら `Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true)`
        で起動する
      - `mouseDragged(with:)` を override し、`super` を呼んだ後
        `lastDragEvent = event` を更新する
      - `mouseUp(with:)` を override し、タイマーを `invalidate()` して
        `super` を呼ぶ
      - `tickAutoScroll()` メソッドで:
          - mouseMode が `.off` 以外でかつ `sendButtonTracking()` の
            ときは early-return
          - `convert(event.locationInWindow, from: nil)` で view-local 座標
          - `point.y > bounds.height` なら up 方向、`point.y < 0` なら
            down 方向
          - 距離 `distance / 20.0` clamp 1–5 行で速度算出
          - `scrollUp(lines:)` / `scrollDown(lines:)` を呼んだ後
            `super.mouseDragged(with: event)` を再投入して
            `selection.dragExtend` を間接発火
- [ ] 1.2 `RoolaTerminalView` の `private let terminal: TerminalView` を
      `private let terminal: RoolaTerminalRenderingView` に差し替え、
      初期化を `RoolaTerminalRenderingView(frame: .zero)` に変更する。
      他の `terminal.xxx` 呼び出しは互換のため無変更。

## 2. ビルド検証

- [ ] 2.1 `flutter build macos --debug` がエラーなく通る。
- [ ] 2.2 `flutter analyze` がクリーン。

## 3. 動作確認

- [ ] 3.1 `flutter run -d macos` で Roola を起動し、ターミナルタブを開く。
- [ ] 3.2 `yes "log line" | head -1000` で長尺出力を流す。
- [ ] 3.3 出力の途中をクリックし、ボタンを押したままカーソルをビュー上端
      の上に動かして保持する。
      - **期待**: バッファが上方向に連続スクロールし、選択範囲が新たに見えた
        行まで伸びる
- [ ] 3.4 同様に、下端の下にカーソルを動かしたとき下方向にスクロールする
      ことを確認する。
- [ ] 3.5 カーソルをビュー内に戻すと autoscroll が止まり、通常のドラッグ
      選択に戻ることを確認する。
- [ ] 3.6 マウスボタンを離すと autoscroll が停止し、選択がそのまま残る
      （⌘C でコピーできる）ことを確認する。
- [ ] 3.7 `vim` を起動してマウス選択を試み、autoscroll が **発動しない**
      ことを確認する（マウスレポーティング温存）。
- [ ] 3.8 ターミナルタブを 2 つ開き、片方でドラッグ autoscroll 中に
      他方が干渉されないことを確認する。

## 4. ドキュメント / メタ更新

- [x] 4.1 `docs/adr/0047-terminal-autoscroll-on-drag-subclass.md` を追加。
- [ ] 4.2 `docs/adr/README.md` の ADR 一覧に 0047 を追加する
      （0044〜0046 と合わせて、README が 0043 までしか無い場合は補完する）。
- [ ] 4.3 `CLAUDE.md` の「主要 ADR」リストに ADR-0047 を追加する。
