## ADDED Requirements

### Requirement: appcast.xml の生成
`release-windows.yml` ワークフローがリリースごとに `appcast-windows.xml` を生成し、WinSparkle が参照できる形式で GitHub に公開する。

#### Scenario: タグ push によるリリース時の appcast 生成
- **WHEN** `v*` タグが push されて `release-windows.yml` が完了する
- **THEN** 最新バージョン情報（バージョン番号・ダウンロード URL・公開日）を含む `appcast-windows.xml` が生成され、リポジトリの main ブランチに commit・push される

#### Scenario: appcast の URL 安定性
- **WHEN** 将来のリリースで appcast が更新される
- **THEN** `https://raw.githubusercontent.com/yahiro0/Roola/main/appcast-windows.xml` のパスは変わらず、すべての既存インストールが最新の appcast を参照できる

### Requirement: appcast.xml フォーマット
appcast-windows.xml は Sparkle / WinSparkle が要求する RSS 2.0 + sparkle 名前空間フォーマットに準拠する。

#### Scenario: 有効な appcast 構造
- **WHEN** WinSparkle が appcast-windows.xml を取得する
- **THEN** `<rss>` ルート、`<channel>` 内の `<item>` に `<sparkle:version>`、`<enclosure url="...">` が含まれており WinSparkle が解析できる

#### Scenario: ダウンロード URL の正確性
- **WHEN** appcast の `<enclosure url>` が設定される
- **THEN** URL は当該バージョンの `RoolaSetup-X.Y.Z.exe` への直接ダウンロードリンク（`https://github.com/yahiro0/Roola/releases/download/vX.Y.Z/RoolaSetup-X.Y.Z.exe`）を指している

### Requirement: appcast CI コミットの無限ループ防止
appcast 更新のコミット・push がさらにリリースワークフローを起動しないよう制御する。

#### Scenario: appcast コミット後のワークフロー非起動
- **WHEN** CI が `appcast-windows.xml` を更新して main に push する
- **THEN** その push イベントは `release-windows.yml` を新たに起動しない（`[skip ci]` コミットメッセージまたは `paths-ignore` 設定による）
