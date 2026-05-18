## 0. スパイク（go/no-go チェックポイント）

- [x] 0.1 SwiftTerm を Xcode `Runner` の SPM 依存として追加（`main` ブランチ pin。design D8 / issue #2）
- [x] 0.2 SwiftTerm `TerminalView` を載せた `NSView` ＋ `FlutterPlatformViewFactory` を実装（捨てスパイクは作らず 4. の本実装をそのまま最初のビルド対象とした）
- [x] 0.3 (a) ペイン本体に収まりリサイズ追従 — 実機確認済み
- [x] 0.4 (b) 日本語 IME インライン表示 — 実機確認済み（SwiftTerm `main` 必須。design D8）
- [ ] 0.5 (c) 透過ウィンドウとの合成 — 実使用で問題報告なし。明示的なストレス検証は未
- [ ] 0.6 (d) タブ DnD オーバーレイと z-order — 明示検証は未
- [x] 0.7 go/no-go 判定 → **go**（C 採用確定。design「実装中の判断更新」参照）

## 1. PTY 出力のバイト直送（②文字化けの解消）

- [x] 1.1 `pty_terminal_runner.dart` から `utf8.decode`（チャンク単位）を撤去。`output` は PTY 出力バイト列をそのまま配信し、UTF-8 解釈は SwiftTerm の VT パーサに委ねる（byte 直送によりチャンク境界の文字化け②が構造的に解消。Dart 側 streaming デコーダは不要になった）
- [x] 1.2 `output` Stream のテストを byte stream 前提に更新（cancel 後も閉じない）

## 2. data 層: TerminalRunner interface の作り直し

- [x] 2.1 `terminal_runner.dart` から `Terminal get terminal`（xterm.dart 型）と関連 import を削除。`output` / `write` / `resize` / `start` / `cancel` / `dispose` / `state` / `currentState` を維持
- [x] 2.2 `pty_terminal_runner.dart` から `Terminal` フィールド・`terminal.onOutput` / `onResize` 配線・`terminal.write` 呼び出しを削除。`output` Stream を描画の唯一の供給源にする
- [x] 2.3 `Terminal? terminal` を受け取っていた `PtyTerminalRunner` / `fromAction` のコンストラクタ引数を整理

## 3. ブリッジ: Dart ⇄ native チャネル

- [x] 3.1 per-tab の `BasicMessageChannel<ByteData?>`（`BinaryCodec`、channel 名 `roola/terminal/<id>`）を張る `TerminalChannel` を実装
- [x] 3.2 `PtyTerminalRunner.output` を subscribe し native へ `feed` するブリッジ配線（`TerminalSurface` 内。ビュー生成前の出力は `TerminalChannel` がバッファ）
- [x] 3.3 native からの入力・リサイズを受けて `write` / `resize` を呼ぶブリッジ配線。O1 確定: 入力はバイトチャネル直送、リサイズは制御用 `MethodChannel`（`roola/terminal/<id>/ctrl`）に分離

## 4. native（Swift）: SwiftTerm ホスト

- [x] 4.1 SwiftTerm `TerminalView` を載せた `NSView` ＋ `FlutterPlatformViewFactory` を `macos/Runner/TerminalPlatformView.swift` に実装し、`creationParams` の `channelId` でチャネルを開く（viewType `roola/terminal-view`）
- [x] 4.2 `TerminalViewDelegate` を実装し `send`（入力）/ `sizeChanged`（リサイズ）を Dart へ転送
- [x] 4.3 チャネル受信 → `terminalView.feed(byteArray:)` で描画
- [x] 4.4 テーマを適用: 16 ANSI ＋ fg/bg/cursor/selection をネイティブ色型にマップ（`TerminalTheme`）
- [x] 4.5 フォントを適用: バンドル済み `SarasaTermJ-Regular.ttf` を `registrar.lookupKey(forAsset:)` 経由で native 登録し `NSFont` を生成（O3）。失敗時はデフォルト等幅にフォールバック
- [x] 4.6 背景透過を設定し、Flutter 側の暗幕を透かす構成にする
- [x] 4.7 `MainFlutterWindow` で `NSViewFactory` を registrar に登録

## 5. Dart 層: ターミナル面ウィジェット

- [x] 5.1 `AppKitView` をホストし `channelId` を `creationParams` で渡す `TerminalSurface` を `lib/ui/explorer/` に実装
- [x] 5.2 ウィジェットのライフサイクルでブリッジ（3）を生成・破棄。`onPlatformViewCreated` で `markReady`（O2: NSView 保持は `IndexedStack` による mount 維持に依存。DnD 移動時のスクロールバック保持は別途検討）

## 6. View 層の置換

- [x] 6.1 `session_view.dart` の `TerminalView`(xterm.dart) を `TerminalSurface` に置換
- [x] 6.2 配色・フォントは native 側（`TerminalTheme`）に定義。旧 `_terminalTheme` 定数値を Swift へ移設
- [x] 6.3 タブ破棄時に `AdhocRunViewModel` 経由で `PtyTerminalRunner.dispose`、`TerminalSurface` dispose で `TerminalChannel` 解放が連動

## 7. ショートカット

- [x] 7.1 洗い出し結果: Flutter のキーハンドラは `explorer_tab_body.dart` のペインローカルな `C`（パスコピー、ADR-0021）のみ。ウィンドウ操作（⌘N 等）は `NSMenu` の key equivalent。SwiftTerm フォーカス時に壊れるアプリ全体ショートカットは存在しない
- [x] 7.2 対応不要 — 既存ショートカットは `NSMenu` key equivalent（フォーカス非依存）かペインローカルで、SwiftTerm 移行の影響を受けない（ADR-0031 / D7）

## 8. 依存・クリーンアップ

- [x] 8.1 `pubspec.yaml` から `xterm` を削除
- [x] 8.2 `xterm` の import 残りがないことを `flutter analyze` で確認（No issues found）
- [x] 8.3 `docs/architecture.md` のターミナル節を ADR-0031 を踏まえて更新
- [x] 8.4 SwiftTerm を post-1.13.0 の `main` commit に pin（v1.13.0 はインライン IME 描画を欠くため。design D8）。**出口: v1.14.0 リリース時にバージョンタグへ戻す（design D9、issue #2 で追跡）**

## 9. テスト

- [x] 9.1 `TerminalRunner` / `PtyTerminalRunner` のテストを byte stream ベースに更新（`terminal` 依存の検証を除去）
- [x] 9.2 `TerminalChannel` のユニットテスト（バッファ flush・native→Dart 受信のチャネルモック）
- [x] 9.3 `AppKitView` を含む View はウィジェットテスト対象外とし、その旨を `docs/architecture.md` のテスト方針に明記

## 10. 仕上げ

- [x] 10.1 `flutter analyze` / `dart format` を通す（No issues found）
- [x] 10.2 全テストを実行しグリーンを確認（175 件 pass）
- [x] 10.3 実機（macOS）で 5 つの不具合（①〜⑤）の解消を確認（①インライン IME 確認済み、②〜⑤ ユーザー確認。以降に発見した不具合は個別対応）
- [x] 10.4 Conventional Commits（日本語サマリ可）でコミット
