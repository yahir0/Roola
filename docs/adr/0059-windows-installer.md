# ADR-0059: Windows インストーラに Inno Setup を採用し per-user インストールとユーザーデータ選択削除を実装する

## Status

Accepted

## Context

ADR-0058 で Windows を対応プラットフォームに追加したが、配布手段が存在しなかった。
macOS は DMG + 公証による完全な配布パイプラインを持つ。Windows でも同等の
「インストーラをダウンロードしてダブルクリックでセットアップ完了」という
体験を提供する必要がある。

## Decision

### インストーラツール: Inno Setup

**採用理由:**
- Pascal スクリプト 1 ファイルで記述でき、学習コストが低い
- `choco install innosetup` で CI 環境に容易に導入できる
- per-user インストール（管理者権限不要）を標準でサポート
- 日本語ウィザード UI（`Japanese.isl`）が同梱されている
- 長期的に安定した後方互換性を持つ

**不採用の代替案:**
- NSIS: 構文が複雑でコミュニティサポートが減少傾向
- WiX / MSI: エンタープライズ向けで過剰に複雑
- MSIX: 署名必須でローカルインストール時に Developer Mode が必要

### インストール先: per-user（`%LocalAppData%\Roola`）

`PrivilegesRequired=lowest` により UAC プロンプトなしでインストール可能。
一般ユーザーが自己完結してセットアップ・アンインストールできる体験を優先した。
`%ProgramFiles%` への system-wide インストールは権限昇格が必要で UX が劣る。

### アンインストール時のユーザーデータ選択削除

アンインストール完了後に確認ダイアログを表示し、ユーザーが
`%AppData%\tech.yahiro.Roola` を削除するか保持するかを選択できるようにした。

**理由:**
- データを問答無用で削除するのはユーザーの意図に反するリスクがある
- 一方で「アンインストールしたのにデータが残った」という混乱も避けたい
- 選択肢を提示することで両方のニーズに対応する

実装は Inno Setup `[Code]` セクションの `CurUninstallStepChanged(usUninstallFinished)` イベントで `MsgBox` を呼ぶ。デフォルトボタンを「いいえ」（保持）にしてデータの誤削除を防ぐ。

### 利用規約の組み込み

インストーラに `LicenseFile=license.rtf` を設定し、ウィザードの同意画面に
利用規約を表示する。`docs/terms-of-use.md` が正本で、`windows/installer/license.rtf`
はインストーラ用の RTF 変換版。

### CI: macOS と別ファイル（`release-windows.yml`）

ランナー・認証情報・Secrets が macOS と異なるため分離する。
`v*` タグ push で両ワークフローが並列起動し、GitHub Releases に
macOS DMG と Windows インストーラの両方がアップロードされる。

## Consequences

- Windows ユーザーは `RoolaSetup-<version>.exe` をダウンロードしてインストールできる
- 管理者権限不要のため、社内 PC 等の制限環境でも利用しやすい
- コード署名なしのため SmartScreen 警告が出る（将来フェーズで対応）
- 自動更新機能は本 ADR の対象外（別 change で検討）
