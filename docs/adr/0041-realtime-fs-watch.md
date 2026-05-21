# ADR-0041: Explorer / Git ビューを FSEvents 監視で自動更新する

- **Status**: Accepted
- **Date**: 2026-05-21

## Context

Finder や CLI など Roola の外でファイルを操作したとき、Explorer タブも Git
ビューも画面が古いままになる。`ExplorerViewModel` は `navigateTo` 1 回ごとに
ディレクトリ直下を `listSync` するだけで、`GitViewModel` も `build` 時 / 操作
完了時にしか `git status` / `git log` を呼ばない。リアルタイム反映は無い。

ターミナルでファイルを増やしたあと Explorer タブをクリックしないと出ない、
Finder 側で削除しても表示が残る、外部で `git commit` しても履歴が更新されない
など、外部編集を併用するユーザーから見ると「壊れている」体験になる。

## Decision

Dart 標準の `Directory.watch()`（macOS では FSEvents をラップする）を使い、
ViewModel に **デバウンスされたファイルシステム監視** を組み込む。

### 設計サマリ

- 監視ロジックは data 層に `DirectoryWatcher` として切り出し、`Stream<void>`
  を返す薄いラッパとする
- 監視は **デバウンス 300ms**。連続イベント（大量コピーや git の内部更新）を
  1 回の再ロードにまとめる
- 監視スコープは ViewModel ごとに決める:
  - **Explorer**: `currentPath` 直下のみ（`recursive: false`）。`navigateTo` で
    監視先を貼り直す
  - **Git**: `repoRoot` 全体（`recursive: true`）。作業ツリーの変更と
    `.git/HEAD` / `.git/index` / `.git/refs/` の変更を拾う
- **除外パス**: Git ビューは `.git/objects/`・`.git/logs/`・`.git/lfs/` を除外
  する（ノイズが多くデバウンス後も再ロードを誘発しやすい）
- **再入抑止**: Git ビューは `runningOperation != null`（自分の git コマンド
  実行中）の間は再ロードをスキップする。操作完了時の `_perform` 自身が
  再ロードを行うため

### 失敗時の挙動

`Directory.watch()` の購読が例外を投げた場合（権限不足等）は **silent fail** と
する。ユーザーは従来通り Explorer のパスバー操作 / Git の手動「Refresh」で更新
できる。フォールバックのポーリングは導入しない。

## Why

- **FSEvents は macOS ネイティブの低コスト監視**。Dart の `Directory.watch()`
  経由で利用でき、外部依存（`watcher` パッケージ等）も不要
- **デバウンスで十分**: 300ms あればコピー・削除・git の内部書込みが大体
  1 イベントにまとまる。100ms 以下は重複ロードが目立ち、1000ms 以上は体感
  として遅延が分かる
- **Explorer は recursive: false で十分**: 深い階層の変化が起きても、
  ユーザーが見ている現在ディレクトリだけ更新すればよい。深部の状態は
  そのパスに移動した時点で読み直される
- **Git は recursive: true 必須**: 作業ツリー側の変更（任意の深さで起きる）も、
  `.git/` 配下のメタ更新も拾わないと「外部 commit が反映されない」「fetch 後
  にブランチ一覧が古い」が再発する
- **`.git/objects/` 除外の根拠**: gc や pack の更新でファイルが大量に変化する。
  履歴の表示には影響しない（コミット表示には `HEAD` / `refs/` の更新があれば
  足りる）

## 代替案

### 代替案 1: ポーリングで一定間隔リフレッシュ

`Timer.periodic` で 1〜2 秒ごとに `listSync` / `git status` を呼ぶ。

- 監視より実装は簡単だが、操作していない時にも CPU / I/O を消費する
- 体感更新は遅い（最大 1〜2 秒）
- 却下。

### 代替案 2: `watcher` パッケージを使う

pub.dev の `watcher` を導入。ポーリングと FSEvents を抽象化してくれる。

- macOS 限定アプリで FSEvents を直接叩ける環境のため、抽象化レイヤの追加は
  メリットが薄い
- 依存を増やしたくない（ADR-0005 の自己完結方針と整合させる）
- 却下。

### 代替案 3: Explorer も `recursive: true` で監視する

「サブツリーが画面外から変わったときに何か出したい」用途。

- 現状はサブツリーの表示が無い（フラットなディレクトリリスト）。recursive
  で拾っても画面に反映するものが無く、無駄なロードが増えるだけ
- ツリービュー機能が入った時点で改めて検討する
- 当面は却下。

## Trade-offs

- **大量ファイル変更で再ロード負荷**: 数千ファイルのコピー / `npm install`
  などで広域に変化があると、デバウンス後の 1 回でも `listSync` / `git status`
  の負荷が立つ。Explorer 直下では問題にならないが、Git は重いリポジトリで
  目立つ可能性がある
- **macOS sandbox / hardened runtime**: 公開 / 配布時の entitlements で
  ファイル監視が制限されるとフォールバック無しで失敗するだけになる。今は
  unsigned ローカルビルド前提なので問題は表面化していない。配布時に再検討
- **macOS のみ前提**: Roola は macOS desktop アプリで他 OS は対象外（ADR-0001）。
  `Directory.watch()` 自体は他 OS でも動くが、デバウンス値 300ms は FSEvents の
  バッチング特性を前提に選んでいる

## References

- ADR-0001（Flutter Desktop / macOS）
- ADR-0026（3 ペインタブ式ワークスペース）
- ADR-0027（per-tab 状態の family 化）
- ADR-0030（Git ビューをタブとして追加）
- Dart `Directory.watch` API: https://api.dart.dev/stable/dart-io/Directory/watch.html
