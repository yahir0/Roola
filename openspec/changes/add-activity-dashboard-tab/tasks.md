## 1. ネットワーク I/O の取得検証（design D8・最初に実施）

- [x] 1.1 macOS: `getifaddrs`（`if_data`・32bit）と `sysctl(NET_RT_IFLIST2)`
      （`if_data64`）の受信 / 送信累積バイトを 1 秒ごとに出力する検証コードを書き、
      ラップアラウンドや負の差分が出るかを確認する
- [x] 1.2 macOS: ループバック・仮想 IF（`utun*` / `awdl*` / `llw*` / `bridge*` 等）の
      除外ルールを決め、大きめのダウンロード / アップロード中にアクティビティ
      モニタ.app のネットワーク値と桁レベルで一致することを確認する
- [ ] 1.3 （Windows 実機で実施）Windows: `GetIfTable2` の `InOctets` / `OutOctets` で同様に検証し、
      タスクマネージャの値と比較する（物理 / 仮想アダプタのフィルタを決める）
- [x] 1.4 検証結果を design.md D8 に追記し、ネットワークの採否を確定する
      （不採用なら以降のネットワーク関連タスクを削除し、ADR に原因を記録する）

## 2. ネイティブ層: `getSystemSnapshot`

- [x] 2.1 macOS: `SystemMetricsProvider` に状態を持たない `snapshot()` を追加する
      （`host_processor_info` のコア別累積 tick、既存のメモリ算出、
      `vm.swapusage`、IOKit `IOBlockStorageDriver` の読み書き累積バイト合計、
      `getloadavg`、採用ならネットワーク累積バイト）
- [x] 2.2 macOS: `roola/system/metrics` に `getSystemSnapshot` を追加する
      （既存 `getSystemMetrics` / `getTopProcesses` は変更しない）
- [x] 2.3 Windows: `roola_channels.cpp` に `getSystemSnapshot` を追加する
      （`NtQuerySystemInformation` のコア別時間、`GlobalMemoryStatusEx` のメモリ /
      ページファイル、PDH のディスク読み書き累積、採用ならネットワーク累積。
      ロードアベレージのキーは返さない）
- [ ] 2.4 （macOS はネイティブ部分を単体実行して確認済み。Windows 実機は未確認）両 OS で `flutter run` し、返り値のキーと値の妥当性を手元で確認する

## 3. data 層

- [x] 3.1 `lib/data/activity_metrics/system_snapshot.dart` に Freezed モデル
      `SystemSnapshot`（コア別累積 tick、メモリ / スワップ、ディスク / ネットワーク
      累積バイト、ロードアベレージ。取得できない項目は null）を定義する
- [x] 3.2 `SystemMetricsRepository` に `fetchSnapshot()` を追加し、macOS / Windows
      実装で `getSystemSnapshot` の Map をモデルへ変換する
- [x] 3.3 表示設定: `ActivityDashboardSettings`（Freezed。mode / tachoStyle /
      showAllCores）と DTO（json_serializable）、Repository（interface + impl）を
      `AppearanceSettings` と同じパターンで追加する
- [x] 3.4 `build_runner` で生成コードを更新する
- [x] 3.5 テスト: Map → `SystemSnapshot` 変換（欠損キーが null になること）と
      設定 DTO の往復・未知値のフォールバックを書く

## 4. ViewModel と計算

- [x] 4.1 `lib/ui/activity_dashboard/activity_rates.dart` に、前回 / 今回の
      スナップショットから CPU 使用率（全体・コア別）と I/O レート（B/s）を
      算出する純粋関数を実装する（カウンタ減少区間は 0 扱い）
- [x] 4.2 `ActivityDashboardViewModel`（autoDispose `Notifier`）を実装する
      （250ms ポーリング、前回スナップショット保持、取得失敗時は直近値を維持）
- [x] 4.3 `ActivityDashboardSettingsNotifier` を実装する（読み込み・変更・保存。既存 `AppearanceSettingsNotifier` に揃え data 層の repository_impl に同居）
- [x] 4.4 `lib/ui/activity_dashboard/meter_physics.dart` に、ばね＋ダンパ
      （k=90・減衰比 0.7・1/240 秒刻み積分）、PPM バリスティクス（上昇 50ms・
      下降 毎秒 60%）、ピークホールド（1.5 秒保持・毎秒 35% 落下）の純粋関数を実装する
- [x] 4.5 テスト: レート算出（ラップ・初回サンプル）、ViewModel のポーリングと
      失敗時の値維持（fake repository）、物理関数の収束・オーバーシュート量・
      ピーク保持時間を書く

## 5. ワークスペース統合

- [x] 5.1 `WorkspaceTab.activity({id})` を追加し、`build_runner` を実行する。
      `pane_widget` / `pane_tab_strip` / `workspace_provider` などの switch を
      網羅する（タイトル「アクティビティ」とアイコン、フォーカス追跡）
- [x] 5.2 `Workspace.openActivityTab({PaneSlotId? slotId})` を実装する（既存が
      あればアクティブ化、無ければ指定スロット・既定は右上に追加）
- [x] 5.3 タブストリップ「+」メニューに「アクティビティモニタ」を追加する
- [x] 5.4 トップバーのポップオーバー（CPU / メモリ）に「タブで開く」を追加し、
      押したらポップオーバーを閉じてタブを開く
- [x] 5.5 `CommandId.openActivityTab` を追加し、コマンドディスパッチ・macOS
      メニューバー・Windows トップメニュー・キー割り当て画面・l10n（ja / en）に
      反映する（既定は ⌘⇧A / Ctrl+Shift+A。design D2 参照）
- [x] 5.6 テスト: `openActivityTab` の単一インスタンス性（2 回開いても 1 つ・
      既存がアクティブになる）と追加先スロットを書く

## 6. 書体とパレット

- [x] 6.1 Barlow Condensed（数値）と Chakra Petch（ラベル）の必要ウェイトを
      `assets/fonts/` に追加し、`pubspec.yaml` に登録する
- [x] 6.2 両書体の OFL 全文を `assets/licenses/` に追加し、`license_bootstrap.dart`
      で `LicenseRegistry` に登録する（ADR-0040）
- [x] 6.3 `ActivityMeterPalette`（`ThemeExtension`）を追加する（LED 緑 / 琥珀 / 赤、
      VFD オレンジ・赤橙、レッドゾーン、文字盤・目盛り・ラベル色など）。
      アクティビティタブ外から参照しない

## 7. 描画（CustomPainter）

- [x] 7.1 タブ body `ActivityTabBody`: ツールバー（LEVEL / TACHO、TACHO 時の
      CLASSIC / DIGITAL / RACE、全コア表示トグル）と、自タブがアクティブな間だけ
      ViewModel を watch する制御を実装する
- [x] 7.2 `MeterAnimator`（Ticker で毎フレーム dt を計算し、物理関数で表示値を
      更新）と、TACHO 切替・スタイル変更時のオープニング演出、アニメーション低減
      設定での即時スナップを実装する
- [x] 7.3 `LevelMeterPainter`（5 グループ・40 セグメント・3 帯・消灯表示・発光・
      ピーク・対数 / コア数目盛り・数値とチャンネル名）を実装する
- [x] 7.4 `ClassicDialPainter`（黒い文字盤・白い目盛り・赤いレッドゾーン線・
      赤橙の針・下部の数値）を実装する
- [x] 7.5 `DigitalDialPainter`（VFD オレンジのセグメント円弧・消灯セグメント・
      通過目盛りの点灯・中央の数値）を実装する
- [x] 7.6 `RaceClusterPainter`（右肩上がり CPU バーグラフ・非線形目盛り・左右
      パネル・円の縁取りと水平線・数値と RACE バッジ・UPTIME）とシフトライトを実装する
- [x] 7.7 全コア表示（LEVEL のチャンネル増加、CLASSIC / DIGITAL のコア別小メーター
      グリッド、RACE のコア別小バーグラフ）を実装する
- [ ] 7.8 `RepaintBoundary` の分割と `shouldRepaint` を設定し、プロファイルで
      1 フレームの描画時間を確認する（目安 4ms 以内）
- [x] 7.9 ウィジェットテスト: モード / スタイル切替で対応する Painter が出ること、
      取得できない項目のメーターが出ないこと、全コア表示トグルの有効 / 無効

## 8. ドキュメント

- [ ] 8.1 ADR-0067「アクティビティモニタをワークスペースタブとして追加する」の
      Status を実装結果に合わせて更新する（ネットワークの採否を含む）
- [x] 8.2 ADR-0068「アクティビティタブでは Polaris の規定を適用しない」を確認し、
      `docs/design-system.md` に適用除外の注記を入れる
- [x] 8.3 CLAUDE.md の主要 ADR 一覧（0067 / 0068 は Proposed で追記済み）の注記を
      実装結果に合わせて更新し、`docs/adr/README.md` の一覧にも追記する

## 9. 動作確認

- [ ] 9.1 macOS で 3 経路からタブを開き、全モード・全スタイル・全コア表示を目視
      確認する（負荷をかけてレッドゾーン・シフトライト・ピークホールドを確認）
- [ ] 9.2 別タブに切り替えるとポーリングが止まり、戻すと再開することを確認する
- [ ] 9.3 トップバーの CPU / メモリ表示がタブの有無で変わらないことを確認する
- [ ] 9.4 Windows で同じ確認を行う（ロードアベレージが出ないこと）
- [x] 9.5 `flutter analyze` と `flutter test` が通ることを確認する
