## 1. 設計判断の記録

- [x] 1.1 `docs/adr/0014-explorer-first-ui.md` を追加
- [x] 1.2 `docs/adr/0015-drop-explorer-root-ceiling.md` を追加
- [x] 1.3 `docs/adr/README.md` に ADR-0014 / 0015 をリンク追加
- [x] 1.4 `CLAUDE.md` の ADR リストに追記

## Phase 1（独立コミット）

### 2. ExplorerViewModel: ceiling 廃止

- [ ] 2.1 `goUp()` の `if (state.currentPath == state.root) { return; }` を削除
- [ ] 2.2 dartdoc の文言を「rootPath は起動時の開始位置のみ」に更新
- [ ] 2.3 `test/ui/explorer/` で goUp の挙動が変わる箇所があれば追従

### 3. ExplorerSidebar: 4 セクション再構成

- [ ] 3.1 「場所」セクションを実装（ホーム / ダウンロード / デスクトップ / ドキュメント / アプリケーション + 「別のフォルダを開く…」）
- [ ] 3.2 「お気に入り」セクションは既存ロジック維持（DropRegion / 右クリック削除・リネーム）
- [ ] 3.3 「ランチャー」セクションを実装（`launcherEntriesProvider` 購読、クリックで `RunRoute(entryId).push` — Phase 1 暫定）
- [ ] 3.4 「実行中」セクションを実装（`activeSessionsProvider` 購読、空時は「なし」表示、クリックで `RunRoute` / `RunAdhocRoute` push、✕ で `terminateSkillSession` / `terminateAdhocSession`）
- [ ] 3.5 サイドバー全体を `ListView` でラップしてスクロール可能化
- [ ] 3.6 各セクション header の見た目を統一（小サイズ caps の見出し）

### 4. AppBar 文言調整

- [ ] 4.1 `ExplorerPage` の AppBar アクション「ルートを変更」tooltip を「起動時のディレクトリを変更」に変更

### 5. テストと検証

- [ ] 5.1 `flutter analyze` 緑
- [ ] 5.2 `flutter test` 緑（`test/ui/explorer/explorer_page_test.dart` の sidebar 構造に依存するアサートがあれば調整）
- [ ] 5.3 macOS 実機での確認
  - 場所セクションの 5 + 1 エントリがクリックで正しく navigate
  - 「別のフォルダを開く…」で file_picker → 選んだ場所に飛ぶ
  - お気に入りに何も登録していなくても、場所セクションから ~ / ダウンロード等に飛べる
  - root より上にも登れる（例: root が `/Users/yahir0/Projects` でも `/Users/` に登れる）
  - サイドバーの「ランチャー」エントリクリックで RunRoute（既存 Home タブ経由と同じ挙動）
  - サイドバーの「実行中」エントリクリックで該当セッションの RunRoute、✕ で破棄
  - Phase 1 段階では Home タブも残っており、両方からランチャーにアクセス可能

### 6. Phase 1 コミット

- [ ] 6.1 commit & push

## Phase 2（別コミット）

### 7. ExplorerSelection 導入

- [ ] 7.1 `lib/ui/explorer/explorer_selection.dart` を Freezed sealed で実装（`directory` / `session`）
- [ ] 7.2 `explorerSelectionNotifierProvider`（keepAlive）を実装
- [ ] 7.3 `ExplorerViewModel.navigateTo` を呼んだら selection も `directory(path)` に同期する仕組み

### 8. body の selection 駆動化

- [ ] 8.1 `_ExplorerBody` を selection で switch するようにし、`_DirectoryListing` / `_SessionTerminal` の 2 widget で構成
- [ ] 8.2 `_SessionTerminal` は既存 `RunPage` から body を抽出して埋め込み形に変換
- [ ] 8.3 selection 切替時の TerminalView lifecycle を観察し、IndexedStack 化が必要か判断

### 9. ⚡ Popover

- [ ] 9.1 `ExplorerPage` の AppBar に `⚡` IconButton を追加
- [ ] 9.2 押下で `HomePage` のタイルグリッドを popover として描画（既存 `HomePage` widget を再利用 or 同等の widget を新設）
- [ ] 9.3 popover のタイルクリックは `selectSession`（永続エントリ）or 既存の RunViewModel build フローを通す

### 10. ルート整理

- [ ] 10.1 `StatefulShellRoute` の Home ブランチを削除し、`ExplorerRoute` を root に
- [ ] 10.2 `RunRoute` / `RunAdhocRoute` を `app/router.dart` から削除
- [ ] 10.3 起動 route を `/explorer` に
- [ ] 10.4 build_runner 再実行

### 11. ActiveSessionsStrip 撤去

- [ ] 11.1 `HomePage` から `ActiveSessionsStrip` を削除（Home 画面自体は popover として残る形）
- [ ] 11.2 サイドバーの「実行中」セクションが唯一の表示源になる

### 12. サイドバーの Phase 1 暫定挙動を置換

- [ ] 12.1 「ランチャー」クリック → `RunRoute.push` を `selectSession` 呼出 + `runViewModelProvider(entryId)` build に置換
- [ ] 12.2 「実行中」クリック → 同様に selection 更新に置換

### 13. テストと検証

- [ ] 13.1 `flutter analyze` 緑
- [ ] 13.2 `flutter test` 緑（route 撤去に伴うテスト調整）
- [ ] 13.3 macOS 実機検証
  - 起動するといきなり Explorer
  - サイドバー「ランチャー」クリック → body がターミナルになる
  - サイドバー「お気に入り」クリック → body がディレクトリ一覧に戻る
  - 「実行中」が複数あれば自由に切替できる
  - ⚡ ボタン → popover でグリッド表示
  - chip 列が消えている

### 14. Phase 2 コミット

- [ ] 14.1 commit & push

## 15. アーカイブ

- [ ] 15.1 全フェーズ完了後、`openspec/changes/archive/<YYYY-MM-DD>-explorer-first-ui/` に移動
