# ADR-0015: Explorer の root ceiling を廃止し、rootPath は「起動時の開始位置」に弱める

- **Status**: Accepted
- **Date**: 2026-05-14

## Context

これまで Explorer は `ExplorerSettings.rootPath` を **ナビゲーション上限（ceiling）** として扱っていた:

- `ExplorerViewModel.goUp()` は `currentPath == root` のとき何もしない
- 「上の階層へ」タイルもルートと一致するときは描画しない設計（実装上は `currentPath != '/'` だけだが、運用上は root より上に行かない前提）

これは launcher 用途で「1 つのワークスペースに閉じ込める」という当初設計の名残。

ADR-0014 で Explorer をメイン UI に格上げし、サイドバーに「場所」セクション（ホーム / ダウンロード / デスクトップ / ドキュメント / アプリケーション）を導入する方針となった。これらは `rootPath` の外を含むため、ceiling のままだと整合性が取れない。

## Decision

`ExplorerSettings.rootPath` の意味付けを **「起動時の開始位置」のみ** に弱める。具体的には:

- `ExplorerViewModel.goUp()` の `currentPath == root` ガードを除去する。root より上にも自由に登れる
- 「上の階層へ」タイルの表示判定は引き続き `currentPath != '/'`（filesystem の root を超えない）
- `rootPath` は build 時の初期 `currentPath` を決めるだけ。それ以降の navigation には影響しない
- AppBar の「ルートを変更」ボタンは継続して `rootPath` を更新するが、これは「次回起動時の開始位置」を変える操作になる
- 「ルートを変更」アイコンの tooltip 文言は「起動時のディレクトリを変更」に更新

## Why

### 代替案 1: ceiling を残しつつ「場所」は別 navigator にする

却下。

- 「ホーム」「ダウンロード」をクリックして root 外に出る挙動を「場所」だけ特例にすると、操作モデルがブレる
- ユーザーは「タイルクリック = 移動」と一貫した認識を持つほうが分かりやすい

### 代替案 2: `rootPath` 自体を完全撤去

却下（当面）。

- 「起動時にどこから始めるか」をユーザーが固定できるのは依然価値がある（プロジェクト用途では特定の場所から始めたい）
- 撤去すると毎回 home directory から開く挙動になり、ユースケース次第で煩わしい

### 採用理由

- 最小変更（goUp の 1 ガードを外すだけ）で挙動が望ましくなる
- `rootPath` の用途を限定するだけで永続データのスキーマ変更不要
- 「場所」セクションが自然に成立する

## Trade-offs

### root より上に登るとパフォーマンス課題が起き得る

ホームディレクトリより上に登るユースケースは少ないが、`/Users/` や `/` 直下を表示するとファイル数が多いケースも。`ExplorerDirectoryLoader` はディレクトリ直下を同期的に列挙するので、エントリ数によっては UI ハングの可能性。

緩和: 現状の `excludes`（.git / node_modules / .DS_Store 等）は維持。将来必要になったら非同期 + ページング化を検討。

### 「ルート」という言葉の意味が変わる

UI 文言の「ルートを変更」は「ceiling を変える」ニュアンスから「初期位置を変える」ニュアンスへ。tooltip 文言を「起動時のディレクトリを変更」に更新する。

### `ExplorerState.root` フィールドの存続

`ExplorerState` に `root` フィールドが残るが、用途は「ルートと一致するときの 上 button 非表示」以外に無くなる（その分岐自体は ADR-0014 で背景画像表示にも使うので残す）。

## References

- ADR-0014: Explorer をメイン UI に格上げ、Skills ランチャーをサブ機能へ降格
