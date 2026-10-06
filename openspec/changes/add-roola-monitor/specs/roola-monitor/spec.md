## ADDED Requirements

### Requirement: 起動すると計器盤を表示する

Roola Monitor SHALL 起動するとウィンドウ全体にアクティビティの計器盤を表示する。
計器盤の表示モード・スタイル・全コア表示・表示項目・ポーリングと描画の挙動は、
Roola のアクティビティタブ（`activity-dashboard`）と同じとする。

#### Scenario: 起動直後

- **WHEN** ユーザーが Roola Monitor を起動する
- **THEN** ウィンドウにツールバー（表示モード・TACHO スタイル・全コア表示の
  切り替え）と計器盤が表示され、メーターが現在の値を示す

#### Scenario: Roola と同じ計器盤

- **WHEN** 同じ表示設定で Roola のアクティビティタブと Roola Monitor を並べる
- **THEN** 両者は同じメーターを同じ見た目で表示する

### Requirement: 表示設定を永続化する

Roola Monitor SHALL 表示モード・TACHO スタイル・全コア表示の選択を保存し、
次回の起動時に同じ表示で開く。保存先は Roola Monitor 専用とし、Roola の設定とは
共有しない。

#### Scenario: 再起動後も同じ表示

- **WHEN** ユーザーが TACHO・DIGITAL・全コア表示を選んで終了し、再び起動する
- **THEN** TACHO・DIGITAL・全コア表示の状態で開く

#### Scenario: 保存できなくても表示は変わる

- **WHEN** 設定ファイルへの書き込みに失敗する
- **THEN** 表示は選んだとおりに切り替わり、エラーは表示されない

### Requirement: ウィンドウ

Roola Monitor SHALL 1 枚のウィンドウを持ち、大きさと位置を次回の起動に引き継ぐ。
ウィンドウは計器盤が崩れない最小サイズより小さくできない。

#### Scenario: 大きさと位置の復元

- **WHEN** ユーザーがウィンドウを動かして大きさを変え、終了してから再び起動する
- **THEN** ウィンドウは前回と同じ位置・大きさで開く

#### Scenario: ウィンドウを閉じる

- **WHEN** ユーザーがウィンドウを閉じる
- **THEN** アプリが終了する

### Requirement: メニューと About

Roola Monitor SHALL macOS のメニューバーに、アプリ名のメニュー（About・サービス・
隠す・ほかを隠す・すべてを表示・終了）とウィンドウメニュー（最小化・拡大／縮小）を
持つ。About には名前・バージョン・アイコンを表示し、同梱する OSS（計器書体を
含む）のライセンスを閲覧できる。

#### Scenario: ライセンスを見る

- **WHEN** ユーザーが About を開いてライセンス表示を選ぶ
- **THEN** Barlow Condensed と Chakra Petch の SIL Open Font License を含む
  ライセンス一覧が表示される

### Requirement: 配布物

Roola Monitor SHALL Developer ID で署名し、Apple の公証を通した DMG として配布
できる。DMG はアプリと `/Applications` へのリンクを含む。アプリの名前は
`Roola Monitor`、Bundle ID は `tech.yahiro.RoolaMonitor` とする。

#### Scenario: 別の Mac で開く

- **WHEN** ユーザーが配布 DMG からアプリを `/Applications` にコピーして起動する
- **THEN** Gatekeeper の警告なしに起動する

#### Scenario: Roola と同時に動かす

- **WHEN** Roola と Roola Monitor を同時に起動する
- **THEN** 両方とも独立して動作し、互いの表示設定に影響しない
