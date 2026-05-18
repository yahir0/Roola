## Goals

- impl.txt 10 / 11 のコア体験（ブラウズ → Skill 検知 → 登録/実行/Claude 起動）を、本 change 単独で完結させる
- 既存の MVVM 構成・`session-registry` モデルとシームレスに統合する
- スコープを膨らませず、後続 change（clone ウィザード・Spotlight アニメ等）で必要な拡張余地を残す

## Non-goals

- ファイル中身プレビュー（テキストエディタ風）
- ファイル / ディレクトリ操作（リネーム・削除・新規作成・移動）
- ディレクトリ監視（`FileSystemEvent` watch）
- 複数ブックマーク保持（Finder のサイドバー風）
- 検知 Skill の自動登録（必ずユーザー確認を挟む）

## Architecture

### ディレクトリ構成

```
lib/
├── data/
│   └── repo_explorer/
│       ├── explorer_settings.dart          # Freezed (lastOpenedPath?)
│       ├── explorer_settings_dto.dart      # JSON DTO
│       ├── explorer_settings_repository.dart      # interface
│       ├── explorer_settings_repository_impl.dart # JSON 実装 + Provider
│       ├── explorer_node.dart              # 1 ディレクトリ / Skill の表現
│       └── explorer_directory_loader.dart  # 直下リストアップ + Skill 検知
├── ui/
│   └── explorer/
│       ├── explorer_page.dart              # ルート画面
│       ├── explorer_view_model.dart        # 現在のパス / 子ノード / 履歴
│       ├── explorer_tree.dart              # ツリー / リスト描画 Widget
│       └── explorer_node_tile.dart         # 1 行 + 右クリックメニュー
```

### 状態管理

#### `explorerSettingsProvider` (新規)

```dart
@Riverpod(keepAlive: true)
class ExplorerSettings extends _$ExplorerSettings {
  @override
  Future<ExplorerSettingsModel> build() async {
    return ref.read(explorerSettingsRepositoryProvider).load();
  }

  Future<void> setRoot(String path) async { ... }
}
```

`appearanceSettings` と同じ形（AsyncNotifier + Repository pattern）。

#### `explorerViewModelProvider` (新規)

```dart
@riverpod
class ExplorerViewModel extends _$ExplorerViewModel {
  @override
  ExplorerState build() { ... }

  void changeRoot(String path) { ... }
  void enter(String childPath) { ... }
  void goUp() { ... }
}
```

`build()` で `explorerSettingsProvider` を watch し、ルートと現在のパスを保持。`enter` / `goUp` でパスを切り替えて配下を再ロード。

#### `ExplorerNode` (Freezed)

```dart
@freezed
sealed class ExplorerNode with _$ExplorerNode {
  const factory ExplorerNode.directory({
    required String path,
    required String name,
    @Default(false) bool hasSkill, // .claude/skills 直下に SKILL.md があれば true
    @Default(<String>[]) List<String> skillNames,
  }) = ExplorerDirectoryNode;
  // 将来的に file タイプも追加できるよう sealed
}
```

### Skill 検知ロジック

各ディレクトリを展開するときに、その直下のフォルダ群について `<dir>/.claude/skills/*/SKILL.md` が存在するかをチェック。再帰しない（孫以降はユーザーがクリックして展開した時に初めてスキャン）。

既存 `SkillScanner` を再利用できる: `SkillScanner.scan(<dir>)` がそのディレクトリの Skill 名を返す。これを各子ディレクトリに対して呼ぶ。1 ディレクトリあたり 1 syscall（`.claude/skills/` の `existsSync`）+ 中身がある時のみ `listSync`。

巨大ディレクトリ対策:
- 子要素のリストアップは現在ディレクトリの直下に限る（再帰しない）
- 開いたディレクトリのキャッシュは保持しない（再訪時は再スキャン、シンプル優先）

### ad-hoc セッションの取り扱い

「Skill を即実行」「このディレクトリで Claude Code を開く」では `LauncherEntry` を作らず、`PtySkillRunner` と `ActiveSessions` だけで完結させる。

#### 既存のセッション起動経路（参考）

```
HomePage → /run/:entryId → RunViewModel.build(entryId)
  └─ launcherEntriesProvider から entry を取得
  └─ PtySkillRunner(repositoryPath, skillName)
  └─ ActiveSessions.register(entryId, ...)
```

#### ad-hoc 経路の設計

```
ExplorerPage → 右クリック → launchAdHocSession(...)
  └─ uuid を発行（`adhoc-<uuid>`）
  └─ PtySkillRunner(repositoryPath, skillName: '' or '/<skill>')
  └─ runViewModelProvider(adhocId) を強制的に build
  └─ ActiveSessions.register(adhocId, ...) ＋ adhoc 用の表示名を一緒に登録
```

ここで問題: 現状 `RunViewModel.build(entryId)` は `launcherEntriesProvider` から該当 entry を取得する。`launcherEntriesProvider` には ad-hoc id は存在しない。

解決案 2 つ:

**案 X: ad-hoc 用に擬似 `LauncherEntry` を一時生成して `launcherEntriesProvider` の state に混ぜる**

却下。`launcherEntriesProvider` は永続化を伴う AsyncNotifier で、エントリ一覧の単一の真実の源。ad-hoc を混ぜると、save 漏れ・誤削除等のリスクと責務の混乱が出る。

**案 Y: `RunViewModel` を改修して、ad-hoc 用の独立した入力経路（メタ情報を直接渡す）を持たせる**

採用。`runViewModelProvider` の family 引数を `String entryId` から `RunTarget` のような Union（entry / adhoc）に変えるか、別 provider（`adhocRunViewModelProvider`）を切る。

シンプルな実装は **別 provider を切る**:

```dart
@Riverpod(keepAlive: true)
class AdhocRunViewModel extends _$AdhocRunViewModel {
  @override
  RunPageState build(AdhocRunArgs args) {
    final runner = PtySkillRunner(
      repositoryPath: args.repositoryPath,
      skillName: args.skillName ?? '',
    );
    ref.read(activeSessionsProvider.notifier).registerAdhoc(
      adhocId: args.adhocId,
      displayName: args.displayName,
      initialState: runner.currentState,
      cancel: runner.cancel,
    );
    // ... 既存 RunViewModel.build と同等
  }
}

@freezed
class AdhocRunArgs with _$AdhocRunArgs {
  const factory AdhocRunArgs({
    required String adhocId,
    required String repositoryPath,
    required String displayName,
    String? skillName,
  }) = _AdhocRunArgs;
}
```

`ActiveSessions` には「entryId → SkillRunState」のみ持つ既存構造を活かしたいので、表示名は ActiveSessions 側に別途 `Map<String, String> _adhocLabels` を持って、ホーム chip 列の `_SessionChip` が `launcherEntriesProvider` で見つからない id の場合は `_adhocLabels[id]` を fallback として参照する。

`RunRoute` も `/run/:entryId` と `/run-adhoc/:adhocId` のように分ける。

### `PtySkillRunner` の skillName 空対応

現状 `_buildArguments` は常に `['/$skillName']` を返す。skillName が空 (`''`) のときは引数を空配列にし、`claude` を引数なしで起動する。

```dart
List<String> _buildArguments() {
  if (skillName.isEmpty) {
    return const []; // 対話モード
  }
  final normalized = skillName.startsWith('/') ? skillName : '/$skillName';
  return [normalized];
}
```

### 起点ディレクトリの永続化

`appearance_settings_repository_impl.dart` と同じパターン:

- `data/repo_explorer/explorer_settings.dart`: Freezed `ExplorerSettingsModel { String? rootPath }`
- DTO で JSON 永続化（`<appSupport>/repo_explorer_settings.json`）
- `ExplorerSettingsRepositoryImpl` interface + impl
- `explorerSettingsProvider` (AsyncNotifier)
- 初回起動・ファイル不在時のデフォルトは `null` を返し、UI 側でホームディレクトリにフォールバック（`Platform.environment['HOME']` または `path_provider` の `getApplicationDocumentsDirectory`）

### ルーティング

```dart
@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [
    TypedGoRoute<RunRoute>(path: 'run/:entryId'),
    TypedGoRoute<RunAdhocRoute>(path: 'run-adhoc/:adhocId'),  // 新規
    TypedGoRoute<ExplorerRoute>(path: 'explorer'),            // 新規
    TypedGoRoute<SettingsRoute>(path: 'settings', routes: ...),
  ],
)
```

AppBar には現在「設定」アイコンしかないが、エクスプローラへの導線として「フォルダ」アイコンを追加する。

### 右クリックメニュー

Flutter の `GestureDetector.onSecondaryTapDown` + `showMenu(context, position, items)` で実装する。Material 標準。

メニュー項目:
- `📂 このディレクトリで Claude を開く` (常に表示)
- `🎯 Skill を即実行` (Skill 検知時のみ、サブメニューで Skill 名選択 or 1 件ならそのまま)
- `➕ Skill を登録` (Skill 検知時のみ、サブメニューで Skill 名選択)

### Skill 登録フロー

検知済みフォルダ右クリック → `Skill を登録` → 該当 Skill 名 1 件選択 → `/settings/entries/new?repositoryPath=...&skillName=...` 相当の URL に navigate。

ただし go_router_builder の `GoRouteData` は query/extra で値を渡せる。`EntryNewRoute` に `initialRepositoryPath` / `initialSkillName` のオプショナル引数を足す:

```dart
class EntryNewRoute extends GoRouteData with $EntryNewRoute {
  const EntryNewRoute({this.initialRepositoryPath, this.initialSkillName});

  final String? initialRepositoryPath;
  final String? initialSkillName;
  ...
}
```

`EntryEditPage` 側は `entryId == null` のとき、これらの初期値を State に流し込む。

## Trade-offs

### `RunViewModel` を分けるか統合するか

ad-hoc 用に `AdhocRunViewModel` を切ると、`RunPage` 側で「どっちの ViewModel か」を分岐する必要が出る。ただし `RunRoute` と `RunAdhocRoute` でルート自体が分かれるので、`RunPage` も `RunAdhocPage` を別ファイルにするか、共通の `RunPage` が両方を受け取るかの選択になる。

採用: 共通の `RunPage` を維持し、コンストラクタで `entryId` か `adhocId` のどちらかを受ける Union を取る。`runViewModelProvider` と `adhocRunViewModelProvider` のどちらを watch するかは router 側で分岐。

理由:
- View 描画は同じ（タイトル + chip + アクションボタン + Terminal）
- ViewModel だけ別、View は共通、で責務がきれい

### 起点ディレクトリ永続化を JSON で別ファイル化する

既存 `appearance_settings.json` 一本に統合する案もあるが、関心が異なる（外観 vs エクスプローラ状態）ため別ファイル。新規 JSON 追加のコストは小さい。

### Skill 検知の遅延 vs 事前

開いたディレクトリの直下のみスキャンする方針。全体の事前インデックスは:
- 大規模ディレクトリで重い
- ディレクトリの追加・削除に追従できない
- そもそも要件にない

ため不要と判断。

## Migration

- `repo_explorer_settings.json` は初回起動時に未存在 → デフォルト（rootPath = null → UI 側でホームディレクトリにフォールバック）。マイグレーション不要
- 既存ユーザーは新ルートが追加されても既存挙動は変わらない（AppBar に新アイコンが 1 つ増えるだけ）
- `PtySkillRunner` の skillName 空対応は後方互換（既存呼び出しは skillName を必ず指定しているため影響なし）
