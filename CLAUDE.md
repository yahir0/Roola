# Roola — Project Guide

汎用ターミナルランチャーアプリ（Flutter Desktop / macOS + Windows）。エクスプローラ機能をメインに、設定済みのディレクトリ + 動作（素のシェル / 任意コマンド / Claude Code Skill）をアイコンとして登録し、ワンクリックで起動できる。Claude Skill 起動はサポート動作の 1 つ（ADR-0014 / ADR-0016）。

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

### デザインシステム（Polaris / ADR-0038）

- **Polaris**（独自デザインシステム・思想は機能主義）。**ダーク専用**。ライトテーマは持たない
- 全デザイン値は `PolarisTokens`（`ThemeExtension`）に集約。色・角丸・余白を
  コンポーネント側にハードコードしない（`Color(0x...)` / マジックナンバー禁止）
- 地はグラファイト（計器面 `well` / 機材面 `machine` / 筐体 `bg` の 3 トーン）、
  アクセントは暖色ゴールド 1 色（アイスブルーに切替可・デフォルトはゴールド）、
  角丸 R=4px、全寸法 4px グリッド、アニメーション 0ms
- コンテンツ面は 1 枚のベゼル付きディスプレイに統一し、内側はフラット（ADR-0054）
- 現行規約の本体: `docs/design-system.md`。判断の背景: ADR-0038 / ADR-0054

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
- ADR-0037: ターミナルのプラットフォームビューと Flutter フォーカスを橋渡しする
- ADR-0038: Polaris デザインシステムを採用する（ADR-0020 を Supersede）
- ADR-0039: トップバーにアクティビティモニタ（CPU / メモリ監視）を追加する
- ADR-0040: About ダイアログと OSS ライセンス画面を提供する
- ADR-0041: Explorer / Git ビューを FSEvents 監視で自動更新する
- ADR-0042: アプリ終了時にワークスペースを破棄し、起動は既定 seed で始める（ADR-0028 を Supersede）
- ADR-0043: メニューから手動でアップデート確認を呼べるようにする
- ADR-0044: タイル右クリックメニューに「現在のフォルダ」項目を追加する
- ADR-0045: サイドバーのお気に入りを Win2000 風ツリーで展開する
- ADR-0046: Explorer に読み取り専用ファイルプレビューパネルを追加する
- ADR-0047: ターミナル選択ドラッグ中の自動スクロールを `TerminalView` のサブクラスで補う
- ADR-0048: アクティビティモニタにディスク I/O とネットワーク I/O を追加する（**不採用** / 番号予約）
- ADR-0049: 起動直後の OS 連携 DnD 登録を初回フレーム後まで遅延する（起動時クラッシュ回避）
- ADR-0050: プレビューに画像 / PDF を追加し、既定非表示 + 選択追従の自動開閉にする（ADR-0046 を一部変更）
- ADR-0051: エクスプローラ一覧を十字キー / Enter で操作できるようにする
- ADR-0052: メニューの key equivalent をフォーカス中ビューより優先する（全ショートカットが効かない不具合の修正）
- ADR-0053: ブランドシンボルを舵から「翼＋フォルダ」へ刷新する（威圧感の解消）
- ADR-0054: コンテンツ面はベゼル付きディスプレイに統一し、内側はフラットにする（設定画面を Material から Polaris へ）
- ADR-0055: ウィンドウ再アクティブ化時に最後のフォーカスペインへフォーカスを戻す
- ADR-0056: ライセンス表示をモーダルシェル化し、ウィンドウヘッダの戻るボタンを廃止する
- ADR-0057: Claude Code のタスク完了を Stop フック + ローカル受信口で macOS 通知する
- ADR-0058: Windows 対応（ADR-0001 Supersede）—対応プラットフォームを macOS + Windows に拡張する
- ADR-0060: アクティビティモニタに Claude Code 使用量メーター（ローカル JSONL 集計・推定コスト）を追加する
- ADR-0061: プレビューのテキストを Text.rich で描画し選択・コピー可能にする（flutter_highlight → highlight）
- ADR-0062: ランチャーの Claude Skill に実行時引数（プロンプト）を渡せるようにする（コマンドライン引数・複数行入力）
- ADR-0063: 「素のシェル（OpenHere）」をログインシェルで起動する（Terminal.app と同じ PATH 構築・node 等の command not found を解消）
- ADR-0064: macOS のトップバーからワードマークを廃止し、信号灯を 40px トップバー内で上下中央へ寄せる（ADR-0038 D9 を一部 Supersede）
- ADR-0065: 匿名アナリティクスに Aptabase を採用する（REST 直叩き・利用規約第 2 版・起動時の同意モーダルとオプトアウト）
- ADR-0066: タスク通知を通知エスケープシーケンス（OSC）方式へ移行する（ADR-0057 Supersede）— ユーザー設定ゼロの in-band 通知（許可待ち即時 + 入力待ち 60 秒）へ。フック経路は安定確認後に撤去。管理対象は Roola 内起動セッションのみ

## ディレクトリ構成

```
.
├── CLAUDE.md                  # このファイル（規約サマリ）
├── docs/
│   ├── architecture.md        # MVVM レイヤー構成・依存方向・各層責務
│   ├── coding-standards.md    # 命名・import 順・コメント・テスト・コミット規約
│   ├── design-system.md       # Polaris デザインシステムの現行規約（生きた仕様）
│   ├── notes/                 # 決定前の構想・議論ログ（日付付き、ADR/OpenSpec の前段階）
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

[MIT License](./LICENSE)
