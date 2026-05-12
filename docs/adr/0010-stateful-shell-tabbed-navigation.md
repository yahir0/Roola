# ADR-0010: Home / Explorer をタブ式 `StatefulShellRoute` で束ね、Run/Settings は root navigator に push

- **Status**: Accepted
- **Date**: 2026-05-12

## Context

これまでの routing は単一 navigator で、以下の構造だった:

```
/                 : HomeRoute → HomePage
/explorer         : ExplorerRoute → ExplorerPage
/run/:id          : RunRoute      → RunPage
/run-adhoc/:id    : RunAdhocRoute → RunPage
/settings         : SettingsRoute → SettingsPage
  entries/new     : EntryNewRoute → EntryEditPage
  entries/:id     : EntryEditRoute→ EntryEditPage
```

ホーム/エクスプローラ間の遷移は AppBar アクションから `.go()` で行い、Run も `.go()` で起動していた。この設計には以下の課題があった:

1. **Run の back ボタンが常にホームへ戻る**: エクスプローラからスキルを起動 → 戻る で、ユーザーが直前まで見ていたディレクトリではなくホーム画面に飛ばされる。`.go()` がスタックを書き換える挙動なので、Run の親は常に `/` になっていた。
2. **エクスプローラ側のディレクトリ表示状態が破棄される**: ホームに戻ってから再度エクスプローラを開くと、見ていたディレクトリ・スクロール位置が初期化される。エクスプローラ画面はずっと同じ route であり、`ExplorerViewModel` も 1 route ぶんしか keep されないため、画面遷移で破棄された。
3. **「ホームへ戻る」と「back」が UI 上区別しづらい**: 実行画面の AppBar に 2 個ボタンが並んでいて、ユーザーから見ると「どっちが何か分からない」「癖で左上の back を押してしまう」状態だった。

ユーザーの要望は次の通り:

- 画面上部に Home / Explorer の **タブを常時表示** し、タブ切り替えで両者を行き来できるようにする
- タブ切り替え時に **エクスプローラの表示状態を破棄しない**（すぐ戻って続きから操作したい）
- 実行画面の back 矢印は **起動元タブへ戻る**（エクスプローラから起動したらエクスプローラへ）
- back 矢印は習慣で押してしまうので、エクスプローラ内のディレクトリ移動でも有効にしたい

## Decision

routing を **`StatefulShellRoute.indexedStack` ベースのタブ構成** に変更する。

```
shell (AppShellRoute)        ← StatefulShellRoute.indexedStack
├── Branch 0 (HomeBranch)
│   └── /         : HomeRoute      → HomePage
└── Branch 1 (ExplorerBranch)
    └── /explorer : ExplorerRoute  → ExplorerPage
─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
/run/:id           : RunRoute       → RunPage         (root navigator, シェル外)
/run-adhoc/:id     : RunAdhocRoute  → RunPage         (root navigator, シェル外)
/settings          : SettingsRoute  → SettingsPage    (root navigator, シェル外)
  entries/new      : EntryNewRoute  → EntryEditPage
  entries/:id      : EntryEditRoute → EntryEditPage
```

主要な実装方針:

1. **シェル内のタブ切り替えは `StatefulNavigationShell.goBranch(index)`** を使う。`indexedStack` は非アクティブ branch の Navigator を破棄しないので、エクスプローラの `ExplorerViewModel` state（カレントパス、children）は自動で保持される。
2. **Run / RunAdhoc / Settings は `.push<void>(context)` で起動** する。シェル外の top-level route なので push 時に root navigator に積まれ、シェル全体（タブ含む）を覆って表示される。Back（`Navigator.pop`）でシェルに戻り、最後にアクティブだった branch の state がそのまま復元される。
3. **シェル直下に `AppShellScope`（InheritedWidget）を被せて `StatefulNavigationShell` を配下に渡す**。各 branch の `AppTabBar` はこの scope を `dependOnInheritedWidgetOfExactType` で購読し、`currentIndex` の変化に追従して rebuild する。`StatefulNavigationShell.maybeOf(context)` は State を返す API なので、reactive な購読には不向きだった。
4. **`MacosWindowAppBar` に `onBack` パラメータを追加** する。`Navigator.canPop` ベースの自動 back に加えて、route スタックが空でも `onBack` が渡れば back ボタンを表示し、push 履歴ではなく ViewModel 上の「論理的な戻る」（エクスプローラでは `goUp()`）を発火する経路を作る。
5. **Run 画面の「ホームへ戻る」ボタン（家アイコン）は撤去**。back 矢印が「起動元タブへ戻る」を担い、「✕ 閉じる」は session 破棄 + `Navigator.pop` で起動元タブへ戻る。home tab に明示的に行きたい場合は、戻ったあとに上部タブで切り替える。

## Consequences

- Pros:
  - ユーザーの直感どおりに back 矢印が「直前の画面」に戻る。Explorer 起動の Run → back で Explorer の表示状態が完全に保持される
  - タブ切り替えで非アクティブ画面が破棄されないので、エクスプローラとホームを頻繁に行き来する作業フローが快適になる
  - 実行画面の AppBar ボタン数が減り（back / 状態 chip / キャンセル or 再実行 / 閉じる）UI が単純化
  - URL 体系は据え置き（`/`, `/explorer`, `/run/:id`, …）でディープリンクや既存テストへの影響が最小
- Cons / 留意点:
  - シェル外 route 間で `.push()` と `.go()` の使い分けが要る。誤って `.go()` を使うとスタックが書き換わり、back の挙動が壊れる。go_router 17 / go_router_builder 4.3 では生成された `extension` が両方提供しているため、レビュー時に注意する
  - Run page を arbitrary URL で直接開いた場合（深 リンク等）、back のフォールバックとして `Navigator.pop` できないので `context.go('/')` で home へ落とすコードを残す。実機ではほぼ通らない経路だが UI 経由のテストでは保護として残す
  - 単体ウィジェットテストで HomePage / ExplorerPage を `MaterialApp(home: ...)` で直接 mount する場合、`AppShellScope` が存在せず `AppTabBar` が高さ 42 の透明 SizedBox になる。テストの assertion を壊さないようフォールバック実装を維持する

## Alternatives Considered

- **タブを使わず単一 navigator のままで Run に push を導入**: back 挙動の問題は解決するが、Explorer の state 破棄問題は残る（route が破棄されると ViewModel も破棄される）。さらに「タブで常時切り替え」の要望を満たせない。
- **Run / Settings をシェル内 branch にも配置**: タブ常時表示を Run 中も実現できるが、Run/Settings が 2 branch 分ぶんに重複定義され、`extra` 渡しなどの再利用も難しくなる。今回の要望（タブは Home/Explorer 用、Run/Settings は cover）にはオーバースペック。
- **Explorer に独自 history stack を持たせ、URL を `/explorer/<encoded-path>` で push する**: URL 化が複雑（パス区切りのエンコード/デコード、ルートとの差分計算）になる。ディレクトリ移動を route push にすると、長い深い階層に降りた時の back スタックがかさみ、`goUp()` 1 回で複数 pop しないと意味的に正しくない。論理 back（`onBack` callback）で十分。
