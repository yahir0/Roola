# ADR-0004: dart-define は単一環境（prod）のみ

- **Status**: Accepted
- **Date**: 2026-05-11

## Context

Flutter プロジェクトでは Flavor（dev / stg / prod）を切って `--dart-define-from-file=dart_defines/<flavor>.json` で環境別の定数を注入するのが一般的。本アプリでこれを採用すべきか判断する必要がある。

本アプリは以下の特性を持つ:

- ローカル CLI（`claude` / `git`）を起動するだけのデスクトップツール
- 外部 API への通信を持たない（URL 切り替えの対象が無い）
- Firebase / Sentry / Analytics などのバックエンドサービスを使う予定もない
- 配布対象は個人 / 公開 OSS としての利用者のみ

## Decision

- Flavor 分離は行わない
- `dart_defines/prod.json` を 1 ファイルだけ用意し、`--dart-define-from-file=dart_defines/prod.json` で読み込む
- VSCode の `.vscode/launch.json` も prod 用 1 コンフィグのみ

## Why

### 代替案 1: dev / stg / prod の 3 Flavor を最初から用意

却下。理由:

- 環境ごとの差分（API URL・Firebase config 等）が現在も将来も発生する見込みが無い
- 設定ファイル・launch.json・ドキュメントが 3 倍に膨れるコストに対し、得られる価値が無い
- 将来 Flavor が必要になっても、その時点で追加する判断ができる

### 代替案 2: dart-define を完全に使わない

却下。理由:

- 将来、ビルド時のフィーチャーフラグやデバッグ用フラグを足したくなる場面はあり得る
- そのための「差し込み口」として 1 ファイルだけは用意しておくほうが、後から構造を追加するより安い

### 採用理由（単一 prod のみ）

- 現状必要な機能は提供できる
- 構成が極小で、ドキュメントもシンプルに済む
- 将来 Flavor が必要になった場合、`dart_defines/dev.json` 追加 + launch.json 1 行追加で済む

## Trade-offs

- `prod` という命名は将来 dev / stg を足した時の対比語として違和感が出る可能性がある。その時点で改名するか、`default.json` にリネームする選択肢を残す
- dart-define ファイル自体を持たない選択肢（`flutter run` だけで起動）も取れたが、後から「ファイルがあれば足せたのに」となるコストを避けた

## References

- Flutter --dart-define-from-file: https://docs.flutter.dev/deployment/flavors
