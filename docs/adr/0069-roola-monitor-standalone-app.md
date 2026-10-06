# ADR-0069: アクティビティモニタを共通パッケージに切り出し、単体アプリ Roola Monitor を同一リポジトリで提供する

- **Status**: Accepted
- **Date**: 2026-10-06

> 仕様・設計の詳細は `openspec/changes/add-roola-monitor/` を参照。

## Context

アクティビティタブ（ADR-0067）の計器盤は、Roola を開いていないときにも横に出して
おきたい需要がある。そこでアクティビティモニタだけを単体アプリとして抜き出し、
DMG で配布する。

一方で Roola 本体でもアクティビティタブとトップバーのモニタは引き続き提供する。
同じ機能を 2 か所で保守する形（コピー、別リポジトリ）は避けたい。

現状の実装は Roola の `lib/` とネイティブ Runner に埋まっている。

- 計測: Dart の `SystemMetricsRepository` と、macOS は `MainFlutterWindow.swift`
  の `SystemMetricsProvider`、Windows は `roola_channels.cpp`
- 計器盤: `lib/ui/activity_dashboard/`、表示設定の永続化は `AppPaths` に依存
- 見た目: Polaris（`lib/app/theme.dart`、トグル、ディスプレイパネル）と計器書体

## Decision

**同一リポジトリ内で、共通部分を 2 つのパッケージに切り出し、Roola と
Roola Monitor の両方が path 依存で参照する。** Roola Monitor は `apps/` 配下の
独立した Flutter アプリとする。

```
packages/polaris/         デザインシステム（テーマ・トークン・共通部品）
packages/roola_activity/  計測（Flutter プラグイン・macOS）＋計器盤＋計器書体
apps/roola_monitor/       単体アプリ（ウィンドウ・メニュー・アイコンだけを持つ）
(ルート)                   Roola 本体
```

### D1. 別リポジトリにせず、同一リポジトリで共有する

コードを 1 か所に置き、どちらのアプリにも同じ変更が入るようにする。ADR・OpenSpec・
署名と公証の手順も共有できる。配布形態や担当が本体と分かれる事情が出てくれば
別リポジトリ化を改めて検討する。

### D2. 「同じプロジェクトに入口を足す」形は採らない

Flutter のネイティブプラグインはプロジェクト単位で全部組み込まれる。同じ
プロジェクトに入口（`main_monitor.dart`）とビルド設定を足す形では、Monitor にも
ターミナル（SwiftTerm）や DnD などが入る。Bundle ID・アイコン・更新設定を
ビルドごとに切り替える仕組みも必要になり、Flavor を持たない方針（ADR-0004）と
衝突する。独立したアプリにすれば、依存は計測と描画に必要なものだけで済む。

### D3. pub workspaces は使わず path 依存にする

Dart の pub workspaces を使うと依存解決が 1 つにまとまる。ただし、ルートの
`pubspec.lock` と `flutter_pty` の上書き（`dependency_overrides`）の扱いが
変わり、Roola 本体のビルドに影響が出る。初版では各アプリが自分の
`pubspec.lock` を持ち、パッケージを path で参照する形にとどめる。

### D4. 計測のネイティブ部分はプラグインにし、macOS だけ移す

`SystemMetricsProvider`（Swift）を `roola_activity` の macOS プラグインへ移す。
チャネル名（`roola/system/metrics`）とメソッドは変えない。

Roola Monitor は macOS のみ対応する。Windows の C++ 実装は Roola の Runner に
残し、Windows 実機で確認できるときに別 change でプラグインへ移す。それまでは
Windows のネイティブ部分だけ Roola の Runner 側にある。

### D5. Polaris をパッケージにする

計器盤のツールバーとパネルは Polaris の部品で組まれているため、Polaris も共有が
必要になる。`lib/app/theme.dart`、`PolarisAccent`、`PolarisToggle`、
`PolarisDisplayPanel` を `packages/polaris` へ移す。Roola 側の import は書き換え、
再エクスポート用のファイルは残さない。

`ActivityMeterPalette` は計器盤側の部品なので `roola_activity` に置く。Polaris
のテーマには登録せず、未登録時の既定値（`ActivityMeterPalette.standard`）で描く。
Polaris が計器盤に依存しないようにするためで、見た目は変わらない。

### D6. 表示設定の保存先はアプリが決める

`roola_activity` は保存先ファイルを受け取るだけにする（Provider を各アプリが
override する）。Roola は従来どおり `<appSupport>/activity_dashboard.json` を
使うので、既存ユーザーの設定は引き継がれる。

### D7. Roola Monitor の初版の範囲

| 項目 | 初版 |
| --- | --- |
| 対応 OS | macOS のみ |
| 表示 | 計器盤（LEVEL / TACHO の全スタイル・全コア表示）。表示設定を永続化 |
| メニュー | About（ライセンス表示を含む）・終了などの標準項目のみ |
| 入れないもの | 自動更新（Sparkle）、匿名アナリティクス、Claude Code 使用量、常に手前に表示、トップバーのモニタ |
| Bundle ID | `tech.yahiro.RoolaMonitor`（Debug / Profile は `dev.` を付ける / ADR-0013） |
| バージョン | Roola とは独立（`apps/roola_monitor/pubspec.yaml`）。0.1.0 から |

計器盤の描画領域では、Polaris の規定を適用しない扱い（ADR-0068）をそのまま
引き継ぐ。

### D8. 配布

署名・公証は Roola と同じ Developer ID で行う。Makefile の署名・DMG 作成・公証の
手順をアプリごとの変数で動かせるようにし、`make monitor-dist` で DMG まで作る。
GitHub Actions のリリース workflow は後続で追加する。

### D9. アイコン

Roola の翼をそのまま使い、フォルダの位置をセグメント式タコメーター（12 分割・
点灯 7）に差し替える（`branding/README.md`）。初版はコードで生成したマスターを
使い、画像生成による清書が届いたら差し替える。

## Why

ユーザーが求めたのは「Roola 内の機能はそのまま残し、単体アプリも出す。ただし
二重保守にしない」こと。共有パッケージ化はこの 3 点を同時に満たす唯一の形だった。

## Trade-offs

- **import の書き換えが広い**: Polaris の移動で Roola の約 50 ファイルの import が
  変わる。機械的な置換で、挙動は変えない。
- **Windows のネイティブ部分だけ共有されていない**: D4 のとおり別 change で
  解消する。
- **ロックファイルが 2 つ**: Roola と Monitor で依存のバージョンがずれる可能性が
  ある。ずれが問題になったら pub workspaces への移行を検討する。
- **Roola Monitor には自動更新がない**: 更新はユーザーが DMG を入れ直す。利用状況を
  見て Sparkle の導入を判断する。

## References

- ADR-0004（dart-define は単一環境）
- ADR-0013（Bundle ID と dev プレフィックス）
- ADR-0038（Polaris）
- ADR-0040（OSS ライセンス表示）
- ADR-0053（ブランドシンボル）
- ADR-0067 / ADR-0068（アクティビティタブ）
