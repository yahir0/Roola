# ADR-0058: Windows 対応（ADR-0001 Supersede）

- **Status**: Accepted
- **Date**: 2026-06-01
- **Supersedes**: ADR-0001

## Context

ADR-0001 は Flutter Desktop を macOS 専用として採用した。Windows 上の開発者が Roola を利用できないという制約が残っていた。

Flutter Desktop は Windows をファーストクラスでサポートしており、主要依存パッケージ（`flutter_pty`・`window_manager`・`super_drag_and_drop`・`pdfrx` 等）が Windows に対応済みであることが確認された。主なブロッカーは以下の 4 点:

1. ターミナルレンダラが macOS 専用（SwiftTerm + `AppKitView`）
2. OS 固有サービス（TrashService・FileOpener・SystemMetrics・通知・Sparkle）
3. macOS 前提のファイルパス・コマンド（`cp -R`・`/` ハードコード）
4. PTY 起動ロジックの macOS シェル前提（`$SHELL` / `-ilc`）

## Decision

対応プラットフォームを macOS + Windows に拡張する。

**macOS の実装は一切変更しない**。SwiftTerm・`AppKitView`・`TerminalPlatformView.swift` はそのまま維持する（塩漬け方針）。

Windows 向けには以下の戦略を採る:

- **ターミナルレンダラ**: xterm.js + WebView2 による新規実装を `TerminalSurfaceWindows` として追加する。`TerminalSurface` で `Platform.isWindows` により分岐する（ADR-0031 §将来拡張経路 (a) = OS ごとに実装を持つ並存方針）
- **シェル選択**: `WindowsShell` enum（cmd / powershell / pwsh）と `TerminalSettings` モデルを追加し、`PtyTerminalRunner._resolveExecutable` に Windows 分岐を追加する
- **プラットフォームサービス**: `TrashService`・`FileOpener`・`UpdateChecker`・`SystemMetricsRepository`・`NotificationService` を abstract interface に昇格させ、macOS 実装はファイルを `_macos.dart` に移動、Windows 実装を `_windows.dart` として追加する。各 Provider の factory は `lib/core/platform_factory.dart` に集約する
- **パス処理**: `ExplorerFileOps.copyInto` の `cp -R` を `dart:io` 再帰コピーに置き換え、パス結合を `package:path` に統一する
- **メニューバー**: macOS 専用項目（`servicesSubmenu`・`hide`・`hideOtherApplications`・`showAllApplications`・Sparkle）を `Platform.isMacOS` で分岐する

## Why

### macOS SwiftTerm を変更しない理由

macOS 版は公開済みで SwiftTerm の品質に依存している。ADR-0031 は SwiftTerm ネイティブビューへの移行を選択した判断であり、これを覆す理由がない。OS ごとに実装を持つ並存方針（ADR-0031 §将来拡張経路 (a)）を採ることで、macOS の品質を維持しながら Windows を追加できる。

### xterm.js + WebView2 を選択した理由

Windows では SwiftTerm 相当の埋め込み可能なネイティブ端末ウィジェットが存在しない。`webview_windows` パッケージは Windows 専用・WebView2 対応で Flutter plugin として安定しており、xterm.js をローカルベンダリングすることで CDN 依存なしに動作させられる。

### interface 化の範囲を OS 固有サービスに限定する理由

CLAUDE.md の規約「差し替え可能性が必要な箇所のみ Repository pattern + interface を残す」に従い、OS ごとに実装が異なるサービスのみを interface 化する。UI レイヤー・ビジネスロジックには影響を与えない。

## Trade-offs

- **レンダラ 2 本の並行保守**: macOS=SwiftTerm・Windows=xterm.js で 2 実装を維持する。将来 Linux 等を追加するたびに増える。その時点で全面 xterm.js 化（ADR-0031 §経路 b）を改めて判断する
- **WebView2 のインストール前提**: Windows 11 は標準搭載、Windows 10 は Edge Chromium 同梱で大半の環境に入っているが、未インストール環境ではターミナルが起動しない。V1 は「WebView2 が必要」をドキュメントに記載するにとどめる
- **ClaudeSkillAction の Windows 対応**: Claude Code が公式に Windows をサポートしたため、PowerShell / pwsh では `-Command "claude /skillName"`、cmd では `/C claude /skillName` で起動する。`claude` は PATH に存在する前提（macOS と同条件）

## References

- ADR-0001: Flutter Desktop（macOS）を採用
- ADR-0031: ターミナル描画を xterm.dart から SwiftTerm ネイティブビューへ移行する
- ADR-0057: Claude Code のタスク完了を Stop フック + ローカル受信口で macOS 通知する
- webview_windows: https://pub.dev/packages/webview_windows
- xterm.js: https://xtermjs.org/
