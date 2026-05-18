# Architecture Decision Records

本プロジェクトの設計判断を時系列で記録する。判断の **WHAT**（決定内容）だけでなく **WHY**（背景・代替案・トレードオフ）を残すことを目的とする。

## 一覧

| ID | タイトル | ステータス |
|---|---|---|
| [0001](./0001-flutter-desktop-macos.md) | Flutter Desktop（macOS）を採用 | Accepted |
| [0002](./0002-pty-from-the-start.md) | ターミナル統合を最初から PTY ベースで実装 | Accepted |
| [0003](./0003-riverpod-hooks-state-management.md) | 状態管理に Riverpod + Hooks を採用 | Accepted |
| [0004](./0004-single-dart-define.md) | dart-define は単一環境（prod）のみ | Accepted |
| [0005](./0005-no-external-skill-dependency.md) | 外部 Skill / プラグインに依存しない自己完結方針 | Accepted |
| [0006](./0006-mvvm-over-clean-architecture.md) | Flutter 公式 MVVM を採用（Clean Architecture を採らない） | Accepted |
| [0007](./0007-riverpod-lint-deferral.md) | `riverpod_lint` / `custom_lint` の採用を当面保留 | Accepted |
| [0008](./0008-keep-alive-skill-sessions.md) | スキル実行セッションを実行画面 widget から切り離して保持 | Accepted |
| [0009](./0009-ad-hoc-skill-sessions.md) | ad-hoc セッションを別 provider で扱う | Accepted |
| [0010](./0010-stateful-shell-tabbed-navigation.md) | Home / Explorer をタブ式 `StatefulShellRoute` で束ね、Run/Settings は root navigator に push | Accepted |
| [0011](./0011-os-drag-and-drop.md) | エクスプローラの DnD を `super_drag_and_drop` で OS 連携にする | Accepted |
| [0012](./0012-multi-window-via-separate-process.md) | マルチウィンドウは別プロセス起動で実現（共有 Engine 方式は後追い検討） | Accepted |
| [0013](./0013-bundle-id-and-dev-prefix.md) | Bundle ID を `tech.yahiro.Roola` に、Debug / Profile は `dev.` プレフィックスで分離 | Accepted |
| [0014](./0014-explorer-first-ui.md) | Explorer をメイン UI に格上げ、Skills ランチャーをサブ機能へ降格 | Accepted |
| [0015](./0015-drop-explorer-root-ceiling.md) | Explorer の root ceiling を廃止、rootPath は「起動時の開始位置」に弱める | Accepted |
| [0016](./0016-generalize-launcher-action.md) | ランチャーを Claude Skill 専用から汎用ターミナルランチャーへ | Accepted |
| [0017](./0017-sarasa-term-j-bundled-font.md) | ターミナル描画フォントに Sarasa Term J を同梱する | Accepted |
| [0018](./0018-launcher-management-out-of-settings.md) | ランチャー管理 UI を Settings から独立画面へ分離 | Accepted |
| [0019](./0019-launcher-folders-single-level.md) | ランチャーをフォルダで 1 階層グループ化する | Accepted |
| [0020](./0020-win11-flat-utility-theme.md) | UI を Win10/11 風フラット実用テーマに転換する | Accepted |
| [0021](./0021-double-click-and-cc-copy.md) | エクスプローラの操作モデルをダブルクリック化 + CC でパスコピー | Accepted |
| [0022](./0022-claude-features-optional.md) | Claude Code 関連機能を optional 化する | Accepted |
| [0023](./0023-drop-custom-icon-support.md) | カスタムアイコン機能を廃止する | Accepted |
| [0024](./0024-explorer-list-density.md) | エクスプローラのタイル表示密度を切替え可能にする | Accepted |
| [0025](./0025-ignore-sigpipe-on-gui-launch.md) | GUI 起動経路の SIGPIPE 即死を AppDelegate で抑止する | Accepted |
| [0026](./0026-three-pane-tabbed-workspace.md) | `/explorer` を 3 画面タブ式ワークスペースに刷新する | Accepted |
| [0027](./0027-per-tab-state-via-family.md) | per-tab 状態を family(tabId) + scoped Provider で実現する | Accepted |
| [0028](./0028-workspace-persistence-and-terminal-respawn.md) | ワークスペースレイアウトの永続化とターミナル再 spawn | Accepted |
| [0029](./0029-favorite-folders-single-level.md) | エクスプローラのお気に入りをフォルダで 1 階層グループ化する | Accepted |
| [0030](./0030-git-tab.md) | Git ビューをワークスペースタブとして追加する | Accepted |
| [0031](./0031-terminal-swiftterm-native-view.md) | ターミナル描画を xterm.dart から SwiftTerm ネイティブビューへ移行する | Accepted |
| [0032](./0032-shift-enter-newline.md) | ターミナルで Shift+Enter を改行（LF）入力に割り当てる | Accepted |
| [0033](./0033-customizable-keyboard-shortcuts.md) | コマンドレジストリとネイティブメニューバーによる統一ショートカット機構 | Accepted |
| [0034](./0034-internationalization.md) | 多言語化を Flutter 公式 gen-l10n（ARB）で実装する | Accepted |
| [0035](./0035-reserve-text-editing-shortcuts.md) | ⌘C/⌘V/⌘X/⌘A/⌘Z をテキスト編集用に予約し、コマンド割り当て不可とする | Accepted |
| [0036](./0036-notepad-floating-panel.md) | ノートパッドをワークスペース外のフローティングパネルとして実装する | Accepted |
| [0037](./0037-terminal-focus-bridge.md) | ターミナルのプラットフォームビューと Flutter フォーカスを橋渡しする | Accepted |

## フォーマット

新規 ADR は以下のテンプレートで作成する:

```markdown
# ADR-XXXX: <タイトル>

- **Status**: Proposed | Accepted | Deprecated | Superseded by ADR-YYYY
- **Date**: YYYY-MM-DD

## Context

<判断が必要になった背景・現状の制約>

## Decision

<決定内容を簡潔に>

## Why

<なぜこの選択をしたか。代替案と比較する>

### 代替案 1: <名前>

<検討した内容と却下理由>

### 代替案 2: <名前>

<同上>

## Trade-offs

<受け入れた制約・将来発生し得るコスト>

## References

- <公式ドキュメント・記事リンク>
```

## 運用ルール

- 設計判断（採用するライブラリ・パターン・規約）が発生したら ADR を 1 件追加する
- 過去の ADR を覆す場合は **新しい ADR を作って `Supersedes ADR-XXXX` と明記** し、古い ADR は `Deprecated` に変更する。古い ADR は削除しない
- 番号は連番（ゼロパディング 4 桁）
- 1 件は 1 ページ以内を目安
