# Architecture

本プロジェクトのレイヤー構成・依存方向・各層の責務を定義する。判断の背景は `docs/adr/` を参照。

## 規範ソース

Flutter 公式の [App architecture guide](https://docs.flutter.dev/app-architecture) を **基盤** として採用し、MVVM（Model-View-ViewModel）パターンに従う。本ドキュメントは公式ガイドの構造をそのまま採り、本プロジェクト特有の判断（差し替え可能性が必要な箇所のみ interface を残す等）を上書きする形で記述する。

ただし「公式ガイドへの完全準拠」は目的ではない。**Flutter エコシステムで事実上の標準となっているライブラリ / パターン**（Riverpod・flutter_hooks・Freezed・go_router 等）は、公式ガイドの例示と一致しない場合でも採用する。具体的な選定理由は各 ADR を参照:

- MVVM 採用と Clean Architecture 不採用: `docs/adr/0006-mvvm-over-clean-architecture.md`
- Riverpod + Hooks 採用（公式の ChangeNotifier + StatefulWidget 例とは異なる）: `docs/adr/0003-riverpod-hooks-state-management.md`

## 全体方針

1. **3 グループ構成**: `ui/` / `data/` / `core/`（と起動系 `app/`）。Clean Architecture のような 4 層構成は採らない
2. **ViewModel = Riverpod Notifier**: 公式ガイドは ChangeNotifier を例示するが、本プロジェクトでは型安全性とテスト容易性のため Riverpod を使う（`docs/adr/0003-riverpod-hooks-state-management.md`）
3. **Use Case 層は作らない**: ロジックは ViewModel に集約。複数 ViewModel から共通利用したい純粋関数は `core/` 配下のユーティリティとして置く
4. **Repository pattern は限定採用**: 差し替え可能性が必要な箇所（PTY 実装・永続化）のみ interface + impl の二段構え。それ以外はクラス 1 つで十分
5. **DTO ⇄ モデル分離は必要時のみ**: 永続化を伴うフィーチャー（`launcher_entry` / `appearance`）でのみ JSON DTO と Freezed モデルを分ける

## ディレクトリ構成

```
lib/
├── main.dart                            # エントリポイント (Flutter 規約に従い lib 直下に置く)
│                                        # WidgetsFlutterBinding + window_manager 初期化 + runApp
├── app/                                 # アプリ最上位の合成 / DI / ルーティング / テーマ
│   ├── app.dart                         # MaterialApp.router / ProviderScope
│   ├── router.dart                      # go_router_builder で定義したルート
│   └── theme.dart                       # ThemeData
│
├── ui/                                  # View + ViewModel
│   ├── home/
│   │   ├── home_page.dart               # View（HookConsumerWidget）
│   │   └── home_view_model.dart         # ViewModel（Riverpod Notifier）
│   ├── settings/
│   │   ├── settings_page.dart
│   │   ├── settings_view_model.dart
│   │   ├── entry_edit_page.dart
│   │   ├── entry_edit_view_model.dart
│   │   └── appearance_section.dart      # 設定画面の外観セクション（Widget 分割）
│   ├── run/
│   │   ├── run_page.dart                # ターミナルビュー
│   │   └── run_view_model.dart
│   └── common/                          # 共通 Widget（ボタン・ダイアログ等）
│
├── data/                                # Model + Repository
│   ├── launcher_entry/
│   │   ├── launcher_entry.dart                  # Freezed モデル
│   │   ├── launcher_entry_dto.dart              # JSON DTO（json_serializable）
│   │   ├── launcher_entry_repository.dart       # interface
│   │   └── launcher_entry_repository_impl.dart  # ローカル JSON ファイル実装
│   ├── appearance/
│   │   ├── appearance_settings.dart
│   │   ├── appearance_settings_dto.dart
│   │   ├── appearance_settings_repository.dart
│   │   └── appearance_settings_repository_impl.dart
│   └── skill_runner/
│       ├── skill_run_state.dart                 # Freezed Union（idle/starting/running/completed/failed/cancelled）
│       ├── skill_runner.dart                    # interface
│       └── pty_skill_runner.dart                # flutter_pty 実装
│
└── core/                                # 横断ユーティリティ
    ├── storage/
    │   └── app_paths.dart               # path_provider ラッパー
    ├── exceptions/
    │   └── app_exception.dart
    └── utils/
        └── ...
```

## 各層の責務と禁止事項

### app/

**責務**:
- アプリ起動シーケンス（`WidgetsFlutterBinding.ensureInitialized` → `window_manager` 初期化 → `runApp`）
- `ProviderScope` の配置と最上位 DI
- `MaterialApp.router` の組み立てとテーマ適用
- go_router 定義

**禁止**:
- ビジネスロジックの実装（ViewModel 以降に置く）
- 画面ごとの状態管理

### ui/

**責務**:
- ユーザーインタラクションの受付
- ViewModel から取得した状態の描画
- ViewModel への入力イベント転送
- 入力バリデーション（フォーム単位、Formz 等を使ってもよい）

**禁止**:
- データソース（Repository 実装・ファイル I/O）への直接アクセス。**必ず ViewModel 経由**
- 副作用を持つ計算（プロセス起動・ファイル I/O）の直接呼び出し

**View の実装基準**:
- `HookConsumerWidget` を基本クラスとする（`flutter_hooks` + `hooks_riverpod`）
- 状態は `ref.watch` で購読、アクションは `ref.read(notifierProvider.notifier).xxx()` で呼ぶ
- ローカル状態（フォームの一時値・トグル状態など）は `useState` 等の Hook で

**ViewModel の実装基準**:
- Riverpod の `Notifier` / `AsyncNotifier`（必要なら family modifier）
- `state` で View に状態を公開、メソッドでアクションを公開
- Repository / Service への依存は `ref.read(xxxRepositoryProvider)` で取得
- View ごとに 1 ViewModel を基本とするが、画面が複雑な場合はセクション単位で分割可
- AsyncValue で非同期状態（loading / data / error）を表現

### data/

**責務**:
- 永続化（ローカル JSON ファイル）
- 外部プロセス制御（PTY）
- ドメインモデル（Freezed）と DTO（json_serializable）の定義
- DTO ⇄ モデルの変換

**禁止**:
- View / Widget への直接参照
- UI 状態の保持（loading / error フラグ等は AsyncValue で ViewModel 側が表現）

**Repository pattern の適用基準**:
- 差し替え可能性がある: interface + impl の二段構え
  - 例: `SkillRunner` interface → `PtySkillRunner` 実装。将来 PTY ライブラリを差し替える可能性
  - 例: `LauncherEntryRepository` interface → ローカル JSON 実装。将来 sqlite に乗り換える可能性
- 差し替え可能性が無い: クラス 1 つで OK（無理に interface を作らない）

### core/

**責務**:
- 複数フィーチャーから共通利用する純粋ユーティリティ
- 例外型定義
- パス解決などのプラットフォーム抽象

**禁止**:
- 特定フィーチャーに固有のロジック
- 状態保持

## 依存方向（許可されるインポート）

```
app/ ────► ui/, data/, core/
ui/  ────► data/ (interface), core/
data/ ────► core/
core/ ────► (依存なし)
```

逆方向は禁止:
- ❌ `data/` から `ui/` を import
- ❌ `core/` から `data/` / `ui/` / `app/` を import
- ❌ `data/<feature-a>/` から `data/<feature-b>/` を import（フィーチャー間結合を避ける）

ui 内のフィーチャー間 import も避ける。共通 Widget は `ui/common/` に置く。

## 状態管理パターン

### Provider の選択

| ケース | 採用 Provider | 理由 |
|---|---|---|
| 同期的な状態（フォームの選択値など） | `Notifier` | 同期で十分 |
| 非同期取得を伴う状態（永続化からの読み込み・PTY 起動） | `AsyncNotifier` | loading / error を AsyncValue で扱える |
| パラメータ依存の状態（entryId ごとの実行状態） | `Notifier.family` / `AsyncNotifier.family` | family modifier で `arg` 単位の状態を作る |
| 単純な参照（Repository インスタンス）| `Provider` | ファクトリとして使う |

### ref の使い分け

| メソッド | 用途 |
|---|---|
| `ref.watch(p)` | リアクティブ購読。値変化で再ビルド |
| `ref.read(p)` | 一度だけ取得。イベントハンドラ内・初期化時に使う |
| `ref.listen(p, callback)` | 副作用付きの監視（SnackBar 表示など） |

### Family と invalidate

- `family` 引数は値オブジェクト（プリミティブ・Freezed）にする。可変オブジェクトは禁止
- 状態を破棄したい時は `ref.invalidate(provider)` を呼ぶ
- 再実行など状態リセットが必要なケースは ViewModel 側で `ref.invalidateSelf()` を呼ぶ

### ローカル状態とグローバル状態の切り分け

- **ローカル**: フォームの一時値、トグル状態、テキスト入力中の値、表示モード（タブ選択など）→ `useState` / `useTextEditingController` 等の Hook
- **グローバル**: 永続化が必要、複数画面で共有、ライフサイクルを跨いで保持 → Riverpod Provider

## エラーハンドリング

- 業務的に起こり得るエラー（リポジトリパス不在・claude 不在）: ViewModel で `AsyncValue.error` または独自の Failure 状態へ遷移
- バグ起因（プログラム不整合）: `throw StateError` などで早期失敗、テストで検出
- 例外は `core/exceptions/app_exception.dart` で定義された型を `data/` 層で投げる

## テスト戦略

詳細は `docs/coding-standards.md` の「テスト」節を参照。要約:

- **Repository（data 層）**: 一時ディレクトリで実 I/O 検証。モックしない
- **ViewModel（ui 層）**: Repository / Service を Mocktail でモックし、`ProviderContainer.test()` で検証
- **Widget（ui 層）**: ViewModel Provider をオーバーライドしてゴールデンパス + 例外系を検証
- **`PtySkillRunner`**: 軽量コマンド（`bash -lc "echo hello"` 等）で実 PTY 経路を検証

## コード生成

`build_runner` で以下を生成:

- Freezed（`freezed_annotation` + `freezed`）: イミュータブルデータ型
- json_serializable: DTO の `fromJson` / `toJson`
- riverpod_generator: Provider の boilerplate 削減
- go_router_builder: ルート定義の型安全化

コマンド:

```bash
dart run build_runner build --delete-conflicting-outputs
# 開発時は watch
dart run build_runner watch --delete-conflicting-outputs
```

生成物（`*.freezed.dart` / `*.g.dart`）は commit する。

## 参考リンク

- Flutter App architecture: https://docs.flutter.dev/app-architecture
- Flutter App architecture case study: https://docs.flutter.dev/app-architecture/case-study
- Riverpod: https://riverpod.dev/docs/introduction/why_riverpod
- flutter_hooks: https://pub.dev/packages/flutter_hooks
- Freezed: https://pub.dev/packages/freezed
- go_router: https://pub.dev/packages/go_router
- xterm: https://pub.dev/packages/xterm
- flutter_pty: https://pub.dev/packages/flutter_pty
