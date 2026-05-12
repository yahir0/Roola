## 1. 設計判断の記録

- [ ] 1.1 `docs/adr/0009-ad-hoc-skill-sessions.md` を追加する（ad-hoc セッションを `launcherEntriesProvider` に混ぜず、`session-registry` の表示名 fallback で扱う判断・別 provider を切る理由）
- [ ] 1.2 `docs/adr/README.md` に ADR-0009 をリンク追加
- [ ] 1.3 `CLAUDE.md` の ADR リストに ADR-0009 を追記

## 2. PtySkillRunner: Skill 名空対応

- [ ] 2.1 `lib/data/skill_runner/pty_skill_runner.dart` の `_buildArguments` で空文字 → 引数なし配列を返す分岐を追加
- [ ] 2.2 `test/data/skill_runner/pty_skill_runner_test.dart` に空 skillName での起動テストを追加（実行可能なディレクトリで `claude` の存在を mock せず、引数構築の検証は indirect に）

## 3. data/repo_explorer: 永続化と検知

- [ ] 3.1 `lib/data/repo_explorer/explorer_settings.dart` を Freezed で実装（`String? rootPath`）
- [ ] 3.2 `lib/data/repo_explorer/explorer_settings_dto.dart` (json_serializable)
- [ ] 3.3 `lib/data/repo_explorer/explorer_settings_repository.dart` (interface)
- [ ] 3.4 `lib/data/repo_explorer/explorer_settings_repository_impl.dart` (JSON 実装 + Provider)
- [ ] 3.5 `appPathsProvider` に `repoExplorerSettingsFile` を追加（`<appSupport>/repo_explorer_settings.json`）
- [ ] 3.6 `lib/data/repo_explorer/explorer_node.dart` を Freezed sealed で実装（`directory` ノード）
- [ ] 3.7 `lib/data/repo_explorer/explorer_directory_loader.dart` でディレクトリ直下リスト + Skill 検知（`SkillScanner` を再利用）
- [ ] 3.8 build_runner 実行 + 生成物 commit
- [ ] 3.9 `test/data/repo_explorer/` にユニットテスト
  - explorer_settings_repository: load / save / 不在時のデフォルト
  - explorer_directory_loader: 子フォルダ列挙、Skill 検知あり / なし、空ディレクトリ、存在しないパス

## 4. ad-hoc セッション基盤

- [ ] 4.1 `lib/data/skill_session/active_sessions.dart` を改修
  - 内部に `Map<String, String> _adhocLabels` を追加
  - `register` にオプションの `String? adhocLabel` を追加。指定されていればその値をラベルとして保持
  - `unregister` 時に `_adhocLabels` からも除去
  - 公開メソッド: `String? labelFor(String entryId)` を追加（fallback 取得用）
- [ ] 4.2 build_runner 再実行
- [ ] 4.3 `test/data/skill_session/active_sessions_test.dart` に ad-hoc ラベル経路のテスト追加
- [ ] 4.4 `lib/ui/run/run_view_model.dart` の隣に `AdhocRunArgs`（Freezed）と `AdhocRunViewModel`（family、keepAlive）を実装
  - build で `PtySkillRunner` を起動、`ActiveSessions.register(adhocId, ..., adhocLabel: args.displayName)` を呼ぶ
  - `cancelRun` / `restart` を `RunViewModel` 同等で提供
- [ ] 4.5 `terminateSkillSession` ヘルパーを ad-hoc 経路でも使えるよう一般化（または `terminateAdhocSession` を別関数で）
- [ ] 4.6 build_runner 再実行
- [ ] 4.7 `test/ui/run/adhoc_run_view_model_test.dart` を追加

## 5. ルーティングと AppBar の拡張

- [ ] 5.1 `lib/app/router.dart` に `ExplorerRoute`（`/explorer`）と `RunAdhocRoute`（`/run-adhoc/:adhocId`）を追加（go_router_builder の `@TypedGoRoute` 経由）
- [ ] 5.2 `EntryNewRoute` に optional な `initialRepositoryPath` / `initialSkillName` クエリパラメータを追加
- [ ] 5.3 build_runner 再実行
- [ ] 5.4 ホーム / 設定 / エクスプローラ の AppBar 各画面に「フォルダ」アイコン（エクスプローラへの遷移）を追加

## 6. ui/explorer: 画面実装

- [ ] 6.1 `lib/ui/explorer/explorer_view_model.dart` を実装（現在のパス、子ノード、`enter` / `goUp` / `changeRoot`）
- [ ] 6.2 `lib/ui/explorer/explorer_page.dart` を実装
  - AppBar に「ルートを変更」「上の階層へ」アイコン
  - body に `ExplorerTree` を描画
  - 「ルートを変更」で `file_picker` の `getDirectoryPath` を呼び、`changeRoot`
- [ ] 6.3 `lib/ui/explorer/explorer_tree.dart` で子ノードを ListView で描画
- [ ] 6.4 `lib/ui/explorer/explorer_node_tile.dart` で 1 行 + 右クリックメニュー
  - `GestureDetector.onSecondaryTapDown` でメニュー表示
  - `showMenu(context, position, items)` で 3 種メニュー（Skill 有無で出し分け）
  - 「Skill を即実行」「Skill を登録」は複数 Skill 検知時にサブメニュー
- [ ] 6.5 build_runner 再実行
- [ ] 6.6 Widget テスト
  - `explorer_page_test.dart`: 初期描画、ルート変更、上下遷移
  - `explorer_node_tile_test.dart`: 右クリックメニューの出し分け、メニュー選択時のハンドラ呼び出し

## 7. EntryEditPage のプリフィル対応

- [ ] 7.1 `EntryEditPage` のコンストラクタに optional な `initialRepositoryPath` / `initialSkillName` を追加
- [ ] 7.2 `EntryEditViewModel.build(entryId)` でこれらが渡されたとき state を初期化（既存 entry の編集時は無視）
- [ ] 7.3 router 側で query/extra から拾って `EntryEditPage` に渡す
- [ ] 7.4 `entry_edit_view_model_test.dart` にプリフィル経路の検証を追加

## 8. ホーム chip の表示名 fallback

- [ ] 8.1 `lib/ui/home/active_sessions_strip.dart` の `_SessionChip` で、`launcherEntriesProvider` に該当 entry が見つからない場合 `ActiveSessions.labelFor(entryId)` を fallback で参照する
- [ ] 8.2 アイコン（ホーム本体のグリッド）には ad-hoc セッションのバッジは出さない（永続エントリではないため）
- [ ] 8.3 `active_sessions_strip_test.dart` に ad-hoc chip 描画ケースを追加

## 9. 動作検証と仕上げ

- [ ] 9.1 `make check`（format / analyze / test）を実行し緑にする
- [ ] 9.2 macOS 実機で以下のシナリオを通す
  - エクスプローラを開く → 初回はホームディレクトリから
  - ルートを変更 → 再起動後も覚えている
  - Skill 検知バッジが正しく付く
  - 右クリック「Skill を登録」 → EntryEditPage がプリフィル状態で開く
  - 右クリック「Skill を即実行」 → chip 列に登場、終了で消える、ホームには永続追加されない
  - 右クリック「このディレクトリで Claude を開く」 → 引数なしで `claude` 起動、chip 表示、完全破棄で消える
- [ ] 9.3 README に「エクスプローラ機能」セクションを追記

## 10. アーカイブ

- [ ] 10.1 全タスク完了後、本 change を `openspec/changes/archive/<YYYY-MM-DD>-repo-explorer/` に移動
