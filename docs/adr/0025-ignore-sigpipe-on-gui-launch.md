# ADR-0025: GUI 起動経路の SIGPIPE 即死を AppDelegate で抑止する

- **Status**: Accepted
- **Date**: 2026-05-15

## Context

Developer ID 署名 + 公証 + ステープリング済みの配布 DMG を `/Applications` にインストール
した Roola を Dock / Finder / `open` 経由（= LaunchServices 経由）で起動すると、ウィンドウが
全く描画されないまま 1〜2 秒で プロセスが消える症状が再現した。一方、ターミナルから
`Contents/MacOS/Roola` を直接実行した場合は同じバイナリでも問題なく起動できた。

切り分けの過程で以下が分かった。

- `codesign --verify --deep --strict` は valid。`spctl --assess` も `Notarized Developer ID`
  で accepted。Gatekeeper / 公証 / 署名は全て通過済み。
- `xattr` に `com.apple.quarantine` は付いていない（quarantine が原因ではない）。
- `lib/main.dart` に診断ログを差し込んで観測したところ、`runApp` の直後まで Dart の main
  関数は完走している。`FlutterError.onError` / `PlatformDispatcher.onError` / `runZonedGuarded`
  のいずれにも例外は届かない。
- `runApp` 後に `Future.delayed(1s)` を仕込んでも 1 秒すら待てずに死ぬ。Dart isolate
  の自然死（microtask / timer 空）でも、`NSSupportsAutomaticTermination` 由来の OS 側自動
  終了でもない（false に設定しても症状変わらず）。
- `launchd` の unified log に決定的な行が残っていた:

```
launchd: exited due to SIGPIPE | sent by Roola[<pid>], ran for 1399ms
```

GUI 起動経路では stdout / stderr の宛先が早期にクローズされる経路があり、Dart / Flutter Engine /
プラグインが起動シーケンス中に write した瞬間にカーネルが SIGPIPE を投げる。デフォルトハンドラ
はプロセス終了であり、Crash Reporter は走らず Dart 例外も発火しないため、原因特定までに数時間
費やした。

## Decision

`macos/Runner/AppDelegate.swift` の `AppDelegate` に `init()` をオーバーライドし、`super.init()`
の前で `signal(SIGPIPE, SIG_IGN)` を呼んで SIGPIPE を恒久的に無視する。

```swift
override init() {
  signal(SIGPIPE, SIG_IGN)
  super.init()
}
```

このシグナルハンドラ設定はプロセス起動の最初期に走る必要があり、AppDelegate の init は
NSApplicationMain より早く呼ばれるためそこに置く。

## Why

- **GUI 起動経路でのみ症状が出る一般的な落とし穴**: Flutter macOS デスクトップでは比較的
  既知の問題で、`flutter_pty` や `window_manager` といった write を行うプラグインを含む
  プロジェクトで再発しやすい。Roola はその両方を持つ。
- **副作用が小さい**: SIGPIPE を無視すると `write(2)` は `errno=EPIPE` を返すだけになる。
  通常はその戻り値で判定するのが本来正しい挙動。シグナルでプロセスごと殺される現状の
  ほうがむしろ異常。
- **配布 DMG として現実的に必要**: ターミナル直起動でしか動かないアプリは配布物として成立
  しないため、回避不可。

## 代替案

### 代替案 1: Dart 側で `ProcessSignal.sigpipe.watch().listen((_) {})` する

`dart:io` の API でハンドリングする案。

- Dart の API は実体としては Flutter Engine が SignalHandler を上書きする形で、ネイティブ
  側で発生する SIGPIPE には間に合わない可能性が高い（Flutter Engine の初期化前に Engine
  が write して SIGPIPE が飛ぶケースを救えない）。
- ネイティブ起動の最初期で `SIG_IGN` するほうが確実。
- 却下。

### 代替案 2: `Info.plist` の `NSSupportsAutomaticTermination=false` で対処

切り分け中に試した案。Automatic Termination は SIGPIPE と無関係なため当然効かなかった。
症状は改善しなかったので不採用。

### 代替案 3: stdout / stderr を起動最初期に `/dev/null` にリダイレクトする

`dup2(open("/dev/null"), STDOUT_FILENO)` などで宛先を差し替えれば SIGPIPE は発生しなくなる。

- 実装は可能だが、ログ目的で stderr を捕捉したいとき（`open --stderr` など）に握り潰す
  ことになり、運用上の柔軟性を失う。
- SIGPIPE 自体を無視するほうがピンポイントで影響範囲が小さい。
- 却下。

## Trade-offs

- **シェル経由で起動した場合でも EPIPE が黙殺される**: パイプ相手が落ちた状態で write して
  も検知できない。Roola は GUI アプリでパイプ越しに何かを stdout に流す運用がないため
  実害は無い。将来 CLI モードを足す場合は別途検討。
- **問題が AppDelegate という Swift 側に隠れる**: Flutter / Dart のレイヤーだけ読むと
  「なぜ落ちないのか」が見えない。ADR への参照コメントを Swift 側に置いて補う。

## References

- 切り分けの過程: `lib/main.dart` に診断ログを段階的に追加し、`launchd` の unified log
  で `SIGPIPE` を発見した経緯。診断コード自体は調査後に削除した。
- 一般情報: Flutter macOS デスクトップで SIGPIPE が起動失敗の原因になるケースは
  Flutter 公式 issue でも複数報告されている既知パターン。
