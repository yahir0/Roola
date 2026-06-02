## Context

macOS の配布パイプラインは `flutter build macos → codesign → DMG → notarize → staple → GitHub Releases` の形で完成している。Windows は `build-windows.yml` でビルド検証のみ行っており、ユーザへの配布手段がない。Flutter Windows ビルドは `build/windows/x64/runner/Release/` に `roola.exe` と依存 DLL 群を展開するが、このディレクトリをそのまま配布するのはユーザフレンドリーでない。

## Goals / Non-Goals

**Goals:**
- Inno Setup でシングル `.exe` インストーラを生成し、ダブルクリックで `%LocalAppData%\Roola` に per-user インストールできるようにする
- `v*` タグ push で Windows インストーラを自動ビルドして GitHub Releases にアップロードする
- `make installer-windows` でローカルからインストーラを生成できるようにする
- バージョン番号を `pubspec.yaml` の `version:` から自動取得する

**Non-Goals:**
- コード署名証明書の取得・設定（SmartScreen 警告は許容。署名対応は別 change）
- Microsoft Store への公開
- 自動アップデート機能（macOS の Sparkle 相当、別 change）
- `x86` / `arm64` 以外のアーキテクチャ対応（`x64` のみ）

## Decisions

### インストーラツール: Inno Setup を採用

**代替候補:**
- NSIS: 機能豊富だが構文が複雑、コミュニティサポートが減少傾向
- WiX / MSI: エンタープライズ向け、過剰に複雑
- MSIX: Windows Store 対応に有利だが署名必須でローカルインストール時に Developer Mode が必要

**決定理由:** Inno Setup は Pascal 風スクリプト 1 ファイルで記述でき、`choco install innosetup` で CI 環境にも容易に導入できる。per-user インストール（管理者権限不要）のサポートも標準的。

### インストール先: `%LocalAppData%\Roola`（per-user）

管理者権限不要で一般ユーザが自己完結してインストール・アンインストールできる。`%ProgramFiles%` への system-wide インストールは権限昇格が必要で UX が悪い。

### バージョン取得: `pubspec.yaml` をパースして Inno Setup に渡す

既存 macOS パイプラインと同様、`pubspec.yaml` の `version: X.Y.Z+N` から semver 部分（`+N` は除外）を抽出。GitHub Actions では PowerShell または bash で `(Get-Content pubspec.yaml | Select-String 'version:').Line.Split(':')[1].Trim().Split('+')[0]` のように取り出して環境変数にセットし、Inno Setup スクリプトに `/DMyAppVersion=X.Y.Z` 形式で渡す。

### CI ワークフロー: 既存 `release.yml` とは別ファイル（`release-windows.yml`）

macOS ワークフローはランナー・認証情報・Secrets が異なり、分離する方が保守しやすい。`v*` タグ push で両ワークフローが並列起動する。

### GitHub Releases へのアップロード: `softprops/action-gh-release` を再利用

macOS と同じアクションで一貫性を保つ。同タグに macOS DMG と Windows インストーラが両方アップロードされる形になる。

## Risks / Trade-offs

- **SmartScreen 警告** → 未署名のため初回実行時に SmartScreen が「不明な発行元」警告を出す。ユーザは「詳細情報 → 実行」で回避可能。許容範囲として初期フェーズでは対処しない
- **Inno Setup バージョン固定なし** → `choco install innosetup` が常に最新版を引く。破壊的変更のリスクはあるが Inno Setup は後方互換性が高い。必要に応じてバージョンピンを追加
- **DLL 漏れ** → Inno Setup の `Source: "{app}\*"; DestDir: "{app}"; Flags: recursesubdirs` でビルド成果物ディレクトリを再帰コピーするため、Flutter が出力した DLL が自動的に含まれる
- **アンインストーラ** → Inno Setup は `unins000.exe` を自動生成し「アプリと機能」から削除可能になる。ユーザデータ（`%AppData%\tech.yahiro.Roola`）はアンインストール時に残す（削除しない）

## Migration Plan

1. `windows/installer/roola.iss` を追加（Inno Setup スクリプト）
2. `Makefile` に `installer-windows` ターゲット追加
3. `.github/workflows/release-windows.yml` を追加
4. `docs/release.md` に Windows リリース手順を追記

ロールバックが必要な場合は追加ファイルを削除するだけで macOS パイプラインへの影響はない。

## Open Questions

- コード署名証明書を将来取得する場合、`release-windows.yml` のどのステップで署名するか（`signtool.exe` を使う想定だが Secrets 設計は別 change で決定）
- Sparkle 相当の自動更新通知を Windows で出す場合のメカニズム（別 change スコープ外）
