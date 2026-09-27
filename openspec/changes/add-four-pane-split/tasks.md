# add-four-pane-split — Tasks

## 1. モデル（data/workspace）

- [x] 1.1 `PaneSlotId` を `topLeft` / `topRight` / `bottomLeft` / `bottomRight` の 4 値にする（`bottom` → `bottomLeft` リネーム）
- [x] 1.2 `WorkspaceLayout` に `bottomRight` フィールドと下段左右比率 `bottomLeftRatio`（既定 0.5）を追加し、`slot()` / `withSlot()` の switch を 4 値へ拡張する。`leftRatio` の doc comment に「上段の」を明示する
- [x] 1.3 `resolveWorkspaceLayout()` を row モデルへ書き換える（`WorkspaceLayoutMode` enum 廃止・`ResolvedWorkspaceLayout` を `{ topSlots, bottomSlots }` に変更・全スロット空は `topLeft` 単体へフォールバック）
- [x] 1.4 `workspace_layout_dto.dart` に `bottomRight` / `bottomLeftRatio` を追加し、`build_runner` を実行する

## 2. ワークスペース UI

- [x] 2.1 `_WorkspaceArea`（`workspace_page.dart`）を row モデルの描画へ書き換える（両 row 非空なら上下 `WorkspaceSplit`、row 内 2 つなら左右 `WorkspaceSplit`、1 つならそのまま）
- [x] 2.2 `workspace_provider.dart` に `setBottomLeftRatio`（0.15〜0.85 クランプ）を追加する
- [x] 2.3 `seedDefaultWorkspace()` の doc comment を「既定 3 ペイン・`bottomRight` は空」に更新する（seed 自体は `bottomRight` を持たない）
- [x] 2.4 `pane_tab_strip.dart` の `_TabMenuAction` に `moveBottomRight` を追加し、右クリックメニューに「タブを右下ペインへ移動」を出す（現在のペインは除外する既存規則に従う）

## 3. コマンド体系

- [x] 3.1 `CommandId.moveTabBottom` → `moveTabBottomLeft` にリネームし、`moveTabBottomRight` を追加する
- [x] 3.2 `CommandRegistry` に `moveTabBottomRight` のメタデータを追加する（アイコン `Icons.south_east`、macOS ⌘⌃4 / Windows Ctrl+Alt+4。`moveTabBottomLeft` は `Icons.south_west` へ）
- [x] 3.3 `command_dispatcher.dart` の `moveTabBottomLeft` / `moveTabBottomRight` の case を実装する
- [x] 3.4 `app_menu_bar.dart` / `windows_top_menu_bar.dart` のタブメニューに 4 つ目の項目を追加する
- [x] 3.5 `command_l10n.dart` と `app_ja.arb` / `app_en.arb` を更新する（`commandMoveTabBottom` → `commandMoveTabBottomLeft` リネーム + `commandMoveTabBottomRight` 追加）し、`flutter gen-l10n` を実行する

## 4. `bottom` → `bottomLeft` の機械的置換

- [x] 4.1 `explorer_node_tile.dart`（Claude / Terminal / cmd / PowerShell / スキル起動の 5 箇所と `_slotContainingTab` のフォールバック）を置換する
- [x] 4.2 `explorer_sidebar.dart`（Claude / Terminal / cmd / PowerShell の 4 箇所）を置換する
- [x] 4.3 `git_tab.dart` / `worktree_create_dialog.dart`（シェル / Claude の 2 箇所）を置換する
- [x] 4.4 `workspace_provider.dart` の `openNotepadNote` と `workspace_page.dart` のノートパッドボタンを置換する

## 5. テスト

- [x] 5.1 `workspace_layout_mode_test.dart` を row モデル前提へ全面書き換えする（4 分割 / 3 分割 2 種（上 2 下 1・上 1 下 2）/ 上段のみ 2 分割 / 下段のみ 2 分割 / 上下 1 つずつ / 単一 / 全空フォールバック）
- [x] 5.2 `workspace_provider_test.dart` に `bottomRight` へのタブ移動・空になったときの再フロー・`setBottomLeftRatio` のクランプを追加し、既存の `bottom` 参照を更新する
- [x] 5.3 `workspace_layout_dto_test.dart` を 4 スロット + 新比率のラウンドトリップへ更新する
- [x] 5.4 `flutter analyze` クリーン・`flutter test` 全件グリーンを確認する

## 6. 手動確認

- [ ] 6.1 起動直後が現行と同一の 3 分割であることを確認する（`bottomRight` が現れない）
- [ ] 6.2 タブ右クリック →「タブを右下ペインへ移動」で 4 分割になり、下段スプリッタが上段と独立に動くことを確認する
- [ ] 6.3 4 分割状態で DnD によるペイン間移動を行い、ターミナルの表示内容とエクスプローラの履歴が保持されることを確認する（GlobalKey による reparent）
- [ ] 6.4 右下ペインのタブを全部閉じると 3 分割へ戻ることと、上段を空にすると下段が全高になることを確認する
- [ ] 6.5 右下フォーカス時に「ターミナルで開く」が左下に開き、⌘T / ⌘N（新規タブコマンド）は右下に開くことを確認する
- [ ] 6.6 ⌘⌃1〜4（Windows: Ctrl+Alt+1〜4）のショートカットとメニュー項目が機能することを確認する

## 7. ドキュメント

- [x] 7.1 ADR-0068（4 分割ワークスペース）を起草する（ADR-0026 代替案 3 の判断を一部変更する経緯・row モデル採用理由・左下固定の理由）
- [x] 7.2 CLAUDE.md の ADR リストに ADR-0068 を追記する
- [x] 7.3 README の画面説明を 4 分割対応に更新する
