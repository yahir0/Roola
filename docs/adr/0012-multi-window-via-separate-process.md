# ADR-0012: マルチウィンドウは別プロセス起動で実現する（共有 Engine 方式は後追い検討）

- **Status**: Accepted
- **Date**: 2026-05-14

## Context

Roola を Finder のように複数ウィンドウで使いたいという要望が出た。具体的には:

- ファイルメニューの「新規ウィンドウ」（⌘N）から空のエクスプローラを別ウィンドウで開きたい
- Dock 右クリックの「新規ウィンドウ」からも同じ操作をしたい
- 同時に複数のディレクトリを並べて見たい

Flutter Desktop で複数ウィンドウを実現する選択肢:

1. **別プロセス起動**: `NSWorkspace.openApplication(at:configuration:)` で `createsNewApplicationInstance: true` を指定し、Roola.app の新しいインスタンスを起動する
2. **`desktop_multi_window` プラグイン**: 1 プロセス内で複数 Flutter エンジンを保持し、それぞれが独立した Dart isolate を持つ
3. **Swift で NSWindow + 共有 FlutterEngine**: 1 プロセス・1 エンジンで Flutter desktop の multi-view API（実験段階）を使い、複数 NSWindow に同じ Dart isolate を渡す

## Decision

**当面は 1（別プロセス起動）で実装する**。`NSWorkspace.shared.openApplication(at: bundleURL, configuration: ...)` を AppDelegate の `@IBAction newWindow(_:)` から呼ぶ。Dock 右クリックメニュー（`applicationDockMenu(_:)`）からも同じアクションを発火する。

将来「Finder と同じく状態をリアルタイム共有したい」と決まったら、3（Swift + 共有 Engine + multi-view API）への移行を検討する。

## Why

### 代替案 1: `desktop_multi_window` プラグイン

却下（当面）。

- プラグインの仕様上、window ごとに別 Dart isolate になり、Riverpod の Container も window ごとに独立する
- 結局「状態がリアルタイム同期しない」点は別プロセスと変わらない
- にもかかわらず、window ID 管理・初期 route の引き渡し・IPC（ファイル経由 or message channel）など実装は重い
- 「軽い別プロセス」レベルの体験のために、依存とコードを増やす意義が薄い

### 代替案 2: Swift NSWindow + 共有 FlutterEngine（multi-view API）

却下（当面）。

- 真の「Finder 等価」状態共有を実現する唯一の道だが、Flutter desktop の multi-view API（`FlutterView` / `FlutterMultiView`）は **2026 年時点で実験段階** で安定 API ではない
- `MaterialApp` / `Navigator` / `go_router` などが multi-view 対応していない可能性が高く、UI 層の大幅な書き換えが必要
- 実装 + 検証で 1〜2 日溶ける見込み
- DMG リリースを早く出す目下のゴールに合わない

### 採用理由（別プロセス）

- `NSWorkspace.openApplication` 数行で完結。プラグイン依存なし
- 各 window が完全に独立したプロセスのため、片方がクラッシュしても他方は無傷
- macOS の標準的な「multi-instance app」挙動。ユーザーから見て自然
- 実装が小さく、後から方針を変えても捨てやすい

## Trade-offs

### 状態がリアルタイム同期しない

window A で launcher entry を追加 / 削除しても、window B のホーム画面は再起動するまで反映されない。設定変更（透過モード等）も同様。ユーザーは「設定変更後は他ウィンドウを開き直す」運用になる。

**緩和案**:

- 永続化ファイル（`launcher_entries.json` 等）に対する `FileSystemEvent` watch を Riverpod 側に仕込んで、外部変更を検知して `invalidate` する
- ただし実装は重いので、まず「不便だ」というフィードバックが上がってから対応する

### JSON 永続化ファイルの書き込み競合

`launcher_entries.json` / `appearance_settings.json` 等を 2 プロセスで同時に書こうとすると、後勝ちで一方の変更が消える可能性がある。実用上は:

- ユーザーが 2 つの window を行き来しながら同時に設定を変える機会はほぼ無い
- 書き込みは ms 単位で完了する

ため、実害が出るのは極めて稀。発生したら lock ファイル or 単一プロセス化（代替案 2）で根本対応する。

### プロセス数 / メモリ

各 window が独立した Flutter Engine + PTY セッションを抱えるため、N window 開くと N プロセス・N × (Flutter + PTY) メモリ。Roola の想定使い方（2〜3 window）では実用上問題ない。

### Dock アイコンが 1 個に見える

`createsNewApplicationInstance` で別プロセスを起動しても、bundle ID は同じなので Dock のアイコンは 1 個。複数 instance が走っていても見た目で気付きにくい。Finder と同じ挙動なので許容。

### `applicationShouldTerminateAfterLastWindowClosed` は true のまま

各プロセスが 1 window を持つため、その window を閉じれば該当プロセスは終了する。他プロセス（他 window）は生き続けるので、ユーザー視点では「Finder のように window を閉じてもアプリは動き続ける」体験になる。

## 将来の見直し条件

以下のいずれかが満たされたら、代替案 2（Swift + 共有 Engine + multi-view）への移行を本格検討する:

- ユーザーから「window 間で設定が即同期しないのが不便」というフィードバックが複数回
- Flutter desktop multi-view API が stable 化し、`MaterialApp` / `go_router` 等が公式対応
- launcher_entries.json の書き込み競合に起因するデータロスが実際に発生

検討時はこの ADR を Superseded にし、新 ADR を起こす。

## References

- https://developer.apple.com/documentation/appkit/nsworkspace/openconfiguration
- https://developer.apple.com/documentation/appkit/nsworkspace/3172700-openapplication
- Flutter multi-view (実験段階): https://github.com/flutter/flutter/issues/30701
- ADR-0001: Flutter Desktop（macOS）採用（前提となる選択）
