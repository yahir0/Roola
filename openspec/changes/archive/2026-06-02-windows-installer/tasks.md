## 1. 利用規約の作成

- [x] 1.1 利用規約の内容を決める（使用許諾範囲・免責事項・禁止事項・再配布の可否・準拠法など、MIT ライセンスとの関係も整理する）
- [x] 1.2 `windows/installer/license.rtf` を作成する（Inno Setup は RTF 形式を推奨。内容は 1.1 で決めたもの）

## 2. Inno Setup スクリプト作成

- [x] 2.1 `windows/installer/` ディレクトリを作成する
- [x] 2.2 `windows/installer/roola.iss` を作成する（AppName / AppVersion（`/DMyAppVersion` で外部注入）/ DefaultDirName=`{localappdata}\Roola` / PrivilegesRequired=lowest / LicenseFile=`license.rtf` / Source: ビルド成果物の再帰コピー / スタートメニューショートカット / デスクトップショートカット（オプション）/ アンインストーラ設定を含む）
- [x] 2.3 `roola.iss` の `[Code]` セクションに Pascal スクリプトを追加し、アンインストール完了時（`CurUninstallStepChanged(usUninstallFinished)`）にメッセージボックス「設定・履歴などのユーザーデータを削除しますか？」を表示する。「はい」選択時は `%AppData%\tech.yahiro.Roola` を再帰削除する
- [x] 2.4 ローカルで `flutter build windows --release` → `iscc windows/installer/roola.iss /DMyAppVersion=0.0.1` を手動実行して `RoolaSetup-0.0.1.exe` が生成されることを確認する
- [x] 2.5 生成したインストーラを Windows 環境でダブルクリックし、利用規約同意画面が表示されること・管理者権限なしでインストール・起動できることを確認する
- [x] 2.6 アンインストールを実行し、「データを削除しますか？」ダイアログが表示されること・「はい」でデータが完全削除されること・「いいえ」でデータが残ることを確認する

## 3. Makefile への `installer-windows` ターゲット追加

- [x] 3.1 `Makefile` に `WIN_INSTALLER_PATH` 変数（`build/RoolaSetup-$(VERSION).exe`）を追加する
- [x] 3.2 `installer-windows` ターゲットを追加する（`pubspec.yaml` からバージョン取得 → `build-windows` → `iscc` 実行 → 出力パスを表示）
- [x] 3.3 `help` ターゲットのコメントに `installer-windows` の説明を追加する
- [x] 3.4 ローカルで `make installer-windows` が成功することを確認する

## 4. GitHub Actions リリースワークフロー作成

- [x] 4.1 `.github/workflows/release-windows.yml` を作成する（トリガー: `v*` タグ push + `workflow_dispatch`、ランナー: `windows-latest`）
- [x] 4.2 Developer Mode 有効化ステップを追加する（既存 `build-windows.yml` の `Enable Developer Mode` ステップを流用）
- [x] 4.3 Flutter セットアップ・依存取得・コード生成ステップを追加する（`.fvmrc` からバージョン取得）
- [x] 4.4 `flutter build windows --release` ステップを追加する
- [x] 4.5 `choco install innosetup -y` ステップを追加する
- [x] 4.6 `pubspec.yaml` からバージョン取得し環境変数にセットするステップを追加する
- [x] 4.7 `iscc` でインストーラを生成するステップを追加する
- [x] 4.8 Actions Artifact としてインストーラをアップロードするステップを追加する（`upload-artifact@v4`、常に実行）
- [x] 4.9 `softprops/action-gh-release` でタグ push 時のみ GitHub Releases にアップロードするステップを追加する（`if: startsWith(github.ref, 'refs/tags/')`）

## 5. ドキュメント更新

- [x] 5.1 `docs/release.md` に Windows リリース手順セクションを追加する（`make installer-windows` での手動ビルド手順、GitHub Actions による自動リリース手順、SmartScreen 警告への対処方法）
- [x] 5.2 `docs/adr/0059-windows-installer.md` を追加する（Inno Setup 採用理由・per-user インストール選択理由・利用規約設置の判断を記録）

## 6. 動作確認（CI）

- [x] 6.1 `release-windows.yml` を `workflow_dispatch` で手動実行し、Actions Artifact から `RoolaSetup-<version>.exe` がダウンロードできることを確認する
- [x] 6.2 ダウンロードしたインストーラを Windows 環境で実行し、利用規約同意画面の表示・インストール・アプリ起動・アンインストールが問題なく完了することを確認する
