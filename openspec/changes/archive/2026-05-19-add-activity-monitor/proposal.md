## Why

Roola は macOS 向けのターミナルランチャー兼エクスプローラであり、シェル /
任意コマンド / Claude Skill を多数同時に起動できる。常時複数のプロセスを
抱えるため「いま機械にどれだけ負荷がかかっているか」「重いのはどのプロセス
か」をアプリ内から把握したい場面がある。現状その手段はなく、ユーザーは
macOS 標準のアクティビティモニタ.app へ切り替える必要がある。トップバーに
常駐する軽量なアクティビティモニタを置くことで、アプリを離れずに負荷状況を
把握できるようにする。

## What Changes

- トップバー右上、メモパッドアイコンと設定アイコンの **左** に、CPU とメモリ
  の負荷を示すアクティビティモニタを常設する。
- CPU / メモリそれぞれを「アイコン＋ミニレベルバー」で常時表示し、システム
  全体の使用率をバーの占有で直感的に示す。
- CPU またはメモリをクリックすると、システム上位プロセスの一覧を出す
  ポップオーバーを開く。CPU 押下なら CPU% 降順、メモリ押下ならメモリ降順。
  各行はプロセス名・CPU%・メモリ MB を表示する。
- macOS のシステムメトリクスを取得するため Flutter ⇔ ネイティブの
  `MethodChannel` を新設する（既存 `roola/trash` と同じパターン）。
- メトリクスは定期ポーリングで更新する。
- 見た目は Polaris デザインシステム（ADR-0038）に準拠する。
- ネイティブ連携方式・ポーリング間隔・取得項目の設計判断を ADR として
  `docs/adr/` に 1 件追加する。

## Capabilities

### New Capabilities

- `activity-monitor`: トップバー常駐のシステム負荷表示（CPU / メモリのミニ
  バー）と、クリックで開く上位プロセス一覧ポップオーバー。macOS の
  システムメトリクスを定期ポーリングで取得し Polaris スタイルで提示する。

### Modified Capabilities

<!-- 既存 spec の要件変更なし。トップバーへのウィジェット追加は実装詳細であり
     既存 capability の要件は変えない。 -->

## Impact

- **UI**: トップバーのアクション領域（`lib/ui/workspace/workspace_page.dart` の
  `actions`）にアクティビティモニタウィジェットを追加。新規 UI ファイル群を
  `lib/ui/activity_monitor/` に配置。
- **data 層**: システムメトリクス取得を `lib/data/activity_metrics/` の
  Repository（interface + impl）に隔離。ネイティブ依存を data 層に閉じ込める。
- **ネイティブ (macOS)**: `macos/Runner/MainFlutterWindow.swift` に新規
  `MethodChannel`（`roola/system/metrics`）を登録。メトリクス取得の Swift
  実装を追加。
- **状態管理**: Riverpod の Notifier / AsyncNotifier でポーリング状態を保持。
- **ドキュメント**: ADR を 1 件追加（ネイティブ連携・ポーリングの設計判断）。
- **実装方式**: 「システム全体のライブ CPU% ／ メモリ使用量 ／ 上位プロセス
  一覧」をまとめて返す macOS 向け pub パッケージは現状存在しない（in-app
  計測系はアプリ自身のみ、device-info 系は静的なハード情報のみ）。そのため
  ネイティブ標準 API ＋ Flutter 標準 `MethodChannel` で実装する。これは依存
  禁止ではなく、用途に合うパッケージがないことによる技術的判断。
