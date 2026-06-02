## Why

Roola は現在 macOS 専用（ADR-0001）で、Windows 上の開発者は利用できない。Flutter Desktop は Windows をファーストクラスでサポートしており、Flutter 自体・主要依存パッケージ（`flutter_pty`・`window_manager`・`super_drag_and_drop`・`pdfrx` 等）が Windows に対応済みのため、移植コストを許容範囲に抑えながら機能同等の Windows 版を実現できる。

## What Changes

- Flutter Windows プロジェクト（`windows/` ディレクトリ）を追加し、アプリが Windows でビルド・起動できるようにする
- **macOS のターミナル実装（SwiftTerm + `AppKitView`）は変更しない**。Windows のみ xterm.js + WebView2 による新規ターミナルレンダラを追加する（ADR-0031 §将来拡張経路 (a) = OS ごとに実装を持つ方針）
- `PtyTerminalRunner._resolveExecutable` に Windows 分岐を追加し、選択されたシェル（cmd / PowerShell）で PTY を起動できるようにする
- Windows ターミナルで使用するシェル（cmd.exe / powershell.exe / pwsh.exe）をユーザーが設定から選択できる機能を追加する
- `TrashService`・`FileOpener`・`SystemMetricsRepository`・`SparkleUpdater`・macOS 通知（ADR-0057）を Platform インターフェースで抽象化し、Windows 向け実装を追加する
- `ExplorerFileOps` の `cp -R` 呼び出しとパス区切り `/` ハードコードをクロスプラットフォーム対応にする
- `AppMenuBar` の macOS 専用項目（`servicesSubmenu`・`hide`・`hideOtherApplications`・`showAllApplications`・Sparkle「アップデートを確認」）を `Platform.isMacOS` で分岐する
- Windows アプリアイコン（ICO）を追加する
- **BREAKING**: ADR-0001（macOS 専用）を Supersede する新 ADR を追加し、対応プラットフォームを macOS + Windows に拡張する

## Capabilities

### New Capabilities

- `windows-bootstrap`: Flutter Windows プロジェクト初期化。`windows/` runner、アプリ名・Bundle ID（`tech.yahiro.Roola`）相当の設定、Windows アプリアイコン、FVM 対応ビルド手順を整備する
- `terminal-renderer-xterm-js`: **Windows 専用**の新規ターミナルレンダラ。xterm.js を WebView2 に埋め込み、`flutter_pty`（ConPTY）の PTY 出力を描画する。macOS は SwiftTerm を維持し変更しない。`TerminalSurface` を `Platform.isWindows` で条件分岐し、Windows のみ新レンダラを使う
- `windows-shell-selector`: Windows ターミナルで使用するシェルをユーザーが選択できる機能。cmd.exe / powershell.exe（v5）/ pwsh.exe（PS7）から選択可能。設定に保存し、新規ターミナル起動時に反映される。`PtyTerminalRunner._resolveExecutable` に Windows 向けシェル分岐を追加する
- `platform-service-abstraction`: `TrashService`・`FileOpener`・`SystemMetricsRepository`・`UpdateChecker`（Sparkle 抽象）・`NotificationService`（ADR-0057 抽象）を abstract interface に昇格させる。macOS 実装は既存コードを維持し、Windows 実装をそれぞれ追加する（ゴミ箱: Win32 `SHFileOperationW`、ファイル開く: `explorer.exe`、メトリクス: `GlobalMemoryStatusEx` + `pdh.dll`、アップデート確認: GitHub Releases API 参照の簡易チェッカー、通知: Windows Toast UWP API）
- `cross-platform-file-ops`: `ExplorerFileOps.copyInto` の `cp -R` を `dart:io` の再帰コピーループへ置き換え、パス結合・区切り文字を `package:path` で統一する

### Modified Capabilities

（なし — 既存の spec.md は変更なし）

## Impact

- **新規**: `windows/` ディレクトリ（C++ runner）、Windows 向けネイティブプラグイン（`windows/runner/`）、`lib/ui/explorer/terminal_surface_windows.dart`、`lib/data/terminal_runner/windows_shell.dart`
- **変更**: `lib/ui/explorer/terminal_surface.dart`（`Platform.isWindows` 分岐追加）、`lib/data/terminal_runner/pty_terminal_runner.dart`（Windows シェル分岐）、`lib/core/system/`（サービス interface 化）、`lib/core/system/explorer_file_ops.dart`、`lib/app/app_menu_bar.dart`
- **macOS への影響なし**: SwiftTerm・`AppKitView`・`TerminalPlatformView.swift` はそのまま維持する
- **依存追加**: WebView2 パッケージ（`webview_windows` または `flutter_inappwebview`）
- **ADR**: ADR-0058（Windows 対応・ADR-0001 Supersede）を追加。ADR-0031 は Supersede しない（macOS SwiftTerm 塩漬け）
