## ADDED Requirements

### Requirement: ローカル JSONL からの使用量集計

システムは `~/.claude/projects/**/*.jsonl` の各行を読み取り、Claude Code の使用量（トークン・推定コスト）を集計 SHALL する。
集計はネットワークや Claude Code 本体プロセスに依存せず、ローカルファイルのみを
入力とする（ADR-0005 自己完結方針）。

集計対象の行は `type` が `assistant` で `message.usage` を持つ行とする。各行から
以下を取得する: `message.usage.input_tokens` / `cache_creation_input_tokens` /
`cache_read_input_tokens` / `output_tokens`、`message.model`、top-level `timestamp`。

#### Scenario: 当日の使用量を集計する

- **WHEN** `~/.claude/projects` 配下の JSONL に `message.usage` を持つ assistant 行が存在する
- **THEN** システムは各行のトークン種別（input / output / cacheRead / cacheCreation）を
  種別ごとに合算した当日（ローカルタイムの 0:00〜現在）の合計を算出する

#### Scenario: usage を持たない行を無視する

- **WHEN** 行が user メッセージ・サマリ・`message.usage` を持たない等で使用量を含まない
- **THEN** システムはその行を集計対象から除外し、エラーにしない

#### Scenario: 破損行をスキップする

- **WHEN** JSONL の特定行が不正な JSON でパースに失敗する
- **THEN** システムはその行のみスキップし、ファイル全体の集計は継続する

### Requirement: 重複レコードの排除

システムは `message.id` と `requestId` の組をキーに重複行を排除 SHALL する。
同一 API レスポンスが複数行に重複記録される可能性に備え、同一キーの行は
1 回のみ集計に算入する。

#### Scenario: 同一 message.id + requestId を二重計上しない

- **WHEN** 同じ `message.id` かつ `requestId` を持つ usage 行が複数存在する
- **THEN** システムはそのうち 1 件のみを集計し、残りを重複として除外する

### Requirement: 推定コストの算定

システムはトークン種別ごとの合計にモデル別単価を掛けて推定コスト（USD）を算出 SHALL する。
コストは「推定」であり厳密な請求額ではないことを UI 上で明示する。
未知のモデル（単価表に無い model 文字列）はコスト 0 として扱い、トークン集計には
引き続き算入する。

#### Scenario: モデル別単価で推定コストを出す

- **WHEN** 集計結果に既知モデルのトークンが含まれる
- **THEN** システムは input / output / cacheRead / cacheCreation それぞれの単価を
  適用し、合算した推定コストを USD で返す

#### Scenario: 未知モデルはコスト 0 として扱う

- **WHEN** 単価表に存在しない `model` 文字列のトークンが含まれる
- **THEN** システムはそのモデルの推定コストを 0 とし、トークン数は通常どおり集計する

### Requirement: ファイル変更のリアルタイム追従

システムはモニタ表示中に対象 JSONL ディレクトリを監視し、追記・新規ファイル作成を検知して使用量表示をほぼリアルタイムに更新 SHALL する。
監視は ADR-0041 の監視方式を踏襲する。

#### Scenario: JSONL 追記で表示が更新される

- **WHEN** Claude Code が稼働中の JSONL に新しい usage 行を追記する
- **THEN** システムは変更を検知して再集計し、トップバーの使用量表示を更新する

#### Scenario: 監視はモニタ表示中のみ常駐する

- **WHEN** アクティビティモニタが表示されている
- **THEN** システムは監視を常駐させ、モニタの破棄時に監視を停止する

### Requirement: トップバー要約表示

システムは `claude` CLI が利用可能な環境でのみ、トップバーに当日の使用量要約を 1 つ表示 SHALL する。
要約は他のシステム指標（CPU / メモリ）と並んで配置し、Polaris デザインシステム
（ADR-0038）のトークン（色・余白・角丸）に従う。ハードコードした色・寸法を用いない。
Claude 関連機能の optional 化（ADR-0022）に従い、`claude` が見つからない環境では
メーターを表示してはならない（MUST NOT）。

#### Scenario: 当日の要約値を表示する

- **WHEN** `claude` CLI が利用可能で、アクティビティモニタが表示されている
- **THEN** システムは当日の合計トークンまたは推定コストを要約値として表示する

#### Scenario: Claude 未検出時はメーターを表示しない

- **WHEN** `claude` CLI が見つからない（[claudeAvailableProvider] が false）
- **THEN** システムは使用量メーターのセルを表示せず、CPU / メモリのモニタのみを表示する

#### Scenario: データが無い場合のプレースホルダ

- **WHEN** `claude` は利用可能だが当日の usage 行が 1 件も存在しない（または `~/.claude/projects` が無い）
- **THEN** システムはエラー表示ではなくゼロ相当のプレースホルダ（例: 0 トークン / $0.00）を表示する

### Requirement: ポップオーバー内訳表示

システムは使用量要約クリック時、既存のポップオーバー機構（ADR-0039）を用いて内訳を展開 SHALL する。
内訳は少なくともトークン種別別（input / output /
cacheRead / cacheCreation）の合計を含む。

#### Scenario: クリックで内訳を開く

- **WHEN** ユーザーがトップバーの使用量要約をクリックする
- **THEN** システムはポップオーバーを開き、当日のトークン種別別合計と推定コストを表示する

#### Scenario: ポップオーバーは排他制御に従う

- **WHEN** 別のアクティビティポップオーバー（CPU / メモリ）が開いている状態で使用量要約をクリックする
- **THEN** システムは既存の排他制御に従い、他のポップオーバーを閉じてから使用量内訳を開く

### Requirement: レートリミット残量の非対象明示

システムは公式レートリミット残量（5h 枠・週次 compute hours の %）を表示しては MUST NOT ならない。
これは機械可読な公開 API が存在せず正確な取得手段が無いためであり、
本機能は使用量メーターに限定する。

#### Scenario: レートリミット％を表示しない

- **WHEN** ユーザーが使用量メーターおよびその内訳を参照する
- **THEN** システムはレートリミット残量％を一切表示せず、表示値が「使用量（推定）」で
  あることが分かる文言を提示する
