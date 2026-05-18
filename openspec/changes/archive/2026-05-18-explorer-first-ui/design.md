## Goals

- Explorer をメイン UI、Skills をサブ機能として再配置し、コア体験（1〜2 クリックの Skill 呼び出し）を維持
- ディレクトリ閲覧と PTY ターミナルを同一エリアで切替表示する「Explorer の一ページとしてのターミナル」体験
- お気に入り未登録時の「飛び先がない」詰みを防ぐ

## Non-goals

- selection 状態の永続化
- 大量ファイルディレクトリ表示の非同期化
- Spotlight 風キーボードランチャー
- 「ホーム / ランチャー専用画面」をユーザー設定で復活させるオプション

## Phase 1 アーキテクチャ

### サイドバーの 4 セクション

```
┌────────────────────┐
│ 場所               │
│  ⌂ ホーム          │
│  ⬇ ダウンロード    │
│  🖥 デスクトップ   │
│  📄 ドキュメント   │
│  📦 アプリケーション│
│  ⋯ 別のフォルダを…  │  ← file_picker
├────────────────────┤
│ お気に入り (+ ボタン) │
│  Docs              │
│  Repos             │
├────────────────────┤
│ ランチャー (+ ボタン) │
│  ⚡ alpha          │
│  ⚡ beta           │
├────────────────────┤
│ 実行中             │
│  ◉ alpha          │
│  ◉ beta           │
│  (なし)            │  ← 空のとき
└────────────────────┘
```

実装方針:

- `ExplorerSidebar` を 1 つの `ListView` にまとめ、4 セクションそれぞれを `SliverPersistentHeader` 不要の単純 `Column` で並べる
- 場所の固定エントリは `_DefaultPlaces`（const list）で定義
- 「別のフォルダを開く…」は `FilePicker.getDirectoryPath` を呼んで `explorerViewModelProvider.navigateTo` する
- ランチャーは `launcherEntriesProvider.value` を購読してリスト描画。クリック時は **Phase 1 の暫定として** 既存の `RunRoute(entryId: ...).push(context)` を呼ぶ
- 実行中は `activeSessionsProvider` + `launcherEntriesProvider` + `ActiveSessions.adhocArgsFor` を組み合わせてラベルを構築（`ActiveSessionsStrip` のロジックをサイドバー向けに移植）。クリックは `RunRoute` / `RunAdhocRoute` push（Phase 1 暫定）。✕ ボタンで `terminateSkillSession` / `terminateAdhocSession`

### root ceiling 廃止

`ExplorerViewModel.goUp()` から `if (state.currentPath == state.root) { return; }` を除去。それ以外の場所では root を参照しない（`ExplorerState.root` フィールドは保持、`_history` も保持）。

「ルートを変更」AppBar アイコンの tooltip 文言を「ルートディレクトリを変更」→「起動時のディレクトリを変更」へ更新。

### Phase 1 で動く中間状態の見た目

- AppBar タブは Home / Explorer 並列のまま（StatefulShellRoute は触らない）
- Home 画面は引き続き存在し、グリッドと chip 列が見える
- Explorer 画面は新サイドバーが表示される
- Explorer のサイドバー「ランチャー」/ 「実行中」クリックは `RunRoute` 全画面遷移（Home と同じ挙動）
- root の上にも登れるようになる

ユーザーは Phase 1 だけで「Explorer サイドバーからランチャー呼べる」体験を得る。Phase 2 で body 切替と Home demotion が入る。

## Phase 2 アーキテクチャ

### `ExplorerSelection` state

```dart
@freezed
sealed class ExplorerSelection with _$ExplorerSelection {
  const factory ExplorerSelection.directory(String path) = _Directory;
  const factory ExplorerSelection.session(String sessionId) = _Session;
}

@Riverpod(keepAlive: true)
class ExplorerSelectionNotifier extends _$ExplorerSelectionNotifier {
  @override
  ExplorerSelection build() {
    final root = ref.watch(explorerSettingsProvider).value?.rootPath ?? _defaultHome();
    return ExplorerSelection.directory(root);
  }
  void selectDirectory(String path) => state = ExplorerSelection.directory(path);
  void selectSession(String id) => state = ExplorerSelection.session(id);
}
```

サイドバーの全タイル / ⚡ popover のタイル / 右クリック「Skill 即実行」が `selectDirectory` / `selectSession` を呼ぶ。

`ExplorerViewModel.navigateTo` も内部で `selectDirectory` を発火するように改修（path 変更と selection を同期）。

### body の構造

```dart
class _ExplorerBody extends ConsumerWidget {
  Widget build(...) {
    final selection = ref.watch(explorerSelectionProvider);
    return switch (selection) {
      ExplorerSelectionDirectory(:final path) => _DirectoryListing(path: path),
      ExplorerSelectionSession(:final id) => _SessionTerminal(id: id),
    };
  }
}
```

`_SessionTerminal` は既存 `RunPage` の body を抽出して埋め込み形に変えた Widget。PTY は keepAlive Provider が握っているので、selection 切替で破棄されない。

### ⚡ Popover

AppBar に `IconButton(Icons.bolt, ...)` を追加。押下で `showMenu` か `MenuAnchor` を使い、popover の中に既存 `HomePage` のグリッドを描画する。各タイルクリックで `selectSession`（永続エントリは `runViewModelProvider(entry.id)` を確実に build してから）または既存の起動ロジックを通す。

### 既存 route の撤去

- `HomeRoute` / `ExplorerRoute` の `StatefulShellRoute` を解体し、`ExplorerRoute` を root のみに
- `RunRoute` / `RunAdhocRoute` を削除
- `EntryNewRoute` / `EntryEditRoute` は設定画面の中の遷移として残す

### chip 列の撤去

`ActiveSessionsStrip` を `HomePage` から削除し、サイドバー「実行中」セクションに完全に置き換える（Phase 1 で並走させていたものを Phase 2 で取り除く）。

## Trade-offs

### Phase 1 の中間状態は二重表示になる

- Home の chip 列と Explorer サイドバーの「実行中」セクションが両方表示される
- 「ランチャー」も Home グリッドとサイドバー両方に出る

Phase 1 でこの状態を一度動かして UI の見え方を確認したのち、Phase 2 で重複を解消する。混乱コストは Phase 1 の短期間だけ。

### selection 切替時の入力フォーカス

PTY セッションを表示中にサイドバーからディレクトリへ切り替えると、xterm.dart の TerminalView が unmount される（実際の PTY は生きているが widget は破棄）。再度同セッションを選ぶと TerminalView が再 mount され、表示は復元されるが xterm.dart 側のスクロール位置は失われる可能性。

緩和: `IndexedStack` で全 session widget を同時に build しておき、selection が変わったら表示だけ切替える。ただし session が増えるとメモリ消費が増えるので、上限（例: 4 件）で破棄する LRU 戦略を別途検討。本 change ではまず単純な build/unmount で始め、xterm の挙動を観察する。

### Phase 2 のディープリンク撤去

`/run/...` 直接 URL で開けなくなる。Roola は URL を外に出さないため影響無し。

## References

- ADR-0010: タブ式 `StatefulShellRoute`（Superseded by ADR-0014）
- ADR-0014: Explorer-first / Home demotion
- ADR-0015: Explorer ceiling 廃止
