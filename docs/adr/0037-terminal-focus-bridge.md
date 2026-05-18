# ADR-0037: ターミナルのプラットフォームビューと Flutter フォーカスを橋渡しする

- **Status**: Accepted
- **Date**: 2026-05-18

## Context

ターミナルは SwiftTerm のネイティブ `NSView` を `AppKitView` プラットフォーム
ビューとしてホストしている（ADR-0031）。このため Roola には **2 つの独立した
フォーカス状態** が存在する:

- macOS の `NSWindow.firstResponder` — キーボード入力が SwiftTerm の
  `NSView` へ届くか、Flutter の `FlutterView` へ届くかを決める。
- Flutter の `FocusManager` のフォーカスツリー — AppBar の `IconButton` 等、
  Flutter ウィジェットのフォーカスを管理する。

`AppKitView` は Flutter のフォーカスツリーに参加していないため、両者が
ずれる。具体的な不具合として、ターミナルで作業中に次が起きていた:

- ターミナルでの Tab（シェル補完のつもり）押下時、その瞬間 `FlutterView`
  側が firstResponder だと、Flutter は Tab を「次のフォーカスへ移動」と解釈し、
  フォーカスツリー内の `IconButton`（設定アイコン等）へフォーカスを移す。
- その状態で Enter を押すと、Flutter 標準のショートカット
  （Enter/Space → `ActivateIntent`）がフォーカス中のボタンを発火させ、
  設定画面へ意図せず遷移する。
- ターミナルをクリックすると SwiftTerm が firstResponder を取り戻し、
  症状が消える。

## Decision

ターミナルのプラットフォームビューを Flutter のフォーカスシステムへ橋渡し
する。`TerminalSurface` に専用の `FocusNode` を持たせ、ネイティブの
firstResponder と Flutter のフォーカスを次の最小機構で同期させる:

- **Flutter → ネイティブ**: `TerminalSurface` を `Focus` でラップし、
  `Listener.onPointerDown` でターミナルのクリックを検知して `FocusNode` に
  フォーカスを要求する。`FocusNode` がフォーカスを得たら、`ctrl` チャネルの
  `focusTerminal` メソッドで SwiftTerm の `NSView` を `makeFirstResponder`
  するよう native へ要求する（`TerminalChannel.requestNativeFocus`）。
- **キー漏れの遮断**: ターミナルの `Focus` に `onKeyEvent` を置き、
  ターミナルがフォーカスを保持している間に万一 Flutter 側へ漏れたキーを
  `KeyEventResult.handled` で消費する。これにより firstResponder の同期が
  非同期で一瞬遅れても、Tab 遷移・Enter による誤発火が起きない。

これにより「ターミナルで作業している間はターミナルの `FocusNode` が Flutter
フォーカスを保持し、かつ SwiftTerm が firstResponder である」状態が保たれ、
キーは常にターミナルへ届く。

## Why

### なぜ `ctrl` チャネル経由の橋渡しか

`AppKitView` のプラットフォームビューフォーカス連携はフレームワーク側の
サポートが限定的で、SwiftTerm の `NSView`（プラットフォームビューの内部
サブビュー）が firstResponder になったことをフレームワークへ自動通知する
仕組みはない。一方、ターミナルには既に native ⇄ Dart の `ctrl`
`MethodChannel`（ADR-0031）が通っており、ここに `focusTerminal` を 1 つ
足すだけで Flutter → native のフォーカス要求を実現できる。新しいチャネルや
依存を増やさずに済む。

### なぜ SwiftTerm を subclass しないか

native → Dart 方向（SwiftTerm が firstResponder になったことを Dart へ通知）
は `becomeFirstResponder` の override で実装できるが、SwiftTerm の
`TerminalView` はメソッドの override 可能性が限定されており（既存コードの
`keyDown` に関する注記を参照）、subclass 方式は壊れやすい。クリック検知は
Flutter 側の `Listener` で代替でき、害のあるズレ（ターミナル作業中に
キーがボタンへ漏れる）はこの一方向＋`onKeyEvent` で解消できるため、
native → Dart 通知は実装しない。

## Trade-offs

- ノートパッドや設定画面など Flutter ウィジェットを操作した後は、Flutter
  フォーカスがターミナルへ自動では戻らない。ターミナルを 1 度クリックすれば
  同期し直す。完全な自動復帰は対象外とする（どのターミナルへ戻すかが一意に
  定まらないため）。
- `onKeyEvent` はターミナルフォーカス保持中の Flutter 側キーを一律
  消費する。アプリのコマンドショートカットはネイティブメニューバー
  （ADR-0033）が責任を持つため影響しないが、将来 Flutter レベルの
  `Shortcuts` を足す場合はこの遮断を考慮する必要がある。

## References

- ADR-0031: ターミナル描画を SwiftTerm ネイティブビューへ移行
- ADR-0033: コマンドレジストリとネイティブメニューバー
