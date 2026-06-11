# task-notification

## ADDED Requirements

### Requirement: OSC 通知シーケンスの解釈

ターミナルペインは、PTY 出力ストリームに含まれる OSC 9（`ESC ] 9 ; <body> BEL/ST`）
および OSC 777（`ESC ] 777 ; notify ; <title> ; <body> BEL/ST`）を通知要求として
解釈しなければならない（SHALL）。解釈したシーケンスは画面に描画してはならない（MUST NOT）。

#### Scenario: OSC 9 を受信して通知が出る

- **WHEN** Roola のペイン内で実行中のプログラムが `printf '\e]9;Done\a'` を出力する
- **THEN** タイトルにタブ名、本文に「Done」を持つ OS 通知が表示される

#### Scenario: OSC 777 を受信して通知が出る

- **WHEN** ペイン内のプログラムが `printf '\e]777;notify;Build;Succeeded\a'` を出力する
- **THEN** タイトル「Build」・本文「Succeeded」の OS 通知が表示される

#### Scenario: 両 OS で同一の挙動

- **WHEN** 同じ OSC シーケンスを macOS（SwiftTerm）と Windows（xterm.js）のペインで出力する
- **THEN** どちらのプラットフォームでも同様に OS 通知が表示される

### Requirement: Claude Code のネイティブ通知の設定ゼロ有効化

Roola は自分が起動する PTY の環境に `TERM_PROGRAM=iTerm.app` および
`TERM_PROGRAM_VERSION` を注入しなければならない（SHALL）。ユーザーの
`~/.claude/settings.json` その他 Claude Code 設定への書き込み・登録案内を
行ってはならない（MUST NOT）。

#### Scenario: インストール直後から claude の通知が動く

- **WHEN** ユーザーがフックや `preferredNotifChannel` を一切設定せずに
  Roola のペインで claude を起動し、claude が許可待ちになる（ペインは非フォーカス）
- **THEN** claude が出力する OSC 9 により「Claude needs your permission」の
  OS 通知が表示される

### Requirement: フォーカス状態の PTY 転送

ペインは、フォーカスの取得・喪失を CSI I（FocusIn）/ CSI O（FocusOut）として
PTY へ書き込まなければならない（SHALL）。

#### Scenario: フォーカス喪失が claude に伝わる

- **WHEN** claude が動作中のペインから別ペインへフォーカスを移す
- **THEN** PTY に CSI O が書き込まれ、以後 claude は通知を出す状態になる

#### Scenario: フォーカス中のペインからは通知しない

- **WHEN** フォーカス中のペイン内のプログラムが OSC 9 を出力する
- **THEN** OS 通知は表示されない（ユーザーは当該画面を見ているため）

### Requirement: 通知クリックによるペインフォーカス復帰

OS 通知のクリックで、Roola のウィンドウを前面化し、通知元のペインへ
フォーカスを移さなければならない（SHALL）。通知元タブが既に閉じられている場合は
フォーカス変更を行わず、エラーも表示しない。

#### Scenario: クリックで該当ペインに戻る

- **WHEN** バックグラウンドの Roola のペイン A から発した通知をクリックする
- **THEN** Roola のウィンドウが前面化し、ペイン A にフォーカスが移る

#### Scenario: 通知元タブが閉じられている

- **WHEN** 通知の発生後に該当タブを閉じ、その通知をクリックする
- **THEN** ウィンドウは前面化するが、フォーカスは現状のまま変わらない

### Requirement: 連続通知の抑制

同一ペインからの通知要求は短時間に連続して発生した場合に抑制（レート制限）
しなければならない（SHALL）。エスケープシーケンス注入（通知バイト列を含むファイルの
`cat` 等）による通知洪水を防ぐため。

#### Scenario: 通知バイト列を大量に含むファイルを cat する

- **WHEN** OSC 9 シーケンスを 100 個含むファイルをペインで `cat` する
- **THEN** OS 通知はレート制限内の件数しか表示されない

### Requirement: フック通知（ADR-0057）との並走時の重複抑止

OSC 経路の通知が機能しているペインについて、同一イベントに対する
フック → HTTP 経路（ADR-0057）の通知を重複表示してはならない（MUST NOT）。

#### Scenario: フック登録済みユーザーで通知が二重にならない

- **WHEN** ADR-0057 の Stop フックを登録済みの環境で、claude のタスクが完了し
  OSC 経路と HTTP 経路の両方から通知要求が届く
- **THEN** OS 通知は 1 件のみ表示される
