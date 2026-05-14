# ADR-0018: ランチャー管理 UI を Settings から独立画面へ分離

- **Status**: Accepted
- **Date**: 2026-05-14

## Context

Roola が「Claude Skills ランチャー」として始まった経緯から、登録済みエントリの一覧 / 追加 / 編集 / 削除 UI は
SettingsPage に同居していた（外観設定 + claude ヘルス + エントリ一覧）。

しかしランチャーが Claude Skill 専用から汎用ターミナルランチャーに拡張され（ADR-0016）、Roola のアイデンティティが
「設定済みディレクトリ + 動作の起動アプリ」になった現在、エントリ一覧は **アプリ設定** ではなく **コンテンツ管理**
の領分。Settings に同居しているのは違和感がある。

## Decision

**ランチャー一覧 / 追加 / 編集 / 削除を独立画面 `LauncherManagementPage` に分離する。**

- 配置: `lib/ui/launchers/launcher_management_page.dart`（新規）
- 関連ファイルも `lib/ui/settings/` → `lib/ui/launchers/` へ移動:
  - `entry_edit_page.dart`（既存）
  - `entry_edit_view_model.dart`（既存）+ 生成物
  - 同名テストファイルも `test/ui/launchers/` へ
- ルート構造を `/settings/entries/*` から `/launchers/*` へ re-nest:
  - `/launchers` — `LauncherManagementRoute`（一覧）
  - `/launchers/new` — `EntryNewRoute`（追加）
  - `/launchers/:entryId` — `EntryEditRoute`（編集）
- 導線: サイドバーのランチャーセクション末尾に「ランチャーを管理…」タイル
  （`_LauncherManageTile`）を置き、`LauncherManagementRoute().push()` する
- SettingsPage は `AppearanceSection` + `_ClaudeHealthBanner` のみに縮小

## Why

「Settings」と「ランチャー管理」は性質が違う:

- **Settings**: アプリ全体の preference（外観、ヘルスチェック等）。基本的に一度設定すれば変わらない静的な領域
- **ランチャー管理**: ユーザーが日常的に追加・編集・削除するコンテンツ。動的な領域

両者を 1 つの画面に同居させると、ユーザーは「アプリ設定を変えたい」場面と「ランチャーを増やしたい」場面で
同じ画面を行き来することになり、メンタルモデルがぼやける。

導線として **サイドバー末尾の「管理…」ボタン** を選んだ理由:

- サイドバーは登録済みランチャーが既に並んでいる場所 → 一覧管理の起点として自然
- AppBar に「管理」ボタンを足すと右上のアイコン列が肥大化する
- 右クリックメニュー方式は in-context だが discoverability が低い（複数エントリの一括管理にも向かない）

### 代替案 1: SettingsPage に残す（現状維持）

- 設定とコンテンツ管理が混在する違和感を解消できない
- 却下

### 代替案 2: AppBar に「管理」アイコンを追加

- 設定の歯車と並べると右上アイコンが 3 個になり混雑する（既に「⚙ / 📁 / 戻る・進む」）
- 却下: AppBar の simplicity を優先

### 代替案 3: サイドバー右クリックメニューだけで完結

- discoverability が低く、複数エントリの一括俯瞰ができない
- 却下: 一覧画面はやはり必要

## Trade-offs

- **ルート構造の変更**: `/settings/entries/*` → `/launchers/*` への deep link 変更。Roola は外部 deep link を
  受けないアプリなので影響なし。
- **ファイル移動の volume**: entry_edit_page / entry_edit_view_model および test 一式を `settings/` から
  `launchers/` へ移動。`git mv` で履歴は維持できる。
- **将来の管理機能拡張余地**: 並べ替え / グルーピング / 検索 / バルク削除などの管理 UI を将来追加する場合、
  独立画面なのでスペースに余裕がある。Settings 同居だったら厳しかった。

## References

- ADR-0016（ランチャーを Claude Skill 専用から汎用化）
- 関連 commit: 本 ADR と同 PR 内のリファクタリング
