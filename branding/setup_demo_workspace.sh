#!/usr/bin/env bash
#
# スクリーンショット撮影用のデモワークスペースを /Users/Shared/Roola-demo に作る。
#
# 目的: README / 宣伝画像用のスクショに、実際の作業ディレクトリやお気に入り・
# アドレスバーの機密情報が映り込まないよう、汎用的なサンプルプロジェクトを用意する。
# Git ビューが populated に見えるよう、コミット履歴と staged/modified/untracked の
# 作業状態まで再現する。作者は "Roola Demo" 固定（実名が出ないように）。
#
# 使い方: bash branding/setup_demo_workspace.sh
# 撤去:   rm -rf /Users/Shared/Roola-demo

set -euo pipefail

ROOT="/Users/Shared/Roola-demo"
DEMO_DATE="2026-05-20T23:16:00"

rm -rf "$ROOT"
mkdir -p "$ROOT"/{app,docs,scripts,tests,lib/launcher,lib/terminal}

# --- サンプルファイル（中身は汎用・機密なし）------------------------------
cat > "$ROOT/README.md" <<'MD'
# Roola demo

A sample project used only for screenshots.

- `app/`     - application sources
- `docs/`    - design notes and ADRs
- `tests/`   - unit and integration tests
- `scripts/` - release and build scripts

## Quick commands

```sh
make build
make test
make release
```
MD

# Makefile（撮影用にクリーンな出力を出す。README の Quick commands と整合）
cat > "$ROOT/Makefile" <<'MK'
build:
	@echo "==> flutter build macos --release"
	@echo "Built Roola-demo.app (12.4 MB)"

test:
	@echo "==> flutter test"
	@echo "00:03 +12: All tests passed!"

release:
	@echo "==> packaging Roola-demo v0.1.0"
	@echo "Created dist/Roola-demo-0.1.0.dmg"
MK

cat > "$ROOT/app/main.dart" <<'DART'
import 'launcher_view.dart';

void main() {
  runApp(const LauncherView());
}
DART

cat > "$ROOT/docs/architecture.md" <<'MD'
# Architecture

MVVM-based three-group layout (ui / data / core).
MD

cat > "$ROOT/scripts/build.sh" <<'SH'
#!/usr/bin/env bash
flutter build macos --release
SH
chmod +x "$ROOT/scripts/build.sh"

cat > "$ROOT/tests/launcher_test.dart" <<'DART'
void main() {
  // sample test placeholder
}
DART

cat > "$ROOT/lib/launcher/entry.dart" <<'DART'
class LauncherEntry {
  final String id;
  final String name;
  final String directory;

  const LauncherEntry({
    required this.id,
    required this.name,
    required this.directory,
  });
}
DART

# --- git 履歴を作る（作者は Roola Demo 固定）-------------------------------
cd "$ROOT"
git init -q
git config user.name "Roola Demo"
git config user.email "demo@example.com"
git config commit.gpgsign false

commit() { # $1 = message, $2 = offset minutes
  GIT_AUTHOR_DATE="$DEMO_DATE" GIT_COMMITTER_DATE="$DEMO_DATE" \
    git commit -q -m "$1"
}

# 1) initial skeleton
echo "build/" > .gitignore
git add .gitignore README.md Makefile docs scripts tests
commit "feat: initial project skeleton"

# 2) LauncherEntry model
git add app/main.dart lib/launcher/entry.dart
commit "feat: add LauncherEntry model"

# 3) implement launcher boot
cat >> app/main.dart <<'DART'

// boot the launcher on startup
DART
git add app/main.dart
commit "feat: implement launcher boot"

# 4) LauncherRunner skeleton
cat > lib/launcher/runner.dart <<'DART'
class LauncherRunner {
  void run(String entryId) {}
}
DART
git add lib/launcher/runner.dart
commit "feat: add LauncherRunner skeleton"

# --- 作業状態を作る（Git ビューを populated に見せる）----------------------
# staged: 新規 group.dart
cat > lib/launcher/group.dart <<'DART'
class LauncherGroup {
  final String id;
  final String name;
  final List<String> entryIds;

  const LauncherGroup({
    required this.id,
    required this.name,
    required this.entryIds,
  });
}
DART
git add lib/launcher/group.dart

# modified（unstaged）: entry.dart に 1 行追加
cat >> lib/launcher/entry.dart <<'DART'

// TODO: support grouping
DART

# untracked: lib/terminal/ 配下
cat > lib/terminal/session.dart <<'DART'
class TerminalSession {}
DART

# --- お気に入りツリー用のディレクトリ（サイドバーに実名を出さないため）-------
# ADR-0045 のお気に入りツリーは対象ディレクトリの子を展開するので、
# 展開して見栄えがするよう子フォルダを用意する。Roola-demo とは別の親に
# 置き、エクスプローラ本体（撮影対象）の一覧を汚さない。
FAV="/Users/Shared/Roola-demo-projects"
rm -rf "$FAV"
mkdir -p "$FAV/Projects/"{web-app,api-server,cli-tool}
mkdir -p "$FAV/FlutterProjects/"{sample-app,widget-gallery}

echo ""
echo "✓ デモワークスペースを作成しました: $ROOT"
echo "  - コミット履歴 4 件（作者: Roola Demo）"
echo "  - staged: lib/launcher/group.dart（新規）"
echo "  - modified: lib/launcher/entry.dart"
echo "  - untracked: lib/terminal/session.dart"
git -c color.ui=never status --short
echo ""
echo "✓ お気に入りツリー用ディレクトリ: $FAV"
echo "  - Projects/{web-app, api-server, cli-tool}"
echo "  - FlutterProjects/{sample-app, widget-gallery}"
