## ADDED Requirements

### Requirement: Git ビューを開く

ユーザーは Git リポジトリ配下のディレクトリから Git ビュー（`GitTab`）を開くことができる。Git 管理下でないパスからは開けない。

#### Scenario: Git 管理下のパスから開く

- **WHEN** エクスプローラタブのカレントパスが Git リポジトリ配下で、ユーザーが「Git ビューを開く」を実行する
- **THEN** システムは `git rev-parse --show-toplevel` で得たリポジトリルートをキーに `GitTab` を隣ペインに生成し、フォーカスする

#### Scenario: Git 管理下でないパス

- **WHEN** カレントパスが Git リポジトリ配下でない
- **THEN** 「Git ビューを開く」は非活性で表示され、ツールチップで Git 管理下でない旨を示す

#### Scenario: 同一リポジトリの GitTab を集約する

- **WHEN** 既に開いている `GitTab` と同じリポジトリルートに対して「Git ビューを開く」が実行される
- **THEN** システムは新しいタブを生成せず、既存の `GitTab` をフォーカスする

#### Scenario: git コマンドが存在しない

- **WHEN** `GitTab` を開こうとした時点で `git` コマンドが PATH 上に見つからない
- **THEN** システムはクラッシュせず、`GitTab` 内に「git コマンドが見つかりません」を表示する

### Requirement: リポジトリ状態の表示と再読込

`GitTab` はリポジトリの現在ブランチ・upstream に対する ahead/behind・作業ツリーの変更一覧を表示する。明示操作で再読込できる。

#### Scenario: 初回ロード

- **WHEN** `GitTab` が開かれる
- **THEN** システムは現在ブランチ・ahead/behind 件数・Staged / Unstaged のファイル一覧・履歴・ブランチ一覧を取得して表示する

#### Scenario: 作業ツリーがクリーン

- **WHEN** 作業ツリーに変更が無い
- **THEN** Changes セクションは「作業ツリーはクリーンです」を表示する

#### Scenario: 再読込

- **WHEN** ユーザーが再読込を実行する
- **THEN** システムはリポジトリ状態を再取得し、表示を更新する

### Requirement: ステージングとコミット

ユーザーはファイル単位で stage / unstage し、メッセージを付けてコミットできる。

#### Scenario: ファイルを stage する

- **WHEN** ユーザーが Unstaged のファイル行の stage 操作を実行する
- **THEN** システムは当該ファイルを index に追加し、そのファイルを Staged グループへ移動して表示する

#### Scenario: ファイルを unstage する

- **WHEN** ユーザーが Staged のファイル行の unstage 操作を実行する
- **THEN** システムは当該ファイルを index から外し、Unstaged グループへ移動して表示する

#### Scenario: コミットする

- **WHEN** Staged にファイルがあり、ユーザーが空でないコミットメッセージを入力して Commit を実行する
- **THEN** システムは staged の内容をコミットし、Changes と履歴を更新し、メッセージ欄をクリアする

#### Scenario: staged が空のときコミットできない

- **WHEN** Staged にファイルが無い
- **THEN** Commit ボタンは非活性で表示される

### Requirement: リモート同期（fetch / pull / push）

ユーザーはツールバーのボタンでリモートとの同期操作を実行できる。

#### Scenario: fetch する

- **WHEN** ユーザーが Fetch を実行する
- **THEN** システムはリモートを fetch し、ahead/behind 表示を更新する

#### Scenario: pull する

- **WHEN** ユーザーが Pull を実行する
- **THEN** システムは upstream から取り込み、作業ツリー・履歴・ahead/behind 表示を更新する

#### Scenario: push する

- **WHEN** ユーザーが Push を実行する
- **THEN** システムはローカルコミットを upstream へ送信し、ahead/behind 表示を更新する

#### Scenario: 同期操作の失敗

- **WHEN** fetch / pull / push が認証エラーやコンフリクト等で失敗する
- **THEN** システムは失敗を通知バーに表示し、リポジトリルートを作業ディレクトリとするターミナルで実行・解決する導線を提供する

#### Scenario: 操作中の多重実行防止

- **WHEN** ある Git 操作が進行中である
- **THEN** 当該タブの Git 操作ボタンは非活性になり、進行中であることが表示される

### Requirement: ブランチ操作

ユーザーはブランチセレクタからブランチの切替・作成・マージ・削除を実行できる。

#### Scenario: ブランチを切り替える

- **WHEN** ユーザーがブランチ一覧から別ブランチを選択する
- **THEN** システムは当該ブランチをチェックアウトし、リポジトリ状態を更新する

#### Scenario: ブランチを作成する

- **WHEN** ユーザーが新しいブランチ名を指定して作成を実行する
- **THEN** システムは現在の HEAD から新ブランチを作成し、それにチェックアウトする

#### Scenario: ブランチをマージする

- **WHEN** ユーザーが対象ブランチを指定してマージを実行する
- **THEN** システムは現在ブランチへ対象ブランチをマージし、結果（成功 / コンフリクト）を表示する

#### Scenario: ブランチを削除する

- **WHEN** ユーザーがブランチの削除を実行する
- **THEN** システムは確認ダイアログを表示し、承認後に当該ブランチを削除する

### Requirement: コミット履歴グラフ

`GitTab` はコミット履歴をグラフ付きで表示し、コミットを選択すると詳細を確認できる。

#### Scenario: 履歴グラフの表示

- **WHEN** `GitTab` が履歴を表示する
- **THEN** 各コミットがグラフ列・メッセージ・作者・日付とともに一覧表示され、ブランチ / タグ / HEAD はラベルで示される

#### Scenario: コミットを選択する

- **WHEN** ユーザーが履歴の 1 コミットを選択する
- **THEN** システムは当該コミットの変更ファイル一覧を表示する

#### Scenario: 大規模履歴のページング

- **WHEN** 履歴の表示末尾までスクロールされる
- **THEN** システムは続きのコミットを追加で取得して表示する

### Requirement: 差分（diff）ビューア

ユーザーは変更ファイルやコミットの差分を行単位の着色付きで閲覧できる。

#### Scenario: 変更ファイルの差分を開く

- **WHEN** ユーザーが Changes のファイル行を開く操作をする
- **THEN** システムは当該ファイルの差分を行単位の追加 / 削除着色で表示する

#### Scenario: コミット内ファイルの差分を開く

- **WHEN** ユーザーが選択コミットの変更ファイル行を開く操作をする
- **THEN** システムは当該コミットでのそのファイルの差分を表示する

### Requirement: 変更の破棄（discard）

ユーザーは作業ツリーの変更を破棄できる。破壊的操作は確認を伴う。

#### Scenario: 単一ファイルの変更を破棄

- **WHEN** ユーザーが 1 ファイルの discard を実行する
- **THEN** システムは当該ファイルの作業ツリー変更を破棄する

#### Scenario: 複数 / 全ファイルの破棄は確認する

- **WHEN** ユーザーが複数ファイルまたは全変更の discard を実行する
- **THEN** システムは確認ダイアログを表示し、承認後にのみ破棄する

### Requirement: stash

ユーザーは作業ツリーの変更を stash に退避・適用・破棄できる。

#### Scenario: stash に退避する

- **WHEN** ユーザーが stash 退避を実行する
- **THEN** システムは作業ツリーの変更を stash に退避し、Changes を更新する

#### Scenario: stash を適用する

- **WHEN** ユーザーが stash 一覧から 1 件を選び apply / pop を実行する
- **THEN** システムは当該 stash を作業ツリーへ適用し、pop の場合は stash から削除する

#### Scenario: stash を破棄する

- **WHEN** ユーザーが stash の drop を実行する
- **THEN** システムは確認後に当該 stash を削除する

### Requirement: Git 操作の隔離

Git へのアクセスは差し替え可能な Repository として `data/git/` に隔離され、UI / ViewModel は実装詳細に依存しない。

#### Scenario: Repository 経由のアクセス

- **WHEN** ViewModel が Git の状態取得・操作を行う
- **THEN** それは `GitRepository` インターフェース経由で行われ、`git` CLI 実行などの詳細は `ProcessGitRepository` 実装に隠蔽される

#### Scenario: ロケール非依存の出力

- **WHEN** `ProcessGitRepository` が `git` コマンドを実行する
- **THEN** 機械可読オプションと `LC_ALL=C` を用い、実行環境のロケールに依存せず出力をパースする
