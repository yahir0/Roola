## Why

macOS は DMG + 公証 + Sparkle による完全な配布パイプラインが整っているが、Windows はビルド確認 CI のみで配布手段が存在しない。Windows ユーザが Roola をインストールできるよう、インストーラ（.exe）の生成と GitHub Releases への配布パイプラインを構築する。

## What Changes

- **新規**: Inno Setup スクリプト（`windows/installer/roola.iss`）を追加し、`flutter build windows` の成果物から `.exe` インストーラを生成できるようにする
- **新規**: `make installer-windows` ターゲット（開発者がローカルでインストーラを生成する）
- **新規**: GitHub Actions ワークフロー `release-windows.yml` — `v*` タグ push をトリガーに Windows リリースビルド → インストーラ生成 → GitHub Releases アップロードを行う
- **変更**: 既存 `release.yml`（macOS）との並列実行、または同一 `release.yml` にジョブ追加

## Capabilities

### New Capabilities

- `windows-installer-build`: Inno Setup を使って Flutter Windows ビルド成果物から `RoolaSetup-<version>.exe` を生成する能力。バージョン番号は `pubspec.yaml` から自動取得。インストール先は `%LocalAppData%\Roola`（per-user インストール、管理者権限不要）
- `windows-release-pipeline`: `v*` タグ push をトリガーに Windows インストーラをビルドして GitHub Releases にアップロードする CI ワークフロー

### Modified Capabilities

（なし）

## Impact

- **追加ファイル**: `windows/installer/roola.iss`、`.github/workflows/release-windows.yml`
- **変更ファイル**: `Makefile`（`installer-windows` ターゲット追加）、`docs/release.md`（Windows リリース手順を追記）
- **依存追加**: CI ランナー（`windows-latest`）に Inno Setup をインストール（`choco install innosetup`）
- **コード署名**: 初期フェーズでは署名なし（SmartScreen 警告は出るが起動可能）。将来フェーズでコード署名証明書対応を検討
- **自動更新**: 初期フェーズでは対象外。macOS の Sparkle に相当する仕組みは別 change で扱う
