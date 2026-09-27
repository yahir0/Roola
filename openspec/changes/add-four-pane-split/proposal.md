# add-four-pane-split — Proposal

## Why

ワークスペースは ADR-0026 以来 `topLeft` / `topRight` / `bottom` の 3 スロット固定で、
下段は常に横いっぱいだった。並列エージェント時代（ADR-0067 の worktree 統合）では
「worktree ごとに Claude セッションを 1 つ」という使い方が中心になり、下段のターミナル
1 面ではセッションをタブで切り替えるしかない。2 つのエージェントを**同時に目視で**
並べたいという要求は、上段のエクスプローラ 2 面と同じ理由で本質的なものになった。

ADR-0026 は代替案 3 で「任意グリッドの自由分割」を却下しているが、その理由は
「上 2 + 下 1 が要求の実体であり、固定 3 スロットで十分」というものだった。要求の実体
（下段 2 面）が変わったため、**任意グリッドには踏み込まず、固定 4 スロット（2×2）へ
1 段だけ広げる**。

## What Changes

- **`PaneSlotId` を 4 値へ**: `bottom` → `bottomLeft` にリネームし、`bottomRight` を追加。
  下段は上段と同じく左右 2 分割になり、独立したスプリッタ比率 `bottomLeftRatio` を持つ
- **既定は 3 分割のまま**: seed（`seedDefaultWorkspace`）は `bottomRight` を空にする。
  空スロットは描画されない（既存の崩し再フロー）ため、**起動直後の見た目は現行と同一**
- **4 分割への到達はユーザー操作のみ**: タブ右クリックメニューの「タブを右下ペインへ移動」
  （新規コマンド `moveTabBottomRight`）と、右下ペインが実体化した後の DnD
- **崩し再フローを「上段 row × 下段 row」モデルへ一般化**: 現行の
  `WorkspaceLayoutMode`（single / twoHorizontal / twoVertical / three の 4 値 enum）は
  4 スロット化で組み合わせが膨らむため、enum を廃して「各 row の非空スロット列」を
  返す形に置き換える。single 〜 four がすべて 1 つの規則で表現できる
- **自動起動先は左下固定**: タイル右クリックのターミナル / Claude、worktree の作成後起動、
  Git ビューの「ターミナルを開く」、ノートパッドボタン、サイドバーの各起動は
  `PaneSlotId.bottomLeft` へ（現行 `bottom` からの機械的リネームのみ・挙動不変）。
  右下は「ユーザーが明示的に置いたものだけが入るペイン」とする
- 新規 ADR を 1 件追加（ADR-0026 の代替案 3 の判断を一部変更する経緯）

## Capabilities

### Modified Capabilities

- `workspace-layout`（archive: `2026-05-15-tabbed-workspace-layout`）:
  「3 ペインスロット構成」「スロット崩し再フロー」「スプリッタによるリサイズ」
  「初回起動時の既定 3 ペイン」の 4 要件を 4 スロット前提へ変更する

### New Capabilities

（なし — 既存 capability の変更に閉じる）

## Impact

- **モデル**: `lib/data/workspace/workspace_layout.dart`（`PaneSlotId` 4 値化・
  `bottomRight` / `bottomLeftRatio` 追加・`slot()` / `withSlot()` 拡張）、
  `workspace_layout_mode.dart`（row モデルへ書き換え・`WorkspaceLayoutMode` 廃止）、
  `workspace_layout_dto.dart`（4 スロット目と新比率のフィールド）
- **UI**: `lib/ui/workspace/workspace_page.dart`（`_WorkspaceArea` の描画）、
  `workspace_provider.dart`（`setBottomLeftRatio`）、`workspace_seed.dart`（コメント）、
  `pane_tab_strip.dart`（移動先メニューに右下）
- **コマンド**: `command_id.dart`（`moveTabBottom` → `moveTabBottomLeft` リネーム +
  `moveTabBottomRight` 追加）、`command_registry.dart`（⌘⌃4 / Ctrl+Alt+4）、
  `command_dispatcher.dart`、`app_menu_bar.dart`、`windows_top_menu_bar.dart`、
  `command_l10n.dart`
- **`bottom` → `bottomLeft` の機械的置換**: `explorer_node_tile.dart`（5 箇所）、
  `explorer_sidebar.dart`（4 箇所）、`git_tab.dart`、`worktree_create_dialog.dart`（2 箇所）、
  `workspace_provider.dart`（`openNotepadNote`）、`workspace_page.dart`（ノートパッドボタン）
- **l10n**: `commandMoveTabBottom` → `commandMoveTabBottomLeft` リネーム +
  `commandMoveTabBottomRight` 追加（en / ja）
- **テスト**: `workspace_layout_mode_test.dart`（row モデルの全組み合わせ）、
  `workspace_provider_test.dart`、`workspace_layout_dto_test.dart`
- **ドキュメント**: 新規 ADR 1 件、CLAUDE.md の ADR リスト追記、README の画面説明
- **依存関係**: 新規パッケージなし
