## 1. 設計判断の記録

- [x] 1.1 `docs/adr/0012-multi-window-via-separate-process.md` を追加（別プロセス方式 vs desktop_multi_window vs Swift NSWindow + 共有 Engine の比較、将来見直し条件）
- [x] 1.2 `docs/adr/README.md` に ADR-0012 をリンク追加
- [x] 1.3 `CLAUDE.md` の ADR リストに ADR-0012 を追記

## 2. MainMenu.xib の書き換え

- [ ] 2.1 `macos/Runner/Base.lproj/MainMenu.xib` を全面差し替え
  - Apple submenu: About / Hide / Hide Others / Show All / Quit のみ、日本語化（Preferences / Services 削除）
  - 「ファイル」menu を追加: 新規ウィンドウ ⌘N（selector `newWindow:` を target=-1 で接続）/ ウィンドウを閉じる ⌘W
  - 「編集」menu: Undo / Redo / Cut / Copy / Paste / 削除 / Select All に絞り、Find / Spelling / Substitutions / Transformations / Speech は削除
  - 「表示」menu: フルスクリーンにする ⌃⌘F のみ
  - 「ウィンドウ」menu: しまう / 拡大/縮小 / すべてを手前に移動
  - 「ヘルプ」menu: systemMenu="help" だけ残す
- [ ] 2.2 AppDelegate と MainFlutterWindow の outlet 接続（applicationMenu / mainFlutterWindow）が xib 書き換え後も生きていることを確認

## 3. AppDelegate.swift

- [ ] 3.1 `@IBAction func newWindow(_ sender: Any?)` を追加: `NSWorkspace.shared.openApplication` で別プロセスを起動
- [ ] 3.2 `override func applicationDockMenu(_ sender: NSApplication) -> NSMenu?` を追加: 「新規ウィンドウ」項目を 1 件出す
- [ ] 3.3 メニューバー / Dock メニューから呼ばれる旨をコメントで明記し、ADR-0012 へリンク

## 4. 動作検証

- [ ] 4.1 `flutter build macos --debug` がエラー無く通る
- [ ] 4.2 起動した Roola のメニューバーが日本語表示、Roola メニューに不要項目（Preferences / Services 等）が無い
- [ ] 4.3 ファイル > 新規ウィンドウ（⌘N）で新インスタンスが起動する
- [ ] 4.4 Dock 右クリック → 新規ウィンドウ で新インスタンスが起動する
- [ ] 4.5 ⌘W で active window だけ閉じ、他の window が残っていればアプリが残る
- [ ] 4.6 Undo / Cut / Copy / Paste / Select All がテキスト入力フィールド上で正しく動く（既存のテキスト編集箇所で確認）

## 5. アーカイブ

- [ ] 5.1 全タスク完了後、`openspec/changes/archive/<YYYY-MM-DD>-macos-menu-and-multiwindow/` に移動
