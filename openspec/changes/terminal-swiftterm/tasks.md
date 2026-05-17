## 0. スパイク（go/no-go チェックポイント）

- [ ] 0.1 SwiftTerm を Xcode `Runner` の SPM 依存として追加し、ビルドが通ることを確認
- [ ] 0.2 SwiftTerm の `TerminalView` を載せた最小の `NSView` ＋ `NSViewFactory` を登録し、`AppKitView` で 1 枚表示する捨てスパイクを作る
- [ ] 0.3 (a) ペイン本体に収まりリサイズ追従するか実測
- [ ] 0.4 (b) 日本語 IME（変換中テキストのインライン表示・確定）が通るか実測
- [ ] 0.5 (c) 透過ウィンドウ（フラットテーマの暗幕）と合成が崩れないか実測
- [ ] 0.6 (d) タブ DnD オーバーレイとプラットフォームビューの z-order が破綻しないか実測
- [ ] 0.7 go/no-go 判定。no-go なら ADR-0031 に差し戻し本 change を中断。go なら 1 以降へ（スパイクコードは破棄）

## 1. 先行修正: streaming UTF-8 デコード（移行と独立）

- [ ] 1.1 `pty_terminal_runner.dart` の PTY 出力 `utf8.decode`（チャンク単位）を `Utf8Decoder` の chunked conversion（streaming）に置き換え、マルチバイト文字のチャンク境界またぎを解消
- [ ] 1.2 チャンク境界をまたぐ日本語バイト列のデコードテストを追加
- [ ] 1.3 `xterm` のまま `flutter analyze` / 全テストを通し、先行コミット（必要なら別 PR）

## 2. data 層: TerminalRunner interface の作り直し

- [ ] 2.1 `terminal_runner.dart` から `Terminal get terminal`（xterm.dart 型）と関連 import を削除。`output` / `write` / `resize` / `start` / `cancel` / `dispose` / `state` / `currentState` を維持
- [ ] 2.2 `pty_terminal_runner.dart` から `Terminal` フィールド・`terminal.onOutput` / `onResize` 配線・`terminal.write` 呼び出しを削除。`output` Stream を描画の唯一の供給源にする
- [ ] 2.3 `Terminal? terminal` を受け取っていた `PtyTerminalRunner` / `fromAction` のコンストラクタ引数を整理

## 3. ブリッジ: Dart ⇄ native チャネル

- [ ] 3.1 per-tab の `BasicMessageChannel<ByteData>`（`BinaryCodec`、channel 名 `roola/terminal/<tabId>`）を張る Dart 側ブリッジを実装
- [ ] 3.2 `PtyTerminalRunner.output` を subscribe し native へ `feed` するブリッジ配線
- [ ] 3.3 native からの入力・リサイズを受けて `write` / `resize` を呼ぶブリッジ配線（O1: 多重化方式を確定）

## 4. native（Swift）: SwiftTerm ホスト

- [ ] 4.1 SwiftTerm `TerminalView` を載せた `NSView` ＋ `NSViewFactory` を `macos/Runner/` に実装し、`creationParams` の `tabId` でチャネルを開く
- [ ] 4.2 `TerminalViewDelegate` を実装し `send`（入力）/ `sizeChanged`（リサイズ）を Dart へ転送
- [ ] 4.3 チャネル受信 → `terminalView.feed(byteArray:)` で描画
- [ ] 4.4 テーマを適用: `_terminalTheme` の 16 ANSI ＋ fg/bg/cursor/selection をネイティブ色型にマップ
- [ ] 4.5 フォントを適用: バンドル済み `SarasaTermJ.ttf` を native で登録し `NSFont` を生成（O3: 同梱方式を確定）。失敗時はデフォルト等幅にフォールバック
- [ ] 4.6 背景透過を設定し、Flutter 側の暗幕を透かす構成にする

## 5. Dart 層: ターミナル面ウィジェット

- [ ] 5.1 `AppKitView` をホストし `tabId` を `creationParams` で渡すターミナル面ウィジェットを `lib/ui/explorer/` に実装
- [ ] 5.2 ウィジェットのライフサイクルでブリッジ（3）を生成・破棄。NSView 保持戦略を実装（O2 を確定）

## 6. View 層の置換

- [ ] 6.1 `session_view.dart` の `TerminalView`(xterm.dart) を新ターミナル面ウィジェットに置換
- [ ] 6.2 `_terminalTheme` / `_terminalStyle` を native へ渡す経路に組み替え（描画自体は native 側、Dart 側定数は native へのマッピング元として保持 or 移設）
- [ ] 6.3 タブ破棄時に `PtyTerminalRunner.dispose` ＋ native NSView・チャネル解放が連動することを確認

## 7. ショートカット

- [ ] 7.1 SwiftTerm フォーカス時に効かなくなるアプリショートカットを洗い出す
- [ ] 7.2 必要なショートカットを `NSMenu` の key equivalent 経由に寄せる（ADR-0031 / D7）

## 8. 依存・クリーンアップ

- [ ] 8.1 `pubspec.yaml` から `xterm` を削除
- [ ] 8.2 `xterm` の import 残りがないことを `flutter analyze` で確認
- [ ] 8.3 `docs/architecture.md` のターミナル節を ADR-0031 を踏まえて更新

## 9. テスト

- [ ] 9.1 `TerminalRunner` / `PtyTerminalRunner` のテストを byte stream ベースに更新（`terminal` 依存の検証を除去）
- [ ] 9.2 streaming UTF-8 デコーダの境界またぎテスト（1.2 を本 change スコープで再掲・維持）
- [ ] 9.3 Dart 側ブリッジのユニットテスト（チャネル送受信のモック）
- [ ] 9.4 `AppKitView` を含む View はウィジェットテスト対象外とし、その旨をテスト方針に明記

## 10. 仕上げ

- [ ] 10.1 `flutter analyze` / `dart format` を通す
- [ ] 10.2 全テストを実行しグリーンを確認
- [ ] 10.3 実機（macOS）で 5 つの不具合（①〜⑤）が解消したことを確認
- [ ] 10.4 Conventional Commits（日本語サマリ可）でコミット
