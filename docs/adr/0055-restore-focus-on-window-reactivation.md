# ADR-0055: ウィンドウ再アクティブ化時に最後のフォーカスペインへフォーカスを戻す

- **Status**: Accepted
- **Date**: 2026-05-24

## Context

ターミナルタブで作業中に別ウィンドウ（別アプリ、または別プロセスの Roola
ウィンドウ。ADR-0012）をアクティブにし、その後 Roola ウィンドウを再度
クリックしてアクティブに戻すと、**フォーカスが直前に触っていたペインではなく
top-left ペインへ移ってしまう**（キーボード操作の対象が勝手に左上の
エクスプローラになる）。

切り分けの結果、原因は次の 2 点だった:

1. **ウィンドウ再アクティブ化を拾う処理がどこにも無い。** macOS ネイティブ側
   （`AppDelegate` / `MainFlutterWindow`）に `windowDidBecomeKey` 等の
   ハンドラは無く、Flutter 側にも `AppLifecycleListener` /
   `didChangeAppLifecycleState` の監視は無い。再アクティブ化時のフォーカス
   復帰は完全に Flutter / macOS の既定挙動任せだった。

2. **既定挙動では「最後のフォーカスペイン」に戻らない。** ウィンドウが key を
   失うと `FlutterView` が first responder を降り、再び key になると
   `FocusManager` が既定のトラバーサルでツリー先頭の focusable
   （= top-left ペイン）を掴む。ワークスペースの各ペイン（Explorer / Terminal
   / Git）には `autofocus` も明示的な `requestFocus` も無いため（ADR-0026 /
   ADR-0027）、「直前に作業していたペイン」という情報は復帰に使われない。

   さらにターミナル（SwiftTerm ネイティブビュー。ADR-0031）は、キー入力先が
   Flutter のフォーカスツリー外のネイティブ first responder にあるため
   （ADR-0037）、ウィンドウが key を失うとネイティブ first responder も外れ、
   再アクティブ化しても誰も `makeFirstResponder` を呼び直さない。

Roola は「直前に触っていたタブ」を [FocusedTab] provider
（`focusedTabId`）で既に追跡している（ADR-0026 design Decision 4。サイドバー
操作の遷移先決定に使う）。この情報を再アクティブ化時のフォーカス復帰にも使う。

## Decision

### D1. 再アクティブ化はネイティブの `becomeKey()` で拾う

`MainFlutterWindow.becomeKey()` をオーバーライドし、`roola/window` という
`FlutterMethodChannel` 経由で Dart 側へ `didBecomeKey` を通知する。

Flutter の `AppLifecycleListener`（アプリ単位の active / inactive）ではなく
ネイティブのウィンドウ単位イベントを選ぶ。理由:

- 不具合は「ウィンドウの first responder 復帰」というウィンドウスコープの
  問題なので、ウィンドウ単位の `becomeKey()` が過不足なく対応する。
- ターミナルのネイティブフォーカス橋渡し（ADR-0037）が既にネイティブ
  ↔ Flutter の MethodChannel を前提にしており、同じ仕組みの延長で済む。

初回ウィンドウ表示時にも `becomeKey()` は発火するが、その時点では
`focusedTabId` が未設定（null）のため D3 の復帰は no-op になり、初期フォーカス
挙動（ADR-0026）は変えない。

### D2. 再アクティブ化を epoch provider で配信する

keepAlive な [WindowActivation] provider（`int` の epoch カウンタ）が
`roola/window` チャネルのハンドラを持ち、`didBecomeKey` を受けるたびに
`state` をインクリメントする。各ペイン body はこの epoch を `ref.listen` し、
変化を「再アクティブ化が起きた」シグナルとして受け取る。

provider は keepAlive で、ワークスペースの各ペイン body が `ref.listen` する
ことでアプリ存続中ずっと生存する。チャネルハンドラは `ref.onDispose` で解放
する。

### D3. 復帰は「自タブが focusedTab のときだけ」各ペインが自前で行う

中央集権のフォーカスノードレジストリは作らず、各ペイン body が自分の
`FocusNode` を再要求する。epoch 変化時、ペインは
`focusedTabProvider.focusedTabId` が自タブ id と一致するときだけ
`focusNode.requestFocus()` を呼ぶ。複数の同種ペインが同時にマウントされて
いても（`IndexedStack`）、再要求するのは focusedTab に一致する 1 つだけ。

- **Terminal**（[TerminalSurface]）: `_focusNode.requestFocus()` に加え、
  `TerminalChannel.requestNativeFocus()` を**直接**呼ぶ。Flutter フォーカスを
  失っていない場合は `hasFocus` が変化せず `requestFocus` だけでは
  `_handleFocusChange`（→ ネイティブ first responder 設定）が再発火しない
  ため、ネイティブ first responder を確実に戻すには直接呼ぶ必要がある。
- **Explorer**（`_DirectoryListing`）: `focusNode.requestFocus()`。これにより
  top-left ペインへの誤遷移を上書きし、十字キー操作（ADR-0051）の対象が
  直前のエクスプローラに戻る。
- **Git**: キーボードフォーカスを持つ `FocusNode` が無い（ADR-0030）ため
  対象外。

レジストリを作らない理由は、`FocusNode` の所有を各 body に残したまま
（登録 / 解除のライフサイクル管理や dangling ノードのリスクを増やさず）、
Riverpod の `watch` / `listen` の語彙だけで配線できるため。

## Consequences

- ターミナル作業中に別ウィンドウへ移って戻っても、ターミナルにフォーカスと
  ネイティブ first responder が戻り、そのままタイプを続けられる。エクスプローラ
  作業中（top-right 等）に戻っても、top-left ではなく直前のエクスプローラに
  戻る。
- ネイティブに薄いウィンドウチャネル（`roola/window`）が 1 本増える。
- **既知の限界**: ノートパッド（ADR-0036。ワークスペース外のフローティング
  パネル・タブではない）で入力中に別アプリへ移って戻ると、`focusedTabId` が
  指す直前のペインへフォーカスが戻り、ノートパッドの入力フォーカスを奪う。
  ノートパッドはタブではなく `focusedTabProvider` の追跡対象外のため。実利用
  での頻度が低い edge case なので当面許容し、問題化したら「入力中のテキスト
  フィールドが primaryFocus のときは復帰を抑止する」ガードを追加する。

## References

- ADR-0026: `/explorer` を 3 画面タブ式ワークスペースに刷新する
- ADR-0027: per-tab 状態を family(tabId) + scoped Provider で実現する
- ADR-0031: ターミナル描画を SwiftTerm ネイティブビューへ移行する
- ADR-0037: ターミナルのプラットフォームビューと Flutter フォーカスを橋渡しする
- ADR-0051: エクスプローラ一覧を十字キー / Enter で操作できるようにする
- ADR-0052: メニューの key equivalent をフォーカス中ビューより優先する
