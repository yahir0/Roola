# Design: カスタマイズ可能なキーボードショートカット機構

## D1. ショートカット機構は PlatformMenuBar 一本化

ショートカットの発火経路を `PlatformMenuBar`（macOS ネイティブメニュー）に一本化し、Flutter の `Shortcuts`/`Actions`/`Intent` は使わない。

理由:

- ADR-0031 によりターミナルは SwiftTerm のネイティブ `AppKitView` で描画される。ターミナルにフォーカスがあるとき、キーイベントはネイティブビューが消費し、Flutter のフォーカスツリー（`Shortcuts`）には届かない。開発者向けツールとしてターミナル作業中もショートカットが効くことは必須要件。
- macOS のネイティブメニューバーの key equivalent は、ファーストレスポンダ（＝どのビューにフォーカスがあるか）に関係なく発火する。ADR-0031 でもこれを SwiftTerm 採用の利点として挙げている。
- `Shortcuts` とメニューバーを併用すると同一コマンドの定義が 2 系統になり、カスタムキーの反映漏れ・不整合のリスクが生じる。単一機構に統一する。

トレードオフ: メニューバーの key equivalent はテキストフィールド編集中も発火する（D6 で対処）。

## D2. コマンドレジストリ（静的メタデータ）

全アクションを `CommandId`（enum）で識別し、`CommandRegistry` が `CommandId → CommandMetadata` の静的 `Map` を持つ。`CommandMetadata` は次を持つ:

- `id`（`CommandId`）
- `category`（`CommandCategory`: explorer / navigation / tab / launcher / git / app）
- `label`（日本語表示名）
- `icon`（`IconData`、コンテキストメニュー / 設定画面のリーディングアイコン）
- `defaultChord`（`KeyChord`、既定キーコンビ）
- `contextDependent`（フォーカス中タブ / 選択に依存するか）

`CommandRegistry` を「全コマンド定義の単一の真実」とし、メニューバー・コンテキストメニュー・設定画面の 3 UI がここを参照する。

## D3. KeyChord モデルと永続化

`KeyChord` は「修飾キー集合 + 1 つのトリガキー」を表す Freezed モデル。

- 修飾キー: `meta`（⌘）/ `control`（⌃）/ `shift`（⇧）/ `alt`（⌥）の bool。
- トリガキー: `LogicalKeyboardKey.keyId`（int）。`keyId` は Flutter が割り当てる安定値で、JSON に書いても将来壊れにくい。
- 永続化は `KeyChordDto`（json_serializable）。`Keybindings` モデルは `Map<CommandId, KeyChord>`（ユーザー上書きのみ。既定は持たない）。`KeybindingsDto` は `CommandId` を `name` 文字列でシリアライズし、読み込み時に未知の `CommandId` 文字列は読み飛ばす（enum 値の増減に対する前方・後方互換）。
- 保存先は `<appSupport>/keybindings.json`。`appearance.json` と同じ `AppPaths` + Repository + `AsyncNotifier` パターン。

`effectiveKeybindingsProvider`（derived `Provider`）が `CommandRegistry` の既定と `keybindingsProvider` の上書きをマージし、`Map<CommandId, KeyChord>` の「実効バインディング」を同期的に返す。メニューバー・コンテキストメニュー・設定画面はこれを watch する。

## D4. コマンドディスパッチ

`CommandDispatcher`（`Provider` で公開）が `dispatch(CommandId, BuildContext)` を持つ。

- `CommandId` ごとに分岐し、コンテキスト依存コマンドはフォーカス中タブ / 選択を provider から解決する（`focusedTabProvider` / `explorerItemSelectionProvider` / `currentTabIdProvider` など）。
- 多くの実処理はダイアログ / SnackBar / ナビゲーションのため `BuildContext` を要する。メニューバーの `onSelected` は Navigator 外のため、`BuildContext` の源として `rootNavigatorKey.currentContext` を使う。コンテキストメニュー経由ではメニューが持つ `BuildContext` を渡す。
- 実処理の本体は既存コード（`ExplorerViewModel` / `workspaceProvider` / `core/system/*` / `GitViewModel`）。`explorer_node_tile.dart` の右クリックメニューハンドラ（`_handleDirectoryAction` など）は、`CommandDispatcher` と右クリックメニューの両方から呼べるトップレベル関数に抽出してから共有する（挙動は不変）。
- コンテキスト解決に失敗したとき（フォーカス中タブが対象種別でない / 選択なし）は no-op とする。v1 ではメニュー項目は常時 enabled とし、無効状態の動的計算は将来課題。

## D5. 既定キーコンビの選定

全コマンドに既定キーを与える。原則:

- すべて修飾キーを 1 つ以上含める。修飾なし単キーは保存不可（D7 のレコーダでバリデーション）。
- macOS のテキスト編集（⌘C / ⌘V / ⌘X / ⌘A / ⌘Z）は既定に使わない。メニューの key equivalent がこれらを横取りすると、パスバーや Git コミットメッセージ等のテキストフィールドの編集が壊れるため（D6）。
- 慣例的な ⌘T（新規タブ）/ ⌘W（タブを閉じる）/ ⌘N（新規）/ ⌘, （設定）はテキスト編集と競合しないため使用する。
- `copyPath` は `C` `C`（ADR-0021）の後継。既定は ⌘⇧C。`copyItem` は ⌘⌥C、`pasteItem` は ⌘⌥V とし、テキスト編集の ⌘C / ⌘V を避ける。

最終的にユーザーが全コマンドのキーを変更でき、衝突は検出される（D7）。既定値は出発点に過ぎない。

## D6. テキストフィールドとの競合

メニューバーの key equivalent はテキストフィールド編集中も発火する（macOS の仕様）。D5 で既定キーから ⌘C / ⌘V / ⌘X / ⌘A / ⌘Z を除外することで、標準的なテキスト編集との競合を防ぐ。ユーザーがこれらをあえて割り当てた場合は自己責任だが、衝突検出はアプリ内コマンド間のみで、OS 標準キーとの競合までは検出しない（ADR-0033 Trade-offs に明記）。

## D7. 衝突検出と設定画面

`KeybindingsPage`（専用ページ、`/keybindings` ルート）が全コマンドをカテゴリ別に一覧する。コマンド数が 30 前後あるため設定画面のセクション内インラインではなく専用ページとする。各行はラベル + 現在のキーコンビ（キーチップ）+ 編集ボタン + 「デフォルトに戻す」ボタン。

キー編集はレコーダダイアログ（`KeyChordRecorderDialog`）で行う。ユーザーが押したキーをキャプチャして `KeyChord` を組み立て、確定前に:

- 修飾キーが 1 つも無ければ警告し確定不可。
- 実効バインディングに同一 `KeyChord` を持つ別コマンドがあれば、そのコマンド名を示して警告し確定不可（保存ブロック）。

衝突検出は純粋関数（`chord_conflict.dart`）で、設定画面の保存前チェックに使う。

## D8. メニューバー構成

`AppMenuBar`（`ConsumerWidget`）が `effectiveKeybindingsProvider` を watch して `PlatformMenuBar` を組む。ユーザーがキーを変更すると即再構築されメニュー表示に反映される。

メニューグループ: Roola（アプリ）/ ファイル / 編集 / 表示 / ターミナル / Git / ウィンドウ。各 `PlatformMenuItem` は `label` をコマンドのラベルから、`shortcut`（`MenuSerializableShortcut` = `SingleActivator`）を実効 `KeyChord` から、`onSelected` を `CommandDispatcher.dispatch` から生成する。

## D9. 割り当て対象外

DnD（ドラッグでの移動 / コピー）、純マウス操作（クリック選択 / ダブルクリック遷移 / 右クリック / マウス進む戻るボタン）、Skill 即実行・Skill 登録（フォルダごとに動的に増減する項目）は `CommandId` 化しない。設定画面では操作モデルの説明として情報表示のみ残す（既存 `_ShortcutsSection` のマウス操作行を踏襲）。

## ADR

- ADR-0033: コマンドレジストリとネイティブメニューバーによる統一ショートカット機構（本 change の設計判断）
- ADR-0021 の `C` `C` 連打部分を supersede する
