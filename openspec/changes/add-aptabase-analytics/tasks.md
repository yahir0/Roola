# Tasks: add-aptabase-analytics

## 1. 準備（ユーザー作業を含む）

- [x] 1.1 Aptabase アカウント作成と App Key 発行（ユーザー作業。リージョンを決め、無料枠の条件を料金ページで確認する）
- [x] 1.2 ADR-0065「匿名アナリティクスに Aptabase を採用する」を docs/adr/ に追加（Firebase / TelemetryDeck / PostHog 不採用理由・既定 ON オプトアウト方式の判断を記録）
- [x] 1.3 `dart_defines/prod.json` に `APTABASE_APP_KEY` を追加し、docs/release.md のビルド手順に反映

## 2. 利用規約の改定

- [x] 2.1 `docs/terms-of-use.md` を第 2 版へ改定（macOS を適用対象に追加 / 第10条を Aptabase の収集実態に改稿 / 版数・改定日を明記）
- [x] 2.2 `assets/terms/terms-of-use.md` としてアセット同梱し、pubspec.yaml に assets 登録
- [x] 2.3 `windows/installer/license.rtf` を第 2 版から再生成
- [x] 2.4 docs/release.md に「規約改定時は docs / assets / license.rtf / バージョン定数の 4 点更新」のチェック項目を追記

## 3. 同意状態の永続化（data 層）

- [x] 3.1 `lib/core/constants/terms.dart` に `currentTermsVersion = 2` を定義
- [x] 3.2 `lib/data/privacy/privacy_settings.dart`（Freezed Entity: `acceptedTermsVersion: int?` / `analyticsEnabled: bool` 既定 true）を作成
- [x] 3.3 `lib/data/privacy/privacy_settings_dto.dart`（json_serializable・nullable 後方互換）を作成
- [x] 3.4 `lib/data/privacy/privacy_settings_repository_impl.dart`（AsyncNotifier・`privacy_settings.json` への load/save・`acceptTerms()` / `setAnalyticsEnabled()`）を appearance パターンに倣って作成し、`AppPaths` にパスを追加
- [x] 3.5 build_runner でコード生成し、Repository のユニットテスト（load 失敗時の defaults / 同意の保存 / トグルの保存）を Mocktail で作成

## 4. アナリティクス送信（AnalyticsService）

- [x] 4.1 ~~pubspec.yaml に `aptabase_flutter` を追加~~ → SDK は依存競合（package_info_plus ^8 固定）のため不採用。dio で REST API を直接実装する（design D3 改訂）
- [x] 4.2 `lib/data/analytics/analytics_service.dart` を作成（dio で `POST /api/v0/events` / App Key 空なら no-op / 未同意・オプトアウト中は送信しない / `trackEvent(name, {props})` を提供）し、Riverpod provider を配線
- [x] 4.3 同意確定後の初期化フローを実装（「同意して開始」→ Aptabase 初期化 → `app_launched` 送信。以後の起動は bootstrap 時に同意済みなら初期化・送信）
- [x] 4.4 ランチャー実行箇所に `launcher_executed` { kind } 送信を追加（パス・コマンド・エントリ名を含めないこと）
- [x] 4.5 AnalyticsService のユニットテスト（同意前 no-op / オプトアウト中 no-op / App Key 空で no-op）を作成

## 5. 同意モーダル（UI）

- [x] 5.1 `lib/ui/consent/terms_consent_modal.dart` を作成（PolarisModalShell ベース・Esc / スクリムで閉じない・規約全文スクロール表示・アナリティクス説明 + トグル既定 ON・「同意して開始」「終了」ボタン）
- [x] 5.2 `lib/app/` に `TermsConsentGate` を作成し、app.dart の builder チェーンへ組み込み（`privacy_settings` を watch、未同意 or 旧バージョン同意ならモーダルを被せる。「終了」でアプリ終了）
- [x] 5.3 ARB（ja / en）に同意モーダルの文言を追加し gen-l10n（規約本文は日本語正文のまま・操作 UI のみ l10n）
- [x] 5.4 同意フローのウィジェットテスト（未同意で表示 / 同意で消える / 旧バージョン同意で再表示 / トグル OFF 同意でアナリティクス無効）を作成

## 6. 設定画面（オプトアウト）

- [x] 6.1 `lib/ui/settings/privacy_section.dart` を作成（「使用状況の統計を送信する」トグル + 規約全文表示への導線）し、settings_page.dart に組み込み
- [x] 6.2 ARB（ja / en）に設定セクションの文言を追加
- [x] 6.3 トグル操作のウィジェットテスト（OFF で永続化・AnalyticsService が送信停止）を作成

## 7. 検証・仕上げ

- [ ] 7.1 macOS で手動検証（新規状態で同意モーダル表示 → 同意 → Aptabase ダッシュボードに app_launched が届く / 再起動でモーダル非表示 / オプトアウトで送信停止）
- [ ] 7.2 Windows で手動検証（同上 + インストーラの license.rtf が第 2 版であること）
- [x] 7.3 `flutter analyze` / 全テストのパスを確認
- [x] 7.4 CLAUDE.md の ADR 一覧に ADR-0065 を追記
