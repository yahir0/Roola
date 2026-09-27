# git-worktree

## ADDED Requirements

### Requirement: worktree の作成（新規ブランチ）

Roola は git リポジトリに対し、新規ブランチを作成してその worktree を展開できなければならない（SHALL）。
ブランチ名と分岐元（既定は現在の HEAD）を指定でき、作成は
`git worktree add -b <branch> <path> <base>` 相当で行う。

#### Scenario: タイル右クリックから新規ブランチで切る

- **WHEN** エクスプローラで git リポジトリのフォルダタイルを右クリックし
  「Worktree を切って開く…」からブランチ名 `feat/x` を入力して作成する
- **THEN** `../<repo>.worktrees/feat-x/` に worktree が作成され、
  ブランチ `feat/x` が現在の HEAD から分岐して作られる

#### Scenario: 非 git フォルダではメニューに出ない

- **WHEN** git リポジトリでないフォルダのタイルを右クリックする
- **THEN** 「Worktree を切って開く…」項目は表示されない

### Requirement: worktree の作成（既存 / リモート追跡ブランチ）

Roola は既存のローカルブランチおよびリモートブランチから worktree を展開できなければならない（SHALL）。
他の worktree（本体含む）でチェックアウト済みのブランチは選択不可として理由を表示し、
作成を試みてはならない（MUST NOT）。

#### Scenario: 既存ローカルブランチで切る

- **WHEN** ダイアログで既存ブランチモードに切り替え、未チェックアウトの
  ローカルブランチを選んで作成する
- **THEN** そのブランチをチェックアウトした worktree が作成される

#### Scenario: チェックアウト済みブランチはグレーアウト

- **WHEN** 本体で `main` をチェックアウト中にブランチピッカーを開く
- **THEN** `main` は選択不可で表示され、チェックアウト済みである旨が分かる

#### Scenario: リモートブランチからトラッキングして切る

- **WHEN** ブランチピッカーで `origin/feat-y`（ローカル未作成）を選んで作成する
- **THEN** `origin/feat-y` をトラッキングするローカルブランチ `feat-y` が作成され、
  その worktree が展開される

### Requirement: worktree の置き場所

Roola は worktree をリポジトリの兄弟ディレクトリ `../<repo>.worktrees/<branch-slug>/` に作成しなければならない（SHALL)。
ブランチ名のスラッシュはハイフンに変換し、同名フォルダが既に存在する場合は
サフィックスで衝突を回避する。

#### Scenario: スラッシュを含むブランチ名の slug 化

- **WHEN** ブランチ名 `feat/login-form` で worktree を切る
- **THEN** フォルダは `<repo>.worktrees/feat-login-form/` に作成される

### Requirement: 作成後のセッション起動

Roola は worktree 作成ダイアログで作成後アクション（何もしない / シェル / Claude）を選択でき、選択に応じて worktree をカレントディレクトリとするターミナルタブを隣ペインに開かなければならない（SHALL）。

#### Scenario: 切ってすぐ Claude を起動する

- **WHEN** 作成後アクションに Claude を選んで worktree を作成する
- **THEN** 新しい worktree のパスを作業ディレクトリとして claude セッションの
  ターミナルタブが隣ペインに開く

### Requirement: Git ビューでの一覧と状態表示

Git ビューは対象リポジトリの worktree 一覧（パス・ブランチ・dirty・ahead/behind・prunable）を表示しなければならない（SHALL）。
一覧はファイルシステム監視（ADR-0041）による自動更新に追従する。本体
（main worktree）は区別して表示し、削除操作を提供しない。

#### Scenario: worktree セクションに状態が出る

- **WHEN** worktree が 2 つあるリポジトリの Git ビューを開く
- **THEN** 各 worktree のブランチ名と dirty / ahead/behind 状態が一覧表示される

#### Scenario: 一覧から開く

- **WHEN** worktree 行の「ここで開く」を実行する
- **THEN** その worktree を作業ディレクトリとするターミナルタブが開く

### Requirement: エクスプローラのタイルバッジ

エクスプローラは worktree ディレクトリのタイルにブランチ名バッジを表示しなければならない（SHALL）。
判定とブランチ名の解決は git プロセスを起動せず、ファイルシステムの読み取り
（`.git` がファイルであること・`gitdir:` ポインタ先の `HEAD`）のみで行わなければならない（MUST）。

#### Scenario: worktree フォルダにブランチ名が出る

- **WHEN** エクスプローラで `<repo>.worktrees/` を開く
- **THEN** 各 worktree フォルダのタイルにチェックアウト中のブランチ名が表示される

#### Scenario: 通常のリポジトリにはバッジが出ない

- **WHEN** `.git` がディレクトリである通常のリポジトリのタイルを表示する
- **THEN** worktree バッジは表示されない

### Requirement: worktree の削除

Roola は Git ビューから worktree を削除できなければならない（SHALL）。未コミットの変更がある worktree は
警告を表示し、ユーザーが明示的に「変更ごと削除」を選んだ場合のみ強制削除する。
削除時にブランチも併せて削除するかを選択できる（既定は残す）。

#### Scenario: クリーンな worktree の削除

- **WHEN** 変更のない worktree を削除する
- **THEN** worktree のフォルダと管理情報が削除され、ブランチは残る

#### Scenario: dirty な worktree は警告

- **WHEN** 未コミットの変更がある worktree を削除しようとする
- **THEN** 変更が失われる旨の警告が表示され、「変更ごと削除」を選ばない限り
  削除されない

#### Scenario: ブランチも一緒に消す

- **WHEN** 削除ダイアログで「ブランチも削除」を有効にして削除する
- **THEN** worktree とブランチの両方が削除される

### Requirement: マージ済み worktree のワンクリック掃除

Git ビューはリポジトリの既定ブランチにマージ済みのブランチを持つ worktree を検出してラベル表示し、ワンクリックで worktree とブランチを掃除できなければならない（SHALL）。
既定ブランチは `origin/HEAD` → `main` → `master` の順で解決する。

#### Scenario: マージ済みの掃除

- **WHEN** 既定ブランチへマージ済みのブランチを持つ worktree の「掃除」を実行する
- **THEN** 確認後、worktree の削除とブランチの削除（`-d`）が 1 操作で行われる

### Requirement: 孤児の検出と修復

Git ビューは管理情報だけ残った worktree（フォルダが直接削除された等）を検出して表示し、prune による整理を提供しなければならない（SHALL）。
リポジトリ移動等でリンク切れした worktree には repair の導線を提供する。

#### Scenario: Finder で消された worktree の整理

- **WHEN** worktree フォルダをエクスプローラ / Finder で直接削除した後、
  Git ビューの worktree セクションを見る
- **THEN** 孤児（prunable）として表示され、「整理」で管理情報が掃除される
