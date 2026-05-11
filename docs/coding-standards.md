# Coding Standards

本プロジェクトのコーディング規約。新規コードと既存コード修正のどちらにも適用する。アーキテクチャの規約は `docs/architecture.md` を参照。

## 命名規約

### Dart 標準に従う

[Effective Dart: Style](https://dart.dev/effective-dart/style) を基本とする。以下は明示しておくポイント。

| 対象 | 規則 | 例 |
|---|---|---|
| クラス・enum・typedef・extension | UpperCamelCase | `LauncherEntry` |
| 変数・関数・パラメータ・引数名 | lowerCamelCase | `entryId`, `loadEntries()` |
| 定数（コンパイル時定数） | lowerCamelCase | `const defaultIconSize = 48` |
| プライベートメンバ | アンダースコア前置 | `_localDataSource` |
| ファイル名 | snake_case | `launcher_entry_repository.dart` |
| ディレクトリ名 | snake_case | `launcher_entry/` |

### プロジェクト固有の命名

| パターン | 例 |
|---|---|
| ViewModel | `<Feature>ViewModel`（例: `HomeViewModel`） |
| Page（View） | `<Feature>Page`（例: `HomePage`） |
| Repository interface | `<Entity>Repository`（例: `LauncherEntryRepository`） |
| Repository 実装 | `<Entity>RepositoryImpl` または機構を表す名前（例: `PtySkillRunner`） |
| Freezed モデル | エンティティ名そのまま（例: `LauncherEntry`） |
| DTO | `<Entity>Dto`（例: `LauncherEntryDto`） |
| State Union | `<Operation>State`（例: `SkillRunState`） |
| Provider 変数 | `<entity>Provider` / `<feature>NotifierProvider`（例: `launcherEntriesProvider`） |

### 名前の付け方の指針

- **意図** を表す名前にする。実装詳細を漏らさない（`saveAsJson` ではなく `save`）
- 真偽値は `is...` / `has...` / `should...` で始める（`isLoading`、`hasError`）
- 動詞句は具体的に: `getEntries` ではなく `loadEntries`（`get` は意味が広すぎる）

## Import 順序

`dart format` の自動整列に従えば概ね正しいが、補足規約として以下を守る:

1. `dart:` 系
2. `package:flutter/` 系
3. `package:` 系（3rd party）
4. `package:claude_skills_launcher/` 系（自プロジェクト）
5. 相対 import（`../` / `./`）

各グループ内はアルファベット順。グループ間に空行を入れる。

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry.dart';

import 'home_view_model.dart';
```

相対 import は **同一フィーチャー内の参照のみ**。フィーチャーを跨ぐ参照は `package:` import を使う。

## コメント規約

### 原則: コメントを書かない

良い命名と良い構造があれば、ほとんどのコメントは不要。WHAT を書くコメントは禁止する（`// 永続化する` の下に `save()` を書くのは無意味）。

### コメントを書くべき場面

WHY が非自明な箇所だけにコメントを書く:

- 一見冗長に見えるが意図がある実装（バグ回避・パフォーマンス対策など）
- 外部の制約（OS の仕様・ライブラリの不具合回避）
- 規約に外れる意思決定（その場で書かないと後で誤って修正される）

```dart
// dart_io の Process.start は macOS Sandbox 下では子プロセスの作業ディレクトリ
// 変更が無視される。flutter_pty が内部的に sh -c 経由で起動することで回避している。
```

### Doc コメント

公開 API（パッケージ外から使われるクラス・トップレベル関数）には `///` で 1〜2 行の Doc コメントを書く。プライベートメンバには不要。

## Widget 実装ガイドライン

- **`HookConsumerWidget` を基本**にする（`flutter_hooks` + `hooks_riverpod`）
- `StatefulWidget` は基本使わない。状態は Hook で表現
- 単一 Widget が大きくなったら早めに分割する（目安: `build` メソッドが 100 行超）
- インデント階層は深くしない（4 段超になりそうなら抽出する）

## エラーハンドリングの書き方

### data 層

- 業務的エラー（パス不在・コマンド不在）は `core/exceptions/` で定義した独自例外として投げる
- 想定外エラーは投げ直すか、`AppException.unknown` でラップする

### ui 層（ViewModel）

- `AsyncNotifier` の場合、Dart の例外は `AsyncValue.error` に自動的に乗る
- `Notifier` の場合、State に Failure フィールドを設けるか、`AsyncValue` ベースの State にする

### View（UI）

- `state.when()` / `state.maybeWhen()` で loading / error / data を分岐
- ユーザーへの表示は SnackBar / ダイアログを使い、`ref.listen` で副作用として行う

## テスト規約

### テストの構成

```
test/
├── data/
│   ├── launcher_entry/
│   │   └── launcher_entry_repository_impl_test.dart
│   ├── appearance/
│   │   └── appearance_settings_repository_impl_test.dart
│   └── skill_runner/
│       └── pty_skill_runner_test.dart
├── ui/
│   ├── home/
│   │   ├── home_view_model_test.dart
│   │   └── home_page_test.dart   # Widget テスト
│   ├── settings/
│   │   └── ...
│   └── run/
│       └── ...
└── helpers/
    └── ...                       # 共通テストヘルパー
```

実装ファイルと 1:1 で対応するテストファイルを `<実装>_test.dart` の名前で置く。

### モック方針

- **Mocktail** を使う（`mockito` ではなく）
- モック対象は **interface（抽象クラス）** のみ。具象クラスのモックは原則禁止
- Fake が必要な場合は `test/helpers/` に Fake クラスを定義

```dart
class _MockLauncherEntryRepository extends Mock implements LauncherEntryRepository {}
```

### test の書き方

- `group()` でクラス単位 / メソッド単位にネスト
- `test()` の説明は「what given when then」で書く
- `setUp` / `tearDown` を活用
- `expect` は具体的に

```dart
group('LauncherEntryRepositoryImpl', () {
  late Directory tempDir;
  late LauncherEntryRepositoryImpl repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('test_');
    repo = LauncherEntryRepositoryImpl(rootDir: tempDir);
  });

  tearDown(() => tempDir.delete(recursive: true));

  group('loadAll', () {
    test('returns empty list when file does not exist', () async {
      final result = await repo.loadAll();
      expect(result, isEmpty);
    });
  });
});
```

### カバレッジの目安

- **Repository / DataSource**: 90%+（外部 I/O を含むので主要パスを全網羅）
- **ViewModel**: 80%+（正常系 + 主要エラー系）
- **Widget**: 主要画面 1 件あたり golden path + 例外系 1〜2 件
- 100% は目指さない。テストしにくいコード（OS 依存・UI 描画）は手動確認に回す

## Riverpod の書き方

### Provider 定義

`riverpod_generator` を使い、関数 / クラス記法で書く:

```dart
@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() => const HomeState.idle();

  Future<void> loadEntries() async {
    state = const HomeState.loading();
    try {
      final entries = await ref.read(launcherEntryRepositoryProvider).loadAll();
      state = HomeState.loaded(entries);
    } on AppException catch (e) {
      state = HomeState.error(e.message);
    }
  }
}
```

### Provider 命名（generator 経由）

- クラス名: `<Feature>ViewModel`
- 生成される Provider 名: `homeViewModelProvider`（generator が自動）

## コミット / PR 規約

### Conventional Commits（日本語サマリ可）

```
<type>: <summary>

<body, optional>
```

| type | 用途 |
|---|---|
| `feat` | 新機能 |
| `fix` | バグ修正 |
| `docs` | ドキュメントのみの変更 |
| `chore` | ビルド・補助ツール・依存更新 |
| `refactor` | 機能変更を伴わないコード整理 |
| `test` | テストの追加・修正 |
| `style` | フォーマット・空白等 |
| `perf` | パフォーマンス改善 |
| `ci` | CI 設定の変更 |
| `build` | ビルドシステム / 依存パッケージの変更 |

サマリは日本語でも英語でも可。混在は避ける。

```
feat: ホーム画面にアイコングリッドを実装

LauncherEntriesProvider を購読し、登録エントリを 4 列グリッドで描画。
未登録時はプレースホルダーと設定画面導線を表示する。
```

### ブランチ命名

- 新機能: `feat/<topic>`
- バグ修正: `fix/<topic>`
- ドキュメント: `docs/<topic>`
- リファクタ: `refactor/<topic>`
- 雑務: `chore/<topic>`

topic は kebab-case の短い記述（例: `feat/home-grid`）。

### マージ前のチェックリスト

- [ ] `dart format` 通過
- [ ] `dart analyze` 警告ゼロ
- [ ] `flutter test` 全グリーン
- [ ] 関連する OpenSpec change のタスクが完了している
- [ ] 設計判断が発生していたら ADR を追加した

## フォーマッタと静的解析

- フォーマッタ: `dart format`（CI でチェック）
- 静的解析: `dart analyze`（`analysis_options.yaml` 準拠、`flutter_lints` ベース + `custom_lint` + `riverpod_lint` を有効化）
- 行長: 80 文字（Dart 標準）

## 公開前チェック（リポジトリを public にする際）

リポジトリを公開リポジトリ化する直前に以下を全件確認:

- [ ] `git grep` で個人情報・組織名・内部 URL が含まれていないこと
- [ ] `pubspec.yaml` の依存に private package が含まれていないこと
- [ ] commit author / committer の email が公開可能であること
- [ ] `LICENSE` を配置していること
- [ ] `README.md` を整備していること
