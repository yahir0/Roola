# ADR-0001: Flutter Desktop（macOS）を採用

- **Status**: Accepted
- **Date**: 2026-05-11

## Context

Mac 上で Claude Code の Skills を起動するワンクリックランチャーアプリを作る。動作環境は Mac に限定する。クロスプラットフォーム要件は当面無いが、将来 Linux / Windows へ展開する余地は閉じたくない。

本アプリで技術的に必須となる要素:

- PTY（擬似端末）統合ターミナル: 子プロセスを擬似端末上で起動し、ANSI 制御を解釈して描画、矢印キー・Ctrl 修飾・ペースト等の対話入力を送れる
- 透過ウィンドウ・カスタム背景の描画
- ローカルファイル（JSON 永続化・アイコン画像）への自由なアクセス

これらを満たす技術スタックを選定する必要がある。

## Decision

Flutter Desktop の macOS ターゲットを採用する。`flutter create --platforms=macos` で macOS 専用プロジェクトとして初期化する。

## Why

### 代替案 1: SwiftUI（ネイティブ）

却下。理由:

- macOS / iOS ネイティブに固定され、将来 Linux / Windows へ展開する余地が消える
- xterm 互換のターミナル UI と PTY 統合に使える成熟したライブラリ群（Dart 版 `xterm` + `flutter_pty` 相当）が Swift 側では Flutter エコシステムほど揃っていない（SwiftTerm 等は存在するが利用例が少なくメンテナンス頻度に差がある）
- 単一バイナリ・配布の手軽さは Flutter Desktop と同等で、それを理由に SwiftUI を選ぶ動機が無い

### 代替案 2: Electron / Tauri

却下。理由:

- Electron はバイナリサイズが数十 MB を下回らず、軽量ランチャーという本アプリの主旨に反する
- Tauri はフロントエンド ↔ Rust 間の IPC を介する設計になり、PTY ストリームのリアルタイム橋渡し・サイズ変更通知・終了ステータス連携が Flutter Desktop の直接統合（`flutter_pty` + `xterm` を同一プロセス内）より複雑
- どちらも DOM ベース描画で、透過ウィンドウ・任意背景のカスタム描画コストが Flutter のネイティブ Skia 描画より大きく、メモリ使用量も増える

### 採用理由（Flutter Desktop）

- **PTY 統合が言語境界なし**: `flutter_pty` + `xterm`（Dart 版）の組み合わせで、PTY バイトストリーム ↔ ターミナル描画 ↔ キー入力送信を単一 Dart プロセス内で完結できる。IPC 設計が不要
- **採用ライブラリの揃い**: Riverpod / flutter_hooks / Freezed / go_router 等、本プロジェクトで採用するライブラリ群が Flutter エコシステムに揃っている（詳細は `docs/architecture.md`）
- **テーマシステムの相性**: Material 3 + ThemeData ベースのテーマシステムが、カスタム背景・透過要件と組み合わせやすい
- **Mac 限定ターゲットでの安定性**: Flutter Desktop の弱点である Windows / Linux 間のプラットフォーム差が、Mac のみターゲットなら顕在化しない
- **Hot reload による開発速度**: UI 反復が速く、デザインシステムの調整がしやすい

## Trade-offs

- Flutter Desktop は iOS / Android ほど成熟しておらず、Skia レンダリング由来の表示差や、特定 macOS API（メニューバー細部・Vibrancy など）のサポートが Swift ネイティブより薄い
- 配布フェーズで Mac App Store / コード署名 / 公証手順が必要になるが、これは他の選択肢でも同様
- 本 ADR は Mac のみサポートを前提とした判断。Windows / Linux を視野に入れた瞬間に再評価が必要

## References

- Flutter for desktop: https://docs.flutter.dev/platform-integration/desktop
- flutter_pty: https://pub.dev/packages/flutter_pty
- xterm: https://pub.dev/packages/xterm
