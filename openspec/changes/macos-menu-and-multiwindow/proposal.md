## Why

現状のメニューバー（macOS 画面上部の global menu）は Flutter プロジェクト初期化時のテンプレートそのままで:

- 英語表記（"About APP_NAME" / "Preferences…" / "Hide Others" / ...）
- 「Preferences…」「Services」「Find」「Spelling」「Substitutions」「Transformations」「Speech」など Roola で使わない項目が多数
- アプリ固有の「新規ウィンドウ」「ウィンドウを閉じる」が無い

ユーザー体験として「Flutter で作ったまま」感が強く、Mac ネイティブ感が削がれている。

加えて Roola を Finder のように複数ウィンドウで使いたい要望があり、メニューバーの「ファイル > 新規ウィンドウ」と Dock 右クリックの「新規ウィンドウ」から呼べるようにする必要がある。

## What Changes

- `macos/Runner/Base.lproj/MainMenu.xib` を全面的に書き換える:
  - すべて日本語化
  - 不要な submenu（Preferences / Services / Find / Spelling / Substitutions / Transformations / Speech）を削除
  - 新規「ファイル」メニューを追加: 新規ウィンドウ ⌘N / ウィンドウを閉じる ⌘W
  - 残す: Roola（apple submenu）/ ファイル / 編集（Undo / Redo / Cut / Copy / Paste / Select All に絞る）/ 表示（Enter Full Screen のみ）/ ウィンドウ / ヘルプ
- `macos/Runner/AppDelegate.swift` に以下を追加:
  - `@IBAction func newWindow(_ sender: Any?)`: `NSWorkspace.openApplication` で Roola.app の新インスタンスを別プロセス起動
  - `override func applicationDockMenu(_ sender: NSApplication) -> NSMenu?`: Dock 右クリックで「新規ウィンドウ」項目を出す

## Capabilities

### New Capabilities

- `macos-shell`: macOS ネイティブの global menu / Dock メニュー / ウィンドウ操作のレイヤーを正式に capability として切り出す。本 change で初出

## Impact

- **コード変更範囲**: Swift / xib のみ。Dart 側は触らない
- **新規依存**: なし
- **ADR**: 別プロセス起動方式の判断は ADR-0012 に記録済み
- **非 goal**:
  - window 間での状態リアルタイム同期（ADR-0012 で将来検討と記録）
  - Recent Windows メニュー、Tabs メニュー
  - Help submenu の中身（systemMenu="help" のままで OS にお任せ）
  - Apple submenu の Services / Preferences（Roola には Preferences ウィンドウが無いため）
