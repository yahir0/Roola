## Context

Explorer タブの body はこれまで「ディレクトリ一覧」だけだった
（`explorer_tab_body.dart` の `Column[ヘッダ, 1px ライン, 一覧]` 構造）。
ここに「読み取り専用ファイルプレビュー」を **同タブ内の右ペイン** として
追加する。

設計判断の背景・代替案は ADR-0046 を参照。本ドキュメントは実装方針の詳細。

制約:

- Polaris デザインシステム（ADR-0038）に準拠。色・余白・角丸は
  `PolarisTokens` 経由、アニメーションは 0ms。色のハードコード禁止。
- per-tab 状態は `family(tabId)` パターン（ADR-0027）。
- ワークスペース永続化はしない（ADR-0042）。プレビュー設定も永続化しない。
- 既存の右クリック → vim 経路は撤去しない。
- Repository pattern は永続化 / 差し替え可能性が必要な箇所のみ
  （ADR-0006）。今回のファイル I/O は `dart:io` 直叩きで interface なし。

## Goals / Non-Goals

**Goals:**

- 主選択ファイルをゼロアクションでプレビュー表示する。
- シンタックスハイライトを Polaris の配色に統合する。
- バイナリ / 大きすぎファイル / 読み込みエラーで UI を破壊しない。
- 編集機能を持ち込まない（読み取り専用に厳密に閉じる）。

**Non-Goals:**

- 編集機能（挿入・削除・保存）。
- 行番号表示（要望が出たら後付け検討）。
- コードフォールディング・検索・ジャンプ。
- 画像 / PDF / 動画 / その他バイナリプレビュー。
- FSEvents による自動再読込（ADR-0041 のフックは今回張らない）。
- パネル表示状態 / 幅の永続化。
- Space キーでのオーバーレイ表示（将来検討）。

## Decisions

### Decision 1: ライブラリは `flutter_highlight` のみ採用する

`flutter_code_editor` ではなく `flutter_highlight` を採用する。理由は
ADR-0046「代替案 1」参照。要点だけ:

- `flutter_code_editor` は編集 UI を内包しており、`readOnly:true` でも
  ライブラリ自体の存在がエディタ化の誘惑になる。
- `flutter_highlight` は `HighlightView(source, language, theme)` を返す
  最小コンポーネント。表示専用に閉じている。

### Decision 2: Explorer タブ内の横分割で実装する

ワークスペースに新タブ種別「preview」を足す代替案は却下（ADR-0046「代替案 3」）。
Explorer タブ内に `Row(listing | preview)` を入れる。

- スプリッタは既存 `workspace_split.dart` の split パターンを参照しつつ、
  Explorer タブ内専用の薄いラッパを作る（外部ワークスペース層と
  混同しないため別ファイル）。
- 最小幅: listing 240px / preview 280px を目安。これより狭くなる場合は
  プレビュー側をトグルで畳むよう促す（自動畳みはしない）。
- 既定の split 比率は 6:4（listing : preview）。

### Decision 3: 状態は `family(tabId)` の AsyncNotifier

`filePreviewViewModelProvider.family(tabId)` を作る。内部で
`explorerSelectionProvider(tabId)` を watch し、主選択ファイルを
`FilePreviewContent` として保持する。

- AsyncValue で「ロード中 / 成功 / バイナリ / 大きすぎ / 失敗」を扱う。
- パネルの可視状態（表示 / 非表示）と split 比率は別の Notifier に分け、
  プレビュー読み込みと再描画を独立させる
  （`filePreviewLayoutProvider.family(tabId)`）。

### Decision 4: ファイル読み込みの責務は data 層に置く

`lib/data/file_preview/file_preview_repository.dart` に
`FilePreviewRepository` を 1 クラスだけ作る（interface なし）。役割:

- `Future<FilePreviewContent> load(String path)`
- ファイル先頭 4 KiB を読み取り NUL バイトの有無でバイナリ判定。
- ファイルサイズが 16 MiB 超なら `FilePreviewContent.tooLarge`。
- 1 MiB 超 16 MiB 以下なら先頭 1 MiB だけ読み取り `isTruncated:true`。
- それ以下はそのまま UTF-8 で読む。decode に失敗したら `binary`。
- 読み込みエラー（FileSystemException）は `failed(message)` でラップ。

`FilePreviewContent` は Freezed sealed:

```dart
@freezed
sealed class FilePreviewContent with _$FilePreviewContent {
  const factory FilePreviewContent.text({
    required String path,
    required String content,
    required String? language,
    required bool isTruncated,
  }) = FilePreviewText;
  const factory FilePreviewContent.binary({required String path}) = FilePreviewBinary;
  const factory FilePreviewContent.tooLarge({
    required String path,
    required int sizeBytes,
  }) = FilePreviewTooLarge;
  const factory FilePreviewContent.failed({
    required String path,
    required String message,
  }) = FilePreviewFailed;
}
```

### Decision 5: 言語判定は最小ロジックで

`lib/ui/explorer/file_preview/language_detector.dart` に純粋関数で
分離する（テストしやすさ重視）。

1. 拡張子 → `flutter_highlight` の language id への map（10〜20 種を
   ホワイトリストで持つ：`dart`, `python`, `javascript`, `typescript`,
   `bash`, `yaml`, `json`, `markdown`, `xml`, `html`, `css`, `scss`,
   `swift`, `go`, `rust`, `java`, `kotlin`, `ruby`, `sql`, ...）。
2. ヒットしなければ shebang を `#!/...` から判定（`bash` / `sh` / `python`）。
3. それでもヒットしなければ `null`（色付けなしのプレーンテキスト）。

### Decision 6: ハイライトテーマは Polaris トークンから組み立てる

`lib/ui/explorer/file_preview/polaris_highlight_theme.dart` で
`Map<String, TextStyle> polarisHighlightTheme(PolarisTokens tokens)` を
作る。`flutter_highlight` 標準テーマ（atom-one-dark 等）は使わず、
全色を `tokens` の `accent` / `text` / `textMuted` / `textSubtle` /
`success` / `warn` / `danger` 等から選んで組み立てる。

- ベース色: `tokens.text`
- コメント: `tokens.textMuted`
- キーワード: `tokens.accent`
- 文字列: `tokens.success` 系（彩度を抑えた版）
- 数値: `tokens.warn` 系
- シンボル / 演算子: `tokens.textSubtle`

具体的なトークン名は実装時に Polaris の現在の token map と照合して決定する。
（不足があれば `PolarisTokens` 側に `syntax*` 系トークンを足す案も検討）。

### Decision 7: 表示状態と幅は in-memory のみ

ワークスペースは終了時に破棄される（ADR-0042）ため、プレビューパネルの
表示 / 非表示と split 比率も合わせて per-tab in-memory のみ。アプリ
再起動で既定（表示・6:4）に戻る。

### Decision 8: リフレッシュは手動。FSEvents は今回連動させない

ADR-0046 で議論済み。`filePreviewViewModelProvider.family(tabId)` に
`reload()` メソッドを持たせ、パネル右上のアイコンから呼ぶ。

## Architecture Sketch

```
lib/
├── data/
│   └── file_preview/
│       ├── file_preview_content.dart        # Freezed sealed
│       ├── file_preview_content.freezed.dart
│       └── file_preview_repository.dart     # interface なし・1 クラス
└── ui/
    └── explorer/
        ├── explorer_tab_body.dart           # 修正: Row(listing | preview)
        └── file_preview/
            ├── file_preview_pane.dart       # メイン Widget
            ├── file_preview_view_model.dart # AsyncNotifier.family(tabId)
            ├── file_preview_view_model.g.dart
            ├── file_preview_layout_provider.dart # 表示状態 / split 比率
            ├── file_preview_layout_provider.g.dart
            ├── language_detector.dart       # 純粋関数
            └── polaris_highlight_theme.dart # PolarisTokens → theme map
```

## Risks / Trade-offs

- **`flutter_highlight` の言語対応漏れ**: 100+ 言語サポートだが、特殊な
  言語（HCL / Nix / Zig 等）はプレーンテキストになる。実害が出てから対応
  リストを広げる。
- **ファイル読み込みの IO ブロック**: `AsyncNotifier` で非同期化するが、
  ネットワークマウント等で I/O が遅いと体感が落ちる。タイムアウトは
  今回入れず、観察してから検討。
- **Explorer タブの最小幅増**: 横分割の追加で狭い構成（3 ペイン × タブ ×
  preview）では Explorer タブが詰まる。トグルで畳めるので致命的ではない。
- **`PolarisTokens` に syntax 系トークンが無い場合の拡張**: テーマ統合で
  色の選定肢が足りない可能性。最小実装では既存トークンから流用し、
  必要なら別 PR で `syntax*` トークンを Polaris に追加する。

## Open Questions

- ファイルサイズしきい値（1 MiB / 16 MiB）は妥当か？ `.log` 系の確認
  ユースケースが多ければ閾値を上げる余地あり → 初期値で出してフィードバック
  待ち。
- パネル右上のアクションは「リフレッシュ」のみで足りるか？「外部エディタ
  で開く」「パスをコピー」も並べる案は検討中だが、初期版では絞る。
