# ADR-0063: 「素のシェル（OpenHere）」をログインシェルで起動する

- **Status**: Accepted
- **Date**: 2026-06-05

## Context

ランチャー / エクスプローラの「開くだけ（`OpenHereAction`）」は、macOS では
`$SHELL`（無ければ `/bin/zsh`）を **引数なし** で spawn していた
（`pty_terminal_runner.dart`：`OpenHereAction() => (_userShell(), const <String>[])`）。
PTY 接続なので zsh は対話シェルにはなる（`~/.zshrc` は読まれる）が、`-l` を
付けていないため **ログインシェルにはならない**。

これにより、Roola の素のシェルで一部のコマンドが `command not found` や
実行時エラーで動かない不具合が報告された。具体例として OpenSpec の CLI
（`openspec`）が「Mac の Terminal.app からは動くが Roola のターミナルからは動かない」
という症状を示した。

調査で原因を切り分けた（最小 PATH を再現して検証）:

- `openspec` 自体は **PATH 上にある**。pnpm の bin（`~/Library/pnpm`）を PATH に
  足す設定が `~/.zshrc` にあり、対話シェルなら non-login でも読まれるため。
- だが `openspec` は **Node 製スクリプト**で実行に `node` が要る。`node` は
  `/usr/local/bin/node` にあり、`/usr/local/bin` を PATH に足すのは macOS の
  `path_helper`。**`path_helper` は `/etc/zprofile` から呼ばれ、ログインシェルでしか
  走らない**。
- 結果、非ログインの素のシェルでは `openspec` は見つかるが内部の `exec node` が
  `node: not found` で失敗していた。

| シェル起動形態 | `node` | `openspec` 実行 |
|---|---|---|
| `zsh -il`（**ログイン**・Terminal.app と同じ） | `/usr/local/bin/node` ✓ | 成功 |
| `zsh -i`（対話だが**非ログイン**・従来の素のシェル） | 見つからず ✗ | `node: not found` |

加えて、Roola の他アクション（`RunCommandAction` は `-ilc`、`ClaudeSkillAction` は
`-i -l`）は **既にログインシェルで起動していた**。素のシェルだけが非ログインで、
一貫していなかった。l10n の説明文（`entryEditOpenHereDescription`）も以前から
「ログインシェル ($SHELL) を起動」と記述しており、**ドキュメントと実装が食い違って
いた**。

## Decision

macOS の `OpenHereAction` を **ログインシェル（`-l`）** で起動する。

```dart
OpenHereAction() => (_userShell(), const <String>['-l']),
```

これにより `/etc/zprofile`（`path_helper`）と `~/.zprofile` が読まれ、Terminal.app /
iTerm2 と同じ PATH 構築になる。Homebrew / node 系を含む各ツールが、手元のターミナル
と同じように解決できる。

Windows は対象外（`_windowsOpenHere` は従来どおり。Windows の PATH 解決はログイン
シェルの概念に依存しないため）。

## Why

- macOS の Terminal.app / iTerm2 は **既定でログインシェルを開く**。Roola は
  「ターミナルランチャー」を標榜する以上、素のシェルの起動も手元のターミナルと
  同じ挙動に揃えるのが筋。
- 原因は特定ツール（openspec / node）固有ではなく、「`/usr/local/bin` 等が
  `path_helper`（login 限定）でしか PATH に乗らない」という macOS 共通の仕組みに
  ある。`-l` を付けるだけで **この種の問題を一括で解消** できる（個別ツールへの
  PATH 追記のような対症療法より上流で直る）。
- 他アクションが既に `-l` 付きで、l10n も「ログインシェル」と説明済み。`-l` 追加は
  **既存の設計意図・ドキュメントへの実装の追従**であり、新しい挙動の導入ではない。

## Trade-offs

- **`~/.zprofile` / `~/.zlogin` の副作用も走る**: ログインシェルが重い初期化
  （バージョンマネージャの初期化、`fortune` 等）を持つ環境では、素のシェルの起動が
  わずかに遅くなりうる。ただし Terminal.app と同条件であり、ユーザーの想定どおり。
- **二重 PATH 構築の可能性**: ユーザーが「`.zprofile` の brew shellenv は login
  でしか走らないから」と `.zshrc` 側にも同じ設定を入れている場合、login かつ
  interactive では両方走る。多くの brew shellenv 設定は冪等（重複追加を避けるガード
  付き）なので実害は小さい。
- **代替案（採用せず）**: 素のシェルを非ログインのまま残し、ユーザーの dotfiles 側で
  `/usr/local/bin` を `.zshrc` に足す対症療法。手元設定への依存が増え、ツールごとに
  再発するため、本体側で `-l` に倒すほうが本質的と判断した。

## References

- ADR-0016: ランチャーを Claude Skill 専用から汎用ターミナルランチャーへ
  （`LauncherAction` sealed union・`OpenHereAction` の導入）
- ADR-0002: PTY ベースのターミナル統合
- `lib/data/terminal_runner/pty_terminal_runner.dart`（`_resolveExecutableMacos`）
- `test/data/terminal_runner/pty_terminal_runner_test.dart`（OpenHere の argv 検証）
- `lib/l10n/app_ja.arb` / `app_en.arb`（`entryEditOpenHereDescription` = 「ログイン
  シェル」）
