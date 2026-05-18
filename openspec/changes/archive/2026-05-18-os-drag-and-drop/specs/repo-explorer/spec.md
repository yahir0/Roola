## MODIFIED Requirements

### Requirement: ドラッグ＆ドロップによるノード移動 / コピー

システムは、エクスプローラ画面上のディレクトリ・ファイルを OS レベルのドラッグ＆ドロップで他の場所に移動 / コピー可能にする SHALL。drag は OS 標準ファイル URI フォーマット（`Formats.fileUri`）で発行され、Finder / 他アプリで受け取れる。drop も同フォーマットを受け、内部・外部いずれの発生元でも Finder と同等の操作判定（ボリューム判定 + 修飾キー）で move / copy を行う。

#### Scenario: アプリ内 → アプリ内 同一ボリューム（修飾キー無し）

- **WHEN** 同一ボリューム内のノードを別ディレクトリのタイルへ drag & drop する（⌥ / ⌘ いずれも押さない）
- **THEN** システムは `ExplorerFileOps.moveInto(sourcePath, targetPath)` を呼ぶ。カーソルバッジは「移動」表示

#### Scenario: アプリ内 → アプリ内 異ボリューム（修飾キー無し）

- **WHEN** 異ボリューム間のノードを別ディレクトリのタイルへ drag & drop する
- **THEN** システムは `ExplorerFileOps.copyInto(sourcePath, targetPath)` を呼ぶ（自動でコピーにフォールバック）。カーソルバッジは「コピー」表示

#### Scenario: ⌥ (option) 押下中の drag

- **WHEN** ユーザーが ⌥ を押しながら任意のノードを drop する
- **THEN** ボリュームに関係なく `copyInto` を呼ぶ。カーソルバッジは「コピー」表示

#### Scenario: ⌘ (command) 押下中の drag

- **WHEN** ユーザーが ⌘ を押しながら同一ボリューム内のノードを drop する
- **THEN** `moveInto` を呼ぶ。カーソルバッジは「移動」表示
- **AND** 異ボリュームの場合は `copyInto` にフォールバックする（強制移動の copy + delete は未対応）

#### Scenario: アプリ内 → サイドバーお気に入りへ drop

- **WHEN** 任意のノードをサイドバーのお気に入りタイルへ drop する
- **THEN** 該当お気に入りのパスを target として上記と同じセマンティクスで move / copy を行う

#### Scenario: アプリ内 → 「上の階層へ」へ drop

- **WHEN** 任意のノードを「上の階層へ」タイルへ drop する
- **THEN** 現在ディレクトリの親パスを target として上記と同じセマンティクスで move / copy を行う
- **AND** drop 元の親が既に現在ディレクトリと同じならカーソルは禁止表示になり drop は無視される

#### Scenario: 自身 / 自身の子孫への drop（拒否）

- **WHEN** あるノードを自身、自身の子孫に drop しようとする
- **THEN** `onDropOver` で `DropOperation.none` を返し、カーソルが禁止表示に切り替わる。drop しても何も起きない

#### Scenario: アプリ内 → Finder / 他アプリ

- **WHEN** エクスプローラのノードをアプリ外（Finder ウィンドウ / デスクトップ / ターミナル / 他アプリ）にドラッグしてドロップする
- **THEN** 受け取り側アプリは `Formats.fileUri` のファイル参照として受け、Finder ならコピー / 移動（同一/異ボリュームで自動判別、⌥ / ⌘ で切り替え）、ターミナルならパスペースト、他アプリなら添付として扱う。アプリ側は drag 完了時に追加の状態変更を行わない

#### Scenario: Finder → アプリ内（ディレクトリへ drop、同一ボリューム）

- **WHEN** Finder / デスクトップから同一ボリューム上のファイル or フォルダをエクスプローラのディレクトリタイルへ drag & drop する
- **THEN** システムは `moveInto` を実行する。カーソルは「移動」表示

#### Scenario: Finder → アプリ内（ディレクトリへ drop、異ボリューム）

- **WHEN** Finder からから異ボリューム上のファイル or フォルダをエクスプローラのディレクトリタイルへ drop する
- **THEN** システムは `copyInto` を実行する（onPerformDrop 側でボリューム判定して自動 copy にフォールバック）
- **AND** カーソル表示は move のままになることがある（外部 drag は onDropOver で source path を同期的に取れないため）

#### Scenario: Finder → アプリ内（サイドバーお気に入り / 「上の階層へ」へ drop）

- **WHEN** Finder からノードをサイドバーお気に入り、または「上の階層へ」タイルへ drop する
- **THEN** それぞれ該当パスに対して同じ move / copy ロジックを実行する
