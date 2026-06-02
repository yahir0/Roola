## ADDED Requirements

### Requirement: TrashService が Windows のゴミ箱を使用する
Windows 環境で `TrashService.moveToTrash` を呼ぶと、Win32 `SHFileOperationW`（`FO_DELETE` + `FOF_ALLOWUNDO`）経由でファイル・ディレクトリをゴミ箱へ移動する SHALL。ゴミ箱から「元に戻す」が可能な SHALL。

#### Scenario: ファイルがゴミ箱に移動される
- **WHEN** Windows でエクスプローラからファイルをゴミ箱に移動する操作を行う
- **THEN** ファイルが Windows のゴミ箱へ移動しエクスプローラ一覧から消える

#### Scenario: 存在しないファイルをゴミ箱移動するとエラーになる
- **WHEN** 存在しないパスを `moveToTrash` に渡す
- **THEN** `PlatformException` が投げられる

### Requirement: FileOpener が Windows でファイル・フォルダを開く
Windows 環境で `FileOpener.open` を呼ぶと `Process.run('explorer.exe', [path])` でデフォルトアプリが起動する SHALL。`revealInFinder` は `explorer.exe /select,<path>` で対象をエクスプローラで選択表示する SHALL。

#### Scenario: ファイルがデフォルトアプリで開かれる
- **WHEN** Windows でファイルを `FileOpener.open` に渡す
- **THEN** そのファイルの関連付けアプリが起動する

#### Scenario: フォルダがエクスプローラで選択表示される
- **WHEN** Windows でパスを `FileOpener.revealInFinder` に渡す
- **THEN** エクスプローラが起動し対象が選択状態で表示される

### Requirement: SystemMetricsRepository が Windows のシステム情報を取得する
Windows 環境で `fetchSystemMetrics` を呼ぶと、`GlobalMemoryStatusEx`（メモリ）および PDH（CPU 使用率）経由の値を返す SHALL。`fetchProcesses` は PDH またはスナップショット API でプロセスリストを返す SHALL。

#### Scenario: CPU・メモリが取得される
- **WHEN** Windows でアクティビティモニタバーが表示されている
- **THEN** CPU% とメモリ使用量が数値で表示される（0% / 0B になっていない）

#### Scenario: プロセスリストが取得される
- **WHEN** Windows でアクティビティモニタポップオーバーを開く
- **THEN** 実行中のプロセス一覧（名前・CPU%・メモリ）が表示される

### Requirement: UpdateChecker が Windows でバージョン確認を提供する
Windows 環境で「アップデートを確認」を実行すると、GitHub Releases API を参照して最新バージョン文字列を取得し、アプリバージョンと比較した結果をダイアログで表示する SHALL（自動ダウンロードは行わない）。macOS の Sparkle は既存の `SparkleUpdater` 実装を維持する SHALL。

#### Scenario: 最新版が表示される
- **WHEN** Windows で「アップデートを確認」メニューを選択する
- **THEN** 最新バージョン番号と「ダウンロードページを開く」ボタンを含むダイアログが表示される

#### Scenario: ネットワーク不可時にエラーが表示される
- **WHEN** ネットワーク接続なしで「アップデートを確認」を選択する
- **THEN** 確認できなかった旨のエラーメッセージが表示される

### Requirement: NotificationService が Windows で Toast 通知を送信する
Windows 環境で Claude Code タスク完了通知（ADR-0057）が有効な場合、Windows Toast 通知として表示される SHALL。`requestAuthorization` は Windows では常に authorized を返す SHALL（OS レベルの通知許可は設定で管理する）。

#### Scenario: タスク完了通知が表示される
- **WHEN** Windows で Claude Code タスクが完了し Stop フックが発火する
- **THEN** Windows Toast 通知が表示される

#### Scenario: authorization が authorized を返す
- **WHEN** Windows で `requestAuthorization` を呼ぶ
- **THEN** `NotificationAuthorizationStatus.authorized` が返る

### Requirement: サービスの Provider は Platform で実装を切り替える
各サービスの Riverpod Provider は `Platform.isMacOS` / `Platform.isWindows` で実装クラスを切り替える SHALL。テストでは `overrideWithValue` で fake 実装への差し替えが可能である SHALL。

#### Scenario: macOS で macOS 実装が使われる
- **WHEN** macOS で `trashServiceProvider` を取得する
- **THEN** `TrashServiceMacos` インスタンスが返る

#### Scenario: Windows で Windows 実装が使われる
- **WHEN** Windows で `trashServiceProvider` を取得する
- **THEN** `TrashServiceWindows` インスタンスが返る
