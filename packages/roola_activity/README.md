# roola_activity

Roola と Roola Monitor が共有するアクティビティモニタ（ADR-0069）。

- `lib/data/activity_metrics/` — システムメトリクスの取得（`roola/system/metrics` チャネル）
- `lib/data/activity_dashboard/` — 計器盤の表示設定と永続化
- `lib/ui/activity_dashboard/` — 計器盤（`ActivityDashboardView`）とメーター描画
- `macos/Classes/` — macOS の計測ネイティブ実装（Flutter プラグイン）

Windows の計測ネイティブ実装は当面 Roola の Runner（`windows/runner/roola_channels.cpp`）に
ある。仕様と設計は `openspec/changes/add-roola-monitor/` を参照。

## 使う側の準備

- `activityDashboardSettingsFileProvider` を、表示設定の保存先ファイルで override する
- 起動時に `registerActivityLicenses()` を呼び、計器書体のライセンスを登録する

## コード生成

```sh
dart run build_runner build --delete-conflicting-outputs
```
