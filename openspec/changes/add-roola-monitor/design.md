## Context

アクティビティ機能は Roola の `lib/` と macOS / Windows の Runner に埋め込まれて
いる。単体アプリから再利用するには、アプリ固有のもの（ワークスペース、`AppPaths`、
`AppException`、Runner のチャネル登録）への依存を切る必要がある。判断の全体像は
ADR-0069。

## Goals / Non-Goals

**Goals**

- アクティビティ機能（計測・計器盤・計器書体）と Polaris のコードを 1 か所に置き、
  Roola と Roola Monitor の両方から使う
- Roola 本体の挙動・見た目・設定ファイルを変えない
- Roola Monitor を署名・公証済みの DMG として配布できる

**Non-Goals**

- Windows 版 Roola Monitor、Windows の計測ネイティブのプラグイン化
- トップバーのモニタ・Claude Code 使用量の共通化（Roola 専用のまま）
- 自動更新・アナリティクス・CI のリリース workflow

## Decisions

### D1. パッケージ構成と依存の向き

```
apps/roola_monitor ──┐
                     ├─> packages/roola_activity ──> packages/polaris
Roola（ルート）──────┘                 ▲
        └──────────────────────────────┴──> packages/polaris
```

- `polaris` は Flutter 以外に依存しない。
- `roola_activity` は `polaris` と Riverpod / Hooks / Freezed に依存する。アプリ
  には依存しない。
- パッケージ内のディレクトリは Roola と同じ `data/` / `ui/` の分け方にそろえる。

### D2. `polaris` の中身

| 移動元（Roola） | 移動先 |
| --- | --- |
| `lib/app/theme.dart` | `packages/polaris/lib/src/theme.dart` |
| `lib/data/appearance/polaris_accent.dart` | `packages/polaris/lib/src/polaris_accent.dart` |
| `lib/ui/common/polaris_toggle.dart` | `packages/polaris/lib/src/polaris_toggle.dart` |
| `lib/ui/common/polaris_display_panel.dart` | `packages/polaris/lib/src/polaris_display_panel.dart` |

公開は `package:polaris/polaris.dart` の 1 ファイルから。`AppTheme.polaris()` は
`ActivityMeterPalette` を登録しなくなる（パレットは未登録時に既定値を返すため
描画は同じ）。

### D3. `roola_activity` の中身

- `lib/data/activity_metrics/`（`SystemMetricsRepository` と macOS / Windows の
  Dart 実装、モデル）: そのまま移動。Windows の Dart 実装も移す（チャネルの
  呼び出し側にすぎず、ネイティブ側は Roola の Runner が引き続き応答する）。
- `lib/data/activity_dashboard/`: 表示設定のモデル・DTO・リポジトリ。
  リポジトリ実装は `AppPaths` ではなく保存先 `File` を受け取る。保存先は
  `activityDashboardSettingsFileProvider`（既定は未実装で、アプリが override
  する）。`AppException` には依存せず、読み込みの I/O 失敗は
  `FileSystemException` をそのまま投げ、保存失敗は Notifier が握りつぶす
  （従来と同じく表示には影響させない）。
- `lib/ui/activity_dashboard/`: 計器盤。ワークスペースに依存していた
  `ActivityTabBody` を分割し、表示部分を `ActivityDashboardView({isActive})` として
  パッケージに置く。Roola はワークスペースから `isActive` を求めて渡すだけの
  `ActivityTabBody` を持つ。Roola Monitor は常に `isActive: true`。
- `ActivityMeterPalette` は `lib/ui/activity_dashboard/` へ移す。
- 計器書体（Barlow Condensed / Chakra Petch）はパッケージの `fonts:` で宣言し、
  `packages/roola_activity/<family>` の名前で参照する。OFL 本文はパッケージの
  アセットに置き、`registerActivityLicenses()` で `LicenseRegistry` に登録する。

### D4. macOS の計測はプラグインにする

`SystemMetricsProvider` を `packages/roola_activity/macos/Classes/` へ移し、
`RoolaActivityPlugin` が `roola/system/metrics` チャネルを登録する。メソッド
（`getSystemMetrics` / `getTopProcesses` / `getSystemSnapshot`）と返り値は変えない。
Roola の `MainFlutterWindow.swift` からは該当コードを削除する。

Windows はプラグインのプラットフォームに含めないため、Roola の Windows Runner が
従来どおり同名チャネルに応答する。

### D5. Roola Monitor のアプリ構成

- `apps/roola_monitor/lib/main.dart`: Application Support の
  `activity_dashboard.json` を保存先として override し、`registerActivityLicenses()`
  を呼んで起動する。
- 画面は `ActivityDashboardView(isActive: true)` を全面に置くだけ。
- メニューは Flutter の `PlatformMenuBar` で組む。アプリ名メニューに About（
  `showAboutDialog`。ライセンス表示ボタンを含む）・サービス・隠す・終了、
  ウィンドウメニューに最小化・拡大縮小。
- ウィンドウ（`MainFlutterWindow.swift`）: タイトルバーを透明にして地の色
  （Polaris の `bg`）と一体にし、ダーク外観に固定する。大きさと位置は
  `setFrameAutosaveName` で macOS に覚えさせる。最小サイズは計器盤が崩れない
  大きさ（480×320）。
- Bundle ID は `tech.yahiro.RoolaMonitor`、Debug / Profile は
  `dev.tech.yahiro.RoolaMonitor`。表示名は `Roola Monitor`。

### D6. App Sandbox

計測に使う API（`host_processor_info` / `host_statistics64` / `sysctl` /
IOKit の `IOBlockStorageDriver` / `getifaddrs` / `getloadavg`）がサンドボックス内
で値を返すか、実機で確かめてから決める。すべて取れればサンドボックスを有効に
する（ファイル書き込みは自アプリのコンテナだけで足りる）。取れない項目があれば
無効にし、理由をここに追記する。

> 確認結果は実装後にここへ追記する。

### D7. 配布手順

Makefile の `sign` / `dmg` の中身を、`APP_BUNDLE` などの変数で動く
`sign-bundle` / `dmg-bundle` に切り出す。Roola の `dist` は従来どおり動く。
Roola Monitor は `monitor-build` → `sign-bundle` → `dmg-bundle` → `notarize` →
`staple` を変数を差し替えて実行する（`make monitor-dist`）。DMG のボリューム名は
アプリ名と分ける（既存 Makefile の注記と同じ理由）。

## Risks / Trade-offs

- **import の大規模な置換で取りこぼしが出る** → `flutter analyze` と全テストで
  検出する。
- **フォントの参照名が変わり、書体が落ちる** → Roola と Monitor の両方で計器の
  書体を目視確認する。
- **サンドボックスで計測値が欠ける** → D6 の確認で判断する。
- **署名・公証はユーザーの認証情報が必要** → 実行前にユーザーに確認し、
  Keychain のロック解除などを依頼する。
