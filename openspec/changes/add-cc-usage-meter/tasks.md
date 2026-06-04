## 1. ドキュメント / 設計判断

- [x] 1.1 ADR-0060「アクティビティモニタに Claude Code 使用量メーターを追加する（ローカル JSONL 集計・レートリミット％は非対象）」を `docs/adr/` に追加する
- [x] 1.2 `CLAUDE.md` の ADR 一覧に ADR-0060 を追記する

## 2. データ層: モデルと単価

- [x] 2.1 `lib/data/cc_usage/cc_usage.dart` に Freezed モデルを定義する（トークン種別別合計 input/output/cacheRead/cacheCreation、推定コスト USD、集計日付範囲）
- [x] 2.2 `lib/data/cc_usage/cc_usage_pricing.dart` にモデル別単価定数（input/output/cacheRead/cacheCreation）を定義し、未知モデルは単価 0 とするルックアップを実装する
- [x] 2.3 build_runner で Freezed 生成物を出力し、解析を通す

## 3. データ層: JSONL 集計リポジトリ

- [x] 3.1 `lib/data/cc_usage/cc_usage_repository.dart` を作成し、`~/.claude/projects` 配下の対象 JSONL を列挙する（当日 mtime 優先で走査）
- [x] 3.2 各行をパースし、`type == assistant` かつ `message.usage` を持つ行のみ抽出する（破損行・usage 無し行はスキップ）
- [x] 3.3 `message.id` + `requestId` をキーに重複行を排除する
- [x] 3.4 top-level `timestamp` をローカルタイム変換し、当日 0:00〜現在の行のみトークン種別ごとに合算する
- [x] 3.5 モデル別単価を適用して推定コストを算定し、`CcUsage` を返す（`~/.claude` 不在時はゼロ値を返す）

## 4. データ層: ファイル監視

- [x] 4.1 既存の監視方式（ADR-0041）を再利用し、対象ディレクトリの追記・新規ファイルを検知する監視を実装する
- [x] 4.2 変更通知をデバウンス（約 300〜500ms）で束ね、再集計を起動する

## 5. UI 層: ViewModel

- [x] 5.1 `lib/ui/activity_monitor/cc_usage_view_model.dart` に Riverpod `Notifier` を実装する（初回フル集計 + FSEvents 購読によるイベント駆動更新、dispose で監視停止）
- [x] 5.2 ローカルタイムの日付変更を検知し当日集計をリセットする（D6 / Risks）
- [x] 5.3 集計失敗・データ不在時にゼロ値プレースホルダへフォールバックする

## 6. UI 層: トップバー要約とポップオーバー

- [x] 6.1 `activity_monitor_bar.dart` に使用量要約セルを追加し、CPU/メモリと並べて配置する（PolarisTokens 経由・ハードコード禁止）
- [x] 6.2 `ActivityPopover` enum に `ccUsage` を追加し、既存の排他ポップオーバー機構に組み込む
- [x] 6.3 ポップオーバー内訳にトークン種別別合計と推定コストを表示し、値が「推定」である旨を明示する
- [x] 6.4 レートリミット％を一切表示しないことを目視確認する

## 7. テスト

- [x] 7.1 `cc_usage_repository` のユニットテスト（集計・重複排除・当日フィルタ・破損行スキップ・usage 無し行除外・未知モデルコスト0・`~/.claude` 不在）を Mocktail/フィクスチャで作成する
- [x] 7.2 単価適用と推定コスト算定のユニットテストを作成する
- [x] 7.3 `cc_usage_view_model` のテスト（初回集計・イベント駆動更新・日付変更リセット・フォールバック）を Provider override で作成する

## 8. 仕上げ

- [x] 8.1 `flutter analyze` と `flutter test` を通す
- [ ] 8.2 アプリ起動で実データに対し当日使用量がトップバーに表示され、JSONL 追記で更新されることを確認する
- [ ] 8.3 Conventional Commits（日本語可）でコミットする
