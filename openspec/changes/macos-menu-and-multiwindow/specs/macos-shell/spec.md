## ADDED Requirements

### Requirement: macOS メニューバーの日本語化と Roola 化

システムは、macOS 画面上部の global menu を Roola にふさわしい構成・日本語表記で提供する SHALL。

#### Scenario: Roola（apple）submenu

- **WHEN** ユーザーがメニューバーの「Roola」を開く
- **THEN** 以下の項目のみが表示される: 「Roola について」/ ―― / 「Roola を隠す ⌘H」/「ほかを隠す ⌥⌘H」/「すべてを表示」/ ―― /「Roola を終了 ⌘Q」
- **AND** 「Preferences…」「Services」は表示されない

#### Scenario: ファイル menu

- **WHEN** ユーザーがメニューバーの「ファイル」を開く
- **THEN** 「新規ウィンドウ ⌘N」と「ウィンドウを閉じる ⌘W」が表示される

#### Scenario: 編集 menu

- **WHEN** ユーザーがメニューバーの「編集」を開く
- **THEN** 「取り消す ⌘Z」「やり直し ⇧⌘Z」/ ―― /「カット ⌘X」「コピー ⌘C」「ペースト ⌘V」「削除」「すべてを選択 ⌘A」のみが表示される
- **AND** 「Find」「Spelling and Grammar」「Substitutions」「Transformations」「Speech」の各 submenu は表示されない

#### Scenario: 表示 menu

- **WHEN** ユーザーがメニューバーの「表示」を開く
- **THEN** 「フルスクリーンにする ⌃⌘F」のみが表示される

#### Scenario: ウィンドウ menu

- **WHEN** ユーザーがメニューバーの「ウィンドウ」を開く
- **THEN** 「しまう ⌘M」「拡大/縮小」「すべてを手前に移動」が表示される

### Requirement: 新規ウィンドウの起動

システムは、ファイルメニューの「新規ウィンドウ」（⌘N）または Dock 右クリックの「新規ウィンドウ」が選択されたとき、Roola.app の新しいインスタンスを別プロセスとして起動する SHALL。

#### Scenario: ファイル > 新規ウィンドウ

- **WHEN** ユーザーがメニューバーから「ファイル > 新規ウィンドウ」を選ぶ（または ⌘N を押す）
- **THEN** Roola.app の新しいインスタンスが別プロセスとして立ち上がる
- **AND** 元の Roola のウィンドウ・状態はそのまま維持される

#### Scenario: Dock 右クリック

- **WHEN** ユーザーが Dock の Roola アイコンを右クリック / 長押しする
- **THEN** メニューに「新規ウィンドウ」項目が含まれる
- **AND** これを選ぶと「ファイル > 新規ウィンドウ」と同じ動作になる

#### Scenario: ⌘W で active window のみ閉じる

- **WHEN** ユーザーが ⌘W を押す
- **THEN** active window が閉じる
- **AND** 同じプロセス内に他の window があればアプリは残る。最後の window だった場合はそのプロセスが終了する（他プロセスで起動した window がいれば全体としてアプリは継続）
