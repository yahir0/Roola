# ADR-0022: Claude Code 関連機能を optional 化する

- **Status**: Accepted
- **Date**: 2026-05-14

## Context

Roola は Claude Code に最適化された開発ツールとして始まったが、ADR-0016 で汎用ターミナルランチャーに
拡張されており、Claude Code がインストールされていないユーザーでも基本的なエクスプローラ / ランチャー
機能は使える設計になっている。

ところが UI 側はまだ「Claude Code が必ず入っている」前提の作りで、未導入環境では:

- フォルダの特別アイコン（`.claude/skills/` 検知）が出るが、クリックしても何も起きない
- 右クリックメニューに「Claude Code を開く」が並ぶが、押すと PTY が即座に失敗
- ランチャー登録時に「Claude Skill」タイプが選べてしまうが、保存しても起動できない
- 未導入の警告は `_ClaudeHealthBanner` として一瞬出るだけで、何が制限されているか分かりづらい

ユーザーフィードバック: 「Claude が入っていないなら Claude 関連 UI を最初から隠してほしい。何が
使えるようになるかを設定画面で示してほしい」。

## Decision

**`claude` CLI の検出状態（`claudeHealthProvider`）に応じて Claude 関連 UI を全面的に gate する。**

### Provider

- `claudeAvailableProvider: Provider<bool>` を新設し、`claudeHealthProvider`（`FutureProvider`）を
  `AsyncValue.when` で `bool` 化する
  - data: `available` 値そのまま
  - loading: **`true`**（起動直後の数百 ms に Claude 関連 UI が点滅するのを避ける）
  - error: false（最終的に false 寄りで保守する）
- 各 UI ウィジェットは `ref.watch(claudeAvailableProvider)` だけで reactive にゲートできる

### Gate 対象

| 箇所 | 旧挙動 | 新挙動 (claude 未導入時) |
|---|---|---|
| `_DirectoryTile` の `folder_special` アイコン / Skill chip / Skill subtitle | 常時表示 | 非表示 |
| 右クリックメニュー「Claude Code を開く」 | 常時表示 | 非表示 |
| 右クリックメニュー「Skill 即実行」「Skill をホーム登録」 | skillNames が空でなければ表示 | 非表示 |
| Entry 編集 SegmentedButton の「Claude Skill」セグメント | 常時表示 | **新規エントリでは非表示** (既存エントリが ClaudeSkillAction の場合は維持) |
| Entry 編集の動作セレクタ上の警告 | なし | warning notice を常時表示 |
| EntryEditViewModel の `SkillScanner.scan` | 常時実行 | スキップ (候補は空配列) |
| 設定画面 | 未導入時の Banner のみ | 「Claude Code 連携」常設セクションで状態 + 機能一覧 + インストール手順 |

### Entry 編集で既存 ClaudeSkillAction を残す理由

claude が後から消えた / 別マシンに移ったケースで、既に保存済みの ClaudeSkillAction エントリを
強制的にタイプ変更させるのは破壊的。セグメントは残し、警告 notice で「保存しても動かない」旨を
伝える。ユーザーが望めば手動で「コマンド実行」「開くだけ」に変えられる。

### 設定画面の `_ClaudeIntegrationSection`

「Claude Code 連携」セクションを常設し、以下を 1 画面に集約:

1. **検出ステータスカード**: ✓ 検出済み (version) / ✗ 未検出 (詳細) / ⏳ 検出中 / ⚠ エラー の 4 状態
2. **有効化される機能の一覧**: チェックリスト形式で 3 項目（Skill 検知、右クリックメニュー、Skill 動作タイプ）
3. **未導入時のみ表示するインストール手順**: `npm install -g @anthropic-ai/claude-code` を
   コードブロックで提示し、コピーボタン付き

## Why

### loading 時に optimistic = true にする理由

Process.run の解決は数百 ms かかる。その間 false を返すと、起動直後に Claude UI が一瞬消えてから
判定後に復活する flicker が出る。多くの場合 claude は入っているので true 寄りにフォールバックする
ほうが UX 上自然。仮に claude が無い環境でも、判定後すぐに UI が消えるだけ。

### 既存データを破壊しない設計

既存 ClaudeSkillAction エントリは:

- データ層では何も変更しない（永続化スキーマも変えない）
- UI 層で「表示はする / 警告は出す / 起動するとエラーになる」運用

これにより claude が再導入された瞬間に即座にすべて元通り動く。逆に新規作成だけは抑制することで、
未導入環境で「動かないエントリを作って後で困る」事故を防ぐ。

### Banner ではなく Section にした理由

旧 `_ClaudeHealthBanner` は「未導入時のみ表示」「アクションなし」「設定の他項目と並ぶと存在感が弱い」
という問題があった。常設セクションにすることで:

- ユーザーは「Claude 連携を有効にするには何をすればいいか」を能動的に学べる
- 検出済みでも version 確認や「何が有効になっているか」が見られる
- インストール手順を Roola アプリ内に持てる（外部リンクに飛ぶ必要がない）

## 代替案

### 代替案 1: claude 未導入時は Skill 関連コード全部を data 層からも消す

`ExplorerDirectoryLoader.scan` をスキップする、`LauncherAction.claudeSkill` を非表示にする等を
データ層で実装する案。

- 後で claude を入れた / 別マシンに移った時にデータが消える可能性
- データ層は claude の存在を意識すべきでないという責務分離
- 却下: UI 層のみで gate する

### 代替案 2: claude 未導入時に Roola を起動拒否する

そもそも Claude Code 必須にする案。Roola 当初の路線。

- ADR-0016 で汎用化したので方針と矛盾
- 却下

### 代替案 3: 起動時に claude を都度チェックし、ユーザーが「再チェック」できるようにする

`claudeHealthProvider` を invalidate するボタンを設置。

- 実装は容易だが、現状は「Roola 起動時に 1 度確認」で十分。再起動すれば再チェックされる
- 必要になったら別 ADR で追加
- 当面却下

## Trade-offs

- **キャッシュ更新タイミング**: claude のインストール → Roola 再起動でないと反映されない。
  常時監視はコストに見合わないため、再起動による反映で運用する
- **設定画面のセクション肥大**: 「Claude 連携」+「外観」+「ショートカット」で 3 セクション。
  順序は Appearance → Claude → Shortcuts として「ブランド色設定 → 機能の有無 → 操作ガイド」
  の流れにする
- **既存 ClaudeSkill エントリの隠れた問題**: 警告 notice はあるが、claude 未導入のままユーザーが
  起動するとエラーが出る。これは PTY 失敗のメッセージとして既に通知される（ハッキリ「claude が無い」
  と伝わる）ので、二重表示は避ける
- **テストでの override 必須**: `claudeHealthProvider` は実 process を呼ぶため、UI テストでは
  必ず `overrideWith` で同期値を返す必要がある（pending Timer 検出に引っかかる）

## References

- ADR-0005（外部 Skill / プラグインに依存しない自己完結方針）
- ADR-0016（ランチャー汎用化）
- [Claude Code 公式ドキュメント](https://docs.claude.com/claude-code)
