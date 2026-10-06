## Why

アクティビティタブ（ADR-0067）の計器盤を、Roola を開いていないときにも横に
出しておきたい。アクティビティモニタだけを単体アプリ **Roola Monitor** として
抜き出し、DMG で配布する。Roola 本体のアクティビティ機能は引き続き提供するため、
同じコードを 2 か所で保守しない構成にする（ADR-0069）。

## What Changes

- 共通部分を同一リポジトリ内の 2 パッケージへ切り出し、Roola と Roola Monitor が
  path 依存で参照する。
  - `packages/polaris`: Polaris のテーマ・トークン・アクセント・トグル・
    ディスプレイパネル（`lib/app/theme.dart` などから移動）
  - `packages/roola_activity`: 計測（Dart のリポジトリ＋ macOS の Swift を
    Flutter プラグイン化）、計器盤（ViewModel・メーター描画・表示設定）、
    計器書体とそのライセンス
- Roola 本体は上記パッケージを使うように書き換える。挙動・見た目・設定ファイルの
  場所は変えない。Windows の計測ネイティブは Runner に残す。
- 単体アプリ `apps/roola_monitor`（macOS のみ）を追加する。1 ウィンドウに計器盤を
  表示し、表示設定を永続化する。メニューは About（ライセンス表示を含む）と
  標準項目のみ。
- アイコン（翼＋セグメント式タコメーター）を追加する。
- Makefile に Roola Monitor のビルド・署名・DMG 作成・公証のターゲットを追加する。
  署名まわりの手順は Roola と共有する。
- ADR-0069 を追加する。

## Capabilities

### New Capabilities

- `roola-monitor`: 単体アプリ Roola Monitor。起動と計器盤の表示、表示設定の
  永続化、ウィンドウ、メニューと About、配布物（DMG）。

### Modified Capabilities

<!-- activity-dashboard の要件は変えない。実装の置き場所だけが変わる。 -->

## Impact

- **Roola 本体**: Polaris・アクティビティ関連の import が `package:polaris` /
  `package:roola_activity` に変わる（約 50 ファイル）。`MainFlutterWindow.swift`
  から `SystemMetricsProvider` を削除（プラグインへ移動）。`pubspec.yaml` から
  計器書体の宣言を削除（パッケージ側へ移動）。
- **新規**: `packages/polaris`、`packages/roola_activity`、`apps/roola_monitor`。
- **docs**: `docs/architecture.md`（ディレクトリ構成）、`docs/design-system.md`
  （Polaris の実装の置き場所）、`docs/release.md`（Roola Monitor の配布手順）。
- **配布**: Makefile に `monitor-*` ターゲット。CI の workflow は対象外（後続）。
