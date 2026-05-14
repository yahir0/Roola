## MODIFIED Requirements

### Requirement: 指定ディレクトリでの PTY 上プロセス起動

システムは、与えられた `LauncherAction` と作業ディレクトリ絶対パスを基に、PTY（擬似端末）上で対応するプロセスを起動する SHALL。動作タイプごとの起動コマンドは以下:

- `OpenHereAction`: `$SHELL`（環境変数 `SHELL` 未設定時は `/bin/zsh`）を引数なしで起動
- `RunCommandAction(command, keepShellAfterExit)`: `$SHELL -lc "<built-command>"` を起動。`keepShellAfterExit=true` のとき `<built-command>` は `<userCommand>; exec $SHELL -i`、false のとき `<userCommand>` そのまま
- `ClaudeSkillAction(skillName)`: `claude /<skillName>` を起動（既存挙動を `ClaudeSkillAction` に閉じ込める）

capability 名は履歴互換のため `skill-runner` のまま据え置くが、コード上は `PtyTerminalRunner`（`lib/data/terminal_runner/pty_terminal_runner.dart`）として汎用 PTY runner を実装する。

#### Scenario: 「開くだけ」動作で起動する

- **WHEN** `OpenHereAction` のエントリが起動される
- **THEN** システムは作業ディレクトリで `$SHELL`（または `/bin/zsh`）を PTY 上で起動し、ユーザーがプロンプトで対話操作できる状態にする

#### Scenario: 「コマンド実行」動作で起動する（シェル残留あり）

- **WHEN** `RunCommandAction(command: 'npm run dev', keepShellAfterExit: true)` のエントリが起動される
- **THEN** システムは作業ディレクトリで `$SHELL -lc "npm run dev; exec $SHELL -i"` を PTY 上で起動する。`npm run dev` が終了しても PTY は閉じず、ログインシェルが続いて起動する

#### Scenario: 「コマンド実行」動作で起動する（シェル残留なし）

- **WHEN** `RunCommandAction(command: 'make build', keepShellAfterExit: false)` のエントリが起動される
- **THEN** システムは作業ディレクトリで `$SHELL -lc "make build"` を PTY 上で起動する。`make build` の終了で PTY も閉じる

#### Scenario: 「Claude Skill」動作で起動する（既存互換）

- **WHEN** `ClaudeSkillAction(skillName: 'my-skill')` のエントリが起動される
- **THEN** システムは作業ディレクトリで `claude /my-skill` を PTY 上で起動する（既存挙動の `_buildArguments` で生成される引数と同一）

#### Scenario: 起動コマンドのバイナリが PATH に存在しない

- **WHEN** 起動対象（`claude` / `$SHELL` / ユーザー指定コマンドを処理する `$SHELL` 自体など）が PATH に存在せず、PTY 起動が失敗する
- **THEN** システムは実行画面に「`<executable>` コマンドが見つかりません。インストールと PATH を確認してください」とエラーを表示し、再試行ボタンを提供する

#### Scenario: 作業ディレクトリが消失している

- **WHEN** エントリに保存された作業ディレクトリパスがアプリ起動後に削除されており、ディレクトリが存在しない
- **THEN** システムは PTY を生成せず、「作業ディレクトリが見つかりません」とエラーを表示する

### Requirement: PTY 入出力ストリームとサイズ制御の公開

システムは、PTY の出力（標準出力 / 標準エラーが混合した端末出力）をバイト列ストリームとして購読可能にし、PTY への書き込み Sink と端末サイズ変更 API を提供する SHALL。動作タイプ（`OpenHere` / `RunCommand` / `ClaudeSkill`）に依らず、同一インターフェースで提供される。

#### Scenario: 出力ストリームを購読する

- **WHEN** `embedded-terminal` が runner の出力ストリームを購読する
- **THEN** PTY 出力のバイト列が時系列順にイベントとして配信される

#### Scenario: 入力を書き込む

- **WHEN** `embedded-terminal` がユーザーのキー入力バイト列を runner の入力 Sink に書き込む
- **THEN** 当該バイト列が即座に PTY へ送信され、子プロセス（`claude` / shell / 任意コマンド）に届く

#### Scenario: 矢印キーや Ctrl 修飾キーを送信する

- **WHEN** ユーザーがターミナル上で矢印キー / Ctrl-C / Ctrl-D を入力する
- **THEN** 対応する制御シーケンスがそのまま PTY へ送られる

#### Scenario: 端末サイズの変更を伝える

- **WHEN** `embedded-terminal` が端末の cols / rows を更新する
- **THEN** システムは PTY に対し対応するサイズ変更（`pty.resize`）を呼び出す

### Requirement: 対話的入力のサポート

システムは、子プロセス側の承認プロンプト（y/n）・選択 UI（矢印キー）・パスワード入力など、**TTY 前提の対話的入力を一通りサポートする** SHALL。動作タイプに依らず、`Process.start` ベースの劣化動作にフォールバックしない。

#### Scenario: Claude Skill の承認プロンプトに応答する

- **WHEN** `ClaudeSkillAction` 起動中に `claude` が `(y/n)` のプロンプトを表示し、ユーザーが `y` + Enter を入力する
- **THEN** PTY に `y\n` が送られ、`claude` は承認として扱う

#### Scenario: シェル / 任意コマンドの対話的プロンプトに応答する

- **WHEN** `OpenHereAction` または `RunCommandAction` で起動した shell / コマンドが対話的プロンプト（例: `sudo` のパスワード入力、`git rebase -i` の editor 起動）を表示する
- **THEN** ユーザーの入力がそのまま PTY 経由で届き、対話操作が成立する

#### Scenario: 矢印キーで選択 UI を操作する

- **WHEN** 子プロセス（`claude` / `fzf` / `vim` 等）が矢印キー操作の選択 UI を表示し、ユーザーが上下矢印を入力する
- **THEN** 対応する ANSI 制御シーケンスが PTY に送られ、UI のハイライトが移動する

### Requirement: プロセスのライフサイクル管理

システムは、PTY 上の子プロセスの開始・終了・キャンセルを観測可能な状態として公開し、ユーザーがキャンセルできるようにする SHALL。動作タイプに依らず同一の状態遷移（idle → starting → running → waitingInput / completed / cancelled / failed）に従う。

#### Scenario: プロセスが正常終了する

- **WHEN** PTY 上のプロセスが終了コードを返して終了する（`RunCommandAction` で `keepShellAfterExit=false` のときの `make build` 終了など）
- **THEN** システムは状態を「完了（終了コード N）」に遷移させ、ターミナル UI に終了コードを表示する

#### Scenario: 「コマンド実行 + シェル残留」では shell が終了するまで完了扱いにならない

- **WHEN** `RunCommandAction(keepShellAfterExit: true)` でコマンド本体が終了し、後置の `exec $SHELL -i` がプロンプトを出している
- **THEN** PTY 上のプロセスはまだ生きているため、状態は「running」または「waitingInput」のまま。ユーザーが `exit` を入力するまで「完了」には遷移しない

#### Scenario: ユーザーがキャンセルする

- **WHEN** ユーザーが実行画面のキャンセルボタンを押す
- **THEN** システムは PTY 経由で SIGTERM を送り、状態を「キャンセル済み」に遷移させる（動作タイプに依らず）

#### Scenario: 実行画面を離脱する

- **WHEN** ユーザーが実行中に画面外へ遷移する（ただしセッション破棄ではない場合）
- **THEN** PTY セッションは保持され、ADR-0008 の方針通り別画面切替後も生き残る。明示的な破棄（サイドバー ✕ボタン）でのみ PTY が終了する

## REMOVED Requirements

### Requirement: `skillName == ""` のフォールバック分岐

**Reason**: `OpenHereAction` で「指定ディレクトリで素のシェルを開く」を一級市民として扱うため、`PtySkillRunner._buildArguments` の `skillName == ""` で引数なし起動するフォールバック分岐は不要になる。

**Migration**: 旧コードで `PtySkillRunner(skillName: "")` を使っていた箇所（エクスプローラ右クリックの「Claude Code を開く」など）は、内部表現として `RunCommandAction(command: 'claude')` を渡すよう変更する。ユーザーから見える挙動は変わらない。
