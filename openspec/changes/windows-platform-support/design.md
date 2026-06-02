## Context

Roola は Flutter Desktop (macOS) 専用アプリとして ADR-0001 で設計された。Flutter Desktop は Windows をファーストクラスでサポートしており、`flutter_pty`（ConPTY 経由）・`window_manager`・`super_drag_and_drop` 等の主要依存パッケージは既に Windows 対応済み。主なブロッカーは (1) ターミナルレンダラが macOS 専用（SwiftTerm + `AppKitView`）、(2) OS 固有サービス（TrashService・FileOpener・SystemMetrics・通知・Sparkle）、(3) macOS 前提のファイルパス・コマンド、(4) PTY 起動ロジックの macOS シェル前提（`$SHELL` / `-ilc`）の 4 点。

## Goals / Non-Goals

**Goals:**
- Windows 上で Roola がビルド・起動し、Explorer・ターミナル・Git ビュー・ランチャー・ノートパッドが動作する
- macOS ビルドの既存機能を一切壊さない（SwiftTerm を含め macOS 実装は塩漬け）
- Windows でシェル（cmd / PowerShell）を選択できる

**Non-Goals:**
- macOS ターミナルレンダラの変更（SwiftTerm は維持）
- Windows インストーラ / 配布自動化（ビルドが通れば十分、パッケージングは別 change）
- Windows での Sparkle 相当の自動更新（V1 はバージョン確認表示のみ）
- Linux 対応（今回のスコープ外）

## Decisions

### D1. ターミナルレンダラ: macOS は SwiftTerm 維持、Windows のみ xterm.js + WebView2 を追加

macOS は公開済みで SwiftTerm の品質に依存しているため変更しない（ADR-0031 §将来拡張経路 (a) — OS ごとに実装を持つ並存方針）。Windows 向けには SwiftTerm 相当の埋め込み可能なネイティブ端末ウィジェットが存在しないため、xterm.js + WebView2 を新規追加する。

- **実装分岐**: `lib/ui/explorer/terminal_surface.dart` で `Platform.isWindows` を判定し、macOS は既存の `AppKitView`（SwiftTerm）、Windows は新規 `terminal_surface_windows.dart`（WebView2 + xterm.js）を返す
- **WebView パッケージ**: `webview_windows` パッケージを第一候補とする（Windows 専用・WebView2 対応・Flutter plugin として安定）。`flutter_inappwebview` は Windows 対応が比較的新しいため、導入前に pub score・issue 数を確認して採否を決める
- **xterm.js とのブリッジ**: PTY バイト出力は `WebViewController.runJavaScript("term.write(...)")` で xterm.js の `term.write(data)` に渡す（base64 エンコード経由）。ユーザー入力は xterm.js の `onData` → JS message → Dart `runner.write` へ。リサイズは `term.resize(cols, rows)` を JS 経由で呼ぶ
- **フォント**: SarasaTermJ は `@font-face` で Flutter assets の URI を参照する。`loadHtmlString` の `baseUrl` に `flutter_assets/` を指定してアクセス可能にする
- **セキュリティ**: xterm.js は CDN 参照せず `assets/js/xterm/` にベンダリングする。WebView は外部 URL ナビゲーションをブロックする

### D2. Windows シェル選択

Windows では `$SHELL` が存在せず、Unix の `-ilc` ラッパーも使えない。`PtyTerminalRunner._resolveExecutable` に Windows 分岐を追加し、設定で選択されたシェルに応じてコマンドを組み立てる。

```
OpenHereAction  (Windows) → 選択シェルを直接起動
  cmd:          cmd.exe
  powershell:   powershell.exe -NoExit
  pwsh:         pwsh.exe -NoExit

RunCommandAction (Windows) → シェル経由でコマンド実行
  cmd:          cmd.exe /K <command>   (/C + keepShell 時は /K)
  powershell:   powershell.exe -NoExit -Command <command>
  pwsh:         pwsh.exe -NoExit -Command <command>

ClaudeSkillAction (Windows) → V1 は未サポート（エラーメッセージを表示）
```

シェル設定は新規モデル `WindowsShell`（enum: `cmd` / `powershell` / `pwsh`）として `lib/data/terminal_runner/windows_shell.dart` に定義し、`AppearanceSettings` ではなく **`TerminalSettings`**（新規 `lib/data/terminal_settings/terminal_settings.dart`）に保持する。責務の分離のため外観設定と端末設定を分けて持つ。

```
lib/data/terminal_settings/
  terminal_settings.dart          ← Freezed モデル（windowsShell フィールドのみ）
  terminal_settings_dto.dart
  terminal_settings_dto.g.dart
  terminal_settings_repository.dart
  terminal_settings_repository_impl.dart
```

`AppPaths` に `terminalSettingsFile` を追加する。設定 UI は Settings ページの「ターミナル」セクションとして追加し、Windows のみ表示する（`Platform.isWindows` 判定）。

### D3. プラットフォームサービスの抽象化方針

CLAUDE.md の規約「差し替え可能性が必要な箇所のみ Repository pattern + interface を残す」に従い、OS ごとに実装が異なるサービスのみ interface に昇格させる。

```
lib/core/system/
  trash_service.dart          → abstract interface TrashService
  trash_service_macos.dart    → method channel（既存コードを移動）
  trash_service_windows.dart  → Win32 SHFileOperationW（新規）
  file_opener.dart            → abstract interface FileOpener
  file_opener_macos.dart      → Process.run('open', ...)（既存コードを移動）
  file_opener_windows.dart    → Process.run('explorer.exe', ...)（新規）
  update_checker.dart         → abstract interface UpdateChecker
  update_checker_macos.dart   → SparkleUpdater ラッパー（既存）
  update_checker_windows.dart → GitHub Releases API 参照（新規）

lib/data/activity_metrics/
  system_metrics_repository.dart       → abstract interface に変更
  system_metrics_repository_macos.dart → method channel（既存コードを移動）
  system_metrics_repository_windows.dart → Win32 GlobalMemoryStatusEx + PDH（新規）

lib/data/task_notification/
  notification_service.dart          → abstract interface（新規）
  notification_service_macos.dart    → UNUserNotificationCenter（既存コードを移動）
  notification_service_windows.dart  → local_notifier パッケージ（新規）
```

Factory は `lib/core/platform_factory.dart` に集約し `Platform.isMacOS` / `Platform.isWindows` で分岐する。Provider は factory を呼ぶだけにする。

### D4. Windows ネイティブプラグインの実装場所

`TrashService` と `SystemMetricsRepository` は Win32 API（`SHFileOperationW`・`GlobalMemoryStatusEx`・`PDH`）を C++ で呼ぶ必要がある。`windows/runner/` 内に `MethodChannel` ハンドラとして実装する（専用 plugin パッケージは作らない）。macOS の Swift 実装が `macos/Runner/` にあるのと対称的な配置。

`FileOpener`（Windows）と `UpdateChecker`（Windows）は `Process.run` / `dart:io` HTTP で実装できるため C++ 不要。

### D5. パス処理

`ExplorerFileOps.copyInto` の `cp -R` を `dart:io` 再帰コピー（walk + `File.copy`）に置き換える。パス結合は `package:path` の `join` / `dirname` / `basename` を使う。`DirectoryWatcher._relativize` の `/` は `Platform.pathSeparator` に変える。

### D6. AppMenuBar の分岐

`PlatformProvidedMenuItemType.servicesSubmenu`・`hide`・`hideOtherApplications`・`showAllApplications` は macOS 専用。Sparkle「アップデートを確認」は macOS のみ。`if (Platform.isMacOS)` で直書きする。Windows では `UpdateChecker` Windows 実装を呼ぶ「アップデートを確認」項目に置き換える。

## Risks / Trade-offs

- **レンダラ 2 本の並行保守**: macOS=SwiftTerm・Windows=xterm.js で 2 実装を維持する。将来 Linux 等を追加するたびに増える。→ 今後 OS が増えた時点で全面 xterm.js 化（ADR-0031 §経路 b）を改めて判断する
- **WebView2 のインストール前提**: Windows 11 は標準搭載、Windows 10 は Edge Chromium 同梱で大半の環境に入っている。未インストール環境ではターミナルが起動しない。→ V1 は「WebView2 が必要」をドキュメントに記載するにとどめる
- **PDH / SHFileOperationW C++ コード**: Windows C++ プラグインのビルドには MSVC が必要。→ CI に `windows-latest` ジョブを追加する
- **pwsh.exe 未インストール環境**: PowerShell 7（`pwsh`）は別途インストールが必要。選択肢には残しつつ、起動時に `pwsh.exe` が見つからない場合は設定 UI にエラー表示する
- **ClaudeSkillAction の Windows 非対応**: Claude Code の公式 Windows サポート状況に依存するため V1 は対応しない。ランチャーから Claude Skill を起動しようとした場合はエラーメッセージを表示する

## Migration Plan

1. **Phase 1 — ブートストラップ**: `flutter create --platforms=windows .` で `windows/` 生成。ターミナル以外の機能が起動する状態まで持っていく
2. **Phase 2 — サービス抽象化**: D3 の interface 分割・factory 実装。macOS ビルドが壊れないことを確認
3. **Phase 3 — パス・コマンド修正**: D5（ファイルパス）・D6（メニュー分岐）を適用
4. **Phase 4 — xterm.js ターミナル（Windows）**: D1 の Windows 専用レンダラを実装。ConPTY（`flutter_pty`）+ xterm.js + WebView2 の組み合わせを Windows 実機で検証
5. **Phase 5 — シェル選択**: D2 の `TerminalSettings`・`WindowsShell` モデル・設定 UI・`PtyTerminalRunner` Windows 分岐を実装
6. **Phase 6 — Windows 全機能テスト**: 全機能を Windows 実機または VM で確認。CI に Windows ビルドジョブ追加

## Open Questions

- `webview_windows` vs `flutter_inappwebview`: `webview_windows` は Windows 専用で軽量だが macOS 版が存在しない（macOS は SwiftTerm を維持するため問題ない）。最終決定は package の pub score・active maintenance 状況を確認してから行う
- Windows Toast 通知に `local_notifier` を使うか C++ の WinRT API 直呼びにするか（`local_notifier` は Windows 実績あり）
