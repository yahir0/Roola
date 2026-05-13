## Goals

- macOS のメニューバー / Dock メニューを Roola にふさわしい構成・日本語表記に書き換える
- ⌘N / Dock 右クリックから新規ウィンドウを開けるようにする
- 実装は Swift / xib のみで完結させ、Dart 層には影響させない

## Non-goals

- window 間で launcher entries / appearance 等の設定を即時同期する仕組み（ADR-0012 の将来検討）
- Recent Files / Recent Windows / Tabs 等のメニュー機能
- Help submenu のカスタム（system にお任せ）

## Menu 構成

### Roola（apple submenu, systemMenu="apple"）

| 表示 | アクション |
|---|---|
| Roola について | `orderFrontStandardAboutPanel:` |
| ―― | |
| Roola を隠す ⌘H | `hide:` |
| ほかを隠す ⌥⌘H | `hideOtherApplications:` |
| すべてを表示 | `unhideAllApplications:` |
| ―― | |
| Roola を終了 ⌘Q | `terminate:` |

### ファイル

| 表示 | アクション |
|---|---|
| 新規ウィンドウ ⌘N | `newWindow:`（AppDelegate に実装） |
| ―― | |
| ウィンドウを閉じる ⌘W | `performClose:` |

### 編集

| 表示 | アクション |
|---|---|
| 取り消す ⌘Z | `undo:` |
| やり直し ⇧⌘Z | `redo:` |
| ―― | |
| カット ⌘X | `cut:` |
| コピー ⌘C | `copy:` |
| ペースト ⌘V | `paste:` |
| 削除 | `delete:` |
| すべてを選択 ⌘A | `selectAll:` |

### 表示

| 表示 | アクション |
|---|---|
| フルスクリーンにする ⌃⌘F | `toggleFullScreen:` |

### ウィンドウ（systemMenu="window"）

| 表示 | アクション |
|---|---|
| しまう ⌘M | `performMiniaturize:` |
| 拡大/縮小 | `performZoom:` |
| ―― | |
| すべてを手前に移動 | `arrangeInFront:` |

### ヘルプ（systemMenu="help"）

中身なし。macOS が標準で検索フィールドを提供する。

## 新規ウィンドウの実装

`AppDelegate.swift`:

```swift
@IBAction func newWindow(_ sender: Any?) {
  let url = Bundle.main.bundleURL
  let config = NSWorkspace.OpenConfiguration()
  config.createsNewApplicationInstance = true
  NSWorkspace.shared.openApplication(at: url, configuration: config) { _, error in
    if let error = error {
      NSLog("Failed to open new Roola instance: \(error)")
    }
  }
}

override func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
  let menu = NSMenu()
  let item = NSMenuItem(
    title: "新規ウィンドウ",
    action: #selector(newWindow(_:)),
    keyEquivalent: ""
  )
  item.target = self
  menu.addItem(item)
  return menu
}
```

xib の「新規ウィンドウ」項目は `target="-1"` (First Responder) + `selector="newWindow:"` で接続する。Cocoa の responder chain により、NSApp の delegate（= AppDelegate）まで selector が伝播し、`@IBAction func newWindow(_:)` が呼ばれる。

別プロセス起動の理由・トレードオフは ADR-0012 を参照。

## Trade-offs

### responder chain ベースで AppDelegate にぶら下げる

`target="-1"` で First Responder に流す方式は、メニュー項目から直接 AppDelegate を target 指定するより疎結合。ただし xib 上では「どこに routing されるか」が見えづらい。AppDelegate のコメントに「メニューバー / Dock メニューから呼ばれる」と明記しておく。

### Dock メニューが「新規ウィンドウ」だけ

将来「最近開いたディレクトリ」「お気に入り」も Dock メニューに出せると Finder っぽくなるが、本 change ではスコープ外。`applicationDockMenu` の追加項目として後付け可能な拡張点。

## References

- ADR-0012: マルチウィンドウは別プロセス起動で実現
- https://developer.apple.com/documentation/appkit/nsapplicationdelegate/1428723-applicationdockmenu
- https://developer.apple.com/documentation/appkit/nsworkspace/openconfiguration/3172700-createsnewapplicationinstance
