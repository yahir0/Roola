## Why

Roola は当初 Claude Code Skills のランチャー（ホーム画面のアイコングリッド）として始まったが、Finder ライクなエクスプローラ機能が育つにつれて **実際の主操作はエクスプローラ** に移行している。にもかかわらず UI は:

- 起動 = HomeRoute（`/`）
- AppBar タブが Home / Explorer 同列
- active session の chip 列は Home 画面下部限定

という Skill ランチャー時代のままで、実態と UI が乖離している。

ただし「Skill ワンクリック起動」は Roola のコア体験のため、Home 機能を単純に隠すと体験ダウン。

## What Changes

エクスプローラを唯一のメイン画面に格上げし、Skills は「サイドバー常設 + AppBar popover」のサブ機能として 1〜2 クリックで使えるようにする。

### Phase 1（本 change の前半 / 単独でも動く中間状態）

- `ExplorerSidebar` を Finder 流の 4 セクション化:
  - **場所**: ホーム / ダウンロード / デスクトップ / ドキュメント / アプリケーション + 「別のフォルダを開く…」（file_picker）
  - **お気に入り**: 既存
  - **ランチャー**: 登録済み LauncherEntry を縦リスト表示。クリックで暫定的に既存 `RunRoute` 全画面遷移（Phase 2 で body 切替に置換）
  - **実行中**: active session を縦リスト表示。空のときは「なし」プレースホルダ
- `ExplorerViewModel` から root ceiling を除去（`goUp` の root 一致ガードを削除）
- AppBar の「ルートを変更」tooltip 文言を「起動時のディレクトリを変更」に変更（ADR-0015 参照）

### Phase 2（本 change の後半 / 別 commit）

- 起動 route を `/explorer` に
- `StatefulShellRoute` の Home ブランチを削除
- `ExplorerSelection` state を導入し、body をディレクトリビュー / PTY ターミナルの 2 種で selection 駆動切替
- `/run/:entryId` / `/run-adhoc/:adhocId` 単独ルートを撤去
- 既存の `ActiveSessionsStrip`（Home 下部 chip 列）を撤去（サイドバー「実行中」に統合）
- AppBar に `⚡` ボタンを追加し、`HomePage` のグリッドを popover として再利用
- Phase 1 で暫定的に `RunRoute` 遷移にしていたサイドバーの「ランチャー」「実行中」クリックを selection 更新に置換

## Capabilities

### Modified Capabilities

- `repo-explorer`: サイドバー 4 セクション化、ceiling 廃止、body の selection 駆動 2 ビュー（Phase 2）
- `launcher-home`: 単独画面から popover 化（Phase 2）。entries の管理導線は設定画面に集約

### Removed Capabilities

- `repo-explorer` / `launcher-home`: タブ式 `StatefulShellRoute` の Home ブランチ（ADR-0010 で導入したが ADR-0014 で Superseded、Phase 2 で撤去）

## Impact

- **永続化スキーマ変更なし**: `ExplorerSettings.rootPath` は意味付けを変えるだけ、フィールドは継続
- **ディープリンク影響**: `/run/...` ルート撤去（Phase 2）。外部から URL では呼べなくなるが Roola は URL を外に出さないため実害なし
- **テスト影響**:
  - 既存 `test/ui/explorer/explorer_page_test.dart` は Phase 1 で sidebar 構造が変わるので調整
  - body 切替テストは Phase 2 で追加
- **非 goal**:
  - selection 状態の永続化（再起動後の自動復元）
  - `ExplorerDirectoryLoader` の非同期化（大量ファイルディレクトリ向け）
  - Spotlight 風キーボードランチャー
