## ADDED Requirements

### Requirement: ExplorerFileOps.copyInto が Windows で動作する
`ExplorerFileOps.copyInto` は `cp -R` プロセス呼び出しを使わず、`dart:io` の再帰コピー（`Directory.list(recursive: true)` で walk し `File.copy` で各ファイルをコピー）で実装される SHALL。macOS・Windows 両方で動作する SHALL。

#### Scenario: ディレクトリが再帰的にコピーされる
- **WHEN** エクスプローラでディレクトリを別フォルダにコピーする
- **THEN** コピー先にすべてのサブディレクトリ・ファイルが再現されている

#### Scenario: ファイルがコピーされる
- **WHEN** エクスプローラで単一ファイルを別フォルダにコピーする
- **THEN** コピー先にファイルが作成される

#### Scenario: コピー先に同名ファイルがある場合はエラーになる
- **WHEN** コピー先に同名の項目が既に存在する
- **THEN** `FileSystemException` が投げられコピーは行われない

### Requirement: パス結合が OS に依存しない
`ExplorerFileOps` のパス結合・区切り文字は `package:path` の `join` / `separator` を使用し、`/` をハードコードしない SHALL。

#### Scenario: Windows でサブディレクトリが正しく生成される
- **WHEN** Windows でエクスプローラから新規フォルダを作成する
- **THEN** `parentPath\folderName` というパスでディレクトリが作成される（バックスラッシュ区切り）

### Requirement: DirectoryWatcher の相対パス計算が Windows で動作する
`DirectoryWatcher._relativize` のパス区切り判定は `Platform.pathSeparator` を参照する SHALL（`/` ハードコードを除去する）。

#### Scenario: Windows でファイル変更が検知される
- **WHEN** Windows でエクスプローラが監視中のディレクトリにファイルを作成する
- **THEN** エクスプローラ一覧が自動更新される

### Requirement: AppMenuBar の macOS 固有項目が Windows で非表示になる
`PlatformProvidedMenuItemType.servicesSubmenu`・`hide`・`hideOtherApplications`・`showAllApplications`・Sparkle「アップデートを確認」は `Platform.isMacOS` が true の場合のみメニューに追加される SHALL。Windows では「アップデートを確認」は `UpdateChecker` の Windows 実装を呼ぶ項目に置き換わる SHALL。

#### Scenario: Windows でメニューバーが表示される
- **WHEN** Windows でアプリを起動しメニューバーを確認する
- **THEN** macOS 専用の「サービス」「隠す」「他を隠す」「すべてを表示」項目が表示されない

#### Scenario: Windows でアップデート確認が動作する
- **WHEN** Windows で「アップデートを確認」メニューを選択する
- **THEN** GitHub Releases API を参照したバージョン確認ダイアログが表示される
