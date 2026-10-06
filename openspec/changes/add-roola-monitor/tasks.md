## 1. Polaris のパッケージ化

- [x] 1.1 `packages/polaris` を作成し、テーマ・トークン・アクセント・トグル・
      ディスプレイパネルを移す（design D2）
- [x] 1.2 `AppTheme.polaris()` から `ActivityMeterPalette` の登録を外す
- [x] 1.3 Roola の import を `package:polaris/polaris.dart` に置き換え、旧ファイルを削除する

## 2. `roola_activity` プラグイン

- [x] 2.1 `packages/roola_activity`（Flutter プラグイン・macOS）を作成する
- [x] 2.2 `SystemMetricsProvider` を Swift のプラグインへ移し、`RoolaActivityPlugin`
      で `roola/system/metrics` を登録する。Roola の `MainFlutterWindow.swift` から削除する
- [x] 2.3 `data/activity_metrics` と `data/activity_dashboard` を移す。設定リポジトリを
      保存先 `File` 注入に変え、`activityDashboardSettingsFileProvider` を追加する
- [x] 2.4 `ui/activity_dashboard` と `ActivityMeterPalette` を移し、
      `ActivityDashboardView({isActive})` を切り出す
- [x] 2.5 計器書体と OFL をパッケージへ移し、フォント参照名を `packages/roola_activity/...`
      にする。`registerActivityLicenses()` を追加する
- [x] 2.6 `build_runner` で生成コードを作り直す
- [x] 2.7 アクティビティの単体テストをパッケージへ移し、パッケージ単体で通す

## 3. Roola 本体の追従

- [x] 3.1 `pubspec.yaml` に path 依存を追加し、計器書体の宣言を削除する
- [x] 3.2 import を書き換え、`ActivityTabBody` をワークスペース連携だけに縮める
- [x] 3.3 `activityDashboardSettingsFileProvider` を `AppPaths` の既存パスで override する
- [x] 3.4 ライセンス登録で `registerActivityLicenses()` を呼ぶ
- [x] 3.5 `flutter analyze` と全テストを通す
- [ ] 3.6 Roola を起動し、アクティビティタブ（全モード・書体）とトップバーのモニタが
      従来どおり動くことを確認する

## 4. Roola Monitor

- [ ] 4.1 `apps/roola_monitor` を作成する（macOS のみ、Bundle ID / 表示名 /
      Debug・Profile の `dev.` プレフィックス）
- [ ] 4.2 起動処理（保存先の override・ライセンス登録）と画面・メニューを実装する
- [ ] 4.3 ウィンドウ（透明タイトルバー・ダーク外観・大きさの記憶・最小サイズ・
      閉じたら終了）を実装する
- [ ] 4.4 アイコンをマスターから 7 サイズ書き出す
- [ ] 4.5 App Sandbox の可否を確認し、design D6 に結果を追記する
- [ ] 4.6 起動して全モードの表示・設定の永続化・About のライセンス・Roola との同時起動を確認する

## 5. 配布

- [ ] 5.1 Makefile の署名・DMG 作成を変数で動くターゲットに切り出し、`monitor-*`
      ターゲットを追加する（Roola の `dist` の挙動は変えない）
- [ ] 5.2 署名・DMG 作成・公証・ステープルを実行し、DMG を検証する
      （`spctl` / `stapler validate`）
- [ ] 5.3 `docs/release.md` に Roola Monitor の配布手順を追記する

## 6. ドキュメント

- [x] 6.1 `docs/architecture.md` のディレクトリ構成に `packages/` と `apps/` を追記する
- [x] 6.2 `docs/design-system.md` の実装ファイルの場所を更新する
- [ ] 6.3 アイコンの清書が届いたら差し替える（後続）
