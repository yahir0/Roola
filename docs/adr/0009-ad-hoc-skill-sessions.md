# ADR-0009: ad-hoc セッションを `launcherEntriesProvider` に混ぜず別 provider で扱う

- **Status**: Accepted
- **Date**: 2026-05-12

## Context

`repo-explorer` change で、エクスプローラ画面の右クリックメニューから以下 2 種類のセッションを起動できるようにする:

1. **Skill を即実行**: アイコン登録を経由せず、検知された Skill をその場で起動
2. **このディレクトリで Claude Code を開く**: Skill 引数なしで `claude` を対話モード起動

いずれも「アイコングリッドには永続的に並ばないが、起動中・終了済みは chip 列に表示し、明示破棄まで保持する」という挙動を期待する（既存の `concurrent-skill-sessions` で導入したライフサイクルモデルと同じ）。

既存セッション基盤は次の構造になっている:

- `launcherEntriesProvider`: 永続化されたエントリ一覧（`AsyncNotifier<List<LauncherEntry>>`）
- `runViewModelProvider(entryId)`: family。`entryId` をキーに `launcherEntriesProvider` から該当 entry を引き、`PtySkillRunner` を起動
- `activeSessionsProvider`: `Map<String, SkillRunState>` で chip 列の真実の源

ad-hoc セッションをどう乗せるかを設計する必要がある。

## Decision

ad-hoc セッションは **`launcherEntriesProvider` に混ぜず、別の family provider（`AdhocRunViewModel`）で扱う**。`ActiveSessions` には内部 `Map<String, String> _adhocLabels` を増やして表示名を保持し、`labelFor(entryId)` で chip 描画時の fallback を提供する。

具体的には:

- `AdhocRunArgs`（Freezed）に `adhocId / repositoryPath / displayName / skillName?` を持たせる
- `adhocRunViewModelProvider(AdhocRunArgs)` を `@Riverpod(keepAlive: true)` で family 定義
- 既存 `runViewModelProvider(entryId)` は変更せず、永続エントリ専用のまま
- ルートも `/run/:entryId`（既存）と `/run-adhoc/:adhocId`（新規）に分離
- 共通 `RunPage` は維持し、`ViewModel` の watch 対象だけを router レベルで分岐

## Why

### 代替案 1: `launcherEntriesProvider` に擬似 `LauncherEntry` を一時的に混ぜる

却下。

- `launcherEntriesProvider` は永続化を伴う `AsyncNotifier` で、`add` / `updateEntry` / `delete` の各操作が JSON ファイルに書き出される
- ad-hoc を混ぜるとファイル書き出しの分岐が必要になり、責務が肥大化する
- 「設定画面で操作する永続エントリ」と「一時的なセッション」が同じ Map に乗ると、誤削除や永続化漏れの温床になる
- entry 一覧 UI（設定画面・ホームグリッド）が ad-hoc を除外する分岐を持たないといけない

### 代替案 2: `runViewModelProvider` を共通化し、family 引数を `RunTarget`（Union: entryId / adhoc）に変える

却下。

- family 引数を Union にすると Riverpod の generator や ref.invalidate の引数比較が複雑化（Freezed 等価で比較されるが、運用上分かりにくい）
- `RunViewModel.build` 内で「entry なら launcherEntries から引く、adhoc ならコンストラクタ引数を直接使う」と if 分岐が増える
- 既存テストが entry 経路前提で書かれており、共通化に伴って大量のテスト書き換えが発生する

### 採用理由（別 provider）

- 永続エントリと ad-hoc の責務が provider レベルで分離されており、責務境界が明確
- 既存 `RunViewModel` を変更せず後方互換を保てる（既存テストへの影響なし）
- `RunPage` 描画は共通のまま、ViewModel だけ別を watch する形になり、router 側だけで分岐が完結する
- `ActiveSessions._adhocLabels` は「表示名 fallback」の単純な Map で、Notifier の責務に小さく収まる

## Trade-offs

### `RunViewModel` と `AdhocRunViewModel` の二重実装

両者でほぼ同等の `build` ロジック（PTY 起動・state listen・register・dispose）を持つことになる。差分は entry 取得経路と register 時のラベル引数のみ。

緩和:

- 共通ロジックを `_buildRunnerAndRegister(...)` のような private function に切り出して両方の build から呼ぶ
- もしくは abstract 基底クラスを設けて差分メソッドだけ override させる

本 change ではまず 2 ファイルに直書きして、第三のセッション種が必要になったタイミングで共通化を検討する（過度の早期抽象化を避ける）。

### `ActiveSessions._adhocLabels` の整合性

`unregister(entryId)` 時に `_adhocLabels[entryId]` も削除する責務を `ActiveSessions` 内に持たせる。register / unregister の対称性を崩さない実装にする。

### chip 列の挙動

ad-hoc chip も既存 chip と同じ見た目（状態アイコン + ラベル + ✕ ボタン）で描画する。タップで `/run-adhoc/:adhocId` に遷移、✕ で完全破棄。フラグやスタイルの差は設けない（混在しても識別不要、というプロダクト判断）。

## References

- `openspec/changes/repo-explorer/`（本 ADR の提案フェーズ）
- ADR-0008: スキル実行セッションを実行画面 widget から切り離して保持（`session-registry` の責務を確立した先行 ADR）
- ADR-0006: Flutter 公式 MVVM の採用（family provider と ViewModel 責務分離の根拠）
