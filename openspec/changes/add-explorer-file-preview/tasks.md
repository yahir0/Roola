## 1. 依存追加 / 下準備

- [x] 1.1 `pubspec.yaml` に `flutter_highlight` を追加し、`flutter pub get`
      を実行する。
- [-] 1.2 ~`flutter_highlight` のサンプル（最小 `HighlightView`）を main から
      仮で呼んでビルド / 描画できることを確認する（確認後に削除）。~ →
      実装本体（`FilePreviewPane`）の組み込み時にビルド成功で代替したため
      別途の仮実装はスキップ。

## 2. data 層（モデル・リポジトリ）

- [x] 2.1 `lib/data/file_preview/file_preview_content.dart` に Freezed sealed
      `FilePreviewContent`（`text` / `binary` / `tooLarge` / `failed`）を
      定義する。
- [x] 2.2 `lib/data/file_preview/file_preview_repository.dart` に
      `FilePreviewRepository` を実装する（interface なし）:
      - 先頭 4 KiB の NUL 判定でバイナリ検出
      - 16 MiB 超は `tooLarge`、1 MiB 超 16 MiB 以下は先頭 1 MiB 読み込み
        `isTruncated:true`
      - UTF-8 decode 失敗 → `binary`
      - `FileSystemException` → `failed(message)` でラップ
      - Riverpod の `filePreviewRepositoryProvider` を併設
- [x] 2.3 `build_runner` を実行して Freezed の生成コードを更新する。

## 3. UI 層（言語判定 / テーマ）

- [x] 3.1 `lib/ui/explorer/file_preview/language_detector.dart` に
      拡張子マップ + shebang 判定の純粋関数
      `String? detectLanguage(String path, String head)` を実装する。
- [x] 3.2 `lib/ui/explorer/file_preview/polaris_highlight_theme.dart` に
      `Map<String, TextStyle> polarisHighlightTheme(PolarisTokens tokens)`
      を実装する。色のハードコードは禁止。
- [x] 3.3 既存 `PolarisTokens`（accent / text / textDim / textFaint /
      signalNew / signalModified / signalConflict）だけで syntax 系を構成
      できたため Polaris への追加トークンは不要。

## 4. UI 層（ViewModel）

- [x] 4.1 `lib/ui/explorer/file_preview/file_preview_view_model.dart` に
      `AsyncNotifier.family(tabId)` を実装する。`explorerItemSelectionProvider`
      の主選択を watch し、ファイルなら `FilePreviewRepository.load` で読み
      込み、ディレクトリ / 非選択なら null を返す。
- [x] 4.2 同 ViewModel に `reload()` を実装し、`invalidateSelf()` で現在の
      主選択を再読込できるようにする。
- [x] 4.3 `lib/ui/explorer/file_preview/file_preview_layout_provider.dart`
      に表示状態（`visible: bool`）と split 比率（`ratio: double`, 既定
      0.6）を保持する Notifier を `family(tabId)` で実装する。永続化なし。

## 5. UI 層（Widget）

- [x] 5.1 `lib/ui/explorer/file_preview/file_preview_pane.dart` に
      プレビューパネルの Widget を実装する:
      - パネルヘッダ（タイトル + リフレッシュアイコン）
      - 本体（`HighlightView` を `SelectionArea` で包んで選択コピー可能化）
      - AsyncValue の状態に応じた placeholder（ローディング / 空 / バイナリ
        / 大きすぎ / 失敗）を i18n キー経由で表示
      - `isTruncated:true` のときは上部に「先頭部分のみ表示」バナー
- [x] 5.2 `explorer_tab_body.dart` の `Column` 構造内側に `LayoutBuilder` →
      `Row(listing | splitter | preview)` の組み立てを追加。最小幅
      listing 240px / preview 280px。両ペインの最小幅を満たせない場合は
      split せず listing のみ表示する。
- [x] 5.3 pane header（`_PaneHeader`）にプレビューパネルの可視トグル
      ボタンを追加。`vertical_split` / `crop_square` で表示状態を示す。
- [x] 5.4 split ratio を Drag でリサイズできる `_PreviewSplitter` を
      `explorer_tab_body.dart` 内に実装（1px 縦線 + 6px ヒット領域 +
      `SystemMouseCursors.resizeColumn`）。

## 6. l10n

- [x] 6.1 ARB（`lib/l10n/app_*.arb`）に以下のキーを追加した:
      - `filePreviewTitle`（プレビュー / Preview）
      - `filePreviewEmpty`（ファイルを選択してプレビュー）
      - `filePreviewBinary`（プレビュー不可（バイナリファイル））
      - `filePreviewTooLarge`（ファイルが大きすぎます ({size})）
      - `filePreviewFailed`（プレビューを表示できません: {message}）
      - `filePreviewTruncated`（先頭部分のみ表示しています）
      - `filePreviewRefreshTooltip`（再読込）
      - `filePreviewToggleTooltip`（プレビューパネルの表示切替）
- [x] 6.2 `flutter gen-l10n` 相当（`l10n.yaml` 設定）で
      `app_localizations*.dart` を更新した。

## 7. テスト

- [x] 7.1 `test/data/file_preview/file_preview_repository_test.dart`:
      - テキスト読み込み成功 + language=null（呼び出し側責務）
      - 先頭 NUL でバイナリ判定
      - 不正 UTF-8 でバイナリ判定
      - 1 MiB 超で `isTruncated:true` + 1 MiB に切り詰め
      - 17 MiB で `tooLarge`
      - 存在しないパスで `failed`
- [x] 7.2 `test/ui/explorer/file_preview/language_detector_test.dart`:
      - 拡張子マッピングの主要パターン（dart / ts / yml / md ほか）
      - 大文字拡張子も判定
      - ファイル名マッピング（Dockerfile / Makefile / .gitignore）
      - shebang フォールバック（bash / python3）
      - 拡張子マッピングが shebang より優先される
- [x] 7.3 `test/ui/explorer/file_preview/file_preview_view_model_test.dart`:
      - 主選択が空 → null
      - 主選択がディレクトリ → null
      - 主選択がファイル → `FilePreviewText` を返し、language が判定される
      - `reload()` で再取得（listen で生存させた状態で）
      - family の分離（別 tabId は独立）

## 8. 動作確認

- [ ] 8.1 `flutter run -d macos` でアプリを起動し、Explorer タブで `.dart`
      `.md` `.yaml` `.json` のプレビューが Polaris の配色で出ることを目視
      確認する。
- [ ] 8.2 大きな `.log` ファイルを開き、truncate バナーが出ることを確認
      する。
- [ ] 8.3 PNG など明らかなバイナリで「プレビュー不可」が出ることを確認
      する。
- [ ] 8.4 トグルでパネルを畳む / 開ける、リフレッシュで再読込されることを
      確認する。
- [ ] 8.5 既存の右クリック → vim 経路が壊れていないことを確認する。

## 9. ドキュメント / メタ更新

- [x] 9.1 `docs/adr/0046-explorer-file-preview-pane.md` を追加。
- [x] 9.2 `docs/adr/README.md` の ADR 一覧に 0044 / 0045 / 0046 を追加。
- [x] 9.3 `CLAUDE.md` の「主要 ADR」リストに ADR-0046 を追加。
