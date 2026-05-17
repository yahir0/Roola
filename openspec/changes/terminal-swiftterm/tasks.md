## 0. スパイク（go/no-go チェックポイント）

- [ ] 0.1 SwiftTerm を Xcode `Runner` の SPM 依存として追加し、ビルドが通ることを確認
- [ ] 0.2 SwiftTerm の `TerminalView` を載せた最小の `NSView` ＋ `NSViewFactory` を登録し、`AppKitView` で 1 枚表示する
- [ ] 0.3 (a) ペイン本体に収まりリサイズ追従するか実測
- [ ] 0.4 (b) 日本語 IME（変換中テキストのインライン表示・確定）が通るか実測
- [ ] 0.5 (c) 透過ウィンドウ（フラットテーマの暗幕）と合成が崩れないか実測
- [ ] 0.6 (d) タブ DnD オーバーレイとプラットフォームビューの z-order が破綻しないか実測
- [ ] 0.7 go/no-go 判定。no-go なら ADR-0031 に差し戻し本 change を中断
      （捨てスパイクは作らず、4. の本実装 NSViewFactory をそのまま最初の
      ビルド対象とし、最初の実機ビルドで 0.3〜0.6 を確認する方針）

## 1. PTY 出力のバイト直送（②文字化けの解消）

- [x] 1.1 `pty_terminal_runner.dart` から `utf8.decode`（チャンク単位）を撤去。
      `output` は PTY 出力バイト列をそのまま配信し、UTF-8 解釈は SwiftTerm の
      VT パーサに委ねる（byte 直送によりチャンク境界の文字化け②が構造的に解消。
      Dart 側 streaming デコーダは不要になった）
- [x] 1.2 `output` Stream のテストを byte stream 前提に更新（cancel 後も閉じない）

## 2. data 層: TerminalRunner interface の作り直し

- [x] 2.1 `terminal_runner.dart` から `Terminal get terminal`（xterm.dart 型）と関連 import を削除。`output` / `write` / `resize` / `start` / `cancel` / `dispose` / `state` / `currentState` を維持
- [x] 2.2 `pty_terminal_runner.dart` から `Terminal` フィールド・`terminal.onOutput` / `onResize` 配線・`terminal.write` 呼び出しを削除。`output` Stream を描画の唯一の供給源にする
- [x] 2.3 `Terminal? terminal` を受け取っていた `PtyTerminalRunner` / `fromAction` のコンストラクタ引数を整理

## 3. ブリッジ: Dart ⇄ native チャネル

- [x] 3.1 per-tab の `BasicMessageChannel<ByteData?>`（`BinaryCodec`、channel 名 `roola/terminal/<id>`）を張る `TerminalChannel` を実装
- [x] 3.2 `PtyTerminalRunner.output` を subscribe し native へ `feed` するブリッジ配線（`TerminalSurface` 内。ビュー生成前の出力は `TerminalChannel` がバッファ）
- [x] 3.3 native からの入力・リサイズを受けて `write` / `resize` を呼ぶブリッジ配線。
      O1 確定: 入力はバイトチャネル直送、リサイズは制御用 `MethodChannel`
      （`roola/terminal/<id>/ctrl`）に分離

## 4. native（Swift）: SwiftTerm ホスト

- [x] 4.1 SwiftTerm `TerminalView` を載せた `NSView` ＋ `FlutterPlatformViewFactory` を `macos/Runner/` に実装し、`creationParams` の `channelId` でチャネルを開く（viewType `roola/terminal-view`）
- [x] 4.2 `TerminalViewDelegate` を実装し `send`（入力）/ `sizeChanged`（リサイズ）を Dart へ転送
- [x] 4.3 チャネル受信 → `terminalView.feed(byteArray:)` で描画
- [x] 4.4 テーマを適用: 16 ANSI ＋ fg/bg/cursor/selection をネイティブ色型にマップ
- [x] 4.5 フォントを適用: バンドル済み `SarasaTermJ-Regular.ttf` を `registrar.lookupKey(forAsset:)` 経由で native 登録し `NSFont` を生成（O3）。失敗時はデフォルト等幅にフォールバック
- [x] 4.6 背景透過を設定し、Flutter 側の暗幕を透かす構成にする
- [x] 4.7 `MainFlutterWindow` で `NSViewFactory` を registrar に登録

## 5. Dart 層: ターミナル面ウィジェット

- [x] 5.1 `AppKitView` をホストし `channelId` を `creationParams` で渡す `TerminalSurface` を `lib/ui/explorer/` に実装
- [x] 5.2 ウィジェットのライフサイクルでブリッジ（3）を生成・破棄。`onPlatformViewCreated` で `markReady`（O2: NSView 保持は IndexedStack による mount 維持に依存。DnD 移動時のスクロールバック保持は別途検討）

## 6. View 層の置換

- [x] 6.1 `session_view.dart` の `TerminalView`(xterm.dart) を `TerminalSurface` に置換
- [x] 6.2 配色・フォントは native 側（4.4 / 4.5）に定義。旧 `_terminalTheme` 定数値を Swift（`TerminalTheme`）へ移設
- [x] 6.3 タブ破棄時に `AdhocRunViewModel` 経由で `PtyTerminalRunner.dispose`、`TerminalSurface` dispose で `TerminalChannel` 解放が連動

## 7. ショートカット

- [ ] 7.1 SwiftTerm フォーカス時に効かなくなるアプリショートカットを洗い出す
- [ ] 7.2 必要なショートカットを `NSMenu` の key equivalent 経由に寄せる（ADR-0031 / D7）

## 8. 依存・クリーンアップ

- [x] 8.1 `pubspec.yaml` から `xterm` を削除
- [x] 8.2 `xterm` の import 残りがないことを `flutter analyze` で確認（No issues found）
- [ ] 8.3 `docs/architecture.md` のターミナル節を ADR-0031 を踏まえて更新

## 9. テスト

- [x] 9.1 `TerminalRunner` / `PtyTerminalRunner` のテストを byte stream ベースに更新（`terminal` 依存の検証を除去）
- [ ] 9.2 `TerminalChannel` のユニットテスト（チャネル送受信のモック・バッファ flush）
- [ ] 9.3 `AppKitView` を含む View はウィジェットテスト対象外とし、その旨をテスト方針に明記

## 10. 仕上げ

- [ ] 10.1 `flutter analyze` / `dart format` を通す
- [ ] 10.2 全テストを実行しグリーンを確認
- [ ] 10.3 実機（macOS）で 5 つの不具合（①〜⑤）が解消したことを確認
- [ ] 10.4 Conventional Commits（日本語サマリ可）でコミット
