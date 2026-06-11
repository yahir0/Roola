# Proposal: add-aptabase-analytics

## Why

Roola は現在ユーザー規模・利用状況を把握する手段を持たず、機能の優先順位付けやプラットフォーム別（macOS / Windows）の利用比率の判断材料がない。匿名アナリティクス（Aptabase）を導入して「どれくらいのユーザーが・どのバージョンで・どの機能を使っているか」を把握できるようにする。

あわせて、データ送信を始める以上、利用規約への明記とユーザーの同意取得が必要になる。現状の利用規約（`docs/terms-of-use.md`）は Windows インストーラ（Inno Setup の同意画面）でのみ提示され、macOS には同意シーンが存在しない。アプリ内の同意フローを設け、macOS の既存ユーザーもアップデート後の初回起動で規約に同意できるようにする。

## What Changes

- **Aptabase 導入**: `aptabase_flutter` を追加し、匿名利用統計を Aptabase ホステッド（クラウド）へ送信する。
  - 送信イベントは最小限から始める: `app_launched`（起動時 1 回）+ 主要操作数種。ユニーク ID・デバイス指紋・個人情報は収集しない（Aptabase の設計上送信されない）。
  - 設定画面に「使用状況の統計を送信する」オプトアウトトグルを追加（既定 ON）。OFF の間は一切送信しない。
- **利用規約の更新**（`docs/terms-of-use.md`）:
  - 第10条を「将来的に Firebase Analytics 等を導入する場合がある」から「Aptabase による匿名利用統計を収集する」へ具体化（収集項目・送信先・オプトアウト手段を明記）。
  - 対象プラットフォームに macOS を追加（第3条・第7条が Windows 専用の記述になっているため）。
  - 規約に **バージョン番号**（または改定日）を導入し、アプリ内同意フローの照合キーにする。
  - Windows インストーラ同梱の `windows/installer/license.rtf` を更新後の規約から再生成する。
- **アプリ内同意フロー**:
  - 同意済み規約バージョンをローカルに永続化する。
  - 起動時に「未同意 or 同意済みバージョン < 現行規約バージョン」なら、メイン UI 操作前に同意モーダルを表示する（規約全文の閲覧導線 + 同意ボタン + アナリティクス送信のトグル）。
  - 同意するまでアナリティクスは初期化・送信しない。

## Capabilities

### New Capabilities

- `usage-analytics`: Aptabase への匿名利用統計の送信。送信イベントの定義、オプトアウト設定の永続化と設定 UI、同意前・オプトアウト中の送信抑止。
- `terms-consent`: 利用規約バージョンの管理と起動時同意フロー。同意状態の永続化、未同意・規約改定時の同意モーダル表示、規約本文（macOS 対応 + アナリティクス条項）の更新。

### Modified Capabilities

（なし — 既存 spec への要求変更はない。`openspec/specs/` は運用上空である）

## Impact

- **依存追加**: `aptabase_flutter`（macOS / Windows 対応）。App Key は Aptabase ダッシュボードで発行し、`dart_defines/prod.json` 経由で注入する想定（単一環境 / ADR-0004 と整合）。
- **コード**:
  - `lib/data/` に同意状態 + アナリティクス設定の Repository（既存の `appearance_settings_repository_impl.dart` パターンに倣う）
  - `lib/app/`（main.dart の bootstrap・起動時モーダル差し込み）
  - `lib/ui/settings/`（オプトアウトトグルのセクション追加）
  - `lib/l10n/` ARB（ja / en）に同意モーダル・設定項目の文言追加
- **ドキュメント**: `docs/terms-of-use.md` 改定、`windows/installer/license.rtf` 再生成、ADR 1 件追加（アナリティクス選定の判断記録）
- **外部サービス**: Aptabase ホステッドのアカウント作成が必要（無料枠想定。料金はサインアップ時に要確認）
- **プライバシー**: 収集は匿名・非個人データのみだが、送信先（Aptabase）の開示と同意取得を本 change 内で完結させる
