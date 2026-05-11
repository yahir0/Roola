# ADR-0007: `riverpod_lint` / `custom_lint` の採用を当面保留

- **Status**: Accepted
- **Date**: 2026-05-12

## Context

本プロジェクトは以下のスタックを採用している:

- `hooks_riverpod` ^3.3.1（実体: `riverpod` 3.2.1）
- `freezed_annotation` ^3.1.0（実体: `freezed` 3.2.5）
- `analyzer` 9.0.0（生成系の transitive）

これらは 2026 年前半に相次いでメジャーバージョンが上がった最新のスタック。Riverpod の使い方ミスを機械的に検出する `riverpod_lint` と、そのランナーである `custom_lint` を dev_dependencies に追加しようとしたところ、`flutter pub add --dev` で **version solving failure** が発生した。

エラーログの要約:

- `riverpod_lint` 安定版は `riverpod` を **3.1.0 まで** しかサポートしていない（本プロジェクトは 3.2.1）
- `riverpod_lint` dev 版は `analyzer ^12.x` を要求（まだリリースされていない先取り）
- `custom_lint` 安定版は `analyzer ^8.x` まで（本プロジェクトは 9.0.0）
- `custom_lint` 旧版は `freezed_annotation ^2.x` を要求（本プロジェクトは 3.1.0）

つまり、`riverpod 3.2.x` + `freezed_annotation 3.x` + `analyzer 9.x` の **3 つが同時に新しすぎる** 状態で、これらと協調する `riverpod_lint` + `custom_lint` の安定版がまだ存在しない。

## Decision

`riverpod_lint` と `custom_lint` を本プロジェクトの dev_dependencies に **当面追加しない**。本体スタック（`hooks_riverpod` 3.3.x / `freezed_annotation` 3.x / `analyzer` 9.x）は最新のまま維持する。

`pubspec.yaml` にはコメントとして lint 保留の状況を明記し、`tasks.md` の 1.4 にも記録する。

## Why

### 代替案 1: スタックをまるごとダウングレード

却下。`hooks_riverpod` を `^3.0.0` に下げ、`freezed_annotation` を `^2.x` に下げれば lint は入る。しかし:

- Freezed 2.x → 3.x、Riverpod 3.0 → 3.2 の双方で API・コード生成の差分があり、後でアップグレードする際に複数パッケージ連鎖のマイグレーションコストが発生する
- 過渡期のために古いバージョンに固定するのは技術的負債の先送り

### 代替案 2: lint だけ古い版にピン留め

却下。`riverpod_lint` のどの版を選んでも、本プロジェクトの組み合わせ（`riverpod 3.2.1` + `freezed_annotation 3.x` + `analyzer 9.x`）と整合する版が存在しないことが pub solver の出力で確認された。

### 採用理由（保留）

- `riverpod_lint` が検出するのは「`@riverpod` の使い方ミス」「`ref.watch` の妥当性」など、**型システムでは捕捉しにくいが、コードレビューと runtime テストで代替可能** な領域
- lint 無しでも `flutter analyze`（標準 analyzer + `flutter_lints` ベースのプロジェクト規約）は走る
- 過渡期は数ヶ月〜半年程度と見られ、エコシステム側（`riverpod_lint` メンテナ）の追従を待つほうが総コストが低い
- 「保留」が明示されており、定期的に再評価できる

## Trade-offs

- Riverpod 固有の使い方ミスが lint で機械的に弾けない。コードレビュー時の注意が必要
- 新規参画者は `@riverpod` 周辺で誤用する余地がある（`docs/architecture.md` の状態管理節で防御）
- `pubspec.yaml` の dev_dependencies に「将来入れる予定」のコメントが残る

## Re-evaluation Plan

以下のいずれかを契機に再評価する:

1. `riverpod_lint` が `riverpod 3.2.x` + `analyzer 9.x` 対応の安定版をリリースした時点
2. 本プロジェクトで Riverpod 関連の使い方ミスが複数回発生した場合（lint 不在のコストが顕在化した時）
3. 3 ヶ月ごとに `flutter pub add --dev --dry-run riverpod_lint custom_lint` を試し、解決可能になっていれば別 change を起こす

## Implementation Notes

`pubspec.yaml` dev_dependencies に以下の注記を残す:

```yaml
# NOTE: riverpod_lint / custom_lint は現時点で riverpod 3.x との依存解決ができない
# ためコメントアウト。エコシステム側が追従し次第追加する（ADR-0007 を参照）。
# custom_lint: ^0.x
# riverpod_lint: ^3.x
```

## References

- pub solver の version solving 失敗ログ（コミット履歴に保存）
- riverpod_lint: https://pub.dev/packages/riverpod_lint
- custom_lint: https://pub.dev/packages/custom_lint
- riverpod: https://pub.dev/packages/riverpod
- analyzer: https://pub.dev/packages/analyzer
