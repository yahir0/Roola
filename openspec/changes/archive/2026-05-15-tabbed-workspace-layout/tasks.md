## 1. ADR

- [x] 1.1 ADR-0026「3 画面タブ式ワークスペースの採用」を `docs/adr/` に追加
- [x] 1.2 ADR-0027「per-tab 状態を family(tabId) + scoped Provider で実現する」を追加
- [x] 1.3 ADR-0028「ワークスペースレイアウトの永続化とターミナル再 spawn」を追加（マルチウィンドウ時の last-write-wins も記載）
- [x] 1.4 `docs/adr/README.md` と `CLAUDE.md` の ADR 一覧に 0026〜0028 を追記

## 2. Phase A — 状態基盤

- [x] 2.1 `WorkspaceTab`（sealed: `ExplorerTab` / `TerminalTab`）モデルを freezed で定義
- [x] 2.2 `PaneSlot`（tabs + activeIndex）モデルを freezed で定義
- [x] 2.3 `WorkspaceLayout`（topLeft / topRight / bottom + topRatio + leftRatio）モデルを freezed で定義
- [x] 2.4 崩し再フローを純粋関数化（コンテンツありスロット数 → 描画モード判定）し、ユニットテスト可能にする
- [x] 2.5 `workspaceProvider`（Notifier, keepAlive）を実装: `addTab` / `closeTab` / `activateTab` / `moveTab` / `setSplitRatio` / `updateTabPath`
- [x] 2.6 `closeTab` / `moveTab` で activeIndex のクランプとスロット崩しを適用、全タブ消失時の $HOME エクスプローラタブ自動 seed を実装
- [x] 2.7 `currentTabIdProvider`（既定 throw の `Provider<String>`）を定義
- [x] 2.8 `focusedTabProvider` と派生 `lastFocusedExplorerTabId` を実装
- [x] 2.9 `ExplorerViewModel` を `family(tabId)` 化、`build()` から `explorerSettingsProvider` の watch を外し、`changeRoot` を廃止
- [x] 2.10 `ExplorerViewModel.navigateTo` 等から `workspaceProvider.updateTabPath` を呼んでパスを反映
- [x] 2.11 `explorerItemSelectionProvider` を `family(tabId)` 化
- [x] 2.12 `explorerSelectionProvider` を廃止し、参照箇所（page / sidebar / node_tile / path_bar / launcher_actions / session_view / run・adhoc VM の onClosed）を洗い出して移行（ファイル削除済み・参照移行は Phase B/C と一体で実施）

## 3. Phase B — レイアウト UI

- [x] 3.1 `WorkspacePage` を新設し、`ExplorerRoute` の描画先を差し替え（Window AppBar + サイドバー + 3 ペイン領域）
- [x] 3.2 自前スプリッタ widget（上下・左右の 2 種、ドラッグで比率更新）を実装
- [x] 3.3 崩し再フローに応じた 3 / 2 / 単一ペインの描画分岐を実装
- [x] 3.4 `PaneWidget`（タブストリップ + `IndexedStack` + `ProviderScope(currentTabId override)`）を実装
- [x] 3.5 タブストリップ widget（タブ chip・アクティブ表示・閉じるボタン・「+」での種別選択追加）を実装
- [x] 3.6 エクスプローラタブ body: 既存ディレクトリ一覧 + ペインヘッダ（戻る / 進む / パスバー）を組み込み、tabId 経由参照に修正
- [x] 3.7 ターミナルタブ body: 既存 `SessionView` を流用して組み込み
- [x] 3.8 タブ DnD: タブ chip の `Draggable<WorkspaceTab>` 化、タブストリップの `DragTarget` 化、ドロップ位置インジケータ描画
- [x] 3.9 DnD のドロップを `workspaceProvider.moveTab` に集約（ストリップ内並べ替え・ペイン間移動を統一）
- [x] 3.10 ペイン body 最上位でフォーカス検出し `focusedTabProvider` を更新

## 4. Phase C — 既存機能の結線

- [x] 4.1 `MacosWindowAppBar` から戻る / 進むを撤去、設定・起動ディレクトリは残置
- [x] 4.2 `ExplorerSidebar` の場所 / お気に入り / 「現在のディレクトリを登録」を `lastFocusedExplorerTabId` 経由に修正（タブ不在時は新規タブ生成）
- [x] 4.3 `launchLauncherEntry` を `bottom` ペインへの `addTab`（ターミナルタブ）に変更、bottom 空時の再生成を実装
- [x] 4.4 「実行中」タイルのクリックを既存タブへのフォーカス / 無ければ bottom 再作成に変更
- [x] 4.5 `explorer_node_tile` / `explorer_path_bar` / `launcher_actions` を `currentTabIdProvider` 経由に修正
- [x] 4.6 `MouseNavigationListener` の戻る / 進むをフォーカス中エクスプローラタブに向ける
- [x] 4.7 `session_view` の `onClosed` 経路をタブ閉じ（`closeTab`）に接続
- [x] 4.8 `WindowCloseGuard` の複数ターミナルタブ下での終了確認を回帰確認

## 5. Phase D — 永続化

- [x] 5.1 `AppPaths` に `workspace.json` の保存先を追加
- [x] 5.2 `WorkspaceLayout` の DTO（json_serializable）と `ExplorerTab` / `TerminalTab` のシリアライズを実装
- [x] 5.3 `WorkspaceRepository`（interface + impl）と `AsyncNotifier` を実装
- [x] 5.4 保存トリガ（タブ開閉 / アクティブ変更 / navigateTo / スプリッタ比率変更）を結線
- [x] 5.5 起動時復元: エクスプローラはパス復元、ターミナルは作業ディレクトリ + action で再 spawn
- [x] 5.6 `workspace.json` 不在 / 不正 / 全スロット空 → 既定 3 ペイン seed を実装

## 6. Phase E — テスト

- [x] 6.1 `workspaceProvider` のユニットテスト: `addTab` / `closeTab` / `activateTab`、activeIndex クランプ、全タブ消失時の自動 seed
- [x] 6.2 崩し再フロー純粋関数のユニットテスト（3 / 2（下空・上片側空）/ 単一の各パターン）
- [x] 6.3 `moveTab` のユニットテスト（ストリップ内並べ替え / ペイン間移動 / 移動で元スロットが空になるケース）
- [x] 6.4 `ExplorerViewModel` family のユニットテスト（タブごとの履歴・カレントパス独立）
- [x] 6.5 永続化 DTO のラウンドトリップテスト（エクスプローラ / ターミナルタブ両種別）
- [x] 6.6 ウィジェットテスト: 3 ペイン描画 / 単一ペイン崩し / タブ閉じ
- [x] 6.7 ウィジェットテスト: ランチャー起動が bottom ペインにターミナルタブを追加する

## 7. 仕上げ

- [x] 7.1 `docs/architecture.md` を更新（ワークスペース / ペイン / タブの層構成、family + scoped tabId の注意点を明記）
- [x] 7.2 `flutter analyze` と `dart format` を通す
- [x] 7.3 全テスト green を確認
- [x] 7.4 手動確認: 初回起動 3 ペイン / 崩し / タブ DnD / 再起動復元
