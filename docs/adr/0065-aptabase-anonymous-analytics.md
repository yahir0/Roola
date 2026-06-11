# ADR-0065: 匿名アナリティクスに Aptabase を採用する（REST 直叩き・規約同意フロー付き）

- **Status**: Accepted
- **Date**: 2026-06-11

## Context

Roola にはユーザー規模・利用状況を知る手段がなく、機能の優先順位付けや
macOS / Windows の利用比率の判断材料がなかった。要件は「いま何十人規模か」
が分かる程度のラフな把握であり、厳密なユニークユーザー数・リテンション
分析は不要。

利用規約（`docs/terms-of-use.md` 第10条）には「Firebase Analytics 等を将来
導入する場合がある」という予告が以前から存在したが、実際にデータ送信を
始めるには (1) 規約の具体化と (2) ユーザーの同意取得が必要になる。同意
シーンは Windows ではインストーラ（Inno Setup の license 画面）にあるが、
**macOS には存在しなかった**。

## Decision

1. **アナリティクスは Aptabase（ホステッド・US リージョン）を採用する**。
   送信イベントは `app_launched`（起動時 1 回）と `launcher_executed`
   { kind } の最小セットから始める。パス・コマンド・エントリ名等の自由
   文字列は props に入れない。
2. **SDK（`aptabase_flutter`）は使わず、インジェスト API
   （`POST {host}/api/v0/events`）を dio で直接叩く**。プロトコルは SDK
   ソースから確認した（セッション ID = epoch 秒 + 乱数 8 桁・1 時間で
   ローテーション・`App-Key` ヘッダ・systemProps）。
3. **利用規約を第 2 版に改定**し、適用対象に macOS を追加、第10条を
   Aptabase の収集実態（収集項目・送信先・オプトアウト手段）に改稿する。
4. **アプリ内同意フロー**を設ける。同意済み規約バージョンを
   `privacy_settings.json` に永続化し、未同意または規約改定時は起動時に
   閉じられない同意モーダルを表示する。モーダルには「使用状況の統計を
   送信する」トグル（既定 ON）を明示し、設定画面からもいつでも変更できる。
   同意するまでアナリティクスは初期化・送信しない。

## Why

### Aptabase の選定（Firebase / TelemetryDeck / PostHog との比較）

- **Windows 対応が決定打**。Firebase Analytics の Flutter プラグインは
  Windows 未対応（flutterfire#12847）。PostHog / TelemetryDeck の Flutter
  SDK も Android / iOS / macOS / Web のみ。Aptabase はデスクトップアプリを
  主眼に設計されており、プロトコルも全プラットフォームで同一。
- **プライバシーファーストで規約負担が最小**。ユニーク ID・デバイス指紋を
  収集せず匿名セッション集計のみのため、規約に収集項目を列挙でき、
  開発者向けアプリのユーザー層にも受け入れられやすい。
- **要件に対して過不足がない**。Aptabase はユーザー単位の分析（MAU /
  リテンション）が設計上できないが、要件は「日次セッション数で規模感を
  見る」ことなので問題にならない。DAU/MAU が必要になったら TelemetryDeck
  REST 等への乗り換えを再検討する（送信は AnalyticsService 1 枚に集約済み）。
- **コスト**: 無料枠（月 20k イベント想定・要確認）内に収まる規模。超過時は
  課金でなく収集停止のため、請求事故が構造的に起きない。

### SDK を使わず REST 直叩きにした理由

- `aptabase_flutter` 0.4.1 は `package_info_plus ^8.0.0` 固定で、Roola の
  `^9.0.0` と**依存解決が失敗する**。
- SDK はオフラインバッファリングのため hive / device_info_plus /
  universal_io を持ち込むが、要件（規模感の把握）にはベストエフォート
  送信で十分で、見合わない。
- API は単純な JSON POST 1 本で、導入済みの dio で実装できる。外部依存を
  増やさないことは自己完結方針（ADR-0005）にも合う。

### 同意フローの設計

- 既定 ON のオプトアウト方式だが、**同意モーダルにトグルを明示して初回に
  必ず選択機会を保証する**（設定の奥に隠さない）。
- App Key は `dart_defines/prod.json`（ADR-0004）経由で注入し、未設定
  ビルド（開発・fork）ではアナリティクス全体が no-op になる。
- 規約本文はアセット同梱（`assets/terms/`）し、オフラインでも同意フローが
  完結する。

## Trade-offs

- **オフライン時のイベントは欠落する**（バッファリングなし）。規模感の
  把握という目的には許容。
- **既定 ON への心理的反発の可能性**。同意画面での明示と規約への列挙で
  透明性を担保する。
- **Aptabase のサービス終了 / 料金変更リスク**。送信は
  `lib/data/analytics/analytics_service.dart` 1 枚に集約してあり差し替えが
  容易。OSS なのでセルフホストへの退路もある。
- **規約の正本（docs）とアセット同梱版の乖離リスク**。リリースガイドに
  「規約改定時は 4 点更新（docs / assets / license.rtf / バージョン定数）」
  のチェック項目を設けて運用で防ぐ。

## References

- ADR-0004: dart-define は単一環境（prod）のみ
- ADR-0005: 外部 Skill / プラグインに依存しない自己完結方針
- OpenSpec change: `openspec/changes/add-aptabase-analytics/`
- Aptabase インジェスト API（SDK ソースから確認）:
  `https://github.com/aptabase/aptabase_flutter`
- `docs/terms-of-use.md`（第 2 版）/ `lib/core/constants/terms.dart`
