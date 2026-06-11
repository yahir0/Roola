# Design: add-aptabase-analytics

## Context

Roola にはユーザー規模・利用状況を知る手段がない。要件は「いま何十人規模か」が分かる程度のラフな把握であり、厳密なユニークユーザー数・リテンション分析は不要（選定時に確認済み）。

利用規約は `docs/terms-of-use.md` が正本で、Windows では Inno Setup の同意画面（`windows/installer/license.rtf`）で提示されるが、macOS には同意シーンが存在しない。また現行規約は第3条・第7条が Windows 専用の記述で、第10条は「Firebase Analytics 等を将来導入する場合がある」という予告に留まっている。

既存の永続化は「Application Support 配下の JSON + Repository + DTO(json_serializable) + Freezed Entity + Riverpod AsyncNotifier」パターン（例: `lib/data/appearance/`）。モーダル UI は `PolarisModalShell`（ADR-0054 / 0056）が確立している。

## Goals / Non-Goals

**Goals:**

- 匿名利用統計（起動数・主要操作・OS / バージョン内訳）を Aptabase ホステッドで収集する
- 利用規約をアナリティクス収集の実態に合わせて改定し、macOS を適用対象に含める
- macOS / Windows ともにアプリ内で規約同意を取得する（規約改定時は再同意）
- アナリティクスのオプトアウト手段を提供する

**Non-Goals:**

- ユニークユーザー数・リテンション・ファネル分析（Aptabase の設計上不可。要件外と確認済み）
- クラッシュレポート収集（Sentry 等は本 change のスコープ外。必要になったら別 change）
- Aptabase のセルフホスト（ホステッドで開始。移行は将来の選択肢として温存）
- プライバシーポリシーの独立文書化（現状どおり規約第10条内で完結させる。個人情報を収集しないため）

## Decisions

### D1: アナリティクスは Aptabase ホステッドを採用する

- **理由**: Flutter SDK（`aptabase_flutter`）が macOS / Windows / Linux を公式サポートする数少ない選択肢。Firebase Analytics は Windows 未対応（flutterfire#12847）、PostHog / TelemetryDeck の Flutter SDK も Windows 非対応。
- ユニーク ID・デバイス指紋を収集しない設計のため、規約・同意の負担が最小（収集項目を列挙でき、GDPR/CCPA 配慮も Aptabase 側が担保）。
- **代替案**: TelemetryDeck REST 直叩き（DAU/MAU が取れるが自前実装が必要。要件外なので過剰）/ GA4 Measurement Protocol（経路がプラットフォームで割れ保守増）→ 不採用。
- 判断の記録として ADR-0065 を追加する。

### D2: App Key は `dart_defines/prod.json` で注入する

- ADR-0004（単一環境 dart-define）に整合。`String.fromEnvironment('APTABASE_APP_KEY')` で参照する。
- Aptabase の App Key はクライアント配布物に埋め込む前提の識別子であり秘匿情報ではないが、リポジトリ直書きよりも既存の dart_defines 経路に乗せる方が一貫する。
- キー未設定（空文字）のときはアナリティクスを no-op にする。開発ビルドや fork ビルドで勝手に送信されない。

### D3: `aptabase_flutter` SDK は使わず、dio で Aptabase REST API を直接叩く（実装時に変更）

- 当初は `aptabase_flutter` の採用を想定していたが、実装時に依存解決が失敗することが判明した（SDK は `package_info_plus ^8.0.0` 固定・Roola は `^9.0.0`）。さらに SDK はオフラインバッファリングのために hive / device_info_plus / universal_io を推移依存として持ち込む。
- Aptabase のインジェスト API は単純（`POST {host}/api/v0/events` にイベント JSON 配列・`App-Key` ヘッダ）で、SDK ソースからプロトコルを確認済み。導入済みの dio で直接実装する方が依存ゼロで済み、自己完結方針（ADR-0005）にも合う。
  - セッション ID: `epoch秒 + 乱数8桁` の文字列。最終送信から 1 時間経過で再生成（SDK と同じ仕様）
  - `systemProps`: isDebug / osName / osVersion / locale / appVersion / appBuildNumber / sdkVersion。OS バージョンは `Platform.operatingSystemVersion` から取得し、device_info_plus は追加しない
  - オフラインバッファリングは持たない。送信はベストエフォート（失敗は握り潰す）。要件は規模感の把握なので欠落は許容（Risks 参照）
- `lib/data/analytics/analytics_service.dart` に `trackEvent(name, {props})` を持つクラスを 1 枚置き、UI / ViewModel からは送信プロトコルを直接触らない。
- interface は作らない（差し替え可能性が必要なのは PTY と永続化のみ、という CLAUDE.md の規約に従う）。Aptabase 廃止時はこのクラスの中身だけ差し替える。
- 送信条件（同意済み && オプトイン）の判定をこのクラスに集約し、呼び出し側は無条件に呼べるようにする。

### D4: 初期イベントは最小セットに固定する

- `app_launched`: 起動時 1 回（OS・アプリバージョン・ロケールは SDK が自動付与）
- `launcher_executed` { kind: shell / command / claudeSkill }: ランチャー実行（コア機能の利用量）
- パス・コマンド文字列・ファイル名などの **自由文字列は props に入れない**（匿名性の担保と規約の「収集項目の列挙」を守るため）。イベント追加時もこの原則に従う。

### D5: 同意状態は新規 `privacy_settings.json` に永続化する

- `lib/data/privacy/` に既存パターン（Entity: Freezed / DTO: json_serializable / Repository: AsyncNotifier）で実装。
- フィールド: `acceptedTermsVersion: int?`（未同意は null）、`analyticsEnabled: bool`（既定 true）。
- 同意（規約バージョン）と送信可否（トグル）は別概念だが、ライフサイクルが同じ（同意モーダルで両方確定し、設定画面でトグルだけ変更）ため 1 ファイルにまとめる。

### D6: 規約バージョンは整数で管理し、アプリ内に定数を持つ

- `docs/terms-of-use.md` の末尾に「第 N 版（発行日）」を明記し、アプリ側は `lib/core/constants/terms.dart` 等に `currentTermsVersion = N` を定数で持つ。
- 今回の改定を **第 2 版** とする（現行 2026-06-02 発行分を第 1 版とみなす）。
- 照合は単純な大小比較: `acceptedTermsVersion == null || acceptedTermsVersion < currentTermsVersion` → 同意モーダル表示。

### D7: 規約本文はアセット同梱し、同意モーダル内で表示する

- `assets/terms/terms-of-use.md` として同梱（正本 `docs/terms-of-use.md` からコピー。リリース手順に「規約改定時は両方更新」を含める）。
- 自己完結方針（ADR-0005）に整合し、オフラインでも同意フローが完結する。Web 配信に依存しない。
- 表示はプレーンテキスト相当のスクロール表示で十分（ライセンス画面 ADR-0056 と同等の見せ方）。規約の正文は日本語（第14条）なので、UI ロケールが英語でも本文は日本語のまま表示し、モーダルの操作 UI（ボタン等）のみ l10n する。

### D8: 同意モーダルは app builder チェーンの Gate として実装する

- `lib/app/app.dart` の builder チェーン（`WindowCloseGuard` 等と同列）に `TermsConsentGate` を追加。`privacy_settings` を watch し、未同意なら全画面モーダル（`PolarisModalShell` ベース、ただし Esc / スクリムで閉じられない）をメイン UI に被せる。
- モーダル構成: 規約全文（スクロール）+ アナリティクス説明 + 「使用状況の統計を送信する」トグル（既定 ON）+ 「同意して開始」ボタン + 「終了」ボタン（同意しない場合はアプリを終了する。規約第1条と整合）。
- 既定 ON のトグルを同意画面に**明示的に見せる**ことで、オプトアウト機会を初回に保証する（黙ってオプトアウト設定の奥に置かない）。
- 同意前は Aptabase を初期化しない。「同意して開始」確定後に `AnalyticsService` を初期化し、その起動の `app_launched` を送信する。

### D9: 設定画面にプライバシーセクションを追加する

- `lib/ui/settings/privacy_section.dart` を新設し、「使用状況の統計を送信する」トグル（ON/OFF 即時反映・永続化）と規約全文表示への導線を置く。
- OFF にした時点で以後の送信を停止する（`AnalyticsService` が `analyticsEnabled` を毎回参照）。

### D10: 規約改定の内容

1. 適用対象に macOS を追加（第3条の動作環境、第7条の OS 免責に macOS / Apple を併記）
2. 第10条を実態に合わせて全面改稿: Aptabase ホステッドへ匿名利用統計（イベント名・OS・アプリバージョン・ロケール等）を送信すること、個人情報・ユニーク識別子・ファイルパス等は送信しないこと、設定からいつでもオプトアウトできることを明記
3. 「第 2 版」と改定日を明記
4. `windows/installer/license.rtf` を改定後の規約から再生成

## Risks / Trade-offs

- [Aptabase の無料枠・料金体系が変わる / サービス終了] → 送信は `AnalyticsService` 1 枚に集約してあり差し替えコストが小さい。OSS なのでセルフホスト移行の退路もある。超過時は課金されず収集停止のみ（設計上、請求事故は起きない）。
- [既定 ON のオプトアウト方式への反発] → 同意モーダルでトグルを明示提示し、初回に必ず選択機会がある。収集内容が匿名・列挙可能であることを規約に明記して透明性で担保。
- [起動時モーダルの体験悪化（毎回出る・他ダイアログと競合）] → 表示条件はバージョン照合のみで、同意済みなら一切出ない。Sparkle の更新ダイアログとは独立だが、同意モーダル表示中もメイン UI はビルド済みのため起動シーケンスへの影響は最小。
- [規約のアセット版と docs 正本の乖離] → リリースチェックリスト（docs/release.md）に「規約改定時: docs / assets / license.rtf / バージョン定数の 4 点更新」を追記して運用で防ぐ。
- [オフライン時のイベント欠落] → 許容する。要件は規模感の把握であり、ベストエフォート送信で十分。

## Open Questions

- Aptabase アカウント作成と App Key 発行（実装着手前にユーザー側で実施が必要。リージョンは EU / US どちらでも可だが、規約に記載する送信先と一致させる）
- 無料枠の正確な条件（サインアップ時に料金ページで確認し、規約・ADR の記述を確定する）
