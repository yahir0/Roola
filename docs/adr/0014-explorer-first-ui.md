# ADR-0014: Explorer をメイン UI に格上げし、Skills ランチャーをサブ機能へ降格する

- **Status**: Accepted
- **Date**: 2026-05-14

## Context

Roola は当初 Claude Code の Skills ランチャー（登録済み Skill × ディレクトリ組み合わせをワンクリック起動するアイコングリッド）として実装され、ホーム画面（タイルグリッド）がメインだった。

その後、ファイル DnD・PTY ターミナル・OS 連携など Finder ライクなエクスプローラ機能が加わり、ユーザーの主な操作起点は **エクスプローラ** に移行した。にも関わらず UI 上は:

- 起動時は `/`（HomeRoute）に飛ぶ
- AppBar のタブで Home / Explorer が同列に並ぶ
- 実行中セッションの chip 列はホーム画面下部にしか出ない

という、Skills ランチャー時代の名残のまま。実態と UI が乖離している。

加えて、サブ機能（Skill 呼び出し）をどう取り回すかが UI 設計のキモ。「単純に Home をどこかに隠す」だけだと、登録済みエントリのワンクリック起動という Roola のコア体験が機能ダウンする。

## Decision

エクスプローラを唯一のメイン画面とし、Skills ランチャーは以下 2 経路でアクセスできる「サブ機能」として位置付ける:

1. **サイドバーの「ランチャー」セクション**: 登録済み LauncherEntry を縦リストで常時表示。1 クリックで起動できる
2. **AppBar の `⚡` ボタン → Popover**: 現状のホームグリッド（大きめタイル + カスタムアイコン）を popover として表示。視覚的に贅沢な全件閲覧

具体的には:

- 起動 route を `/explorer` に変更
- `StatefulShellRoute` の Home ブランチを削除（Explorer 単一に）
- `HomePage` のタイルグリッドは popover の中身として再利用
- AppBar に `⚡` アイコンボタンを追加し、popover を開く
- サイドバーは Finder 流に **4 セクション** に再構成:
  - **場所**: ホーム / ダウンロード / デスクトップ / ドキュメント / アプリケーション + 「別のフォルダを開く…」
  - **お気に入り**: ユーザー登録のフォルダ（既存）
  - **ランチャー**: 登録済み Skill エントリ
  - **実行中**: active session（Skill / Terminal 双方）。空のときは「なし」のプレースホルダ
- body は **selection-driven**: サイドバーのいずれかを選ぶと、選択がディレクトリならディレクトリ一覧、セッションなら PTY ターミナルを描画。両者は同一エリアで切り替わる
- 既存の「Home 下部の active session chip 列」「`/run/:id` / `/run-adhoc/:id` 独立ルート」は撤去し、selection 駆動に統合

## Why

### 代替案 1: タブを保ったまま順序だけ Explorer 優先に

却下。

- 「同列タブ」のまま見せると「Home と Explorer は同等の機能」というメッセージを発し続ける
- 実態は Explorer がメイン。タブで両者を並べると初見ユーザーが Home に迷い込みやすい

### 代替案 2: Home を完全撤去し、Skills は右クリック / Spotlight 風 UI のみ

却下。

- Skill ランチャー視認性 / 1 クリック起動性が大幅に後退する
- 「Skills 機能ダウンさせない」というオーナーの明示要件に反する

### 採用理由

- サイドバーの「ランチャー」で常時 1 クリック起動 → 機能ダウンしない（むしろ Home タブ経由より 1 クリック減る）
- Popover で視覚的タイル UI を保存
- selection-driven body により「ディレクトリ ↔ ターミナル」が同一エリアで切替可能 → Finder + ターミナルが一枚岩のアプリ感
- 「場所」セクションで初期ユーザーがお気に入り未登録でも詰まない

## Trade-offs

### `RunPage` 単独 route の撤去でディープリンクが消える

`/run/:id` を URL から呼べなくなる。Roola はそもそも URL を外に出さないため実害なし。

### selection 状態の永続化は当面しない

アプリ再起動時は強制的にディレクトリビュー（rootPath）に戻る。「再起動前に開いていたセッション」は ADR-0008 / ADR-0009 のキープアライブで残るが、自動選択はしない。サイドバーから明示的に選び直す運用。

### サイドバー縦領域

4 セクションを縦に積むので長くなる。低解像度では「実行中」が画面外に行く可能性。`ListView` でスクロール可能にする。

### Phase 化

実装範囲が大きいため 2 commit に分けて段階リリース:

- **Phase 1**: ADR / OpenSpec / サイドバー 4 セクション化 / ceiling 廃止（ADR-0015）
- **Phase 2**: body 切替 + Home タブ廃止 + ⚡ popover + chip 列撤去

Phase 1 後の中間状態では、サイドバーの「ランチャー」「実行中」クリックは既存の `/run/:id` 全画面遷移を使う（暫定）。Phase 2 で selection-driven に置換される。

## References

- ADR-0008: スキル実行セッションを実行画面 widget から切り離して保持
- ADR-0009: ad-hoc セッションを別 provider で扱う
- ADR-0010: Home / Explorer をタブ式 `StatefulShellRoute` で束ねる（**本 ADR で Superseded — Home タブ廃止**）
- ADR-0015: Explorer の root ceiling を廃止（本 ADR とセット）
