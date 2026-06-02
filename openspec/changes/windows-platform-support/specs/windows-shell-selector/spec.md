## ADDED Requirements

### Requirement: ユーザーが Windows のデフォルトシェルを選択できる
Settings ページの「ターミナル」セクション（Windows のみ表示）で、`cmd.exe`・`powershell.exe`（PowerShell 5）・`pwsh.exe`（PowerShell 7）の 3 択からデフォルトシェルを選択できる SHALL。選択は `TerminalSettings` として永続化される SHALL。

#### Scenario: Settings でシェルを切り替える
- **WHEN** Windows の Settings > ターミナルで PowerShell を選択する
- **THEN** 選択が保存され、次回起動後も維持される

#### Scenario: macOS で設定セクションが表示されない
- **WHEN** macOS で Settings ページを開く
- **THEN** Windows シェル選択セクションが表示されない

### Requirement: 新規ターミナルタブが選択されたシェルで起動する
`OpenHereAction` で開くターミナルは、設定で選択されたシェルで起動する SHALL。デフォルトは `powershell.exe` とする SHALL。

#### Scenario: cmd が選択されている場合 cmd.exe で起動する
- **WHEN** シェルを cmd に設定した状態でターミナルタブを開く
- **THEN** `cmd.exe` が PTY で起動しコマンドプロンプトが表示される

#### Scenario: PowerShell が選択されている場合 powershell.exe で起動する
- **WHEN** シェルを PowerShell（v5）に設定した状態でターミナルタブを開く
- **THEN** `powershell.exe -NoExit` が起動し PS プロンプトが表示される

#### Scenario: pwsh が選択されている場合 pwsh.exe で起動する
- **WHEN** シェルを PowerShell 7 に設定した状態でターミナルタブを開く
- **THEN** `pwsh.exe -NoExit` が起動し PS7 プロンプトが表示される

### Requirement: pwsh.exe が未インストールの場合に警告を表示する
設定で PowerShell 7 を選択した際に `pwsh.exe` が PATH 上に見つからない場合、設定 UI にエラーメッセージを表示する SHALL。ターミナルを開こうとした場合も起動失敗メッセージを表示する SHALL。

#### Scenario: pwsh が見つからない場合に警告が出る
- **WHEN** pwsh.exe が未インストールの環境で PowerShell 7 を選択する
- **THEN** 「pwsh.exe が見つかりません。PowerShell 7 をインストールしてください。」に相当するメッセージが設定 UI に表示される

### Requirement: RunCommandAction が選択されたシェルでコマンドを実行する
`RunCommandAction` によるコマンド実行は、選択されたシェルの構文でコマンドを起動する SHALL。

#### Scenario: cmd でコマンドが実行される（keepShellAfterExit=false）
- **WHEN** cmd 選択時にコマンド `dir` を持つランチャーを起動する（keepShellAfterExit=false）
- **THEN** `cmd.exe /C dir` が実行され完了後に PTY が終了する

#### Scenario: cmd でコマンドが実行される（keepShellAfterExit=true）
- **WHEN** cmd 選択時にコマンド `dir` を持つランチャーを起動する（keepShellAfterExit=true）
- **THEN** `cmd.exe /K dir` が実行され完了後もプロンプトが残る

#### Scenario: PowerShell でコマンドが実行される
- **WHEN** PowerShell 選択時にコマンドを持つランチャーを起動する
- **THEN** `powershell.exe -Command <command>` が実行される

### Requirement: ClaudeSkillAction は Windows V1 で非サポートとする
Windows 環境で `ClaudeSkillAction` を実行しようとした場合、PTY を起動せず「Claude Code のスキル起動は Windows では未サポートです」に相当するエラーメッセージを `SkillRunState.failed` として配信する SHALL。

#### Scenario: Windows で Claude Skill を起動するとエラーになる
- **WHEN** Windows でランチャーから Claude Skill アクションを起動する
- **THEN** ターミナルにエラーメッセージが表示され PTY プロセスは起動しない
