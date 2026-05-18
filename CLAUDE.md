# Roola — Project Guide

Mac 向けの汎用ターミナルランチャーアプリ（Flutter Desktop / macOS）。エクスプローラ機能をメインに、設定済みのディレクトリ + 動作（素のシェル / 任意コマンド / Claude Code Skill）をアイコンとして登録し、ワンクリックで起動できる。Claude Skill 起動はサポート動作の 1 つ（ADR-0014 / ADR-0016）。

## このドキュメントの位置付け

本リポジトリは **AI ツール（Claude Code 等）に依存せず、リポジトリ単体で完結する** ことを設計目標にしている。外部の Skill / プラグイン / 個人ナレッジに依存せず、このリポジトリの `docs/` を読めば誰でも保守できる状態を維持する。

## 規約サマリ

詳細は `docs/` を参照。ここには「守ること」だけを列挙する。

### アーキテクチャ

- Flutter 公式 [App architecture guide](https://docs.flutter.dev/app-architecture) を **基盤** とした **MVVM ベースの 3 グループ構成**（`ui/` / `data/` / `core/` + 起動系 `app/`）
- 公式ガイドの完全準拠は目的としない。Flutter エコシステムで事実上の標準となっているライブラリ・パターンは積極採用する（Riverpod / flutter_hooks / Freezed / go_router 等）
- ViewModel は **Riverpod** の `Notifier` / `AsyncNotifier`（公式は ChangeNotifier 例示）
- 差し替え可能性が必要な箇所（PTY 実装・永続化）のみ **Repository pattern + interface** を残す。それ以外は interface を作らない
- Use Case 層は作らない。ロジックは ViewModel に集約
- 詳細: `docs/architecture.md`、判断背景は `docs/adr/`

### 状態管理

- グローバル状態: **Riverpod**（`Notifier` / `AsyncNotifier`、必要なら family modifier）
- ローカル状態: **flutter_hooks**（`useState` / `useEffect` / `useMemoized` 等）
- `ref.watch` / `ref.read` / `ref.listen` の使い分けは `docs/architecture.md` 参照

### モデル / シリアライゼーション

- イミュータブルモデル: **Freezed**
- JSON 永続化: **json_serializable**
- DTO ⇄ モデル分離は **永続化を伴うフィーチャーのみ** 実施。表示専用の状態クラスでは分離しない

### ルーティング

- **go_router** + **go_router_builder** で型安全な `GoRouteData` を定義

### テスト

- ユニット / ウィジェットテストフレームワーク: Flutter 標準
- モック: **Mocktail**（`when()` / `verify()`）
- 各クラスのテスト方針: `docs/coding-standards.md`

### コミット / PR

- **Conventional Commits（日本語サマリ可）**: `feat:` / `fix:` / `docs:` / `chore:` / `refactor:` / `test:` / `style:` / `perf:` / `ci:` / `build:`
- ブランチ命名: `feat/<topic>` / `fix/<topic>` / `chore/<topic>`
- 詳細: `docs/coding-standards.md` のコミット節

### Flutter SDK バージョン管理

- **FVM**（`.fvmrc` でバージョン固定）

### 環境設定

- 単一環境（prod）。Flavor 分離は行わない。`dart_defines/prod.json` のみ
- 詳細と背景: `docs/adr/0004-single-dart-define.md`

## 重要な設計判断（ADR）

判断と背景は `docs/adr/` に時系列で記録する。新しい設計判断を行う際は ADR を 1 件追加すること。

主要 ADR:

- ADR-0001: Flutter Desktop（macOS）採用
- ADR-0002: PTY ベースのターミナル統合を最初から採用
- ADR-0003: Riverpod + Hooks による状態管理
- ADR-0004: dart-define は単一環境（prod）のみ
- ADR-0005: 外部 Skill / プラグインに依存しない自己完結方針
- ADR-0006: Flutter 公式 MVVM の採用（Clean Architecture を採らない理由）
- ADR-0007: `riverpod_lint` / `custom_lint` の採用を当面保留
- ADR-0008: スキル実行セッションを実行画面 widget から切り離して保持
- ADR-0009: ad-hoc セッションを別 provider で扱う
- ADR-0010: Home / Explorer をタブ式 `StatefulShellRoute` で束ねる
- ADR-0011: エクスプローラの DnD を `super_drag_and_drop` で OS 連携にする
- ADR-0012: マルチウィンドウは別プロセス起動で実現（共有 Engine 方式は後追い検討）
- ADR-0013: Bundle ID を `tech.yahiro.Roola` に、Debug / Profile は `dev.` プレフィックスで分離
- ADR-0014: Explorer をメイン UI に格上げ、Skills ランチャーをサブ機能へ降格
- ADR-0015: Explorer の root ceiling を廃止、rootPath は「起動時の開始位置」に弱める
- ADR-0016: ランチャーを Claude Skill 専用から汎用ターミナルランチャーへ
- ADR-0017: ターミナル描画フォントに Sarasa Term J を同梱する
- ADR-0018: ランチャー管理 UI を Settings から独立画面へ分離
- ADR-0019: ランチャーをフォルダで 1 階層グループ化する
- ADR-0020: UI を Win10/11 風フラット実用テーマに転換する
- ADR-0021: エクスプローラの操作モデルをダブルクリック化 + CC でパスコピー
- ADR-0022: Claude Code 関連機能を optional 化する
- ADR-0023: カスタムアイコン機能を廃止する
- ADR-0024: エクスプローラのタイル表示密度を切替え可能にする
- ADR-0025: GUI 起動経路の SIGPIPE 即死を AppDelegate で抑止する
- ADR-0026: `/explorer` を 3 画面タブ式ワークスペースに刷新する
- ADR-0027: per-tab 状態を family(tabId) + scoped Provider で実現する
- ADR-0028: ワークスペースレイアウトの永続化とターミナル再 spawn
- ADR-0029: エクスプローラのお気に入りをフォルダで 1 階層グループ化する
- ADR-0030: Git ビューをワークスペースタブとして追加する
- ADR-0031: ターミナル描画を xterm.dart から SwiftTerm ネイティブビューへ移行する
- ADR-0032: ターミナルで Shift+Enter を改行（LF）入力に割り当てる
- ADR-0033: コマンドレジストリとネイティブメニューバーによる統一ショートカット機構
- ADR-0034: 多言語化を Flutter 公式 gen-l10n（ARB）で実装する
- ADR-0035: ⌘C/⌘V/⌘X/⌘A/⌘Z をテキスト編集用に予約し、コマンド割り当て不可とする
- ADR-0036: ノートパッドをワークスペース外のフローティングパネルとして実装する

## ディレクトリ構成

```
.
├── CLAUDE.md                  # このファイル（規約サマリ）
├── docs/
│   ├── architecture.md        # MVVM レイヤー構成・依存方向・各層責務
│   ├── coding-standards.md    # 命名・import 順・コメント・テスト・コミット規約
│   └── adr/                   # 設計判断の時系列記録
│       ├── README.md
│       ├── 0001-flutter-desktop-macos.md
│       ├── 0002-pty-from-the-start.md
│       ├── 0003-riverpod-hooks-state-management.md
│       ├── 0004-single-dart-define.md
│       ├── 0005-no-external-skill-dependency.md
│       └── 0006-mvvm-over-clean-architecture.md
├── openspec/                  # 仕様駆動開発の change 管理（OpenSpec）
│   ├── config.yaml
│   ├── changes/<name>/        # 進行中の change
│   └── specs/                 # archive 済み spec
├── lib/                       # Flutter コード本体（未生成）
└── ...
```

## 開発ワークフロー

1. 機能追加は OpenSpec の change として `openspec/changes/<name>/` に proposal / design / specs / tasks を起こす
2. 設計判断が発生したら `docs/adr/` に 1 件 ADR を追加
3. 実装は `docs/architecture.md` のレイヤー構成と `docs/coding-standards.md` の規約に従う
4. コミットメッセージは Conventional Commits（日本語サマリ可）

## ライセンス

未定（公開時に設定）。
