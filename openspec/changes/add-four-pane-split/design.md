# add-four-pane-split — Design

## Context

コード調査（2026-08-06）で確認した現行構造を前提とする。

- **状態の正本**: `WorkspaceLayout`（Freezed）が `topLeft` / `topRight` / `bottom` の
  3 つの `PaneSlot` と、`topRatio`（上下）/ `leftRatio`（上段左右）の 2 比率を持つ。
  `PaneSlot` は「タブ群 + `activeIndex`」で、**タブ 0 個 = 空スロット**
- **崩し再フロー**: `resolveWorkspaceLayout()`（純粋関数）が非空スロット数 0/1/2/3 で
  分岐し、`WorkspaceLayoutMode`（single / twoHorizontal / twoVertical / three）と
  描画順の `visibleSlots` を返す。`_WorkspaceArea` がモードごとに `WorkspaceSplit` を
  ネストする
- **明示的な「分割」操作は存在しない**: 「空スロットにタブが入る = 分割される」という
  等式で成立している。分割 UI が無いのはバグではなく設計
- **スロット非依存な部分**: per-tab 状態（`explorerViewModelProvider(tabId)` 等）は
  family のキーが `tabId` でスロットと無関係。フォーカス追跡（`focusedTabProvider`）も
  `tabId` ベース。`PaneWidget` / `PaneTabStrip` は `slotId` を引数に取る作り
- **`PaneSlotId.values` を走査する箇所**: `workspace_provider`（`_locate` / `tabById` /
  `openGitTab` / `openNotepadNote`）、`command_dispatcher`（`_focusedSlot` / `_cycleTab`）、
  `notification_click_provider`、`explorer_sidebar`、`explorer_node_tile`
  （`_slotContainingTab`）— **いずれも列挙値が増えれば自動的に 4 スロット対応になる**

## Goals / Non-Goals

**Goals:**

- 下段を左右 2 分割できるようにし、Claude セッションを 2 面同時に並べられるようにする
- 起動直後の見た目・操作感を現行 3 分割から一切変えない
- 新スロットが既存スロットと同じ振る舞い（タブ操作・状態保持・崩し再フロー）を持つ

**Non-Goals:**

- 任意グリッドの自由分割（ADR-0026 代替案 3。5 分割以上・入れ子分割は対象外）
- ペイン数・配置の設定化 / レイアウトプリセット
- レイアウトの永続化（ADR-0042 で廃止済み。DTO はフィールドを追随させるのみ）
- 自動起動先の賢い振り分け（下段のどちらに開くかの動的判断。左下固定で据え置く）

## Decisions

### D1. `WorkspaceLayoutMode` enum を廃し「上段 row × 下段 row」モデルへ

4 スロットのまま enum 分岐を続けると、非空スロットの組み合わせは 15 通りになり、
モードは最低 6 値（single / twoHorizontal / twoVertical / 上 2 下 1 / 上 1 下 2 / four）
必要になる。代わりに **row 単位で独立に解決する**:

```
topSlots    = [topLeft, topRight]    のうち非空
bottomSlots = [bottomLeft, bottomRight] のうち非空

両 row とも非空 → Column(上段, 下段)      … topRatio
片方だけ非空   → その row を全画面
row 内 2 つ    → Row(左, 右)              … 上段 leftRatio / 下段 bottomLeftRatio
row 内 1 つ    → そのまま全幅
```

- `ResolvedWorkspaceLayout` は `{ topSlots, bottomSlots }` の 2 リストのみを持つ。
  `mode` / `visibleSlots` は廃止（参照元は `_WorkspaceArea` のみで、影響は局所的）
- 既存の全パターンがこの規則の帰結として出る:
  - 3 分割 = 下段が `bottomLeft` 1 つ → 下段が全幅（**現行と同一の描画**）
  - `twoHorizontal` = 片方の row に 2 つ / `twoVertical` = 各 row に 1 つずつ
  - `single` = 1 つの row に 1 つだけ
- 全スロット空のフォールバックは現行どおり `topLeft` 単体を返す
  （実際には `_ensureNotEmpty` が先に seed するため理論上のみ）

**代替案（enum を 6 値へ拡張）**: 変更量は小さいが、`three` に「上 2 下 1」と
「上 1 下 2」の 2 種があり `visibleSlots` の順序解釈が呼び出し側依存になる。
row モデルなら順序の解釈が構造に埋まるため却下。

### D2. スロット名は `bottom` → `bottomLeft` にリネームする

- `bottom` を残して `bottomRight` だけ足すと、下段左右で名前の対称性が崩れ、
  「`bottom` は下段全体か左下か」が読み手に伝わらない
- 参照は 15 箇所程度で、すべて機械的置換（挙動不変）。コンパイルエラーで漏れを検出できる
- 比率フィールドは `leftRatio`（上段・既存維持）/ `bottomLeftRatio`（下段・新規）とする。
  `leftRatio` → `topLeftRatio` へのリネームは対称性は上がるが差分を広げるだけなので
  行わず、doc comment で「上段の」と明示する

### D3. 右下ペインへの到達経路はタブ右クリック + DnD

- **タブ右クリックメニュー**: `_TabMenuAction` に `moveBottomRight` を追加。既存 3 項目と
  同じ「現在のペイン以外を出す」規則に従う
- **DnD**: `moveTab` 経由なので、右下ペインが描画されていれば既存のドロップ受け口
  （`_TabChip` / `_EndDropZone`）がそのまま効く。**追加実装は不要**
- **空の間はドロップできない**: 空スロットは描画されないため、右下が空のうちは
  DnD の受け口も「+」も存在しない。最初の 1 枚は右クリックメニューで送る必要がある。
  これは既存スロット（`topRight` / `bottomLeft`）と同じ性質で、それらが既定 seed で
  最初から埋まっているために表面化していなかっただけ。新たな例外は作らない
- 専用の「分割」コマンド（⌘⌃D 等）は作らない。既存の移動コマンド体系
  （⌘⌃1/2/3）に 4 つ目（⌘⌃4）を足す方が語彙が一貫する

### D4. 自動起動先は左下固定（`bottomLeft`）

タイル右クリックのターミナル / Claude / スキル、worktree 作成後の起動、Git ビューの
「ターミナルを開く」、ノートパッドボタン、サイドバーの各起動は、下段にフォーカスが
あっても常に `bottomLeft` へ開く（現行の `bottom` からのリネームのみ）。

- 右下は「ユーザーが明示的に置いたものだけが入るペイン」となり、自動で開いたタブに
  作業中のセッションが押し流されない
- 「フォーカス中が下段ならそのペイン」への変更は `_focusedSlot()` と同じ要領で後から
  小さく入れられる。まず挙動不変で出し、使ってから判断する
- 例外は既に存在する `_slotContainingTab()`（`explorer_node_tile.dart`）で、
  こちらは `PaneSlotId.values` 走査のため**右下のエクスプローラから開いたエディタタブは
  右下に出る**（自動的に正しい挙動になる）

## Risks / Trade-offs

- **4 分割時の各ペインが狭い**: ADR-0026 が挙げた「3 分割時の各ペインが狭い」がさらに
  進む。ユーザーが明示的に選んだときだけ 4 分割になる設計（既定は 3 分割）で緩和する。
  `WorkspaceSplit` の `minPaneSize` と比率クランプ（0.15〜0.85）は現行のまま効く
- **`resolveWorkspaceLayout` の戻り値型変更**: `WorkspaceLayoutMode` を参照している
  テスト（`workspace_layout_mode_test.dart`）は全面書き換えになる。参照元の実コードは
  `_WorkspaceArea` 1 箇所のみなので影響範囲は小さい
- **右下ペインの片道感**: 生成が右クリックメニュー経由のみで、戻すときも同様。
  既存 3 ペインと同じ操作感なので新たな学習コストは生まない

## Open Questions

（なし）
