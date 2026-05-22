# ADR-0049: 起動直後の OS 連携 DnD 登録を初回フレーム後まで遅延する

- **Status**: Accepted
- **Date**: 2026-05-22

## Context

Roola のエクスプローラは、OS とのファイル DnD（ドラッグ＆ドロップ）に
`super_drag_and_drop` / `super_native_extensions` を使う（[ADR-0011]）。
このプラグインは macOS ネイティブ層で、ドロップ先（`DropRegion`）や
ドラッグ元（`DragItemWidget` / `DraggableWidget`）の登録時に
`irondash_engine_context` 経由で **engine handle → FlutterView** を解決する。

アプリ起動時に **間欠的な** クラッシュ（`EXC_BAD_ACCESS` / `SIGSEGV`）が
発生する報告があった。クラッシュレポートのメインスレッドのスタックは次の通り。

```
0  libobjc.A.dylib            objc_loadWeakRetained + 32
1  irondash_engine_context    +[IrondashEngineContextPlugin getFlutterView:]
2-7 super_native_extensions   （DnD のドロップ先登録パス）
8  CoreFoundation             __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM
```

- 例外サブタイプ: `KERN_INVALID_ADDRESS at 0x0000000000000008`
- `objc_loadWeakRetained` に渡された weak 変数アドレスが `x0 = 0x8`
  （= `self == nil` 相当のオブジェクトの offset 8 にある `_flutterView`
  ivar を読もうとした）

### 根本原因（engine/view レジストリ確定前の DnD 登録レース）

`+[IrondashEngineContextPlugin getFlutterView:]` は、irondash が保持する
**engine handle → FlutterView（weak）の `NSMutableDictionary`** を
`objectForKey:` で引く。起動直後はこのレジストリがまだ確定しておらず
（`window_manager` でのウィンドウ表示・view の attach タイミングと前後する）、
`super_native_extensions` が最初の `DropRegion` / `DragItemWidget` の
マウントでドロップ先を OS に登録しようとした瞬間に、Dictionary から
**解放済み／不正なエントリ**を掴み、その weak `_flutterView` のロードで
クラッシュする。

タイミングが合致したときだけ壊れるため、**毎回ではなく起動直後に時々**
という症状になる。Roola は [ADR-0042] により起動時に既定 seed で
エクスプローラタブを開くため、`DropRegion` 系 Widget が**初回フレームで
一斉にマウント**され、このレースの窓を踏みやすい。

`super_drag_and_drop` / `super_native_extensions`（0.9.1）/
`irondash_engine_context`（0.5.5）はいずれも本 ADR 時点で pub.dev の
**最新版**であり、バージョン更新では解消しない。原因は third-party の
ネイティブ層にあり、Roola からフォークせずに直すなら Flutter 側で
登録タイミングをずらすのが現実解となる。

[ADR-0011]: 0011-explorer-dnd-super-drag-and-drop.md
[ADR-0042]: 0042-discard-workspace-on-exit.md

## Decision

OS 連携 DnD の登録を、**初回フレーム描画後まで遅延**する。

- `dndReadyProvider`（`Notifier<bool>`）を新設する
  （`lib/ui/explorer/dnd_ready_provider.dart`）。起動直後は `false`。
- アプリ最上位ツリーに `DndReadyGate` を 1 つ配置し、`initState` の
  `WidgetsBinding.instance.addPostFrameCallback` で最初のフレーム完了後に
  `dndReadyProvider` を `true` にする（`window_manager.show()` は `main()`
  で既に完了しているため、このタイミングでは engine/view レジストリが
  確定している）。
- エクスプローラ内の `super_native_extensions` 系 Widget は、
  `ref.watch(dndReadyProvider)` が `true` になってからマウントする。
  `false` の間は同等の素のサブツリー（DnD ラッパ無し）を返す。対象は
  以下の 6 箇所:
  - `DropRegion`: 現在ディレクトリ背景 / 親ディレクトリタイル /
    ディレクトリタイル / サイドバーお気に入り行
  - `DragItemWidget` + `DraggableWidget`: ディレクトリタイル /
    ファイルタイル（ドラッグ元）
- サイドバーの内部並べ替えに使う `LongPressDraggable` は Flutter 標準
  （super_native_extensions ではない）なので、ゲート対象外でそのまま包む。

ユーザー体感は「起動直後の 1 フレームだけ DnD が無効」で、実質知覚されない。

## Why

- **すぐ直る・リポジトリ内で完結**: third-party ネイティブのバグだが、
  Flutter 側で登録タイミングを 1 フレームずらすだけで競合の窓を塞げる。
  最新版でも残るバグであり、上流修正やバージョン更新を待たない。
- **副作用が小さい**: 既存の DnD 挙動・見た目は不変。`dndReady` が
  `true` になった後は従来とまったく同じツリーを構築する。ゲート中も
  クリック／ダブルクリック／コンテキストメニューは素のサブツリーで動作する。
- **フォークしない**: `super_native_extensions` / `irondash_engine_context`
  をフォークして native を直すより、Dart 側の最小ゲートのほうが
  バージョン追従が容易。

## 代替案

### 代替案 1: プラグインを更新する

- 3 つとも本 ADR 時点で pub.dev 最新版（0.9.1 / 0.5.5）であり、更新では
  直らない。却下（更新自体は将来も継続するが、本件の解にはならない）。

### 代替案 2: `irondash_engine_context` / `super_native_extensions` をフォーク

- ネイティブ層の Dictionary アクセスを安全化すれば根本治療になりうる。
- 2 つのプラグインのフォーク管理は割に合わず、バージョン追従コストが高い。
  却下。

### 代替案 3: 起動時のエクスプローラタブ復元（seed）自体を遅延する

- DnD だけでなくエクスプローラ全体を 1 フレーム遅らせる案。
- メイン UI の初回描画が遅れ、起動が一瞬空白になる。影響範囲が広く
  過剰。DnD 登録だけをゲートするほうが副作用が小さい。却下。

## Trade-offs

- **緩和策であって根本修正ではない**: 競合の「窓」を初回フレーム後へ
  ずらして塞ぐ。`addPostFrameCallback` 時点でレジストリが確定している
  前提に依存する。万一それでも再発する場合は、`Future.delayed` で
  さらに短い遅延（例: 100ms）を足す余地を残す。
- **間欠的クラッシュゆえ検証が難しい**: 「直った」の確証は、修正後に
  起動を多数回繰り返して再発しないことの観察で担保するしかない。
- **将来上流が直したら撤去候補**: プラグイン側で安全化されたら、
  `dndReadyProvider` / `DndReadyGate` とゲート分岐は撤去できる。
  `Status` を Deprecated にして ADR を残す方針。

## References

- 起動時クラッシュレポート（`tech.yahiro.Roola` 0.0.18 / macOS 26.4.1）—
  `objc_loadWeakRetained` → `+[IrondashEngineContextPlugin getFlutterView:]`
  → `super_native_extensions` の DnD 登録パスで `KERN_INVALID_ADDRESS at 0x8`
- ADR-0011（エクスプローラの DnD を `super_drag_and_drop` で OS 連携にする）
- ADR-0042（アプリ終了時にワークスペースを破棄し、起動は既定 seed で始める。
  起動時に `DropRegion` が一斉マウントされる前提条件）
- `lib/ui/explorer/dnd_ready_provider.dart`（`dndReadyProvider` /
  `DndReadyGate`）
