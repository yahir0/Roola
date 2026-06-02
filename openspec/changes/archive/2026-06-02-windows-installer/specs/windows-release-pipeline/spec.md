## ADDED Requirements

### Requirement: `v*` タグ push で Windows リリースワークフローが起動する
`.github/workflows/release-windows.yml` は `on.push.tags: ['v*']` をトリガーとし、`windows-latest` ランナー上でビルド → インストーラ生成 → GitHub Releases アップロードを行う。

#### Scenario: `v*` タグ push でワークフロー起動
- **WHEN** `git push origin v1.0.0` のように `v` プレフィックスのタグを push する
- **THEN** `release-windows.yml` ワークフローが自動的に開始される

#### Scenario: `v*` 以外のタグ push ではワークフローが起動しない
- **WHEN** `v` プレフィックスなしのタグ（例: `beta-1`）を push する
- **THEN** `release-windows.yml` ワークフローは起動しない

### Requirement: Developer Mode を有効化してビルドが成功する
CI ランナー上でシンボリックリンク作成に必要な Developer Mode を有効化したうえで `flutter build windows --release` を実行し、成功する。

#### Scenario: Release ビルド成功
- **WHEN** ワークフローが `flutter build windows --release` ステップを実行する
- **THEN** `build/windows/x64/runner/Release/roola.exe` が生成される

### Requirement: Inno Setup をインストールしてインストーラを生成する
CI ランナー上で `choco install innosetup -y` により Inno Setup を導入し、`iscc` コマンドで `.exe` インストーラを生成する。

#### Scenario: インストーラ生成成功
- **WHEN** CI がインストーラ生成ステップを実行する
- **THEN** `build/RoolaSetup-<version>.exe` が存在する

### Requirement: GitHub Releases にインストーラをアップロードする
タグ push をトリガーとした実行時、生成した `RoolaSetup-<version>.exe` を `softprops/action-gh-release` で当該リリースにアップロードする。

#### Scenario: GitHub Releases にアセットが追加される
- **WHEN** `v*` タグ push でワークフローが完了する
- **THEN** 対応する GitHub Release に `RoolaSetup-<version>.exe` がアセットとして存在する

### Requirement: `workflow_dispatch` による手動実行
`workflow_dispatch` トリガーで手動起動できる。手動起動の場合はインストーラを GitHub Releases にアップロードせず、Actions Artifacts としてダウンロード可能にする。

#### Scenario: 手動実行でアーティファクトが生成される
- **WHEN** GitHub Actions UI から `release-windows.yml` を手動実行する
- **THEN** Actions の実行詳細から `RoolaSetup-<version>.exe` をダウンロードできる
- **THEN** GitHub Releases への新規リリース作成は行われない
